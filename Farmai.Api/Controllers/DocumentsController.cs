using Farmai.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Farmai.Api.Controllers;

[ApiController]
[Route("api/documents")]
public class DocumentsController(
    IDocumentDownloadService downloadService,
    ILogger<DocumentsController> log) : ControllerBase
{
    /// <summary>
    /// Descarga un batch de documentos (500 por defecto)
    /// </summary>
    [HttpPost("download-batch")]
    public async Task<IActionResult> DownloadBatch(
        [FromQuery] int batchNumber = 1,
        [FromQuery] int batchSize = 500,
        [FromQuery] int delayMs = 200,
        CancellationToken ct = default)
    {
        log.LogInformation("Iniciando descarga de batch {BatchNumber}", batchNumber);

        try
        {
            var result = await downloadService.DownloadBatchAsync(batchNumber, batchSize, delayMs, ct);
            return Ok(result);
        }
        catch (Exception ex)
        {
            log.LogError(ex, "Error en descarga de batch {BatchNumber}", batchNumber);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Obtiene resumen de estado de descargas
    /// </summary>
    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary(CancellationToken ct = default)
    {
        var summary = await downloadService.GetDownloadSummaryAsync(ct);
        return Ok(summary);
    }

    /// <summary>
    /// Procesa documentos en cola de reintentos
    /// </summary>
    [HttpPost("retry-failed")]
    public async Task<IActionResult> RetryFailed([FromQuery] int maxRetries = 50, CancellationToken ct = default)
    {
        log.LogInformation("Procesando reintentos (max {MaxRetries})", maxRetries);

        try
        {
            var result = await downloadService.ProcessRetriesAsync(maxRetries, ct);
            return Ok(result);
        }
        catch (Exception ex)
        {
            log.LogError(ex, "Error procesando reintentos");
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Sirve una Ficha Técnica
    /// </summary>
    [HttpGet("ft/{nregistro}")]
    public IActionResult GetFichaTecnica(string nregistro)
    {
        var basePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "_data", "documentos", "fichas_tecnicas");
        var filePath = Path.Combine(basePath, $"{nregistro}.pdf");

        if (!System.IO.File.Exists(filePath))
        {
            log.LogWarning("Ficha técnica no encontrada: {NRegistro}", nregistro);
            return NotFound(new { error = "Documento no encontrado", nregistro, tipo = "FT" });
        }

        var bytes = System.IO.File.ReadAllBytes(filePath);
        return File(bytes, "application/pdf", $"FT_{nregistro}.pdf");
    }

    /// <summary>
    /// Sirve un Prospecto
    /// </summary>
    [HttpGet("p/{nregistro}")]
    public IActionResult GetProspecto(string nregistro)
    {
        var basePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "_data", "documentos", "prospectos");
        var filePath = Path.Combine(basePath, $"{nregistro}.pdf");

        if (!System.IO.File.Exists(filePath))
        {
            log.LogWarning("Prospecto no encontrado: {NRegistro}", nregistro);
            return NotFound(new { error = "Documento no encontrado", nregistro, tipo = "Prospecto" });
        }

        var bytes = System.IO.File.ReadAllBytes(filePath);
        return File(bytes, "application/pdf", $"P_{nregistro}.pdf");
    }

    /// <summary>
    /// Sirve un documento tipo IPE u otro
    /// </summary>
    [HttpGet("ipe/{nregistro}")]
    public IActionResult GetIPE(string nregistro)
    {
        var basePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "_data", "documentos", "otros");
        var filePath = Path.Combine(basePath, $"{nregistro}.pdf");

        if (!System.IO.File.Exists(filePath))
        {
            log.LogWarning("IPE no encontrado: {NRegistro}", nregistro);
            return NotFound(new { error = "Documento no encontrado", nregistro, tipo = "IPE" });
        }

        var bytes = System.IO.File.ReadAllBytes(filePath);
        return File(bytes, "application/pdf", $"IPE_{nregistro}.pdf");
    }
}
