using System.Security.Cryptography;
using System.Text;
using Farmai.Api.Data;
using Farmai.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace Farmai.Api.Services;

public interface IDocumentDownloadService
{
    Task<BatchDownloadResult> DownloadBatchAsync(int batchNumber, int batchSize = 500, int delayMs = 200, CancellationToken ct = default);
    Task<DownloadSummary> GetDownloadSummaryAsync(CancellationToken ct = default);
    Task<RetryResult> ProcessRetriesAsync(int maxRetries = 50, CancellationToken ct = default);
}

public class DocumentDownloadService(
    IHttpClientFactory httpFactory,
    FarmaiDbContext db,
    ILogger<DocumentDownloadService> log) : IDocumentDownloadService
{
    private readonly string _baseDocsPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "_data", "documentos");

    /// <summary>
    /// Descarga un batch de documentos (500 por defecto)
    /// </summary>
    public async Task<BatchDownloadResult> DownloadBatchAsync(int batchNumber, int batchSize = 500, int delayMs = 200, CancellationToken ct = default)
    {
        log.LogInformation("Iniciando batch {BatchNumber} con tamaño {BatchSize}", batchNumber, batchSize);

        // 1. Crear registro de batch
        var batch = new DocumentDownloadBatch
        {
            BatchNumber = batchNumber,
            Status = "running",
            TotalDocs = 0,
            StartedAt = DateTime.UtcNow
        };
        db.DocumentDownloadBatch.Add(batch);
        await db.SaveChangesAsync(ct);

        var startTime = DateTime.UtcNow;
        int downloaded = 0, failed = 0, skipped = 0;
        var errors = new List<string>();

        try
        {
            // 2. Obtener documentos pendientes
            var pendingDocs = await db.Documento
                .Where(d => !d.Downloaded && d.DownloadAttempts < 3)
                .OrderBy(d => d.DownloadAttempts)
                .ThenBy(d => d.Tipo)
                .ThenBy(d => d.Id)
                .Take(batchSize)
                .ToListAsync(ct);

            batch.TotalDocs = pendingDocs.Count;
            await db.SaveChangesAsync(ct);

            if (pendingDocs.Count == 0)
            {
                batch.Status = "completed";
                batch.FinishedAt = DateTime.UtcNow;
                batch.DurationSeconds = (int)(DateTime.UtcNow - startTime).TotalSeconds;
                await db.SaveChangesAsync(ct);

                return new BatchDownloadResult
                {
                    BatchId = batch.Id,
                    BatchNumber = batchNumber,
                    Status = "completed",
                    TotalDocs = 0,
                    Downloaded = 0,
                    Failed = 0,
                    Skipped = 0,
                    DurationSeconds = 0,
                    Message = "No hay documentos pendientes"
                };
            }

            log.LogInformation("Batch {BatchNumber}: {Count} documentos encontrados", batchNumber, pendingDocs.Count);

            // 3. Descargar cada documento
            int progress = 0;
            foreach (var doc in pendingDocs)
            {
                ct.ThrowIfCancellationRequested();

                progress++;
                if (progress % 50 == 0)
                {
                    log.LogInformation("Batch {BatchNumber}: Progreso {Progress}/{Total}", batchNumber, progress, pendingDocs.Count);
                }

                try
                {
                    var result = await DownloadSingleDocumentAsync(doc, batch.Id, ct);

                    if (result.Success)
                    {
                        downloaded++;
                        batch.Downloaded = downloaded;
                    }
                    else
                    {
                        failed++;
                        batch.Failed = failed;
                        if (!string.IsNullOrEmpty(result.ErrorMessage))
                        {
                            errors.Add($"{doc.NRegistro}-{doc.Tipo}: {result.ErrorMessage}");
                        }
                    }

                    // Delay para no sobrecargar CIMA
                    if (delayMs > 0 && progress < pendingDocs.Count)
                    {
                        await Task.Delay(delayMs, ct);
                    }
                }
                catch (Exception ex)
                {
                    log.LogError(ex, "Error descargando documento {NRegistro} tipo {Tipo}", doc.NRegistro, doc.Tipo);
                    failed++;
                    batch.Failed = failed;
                    errors.Add($"{doc.NRegistro}-{doc.Tipo}: {ex.Message}");

                    // Registrar intento fallido
                    await RegisterFailedAttemptAsync(doc.Id, 0, ex.Message, batch.Id, ct);
                }

                // Actualizar progreso cada 10 documentos
                if (progress % 10 == 0)
                {
                    await db.SaveChangesAsync(ct);
                }
            }

            // 4. Finalizar batch
            batch.Status = "completed";
            batch.FinishedAt = DateTime.UtcNow;
            batch.DurationSeconds = (int)(DateTime.UtcNow - startTime).TotalSeconds;

            if (errors.Count > 0 && errors.Count <= 100)
            {
                batch.ErrorsJson = System.Text.Json.JsonSerializer.Serialize(new { errors = errors.Take(100).ToList() });
            }

            await db.SaveChangesAsync(ct);

            log.LogInformation("Batch {BatchNumber} completado: {Downloaded} descargados, {Failed} fallidos en {Duration}s",
                batchNumber, downloaded, failed, batch.DurationSeconds);

            return new BatchDownloadResult
            {
                BatchId = batch.Id,
                BatchNumber = batchNumber,
                Status = "completed",
                TotalDocs = pendingDocs.Count,
                Downloaded = downloaded,
                Failed = failed,
                Skipped = skipped,
                DurationSeconds = batch.DurationSeconds ?? 0,
                Errors = errors.Take(10).ToList()
            };
        }
        catch (Exception ex)
        {
            log.LogError(ex, "Error crítico en batch {BatchNumber}", batchNumber);

            batch.Status = "failed";
            batch.FinishedAt = DateTime.UtcNow;
            batch.DurationSeconds = (int)(DateTime.UtcNow - startTime).TotalSeconds;
            batch.ErrorsJson = System.Text.Json.JsonSerializer.Serialize(new { error = ex.Message });

            await db.SaveChangesAsync(ct);

            throw;
        }
    }

    /// <summary>
    /// Descarga un documento individual
    /// </summary>
    private async Task<SingleDownloadResult> DownloadSingleDocumentAsync(Documento doc, long batchId, CancellationToken ct)
    {
        if (string.IsNullOrEmpty(doc.UrlPdf))
        {
            return new SingleDownloadResult
            {
                Success = false,
                HttpStatus = 0,
                ErrorMessage = "URL vacía"
            };
        }

        var startTime = DateTime.UtcNow;

        try
        {
            using var client = httpFactory.CreateClient("CimaDocuments");
            client.Timeout = TimeSpan.FromSeconds(30);

            // Descargar PDF
            var response = await client.GetAsync(doc.UrlPdf, ct);

            int httpStatus = (int)response.StatusCode;

            if (!response.IsSuccessStatusCode)
            {
                await RegisterFailedAttemptAsync(doc.Id, httpStatus, $"HTTP {httpStatus}", batchId, ct);

                return new SingleDownloadResult
                {
                    Success = false,
                    HttpStatus = httpStatus,
                    ErrorMessage = $"HTTP {httpStatus}"
                };
            }

            // Leer contenido
            var bytes = await response.Content.ReadAsByteArrayAsync(ct);

            if (bytes.Length == 0)
            {
                await RegisterFailedAttemptAsync(doc.Id, httpStatus, "Archivo vacío", batchId, ct);

                return new SingleDownloadResult
                {
                    Success = false,
                    HttpStatus = httpStatus,
                    ErrorMessage = "Archivo vacío"
                };
            }

            // Calcular hash
            using var sha256 = SHA256.Create();
            var hash = Convert.ToHexString(sha256.ComputeHash(bytes));

            // Determinar carpeta según tipo
            string folder = doc.Tipo switch
            {
                1 => "fichas_tecnicas",
                2 => "prospectos",
                _ => "otros"
            };

            // Crear directorios si no existen
            var folderPath = Path.Combine(_baseDocsPath, folder);
            Directory.CreateDirectory(folderPath);

            // Nombre de archivo: NRegistro.pdf
            var fileName = $"{doc.NRegistro}.pdf";
            var filePath = Path.Combine(folderPath, fileName);

            // Guardar archivo
            await File.WriteAllBytesAsync(filePath, bytes, ct);

            // Actualizar documento
            doc.Downloaded = true;
            doc.DownloadedAt = DateTime.UtcNow;
            doc.LocalPath = filePath;
            doc.FileName = fileName;
            doc.FileHash = hash;
            doc.FileSize = bytes.Length;
            doc.HttpStatus = httpStatus;
            doc.ErrorMessage = null;
            doc.DownloadAttempts++;
            doc.LastAttemptAt = DateTime.UtcNow;
            doc.UrlLocal = $"/api/documents/{GetTipoPath(doc.Tipo)}/{doc.NRegistro}";

            // Log de descarga exitosa
            var logEntry = new DocumentDownloadLog
            {
                BatchId = batchId,
                DocumentId = doc.Id,
                NRegistro = doc.NRegistro,
                Tipo = doc.Tipo,
                UrlPdf = doc.UrlPdf!,
                Success = true,
                HttpStatus = httpStatus,
                FileSize = bytes.Length,
                DurationMs = (int)(DateTime.UtcNow - startTime).TotalMilliseconds
            };

            db.DocumentDownloadLog.Add(logEntry);

            return new SingleDownloadResult
            {
                Success = true,
                HttpStatus = httpStatus,
                FileSize = bytes.Length,
                FileHash = hash
            };
        }
        catch (Exception ex)
        {
            log.LogError(ex, "Error descargando documento {NRegistro} tipo {Tipo}", doc.NRegistro, doc.Tipo);

            await RegisterFailedAttemptAsync(doc.Id, 0, ex.Message, batchId, ct);

            return new SingleDownloadResult
            {
                Success = false,
                HttpStatus = 0,
                ErrorMessage = ex.Message
            };
        }
    }

    /// <summary>
    /// Registra un intento fallido
    /// </summary>
    private async Task RegisterFailedAttemptAsync(long documentId, int httpStatus, string errorMessage, long batchId, CancellationToken ct)
    {
        var doc = await db.Documento.FindAsync(new object[] { documentId }, ct);

        if (doc == null) return;

        doc.DownloadAttempts++;
        doc.LastAttemptAt = DateTime.UtcNow;
        doc.HttpStatus = httpStatus;
        doc.ErrorMessage = errorMessage?.Length > 500 ? errorMessage.Substring(0, 500) : errorMessage;

        // Log de intento fallido
        var logEntry = new DocumentDownloadLog
        {
            BatchId = batchId,
            DocumentId = documentId,
            NRegistro = doc.NRegistro,
            Tipo = doc.Tipo,
            UrlPdf = doc.UrlPdf ?? "",
            Success = false,
            HttpStatus = httpStatus,
            ErrorMessage = errorMessage,
            DurationMs = 0,
            RetryCount = doc.DownloadAttempts
        };

        db.DocumentDownloadLog.Add(logEntry);

        // Si ya intentó 3 veces, mover a cola de reintentos
        if (doc.DownloadAttempts >= 3)
        {
            var existingRetry = await db.DocumentDownloadRetry
                .FirstOrDefaultAsync(r => r.DocumentId == documentId && r.Status == "pending", ct);

            if (existingRetry == null)
            {
                var retry = new DocumentDownloadRetry
                {
                    DocumentId = documentId,
                    NRegistro = doc.NRegistro,
                    Tipo = doc.Tipo,
                    UrlPdf = doc.UrlPdf ?? "",
                    Attempts = doc.DownloadAttempts,
                    LastError = errorMessage,
                    NextRetryAt = DateTime.UtcNow.AddHours(1)
                };

                db.DocumentDownloadRetry.Add(retry);
            }
        }

        await db.SaveChangesAsync(ct);
    }

    /// <summary>
    /// Obtiene resumen de descargas
    /// </summary>
    public async Task<DownloadSummary> GetDownloadSummaryAsync(CancellationToken ct = default)
    {
        var summary = await db.Documento
            .GroupBy(d => 1)
            .Select(g => new DownloadSummary
            {
                TotalDocuments = g.Count(),
                Downloaded = g.Count(d => d.Downloaded),
                Pending = g.Count(d => !d.Downloaded),
                WithRetries = g.Count(d => !d.Downloaded && d.DownloadAttempts > 0),
                Failed = g.Count(d => !d.Downloaded && d.DownloadAttempts >= 3),
                TotalBytes = g.Sum(d => d.FileSize) ?? 0,
                TotalMB = Math.Round((g.Sum(d => d.FileSize) ?? 0) / 1024.0 / 1024.0, 2),
                TotalGB = Math.Round((g.Sum(d => d.FileSize) ?? 0) / 1024.0 / 1024.0 / 1024.0, 2)
            })
            .FirstOrDefaultAsync(ct);

        return summary ?? new DownloadSummary();
    }

    /// <summary>
    /// Procesa reintentos pendientes
    /// </summary>
    public async Task<RetryResult> ProcessRetriesAsync(int maxRetries = 50, CancellationToken ct = default)
    {
        var pendingRetries = await db.DocumentDownloadRetry
            .Where(r => r.Status == "pending")
            .Where(r => r.NextRetryAt == null || r.NextRetryAt <= DateTime.UtcNow)
            .Where(r => r.Attempts < r.MaxAttempts)
            .OrderBy(r => r.Priority)
            .Take(maxRetries)
            .ToListAsync(ct);

        if (pendingRetries.Count == 0)
        {
            return new RetryResult { ProcessedCount = 0, SuccessCount = 0, FailedCount = 0 };
        }

        int success = 0, failed = 0;

        foreach (var retry in pendingRetries)
        {
            var doc = await db.Documento.FindAsync(new object[] { retry.DocumentId }, ct);

            if (doc == null) continue;

            retry.Status = "in_progress";
            retry.LastAttemptAt = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);

            var result = await DownloadSingleDocumentAsync(doc, 0, ct);

            if (result.Success)
            {
                retry.Status = "resolved";
                success++;
            }
            else
            {
                retry.Attempts++;
                retry.LastError = result.ErrorMessage;

                if (retry.Attempts >= retry.MaxAttempts)
                {
                    retry.Status = "exhausted";
                }
                else
                {
                    retry.Status = "pending";
                    retry.NextRetryAt = DateTime.UtcNow.AddHours(2); // Esperar 2 horas
                }

                failed++;
            }

            await db.SaveChangesAsync(ct);
        }

        return new RetryResult
        {
            ProcessedCount = pendingRetries.Count,
            SuccessCount = success,
            FailedCount = failed
        };
    }

    private static string GetTipoPath(short tipo) => tipo switch
    {
        1 => "ft",
        2 => "p",
        3 => "ipe",
        _ => "other"
    };
}

// DTOs
public class BatchDownloadResult
{
    public long BatchId { get; set; }
    public int BatchNumber { get; set; }
    public string Status { get; set; } = "";
    public int TotalDocs { get; set; }
    public int Downloaded { get; set; }
    public int Failed { get; set; }
    public int Skipped { get; set; }
    public int DurationSeconds { get; set; }
    public string? Message { get; set; }
    public List<string> Errors { get; set; } = new();
}

public class SingleDownloadResult
{
    public bool Success { get; set; }
    public int HttpStatus { get; set; }
    public long FileSize { get; set; }
    public string? FileHash { get; set; }
    public string? ErrorMessage { get; set; }
}

public class DownloadSummary
{
    public int TotalDocuments { get; set; }
    public int Downloaded { get; set; }
    public int Pending { get; set; }
    public int WithRetries { get; set; }
    public int Failed { get; set; }
    public long TotalBytes { get; set; }
    public double TotalMB { get; set; }
    public double TotalGB { get; set; }
}

public class RetryResult
{
    public int ProcessedCount { get; set; }
    public int SuccessCount { get; set; }
    public int FailedCount { get; set; }
}
