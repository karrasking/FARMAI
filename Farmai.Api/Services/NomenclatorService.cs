// File: Services/NomenclatorService.cs
using System.Xml;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using Farmai.Api.Data;

namespace Farmai.Api.Services;

public interface INomenclatorService
{
    Task<object> RunAsync(string url, CancellationToken ct = default);
}

public class NomenclatorService(
    IZipOrXmlFetcher fetcher,
    FarmaiDbContext db,
    ILogger<NomenclatorService> _log) : INomenclatorService
{
    public async Task<object> RunAsync(string url, CancellationToken ct = default)
    {
        _log.LogInformation("NomenclatorService.RunAsync url={Url}", url);

        // 1) Descarga y extracción
        var fetch = await fetcher.FetchAllAsync(url, ct);
        var latest = fetch.LatestDir;

        // 2) Carga diccionarios mínimos
        await EnsureTablesAsync(ct);
        var counts = new Dictionary<string, int>();

        counts["LABORATORIOS"] = await LoadLaboratoriosAsync(Path.Combine(latest, "DICCIONARIO_LABORATORIOS.xml"), ct);
        counts["VIAS"] = await LoadViasAsync(Path.Combine(latest, "DICCIONARIO_VIAS_ADMINISTRACION.xml"), ct);
        counts["FORMA"] = await LoadFormasAsync(Path.Combine(latest, "DICCIONARIO_FORMA_FARMACEUTICA.xml"), false, ct);
        counts["FORMA_SIMPL"] = await LoadFormasAsync(Path.Combine(latest, "DICCIONARIO_FORMA_FARMACEUTICA_SIMPLIFICADAS.xml"), true, ct);
        counts["SITREG"] = await LoadSitRegAsync(Path.Combine(latest, "DICCIONARIO_SITUACION_REGISTRO.xml"), ct);

        // 3) Registrar corrida 'dicts'
        long runId = await InsertSyncRunAsync("dicts", ct);
        int total = counts.Values.Sum();
        await CloseSyncRunAsync(runId, ok: true, apiCalls: 0, found: total, changed: total, errorsJson: null, ct);

        _log.LogInformation("NomenclatorService.RunAsync done loaded={@counts}", counts);

        return new
        {
            status = "ok",
            latestDir = latest,
            manifest = fetch.ManifestPath,
            loaded = counts,
            files = fetch.Files.Select(f => new { f.FileName, f.Size }).ToList()
        };
    }

    // ---------------- infra SyncRun ----------------
    private async Task<long> InsertSyncRunAsync(string kind, CancellationToken ct)
    {
        await using var conn = new NpgsqlConnection(db.Database.GetConnectionString());
        await conn.OpenAsync(ct);
        const string sql = @"INSERT INTO ""SyncRun""(""Kind"",""StartedAt"") VALUES (@k, now()) RETURNING ""Id"";";
        await using var cmd = new NpgsqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("@k", kind);
        var obj = await cmd.ExecuteScalarAsync(ct);
        return Convert.ToInt64(obj);
    }

    private async Task CloseSyncRunAsync(long id, bool ok, int apiCalls, int found, int changed, string? errorsJson, CancellationToken ct)
    {
        var sql = @"
        UPDATE ""SyncRun"" SET
            ""FinishedAt"" = now(),
            ""Ok""         = @p_ok,
            ""ApiCalls""   = @p_api,
            ""Found""      = @p_found,
            ""Changed""    = @p_changed,
            ""Unchanged""  = GREATEST(@p_found-@p_changed,0),
            ""DurationMs"" = EXTRACT(MILLISECOND FROM (now()-""StartedAt""))::int,
            ""ErrorsJson"" = @p_err::jsonb
        WHERE ""Id""=@p_id;";
        var parameters = new object[] {
            new NpgsqlParameter("p_ok", ok),
            new NpgsqlParameter("p_api", apiCalls),
            new NpgsqlParameter("p_found", found),
            new NpgsqlParameter("p_changed", changed),
            new NpgsqlParameter<string?>("p_err", errorsJson ?? (string?)null),
            new NpgsqlParameter("p_id", id),
        };
        await db.Database.ExecuteSqlRawAsync(sql, parameters, ct);
    }

    private async Task EnsureTablesAsync(CancellationToken ct)
    {
        var sql = """
        CREATE TABLE IF NOT EXISTS "LaboratoriosDicStaging"(
          "Codigo" int PRIMARY KEY,
          "Nombre" text NOT NULL,
          "Direccion" text,
          "CodigoPostal" text,
          "Localidad" text,
          "Cif" text
        );
        CREATE TABLE IF NOT EXISTS "ViaAdministracionDicStaging"(
          "Id" int PRIMARY KEY,
          "Nombre" text NOT NULL
        );
        CREATE TABLE IF NOT EXISTS "FormaFarmaceuticaDicStaging"(
          "Id" int PRIMARY KEY,
          "Nombre" text NOT NULL
        );
        CREATE TABLE IF NOT EXISTS "FormaFarmaceuticaSimplificadaDicStaging"(
          "Id" int PRIMARY KEY,
          "Nombre" text NOT NULL
        );
        CREATE TABLE IF NOT EXISTS "SituacionRegistroDicStaging"(
          "Codigo" int PRIMARY KEY,
          "Nombre" text NOT NULL
        );
        """;
        await db.Database.ExecuteSqlRawAsync(sql, ct);
    }

    // --------------- XmlReader settings ---------------
    private static XmlReaderSettings Xrs() => new()
    {
        Async = true,
        IgnoreComments = true,
        IgnoreWhitespace = true,
        DtdProcessing = DtdProcessing.Ignore
    };

    // --------------- helper: lee TODOS los hijos (ignorando namespace) ---------------
    private static Dictionary<string, string> ReadChildMap(XmlReader sub)
    {
        var map = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        if (sub.NodeType != XmlNodeType.Element) sub.Read(); // posicionar en contenedor

        int depth0 = sub.Depth;
        while (sub.Read())
        {
            if (sub.NodeType == XmlNodeType.Element)
            {
                string name = sub.LocalName; // sin namespace
                string val = sub.ReadElementContentAsString();
                if (!map.ContainsKey(name)) map[name] = val;
            }
            else if (sub.NodeType == XmlNodeType.EndElement && sub.Depth == depth0)
            {
                break;
            }
        }
        return map;
    }

    private static string? Get(Dictionary<string, string> m, string key)
        => m.TryGetValue(key, out var v) ? v : null;

    // --------------- loaders ----------------
    private async Task<int> LoadLaboratoriosAsync(string path, CancellationToken ct)
    {
        if (!File.Exists(path)) { _log.LogWarning("File not found: {Path}", path); return 0; }

        await using var conn = new NpgsqlConnection(db.Database.GetConnectionString());
        await conn.OpenAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        var up = new NpgsqlCommand("""
        INSERT INTO "LaboratoriosDicStaging"("Codigo","Nombre","Direccion","CodigoPostal","Localidad","Cif")
        VALUES (@c,@n,@d,@cp,@loc,@cif)
        ON CONFLICT ("Codigo") DO UPDATE SET
          "Nombre"=EXCLUDED."Nombre",
          "Direccion"=EXCLUDED."Direccion",
          "CodigoPostal"=EXCLUDED."CodigoPostal",
          "Localidad"=EXCLUDED."Localidad",
          "Cif"=EXCLUDED."Cif";
        """, conn, tx);
        up.Parameters.Add(new("c", NpgsqlTypes.NpgsqlDbType.Integer));
        up.Parameters.Add(new("n", NpgsqlTypes.NpgsqlDbType.Text));
        up.Parameters.Add(new("d", NpgsqlTypes.NpgsqlDbType.Text));
        up.Parameters.Add(new("cp", NpgsqlTypes.NpgsqlDbType.Text));
        up.Parameters.Add(new("loc", NpgsqlTypes.NpgsqlDbType.Text));
        up.Parameters.Add(new("cif", NpgsqlTypes.NpgsqlDbType.Text));

        var doc = new XmlDocument();
        doc.Load(path);
        var nsm = new XmlNamespaceManager(doc.NameTable);
        nsm.AddNamespace("ns", "http://schemas.aemps.es/prescripcion/aemps_prescripcion_laboratorios");

        int hits = 0, rows = 0;
        foreach (XmlNode n in doc.SelectNodes("//ns:laboratorios", nsm)!)
        {
            hits++;
            var cod = n.SelectSingleNode("ns:codigolaboratorio", nsm)?.InnerText?.Trim();
            var nom = n.SelectSingleNode("ns:laboratorio", nsm)?.InnerText?.Trim();
            var dir = n.SelectSingleNode("ns:direccion", nsm)?.InnerText?.Trim();
            var cp = n.SelectSingleNode("ns:codigopostal", nsm)?.InnerText?.Trim();
            var loc = n.SelectSingleNode("ns:localidad", nsm)?.InnerText?.Trim();
            var cif = n.SelectSingleNode("ns:cif", nsm)?.InnerText?.Trim();

            if (hits == 1) _log.LogInformation("DBG Laboratorios XPath: cod={Cod} nom={Nom}", cod, nom);

            if (int.TryParse(cod, out var id) && !string.IsNullOrWhiteSpace(nom))
            {
                up.Parameters["c"].Value = id;
                up.Parameters["n"].Value = nom!;
                up.Parameters["d"].Value = (object?)dir ?? DBNull.Value;
                up.Parameters["cp"].Value = (object?)cp ?? DBNull.Value;
                up.Parameters["loc"].Value = (object?)loc ?? DBNull.Value;
                up.Parameters["cif"].Value = (object?)cif ?? DBNull.Value;
                await up.ExecuteNonQueryAsync(ct);
                rows++;
            }
        }

        await tx.CommitAsync(ct);
        _log.LogInformation("Nomenclator loader {Loader} file={Path} hits={Hits} inserted={Inserted}", "Laboratorios", path, hits, rows);
        return rows;
    }

    private async Task<int> LoadViasAsync(string path, CancellationToken ct)
    {
        if (!File.Exists(path)) { _log.LogWarning("File not found: {Path}", path); return 0; }

        await using var conn = new NpgsqlConnection(db.Database.GetConnectionString());
        await conn.OpenAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        var up = new NpgsqlCommand("""
        INSERT INTO "ViaAdministracionDicStaging"("Id","Nombre")
        VALUES (@i,@n)
        ON CONFLICT ("Id") DO UPDATE SET "Nombre"=EXCLUDED."Nombre";
        """, conn, tx);
        up.Parameters.Add(new("i", NpgsqlTypes.NpgsqlDbType.Integer));
        up.Parameters.Add(new("n", NpgsqlTypes.NpgsqlDbType.Text));

        var doc = new XmlDocument(); doc.Load(path);
        var nsm = new XmlNamespaceManager(doc.NameTable);
        nsm.AddNamespace("ns", "http://schemas.aemps.es/prescripcion/aemps_prescripcion_vias_administracion");

        int hits = 0, rows = 0;
        foreach (XmlNode n in doc.SelectNodes("//ns:viasadministracion", nsm)!)
        {
            hits++;
            var idTxt = n.SelectSingleNode("ns:codigoviaadministracion", nsm)?.InnerText?.Trim();
            var nom = n.SelectSingleNode("ns:viaadministracion", nsm)?.InnerText?.Trim();
            if (hits == 1) _log.LogInformation("DBG Vias XPath: id={Id} nom={Nom}", idTxt, nom);

            if (int.TryParse(idTxt, out var id) && !string.IsNullOrWhiteSpace(nom))
            {
                up.Parameters["i"].Value = id;
                up.Parameters["n"].Value = nom!;
                await up.ExecuteNonQueryAsync(ct);
                rows++;
            }
        }
        await tx.CommitAsync(ct);
        _log.LogInformation("Nomenclator loader {Loader} file={Path} hits={Hits} inserted={Inserted}", "Vias", path, hits, rows);
        return rows;
    }

    private async Task<int> LoadFormasAsync(string path, bool simplificada, CancellationToken ct)
    {
        if (!File.Exists(path)) { _log.LogWarning("File not found: {Path}", path); return 0; }

        string nsUri, elem, idTag, nameTag, table, nameUniqueConstraint;
        if (simplificada)
        {
            nsUri = "http://schemas.aemps.es/prescripcion/aemps_prescripcion_formas_farmaceuticas_simplificadas";
            elem = "formasfarmaceuticassimplificadas";
            idTag = "codigoformafarmaceuticasimplificada";
            nameTag = "formafarmaceuticasimplificada";
            table = "FormaFarmaceuticaSimplificadaDicStaging";
            nameUniqueConstraint = "UX_FormaFarmaceuticaSimplificadaDicStaging_NombreCanon";
        }
        else
        {
            nsUri = "http://schemas.aemps.es/prescripcion/aemps_prescripcion_formas_farmaceuticas";
            elem = "formasfarmaceuticas";
            idTag = "codigoformafarmaceutica";
            nameTag = "formafarmaceutica";
            table = "FormaFarmaceuticaDicStaging";
            nameUniqueConstraint = "UX_FormaFarmaceuticaDicStaging_NombreCanon";
        }

        await using var conn = new NpgsqlConnection(db.Database.GetConnectionString());
        await conn.OpenAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        // No TRUNCATE (evitamos permisos). Limpiamos con DELETE.
        await using (var del = new NpgsqlCommand($@"DELETE FROM ""{table}"";", conn, tx))
            await del.ExecuteNonQueryAsync(ct);

        var insert = new NpgsqlCommand($@"
    INSERT INTO ""{table}""(""Id"",""Nombre"")
    VALUES (@i,@n)
    ON CONFLICT (""NombreCanon"") DO NOTHING;", conn, tx);

        insert.Parameters.Add(new("i", NpgsqlTypes.NpgsqlDbType.Integer));
        insert.Parameters.Add(new("n", NpgsqlTypes.NpgsqlDbType.Text));

        var doc = new XmlDocument(); doc.Load(path);
        var nsm = new XmlNamespaceManager(doc.NameTable);
        nsm.AddNamespace("ns", nsUri);

        int hits = 0, inserted = 0, skipped = 0;
        foreach (XmlNode n in doc.SelectNodes($"//ns:{elem}", nsm)!)
        {
            hits++;
            var idTxt = n.SelectSingleNode($"ns:{idTag}", nsm)?.InnerText?.Trim();
            var nom = n.SelectSingleNode($"ns:{nameTag}", nsm)?.InnerText;

            // Normalización: colapsar espacios + trim
            if (!string.IsNullOrWhiteSpace(nom))
                nom = System.Text.RegularExpressions.Regex.Replace(nom, @"\s+", " ").Trim();

            if (int.TryParse(idTxt, out var id) && !string.IsNullOrWhiteSpace(nom))
            {
                insert.Parameters["i"].Value = id;
                insert.Parameters["n"].Value = nom!;
                var affected = await insert.ExecuteNonQueryAsync(ct); // 1 si insertado, 0 si duplicado de NombreCanon
                if (affected == 1) inserted++; else skipped++;
            }
        }

        await tx.CommitAsync(ct);
        _log.LogInformation("Nomenclator loader {Loader} file={Path} hits={Hits} inserted={Inserted} skippedByNombreCanon={Skipped}",
            "FormaFarmaceutica", path, hits, inserted, skipped);
        return inserted;
    }



    private async Task<int> LoadSitRegAsync(string path, CancellationToken ct)
    {
        if (!File.Exists(path)) { _log.LogWarning("File not found: {Path}", path); return 0; }

        await using var conn = new NpgsqlConnection(db.Database.GetConnectionString());
        await conn.OpenAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        var up = new NpgsqlCommand("""
        INSERT INTO "SituacionRegistroDicStaging"("Codigo","Nombre")
        VALUES (@c,@n)
        ON CONFLICT ("Codigo") DO UPDATE SET "Nombre"=EXCLUDED."Nombre";
        """, conn, tx);
        up.Parameters.Add(new("c", NpgsqlTypes.NpgsqlDbType.Integer));
        up.Parameters.Add(new("n", NpgsqlTypes.NpgsqlDbType.Text));

        var doc = new XmlDocument(); doc.Load(path);
        var nsm = new XmlNamespaceManager(doc.NameTable);
        nsm.AddNamespace("ns", "http://schemas.aemps.es/prescripcion/aemps_prescripcion_situacion_registro");

        int hits = 0, rows = 0;
        foreach (XmlNode n in doc.SelectNodes("//ns:situacionesregistro", nsm)!)
        {
            hits++;
            var cod = n.SelectSingleNode("ns:codigosituacionregistro", nsm)?.InnerText?.Trim();
            var nom = n.SelectSingleNode("ns:situacionregistro", nsm)?.InnerText?.Trim();
            if (hits == 1) _log.LogInformation("DBG SitReg XPath: cod={Cod} nom={Nom}", cod, nom);

            if (int.TryParse(cod, out var id) && !string.IsNullOrWhiteSpace(nom))
            {
                up.Parameters["c"].Value = id;
                up.Parameters["n"].Value = nom!;
                await up.ExecuteNonQueryAsync(ct);
                rows++;
            }
        }
        await tx.CommitAsync(ct);
        _log.LogInformation("Nomenclator loader {Loader} file={Path} hits={Hits} inserted={Inserted}", "SituacionRegistro", path, hits, rows);
        return rows;
    }
}
