//File: NomenclatorService.cs
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
        // 1) Descarga y extracción
        var fetch = await fetcher.FetchAllAsync(url, ct);
        var latest = fetch.LatestDir;

        // 2) Carga diccionarios mínimos (idempotente)
        var counts = new Dictionary<string, int>();
        await EnsureTablesAsync(ct);

        counts["LABORATORIOS"] = await LoadLaboratoriosAsync(Path.Combine(latest, "DICCIONARIO_LABORATORIOS.xml"), ct);
        counts["VIAS"] = await LoadViasAsync(Path.Combine(latest, "DICCIONARIO_VIAS_ADMINISTRACION.xml"), ct);
        counts["FORMA"] = await LoadFormasAsync(Path.Combine(latest, "DICCIONARIO_FORMA_FARMACEUTICA.xml"), false, ct);
        counts["FORMA_SIMPL"] = await LoadFormasAsync(Path.Combine(latest, "DICCIONARIO_FORMA_FARMACEUTICA_SIMPLIFICADAS.xml"), true, ct);
        counts["SITREG"] = await LoadSitRegAsync(Path.Combine(latest, "DICCIONARIO_SITUACION_REGISTRO.xml"), ct);
        // (dejamos ATC, DCP, DCPF, DCSA, EXCIPIENTES, ENVASES, UNIDAD_CONTENIDO, PRINCIPIOS_ACTIVOS para la 2ª pasada)

        // 3) Registrar corrida 'dicts'
        long runId = await InsertSyncRunAsync("dicts", ct);
        await CloseSyncRunAsync(runId, ok: true,
            apiCalls: 0,
            found: counts.Values.Sum(),
            changed: counts.Values.Sum(),
            errorsJson: null, ct);

        return new
        {
            status = "ok",
            latestDir = latest,
            manifest = fetch.ManifestPath,
            loaded = counts,
            files = fetch.Files.Select(f => new { f.FileName, f.Size }).ToList()
        };
    }

    // ---------- infra mínima (reutiliza estilo de SyncService) ------------
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

    // ---------- loaders (streaming con XmlReader, idempotentes) -----------
    private static XmlReaderSettings Xrs() => new() { IgnoreComments = true, IgnoreWhitespace = true, DtdProcessing = DtdProcessing.Ignore };

    private async Task<int> LoadLaboratoriosAsync(string path, CancellationToken ct)
    {
        if (!File.Exists(path)) return 0;
        const string ns = "http://schemas.aemps.es/prescripcion/aemps_prescripcion_laboratorios";
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

        int rows = 0;
        using var xr = XmlReader.Create(path, Xrs());
        while (await xr.ReadAsync())
        {
            if (xr.NodeType == XmlNodeType.Element && xr.LocalName == "laboratorios" && xr.NamespaceURI == ns)
            {
                var x = xr.ReadSubtree();
                string? s(string name) => ReadInnerText(x, name, ns);
                var cod = s("codigolaboratorio");
                var nom = s("laboratorio")?.Trim();
                if (int.TryParse(cod, out var id) && !string.IsNullOrWhiteSpace(nom))
                {
                    up.Parameters["c"].Value = id;
                    up.Parameters["n"].Value = nom;
                    up.Parameters["d"].Value = s("direccion") ?? (object)DBNull.Value;
                    up.Parameters["cp"].Value = s("codigopostal") ?? (object)DBNull.Value;
                    up.Parameters["loc"].Value = s("localidad") ?? (object)DBNull.Value;
                    up.Parameters["cif"].Value = s("cif") ?? (object)DBNull.Value;
                    await up.ExecuteNonQueryAsync(ct);
                    rows++;
                }
            }
        }
        await tx.CommitAsync(ct);
        return rows;
    }

    private async Task<int> LoadViasAsync(string path, CancellationToken ct)
    {
        if (!File.Exists(path)) return 0;
        const string ns = "http://schemas.aemps.es/prescripcion/aemps_prescripcion_vias_administracion";
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
        int rows = 0;

        using var xr = XmlReader.Create(path, Xrs());
        while (await xr.ReadAsync())
        {
            if (xr.NodeType == XmlNodeType.Element && xr.LocalName == "viasadministracion" && xr.NamespaceURI == ns)
            {
                var x = xr.ReadSubtree();
                string? s(string name) => ReadInnerText(x, name, ns);
                if (int.TryParse(s("codigoviaadministracion"), out var id) && !string.IsNullOrWhiteSpace(s("viaadministracion")))
                {
                    up.Parameters["i"].Value = id;
                    up.Parameters["n"].Value = s("viaadministracion")!.Trim();
                    await up.ExecuteNonQueryAsync(ct);
                    rows++;
                }
            }
        }
        await tx.CommitAsync(ct);
        return rows;
    }

    private async Task<int> LoadFormasAsync(string path, bool simplificada, CancellationToken ct)
    {
        if (!File.Exists(path)) return 0;
        var ns = simplificada
            ? "http://schemas.aemps.es/prescripcion/aemps_prescripcion_formas_farmaceuticas_simplificadas"
            : "http://schemas.aemps.es/prescripcion/aemps_prescripcion_formas_farmaceuticas";

        var elem = simplificada ? "formasfarmaceuticassimplificadas" : "formasfarmaceuticas";
        var idTag = simplificada ? "codigoformafarmaceuticasimplificada" : "codigoformafarmaceutica";
        var nameTag = simplificada ? "formafarmaceuticasimplificada" : "formafarmaceutica";
        var table = simplificada ? "FormaFarmaceuticaSimplificadaDicStaging" : "FormaFarmaceuticaDicStaging";

        await using var conn = new NpgsqlConnection(db.Database.GetConnectionString());
        await conn.OpenAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        var up = new NpgsqlCommand($"""
            INSERT INTO "{table}"("Id","Nombre")
            VALUES (@i,@n)
            ON CONFLICT ("Id") DO UPDATE SET "Nombre"=EXCLUDED."Nombre";
        """, conn, tx);
        up.Parameters.Add(new("i", NpgsqlTypes.NpgsqlDbType.Integer));
        up.Parameters.Add(new("n", NpgsqlTypes.NpgsqlDbType.Text));
        int rows = 0;

        using var xr = XmlReader.Create(path, Xrs());
        while (await xr.ReadAsync())
        {
            if (xr.NodeType == XmlNodeType.Element && xr.LocalName == elem && xr.NamespaceURI == ns)
            {
                var x = xr.ReadSubtree();
                string? s(string name) => ReadInnerText(x, name, ns);
                if (int.TryParse(s(idTag), out var id) && !string.IsNullOrWhiteSpace(s(nameTag)))
                {
                    up.Parameters["i"].Value = id;
                    up.Parameters["n"].Value = s(nameTag)!.Trim();
                    await up.ExecuteNonQueryAsync(ct);
                    rows++;
                }
            }
        }
        await tx.CommitAsync(ct);
        return rows;
    }

    private async Task<int> LoadSitRegAsync(string path, CancellationToken ct)
    {
        if (!File.Exists(path)) return 0;
        const string ns = "http://schemas.aemps.es/prescripcion/aemps_prescripcion_situacion_registro";
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
        int rows = 0;

        using var xr = XmlReader.Create(path, Xrs());
        while (await xr.ReadAsync())
        {
            if (xr.NodeType == XmlNodeType.Element && xr.LocalName == "situacionesregistro" && xr.NamespaceURI == ns)
            {
                var x = xr.ReadSubtree();
                string? s(string name) => ReadInnerText(x, name, ns);
                if (int.TryParse(s("codigosituacionregistro"), out var id) && !string.IsNullOrWhiteSpace(s("situacionregistro")))
                {
                    up.Parameters["c"].Value = id;
                    up.Parameters["n"].Value = s("situacionregistro")!.Trim();
                    await up.ExecuteNonQueryAsync(ct);
                    rows++;
                }
            }
        }
        await tx.CommitAsync(ct);
        return rows;
    }

    private static string? ReadInnerText(XmlReader sub, string tag, string ns)
    {
        using (sub)
        {
            while (sub.Read())
                if (sub.NodeType == XmlNodeType.Element && sub.LocalName == tag && sub.NamespaceURI == ns)
                    return sub.ReadElementContentAsString();
        }
        return null;
    }
}
