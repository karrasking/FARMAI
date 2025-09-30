using System.Data;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Farmai.Api.Data;
using Npgsql;            // <-- NUEVO
using NpgsqlTypes;      // <-- NUEVO


namespace Farmai.Api.Services;

public class SyncService(
    ICimaClient cima,
    FarmaiDbContext db,
    ILogger<SyncService> log) // Ahora 'log' se usará
{
    public async Task<object> RunDailyAsync(string? since, CancellationToken ct)
    {
        var madridNow = TimeZoneInfo.ConvertTime(DateTime.UtcNow, GetMadridTz());

        static TimeZoneInfo GetMadridTz()
        {
            try { return TimeZoneInfo.FindSystemTimeZoneById("Europe/Madrid"); } catch { }
            try { return TimeZoneInfo.FindSystemTimeZoneById("Romance Standard Time"); } catch { }
            return TimeZoneInfo.Utc;
        }

        var fecha = since?.Trim();
        if (string.IsNullOrWhiteSpace(fecha))
            fecha = madridNow.AddDays(-1).ToString("dd'/'MM'/'yyyy");

        // ✅ BUENA PRÁCTICA: Registrar el inicio de la operación
        log.LogInformation("Iniciando SyncService.RunDailyAsync para la fecha: {SinceDate}", fecha);

        long runId = await InsertSyncRunAsync("daily", ct);
        int apiCalls = 0, found = 0, changed = 0;
        string? error = null;

        try
        {
            var lista = await cima.GetRegistroCambiosAsync(fecha!, ct); apiCalls++;
            if (lista.StatusCode is < 200 or >= 300 || string.IsNullOrWhiteSpace(lista.Body))
                throw new InvalidOperationException($"CIMA registroCambios devolvió un estado no exitoso: {lista.StatusCode}");

            var nregs = ExtractNRegistros(lista.Body);
            found = nregs.Count;
            log.LogInformation("Se encontraron {FoundCount} registros para procesar.", found);

            foreach (var nreg in nregs)
            {
                var det = await cima.GetMedicamentoByNRegistroAsync(nreg, ct); apiCalls++;
                if (det.StatusCode is < 200 or >= 300 || string.IsNullOrWhiteSpace(det.Body))
                {
                    // ✅ BUENA PRÁCTICA: Registrar si una llamada específica falla
                    log.LogWarning("No se pudo obtener el detalle para el nregistro {NRegistro}. Código de estado: {StatusCode}", nreg, det.StatusCode);
                    continue;
                }

                var rowHash = await ComputeHashInPgAsync(det.Body, ct);
                var affected = await UpsertMedicamentoRawAndOutboxAsync(nreg, det.Body, rowHash, ct);
                if (affected > 0) changed += 1;
            }

            await CloseSyncRunAsync(runId, ok: true, apiCalls, found, changed, errorsJson: null, ct);

            // ✅ BUENA PRÁCTICA: Registrar el resultado final
            log.LogInformation("SyncService.RunDailyAsync finalizado con éxito. Registros encontrados: {Found}, modificados: {Changed}", found, changed);
        }
        catch (Exception ex)
        {
            // ✅ SOLUCIÓN PRINCIPAL: Usar el logger para registrar el error completo
            log.LogError(ex, "Error crítico durante la ejecución de SyncService.RunDailyAsync para la fecha: {SinceDate}", fecha);

            error = ex.Message; // Puedes mantener esto si lo necesitas para la respuesta
            await CloseSyncRunAsync(runId, ok: false, apiCalls, found, changed,
                errorsJson: JsonSerializer.Serialize(new { error, since = fecha }), ct);
            throw; // Vuelves a lanzar la excepción para que el вызывающий código se entere del fallo
        }

        return new { runId, kind = "daily", since = fecha, apiCalls, found, changed, unchanged = found - changed };
    }

    // ---------- helpers DB (raw Npgsql a través del DbContext) ----------

    private async Task<long> InsertSyncRunAsync(string kind, CancellationToken ct)
    {
        await using var conn = new NpgsqlConnection(db.Database.GetConnectionString());
        await conn.OpenAsync(ct);

        const string sql = @"INSERT INTO ""SyncRun""(""Kind"",""StartedAt"")
                         VALUES (@k, now()) RETURNING ""Id"";";

        await using var cmd = new NpgsqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("@k", kind);

        var obj = await cmd.ExecuteScalarAsync(ct);
        return Convert.ToInt64(obj);
    }


    private async Task CloseSyncRunAsync(long id, bool ok, int apiCalls, int found, int changed, string? errorsJson, CancellationToken ct)
    {
        var sql = @"
        UPDATE ""SyncRun""
        SET ""FinishedAt"" = now(),
            ""Ok""         = @p_ok,
            ""ApiCalls""   = @p_api,
            ""Found""      = @p_found,
            ""Changed""    = @p_changed,
            ""Unchanged""  = GREATEST(@p_found-@p_changed, 0),
            ""DurationMs"" = EXTRACT(MILLISECOND FROM (now()-""StartedAt""))::int,
            ""ErrorsJson"" = @p_err::jsonb
        WHERE ""Id"" = @p_id;";

        var parameters = new object[]
        {
        new NpgsqlParameter("p_ok", ok),
        new NpgsqlParameter("p_api", apiCalls),
        new NpgsqlParameter("p_found", found),
        new NpgsqlParameter("p_changed", changed),
        // Tipamos como TEXT; el ::jsonb del SQL hace el cast. Si es null => NULL::jsonb
        new NpgsqlParameter<string?>("p_err", errorsJson ?? (string?)null),
        new NpgsqlParameter("p_id", id)
        };

        await db.Database.ExecuteSqlRawAsync(sql, parameters, ct);
    }


    private async Task<string> ComputeHashInPgAsync(string jsonBody, CancellationToken ct)
    {
        await using var conn = new NpgsqlConnection(db.Database.GetConnectionString());
        await conn.OpenAsync(ct);

        const string sql = @"SELECT farmai_hash_jsonb(@j::jsonb);";

        await using var cmd = new NpgsqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("@j", jsonBody);

        var hash = (string)(await cmd.ExecuteScalarAsync(ct))!;
        return hash;
    }


    private async Task<int> UpsertMedicamentoRawAndOutboxAsync(string nregistro, string jsonBody, string rowHash, CancellationToken ct)
    {
        await using var conn = new NpgsqlConnection(db.Database.GetConnectionString());
        await conn.OpenAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        // 1) UPSERT condicional en MedicamentoDetalleRaw
        const string upSql = @"
        WITH up AS (
          INSERT INTO ""MedicamentoDetalleRaw""(""NRegistro"",""Json"",""RowHash"",""Fuente"")
          VALUES (@nr, @j::jsonb, @h, 'api')
          ON CONFLICT (""NRegistro"") DO UPDATE
            SET ""Json""     = EXCLUDED.""Json"",
                ""RowHash""  = EXCLUDED.""RowHash"",
                ""Fuente""    = EXCLUDED.""Fuente"",
                ""FetchedAt"" = now()
          WHERE ""MedicamentoDetalleRaw"".""RowHash"" IS DISTINCT FROM EXCLUDED.""RowHash""
          RETURNING 1
        )
        SELECT COUNT(*) FROM up;";

        int affected;
        await using (var upCmd = new NpgsqlCommand(upSql, conn, tx))
        {
            upCmd.Parameters.AddWithValue("@nr", nregistro);
            upCmd.Parameters.AddWithValue("@j", jsonBody);
            upCmd.Parameters.AddWithValue("@h", rowHash);
            affected = Convert.ToInt32(await upCmd.ExecuteScalarAsync(ct));
        }

        // 2) Outbox idempotente (misma tx)
        const string obSql = @"
        INSERT INTO ""Outbox""(""Entity"",""EntityKey"",""Action"",""PayloadJson"",""RowHash"",""CreatedAt"")
        VALUES ('Medicamento', @nr, 'UPSERT', @j::jsonb, @h, now())
        ON CONFLICT (""Entity"",""EntityKey"",""RowHash"") DO NOTHING;";

        await using (var obCmd = new NpgsqlCommand(obSql, conn, tx))
        {
            obCmd.Parameters.AddWithValue("@nr", nregistro);
            obCmd.Parameters.AddWithValue("@j", jsonBody);
            obCmd.Parameters.AddWithValue("@h", rowHash);
            await obCmd.ExecuteNonQueryAsync(ct);
        }

        await tx.CommitAsync(ct);
        return affected; // 1 => hubo cambio; 0 => mismo hash
    }

    // ======= MÉTODO NUEVO: mensual "full" con XML + detalle por API =======
    public async Task<object> RunMonthlyFullAsync(string? url, CancellationToken ct)
    {
        var runId = await InsertSyncRunAsync("monthly", ct);
        int apiCalls = 0, found = 0, changed = 0;

        try
        {
            // 1) Descargar XML (texto)
            var xmlResp = await cima.GetNomenclatorXmlAsync(url, ct); apiCalls++;
            if (xmlResp.StatusCode is < 200 or >= 300 || string.IsNullOrWhiteSpace(xmlResp.Body))
                throw new InvalidOperationException($"Nomenclátor XML no disponible (status {xmlResp.StatusCode}).");

            // 2) Extraer nregistros del XML
            var nregs = ExtractNRegistrosFromXml(xmlResp.Body);
            nregs = nregs.Distinct().ToList();
            found = nregs.Count;
            log.LogInformation("Mensual: {Count} nregistros extraídos del XML.", found);

            // 3) Hidratación completa por API (reutiliza el camino diario)
            int i = 0;
            foreach (var nreg in nregs)
            {
                ct.ThrowIfCancellationRequested();

                // (opcional) log cada 1000
                if (++i % 1000 == 0) log.LogInformation("Procesados {i}/{found}...", i, found);

                var det = await cima.GetMedicamentoByNRegistroAsync(nreg, ct); apiCalls++;
                if (det.StatusCode is < 200 or >= 300 || string.IsNullOrWhiteSpace(det.Body))
                    continue;

                var rowHash = await ComputeHashInPgAsync(det.Body, ct);
                var affected = await UpsertMedicamentoRawAndOutboxAsync(nreg, det.Body, rowHash, ct);
                if (affected > 0) changed++;
            }

            await CloseSyncRunAsync(runId, ok: true, apiCalls, found, changed, errorsJson: null, ct);
            return new { runId, kind = "monthly", total = found, changed, unchanged = found - changed, apiCalls };
        }
        catch (Exception ex)
        {
            log.LogError(ex, "Fallo en monthly full sync.");
            await CloseSyncRunAsync(runId, ok: false, apiCalls, found, changed,
                JsonSerializer.Serialize(new { error = ex.Message, url }), ct);
            throw;
        }
    }

    public async Task<object> RunBackfillMedicamentosAsync(int limit, int maxParallel, int delayMs, CancellationToken ct)
    {
        // 1) Candidatos (NRegistro en Staging que NO están en Raw)
        var sql = @"
        SELECT DISTINCT s.""NRegistro""
        FROM ""PrescripcionStaging"" s
        LEFT JOIN ""MedicamentoDetalleRaw"" r ON r.""NRegistro"" = s.""NRegistro""
        WHERE r.""NRegistro"" IS NULL
        ORDER BY s.""NRegistro""
        LIMIT @lim;";
        if (limit <= 0) sql = sql.Replace("LIMIT @lim;", ""); // todos

        var nregs = new List<string>();
        await using (var conn = new NpgsqlConnection(db.Database.GetConnectionString()))
        {
            await conn.OpenAsync(ct);
            await using var cmd = new NpgsqlCommand(sql, conn);
            if (limit > 0) cmd.Parameters.AddWithValue("@lim", limit);
            await using var rdr = await cmd.ExecuteReaderAsync(ct);
            while (await rdr.ReadAsync(ct))
                nregs.Add(rdr.GetString(0));
        }

        if (nregs.Count == 0)
            return new { found = 0, processed = 0, changed = 0, skipped = 0 };

        // 2) Abre run "backfill"
        long runId = await InsertSyncRunAsync("backfill", ct);
        int processed = 0, changed = 0, skipped = 0, apiCalls = 0;

        var sem = new SemaphoreSlim(Math.Max(1, maxParallel));
        var tasks = nregs.Select(async nr =>
        {
            await sem.WaitAsync(ct);
            try
            {
                var det = await cima.GetMedicamentoByNRegistroAsync(nr, ct); Interlocked.Increment(ref apiCalls);
                if (det.StatusCode is < 200 or >= 300 || string.IsNullOrWhiteSpace(det.Body))
                {
                    Interlocked.Increment(ref skipped);
                    return;
                }
                var rowHash = await ComputeHashInPgAsync(det.Body, ct);
                var aff = await UpsertMedicamentoRawAndOutboxAsync(nr, det.Body, rowHash, ct);
                if (aff > 0) Interlocked.Increment(ref changed);
                Interlocked.Increment(ref processed);
                if (delayMs > 0) await Task.Delay(delayMs, ct);
            }
            finally { sem.Release(); }
        });

        try
        {
            await Task.WhenAll(tasks);
            await CloseSyncRunAsync(runId, ok: true, apiCalls, found: nregs.Count, changed, errorsJson: null, ct);
        }
        catch (Exception ex)
        {
            await CloseSyncRunAsync(runId, ok: false, apiCalls, found: nregs.Count, changed,
                errorsJson: JsonSerializer.Serialize(new { error = ex.Message }), ct);
            throw;
        }

        return new { runId, kind = "backfill", found = nregs.Count, processed, changed, skipped, apiCalls };
    }


    // ======= helper XML muy tolerante (busca <nregistro> o <nreg>) =======
    private static List<string> ExtractNRegistrosFromXml(string xml)
    {
        var list = new List<string>();
        using var r = System.Xml.XmlReader.Create(new StringReader(xml), new System.Xml.XmlReaderSettings
        {
            IgnoreComments = true,
            IgnoreWhitespace = true,
            DtdProcessing = System.Xml.DtdProcessing.Ignore
        });

        while (r.Read())
        {
            if (r.NodeType != System.Xml.XmlNodeType.Element) continue;
            if (r.Name.Equals("nregistro", StringComparison.OrdinalIgnoreCase) ||
                r.Name.Equals("nreg", StringComparison.OrdinalIgnoreCase))
            {
                var val = r.ReadElementContentAsString()?.Trim();
                if (!string.IsNullOrWhiteSpace(val)) list.Add(val);
            }
        }
        return list;
    }

    // Parser tolerante: extrae lista de nregistros de la respuesta (array o {resultados:[...]})
    private static List<string> ExtractNRegistros(string json)
    {
        var list = new List<string>();
        using var doc = JsonDocument.Parse(json);
        var root = doc.RootElement;

        IEnumerable<JsonElement> seq =
            root.ValueKind == JsonValueKind.Array
                ? root.EnumerateArray()
                : root.TryGetProperty("resultados", out var arr) ? arr.EnumerateArray()
                : Enumerable.Empty<JsonElement>();

        foreach (var el in seq)
        {
            if (el.ValueKind == JsonValueKind.String)
            {
                var s = el.GetString();
                if (!string.IsNullOrWhiteSpace(s)) list.Add(s!);
                continue;
            }
            if (el.TryGetProperty("nregistro", out var nr) && nr.ValueKind == JsonValueKind.String)
                list.Add(nr.GetString()!);
            else if (el.TryGetProperty("nreg", out var nr2) && nr2.ValueKind == JsonValueKind.String)
                list.Add(nr2.GetString()!);
        }

        return list.Distinct().ToList();
    }
}
