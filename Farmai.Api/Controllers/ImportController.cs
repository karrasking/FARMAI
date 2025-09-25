// File: Controllers/ImportController.cs
using Farmai.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;
using System.Threading;
using System.Diagnostics;

namespace Farmai.Api.Controllers;

[ApiController]
[Route("api/import")]
public class ImportController(ICimaClient cima, ImportService import) : ControllerBase
{
    // Importa por nombre y guarda/upserta en nuestra BD
    // GET /api/import/medicamentos?nombre=ibuprofeno
    [HttpGet("medicamentos")]
    public async Task<IActionResult> ImportMedicamentos([FromQuery] string nombre, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(nombre))
            return BadRequest("Parámetro 'nombre' requerido.");

        var resp = await cima.GetMedicamentosByNombreAsync(nombre, ct);

        if (resp.StatusCode is >= 200 and < 300 && !string.IsNullOrWhiteSpace(resp.Body) &&
            (resp.Body.TrimStart().StartsWith("{") || resp.Body.TrimStart().StartsWith("[")))
        {
            var count = await import.UpsertMedicamentosFromCimaJsonAsync(resp.Body, ct);
            return Ok(new { imported = count });
        }

        return StatusCode(resp.StatusCode, resp.Body);
    }

    [HttpPost("enriquecer")]
    public async Task<IActionResult> Enriquecer(
        [FromQuery] int limit = 150,
        [FromQuery] bool overwrite = false,
        CancellationToken ct = default)
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        // Traemos nregistros a procesar
        var query = import.Db.Medicamentos.AsQueryable();
        if (!overwrite)
            query = query.Where(m => !import.Db.MedicamentoDetalleStaging.Any(s => s.NRegistro == m.NRegistro));

        if (limit > 0) query = query.Take(limit);

        var nregs = await query.Select(m => m.NRegistro).ToListAsync(ct);
        if (nregs.Count == 0)
            return Ok(new { message = "Nada que enriquecer.", total = 0 });

        int ok = 0, ko = 0;
        foreach (var nr in nregs)
        {
            if (ct.IsCancellationRequested) break;

            var resp = await cima.GetMedicamentoByNRegistroAsync(nr, ct);

            if (resp.StatusCode == 200 && !string.IsNullOrWhiteSpace(resp.Body) &&
                (resp.Body.TrimStart().StartsWith("{") || resp.Body.TrimStart().StartsWith("[")))
            {
                // UPSERT a staging vía SQL nativo para ON CONFLICT
                var sql = """
                      INSERT INTO "MedicamentoDetalleStaging"("NRegistro","DetalleJson")
                      VALUES (@p0, @p1::jsonb)
                      ON CONFLICT ("NRegistro") DO UPDATE
                      SET "DetalleJson" = EXCLUDED."DetalleJson";
                      """;
                await import.Db.Database.ExecuteSqlRawAsync(sql, [nr, resp.Body], ct);
                ok++;
            }
            else
            {
                ko++;
            }

            // Throttle cívico
            await Task.Delay(100, ct);
        }
        stopwatch.Stop();
        return Ok(new
        {
            procesados = nregs.Count,
            exitosos = ok,
            errores = ko,
            tiempoTotal = stopwatch.Elapsed.ToString() // Formato "hh:mm:ss.ms"
        });
    }

}
