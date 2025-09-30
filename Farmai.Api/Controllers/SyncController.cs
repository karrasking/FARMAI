// File: Controllers/SyncController.cs
using Farmai.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Farmai.Api.Controllers;

[ApiController]
[Route("api/sync")]
public class SyncController(IZipOrXmlFetcher fetcher, SyncService sync) : ControllerBase
{
    // GET /api/sync/fetch-monthly?url=...
    [HttpGet("fetch-monthly")]
    public async Task<IActionResult> FetchMonthly([FromQuery] string url, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(url))
            return BadRequest("Parámetro 'url' requerido.");
        var res = await fetcher.FetchPrescripcionXmlAsync(url, ct);
        return Ok(res);
    }

    // POST /api/sync/run-daily?since=dd/MM/yyyy
    [HttpPost("run-daily")]
    public async Task<IActionResult> RunDaily([FromQuery] string? since, CancellationToken ct)
    {
        var res = await sync.RunDailyAsync(since, ct);
        return Ok(res);
    }

    // POST /api/sync/backfill-medicamentos?limit=0&maxParallel=4&delayMs=200
    [HttpPost("backfill-medicamentos")]
    public async Task<IActionResult> Backfill([FromQuery] int limit = 0, [FromQuery] int maxParallel = 4, [FromQuery] int delayMs = 200, CancellationToken ct = default)
    {
        var res = await sync.RunBackfillMedicamentosAsync(limit, maxParallel, delayMs, ct);
        return Ok(res);
    }
    // POST /api/sync/nomenclator/run?url=...
    [HttpPost("nomenclator/run")]
    public async Task<IActionResult> RunNomenclator([FromServices] INomenclatorService svc,
    [FromQuery] string url = "https://listadomedicamentos.aemps.gob.es/prescripcion.zip",
    CancellationToken ct = default)
    {
        var res = await svc.RunAsync(url, ct);
        return Ok(res);
    }

}
