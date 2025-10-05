# Script para reprocesar documentos pendientes
# Ejecuta batches adicionales hasta que no queden pendientes

$maxBatches = 15  # Límite de seguridad
$batchSize = 500
$delayMs = 200
$startBatch = 89

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  REPROCESANDO DOCUMENTOS PENDIENTES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Ver cuántos pendientes hay
$summary = Invoke-RestMethod -Uri "http://localhost:5265/api/documents/summary" -Method GET
Write-Host "Estado inicial:" -ForegroundColor Yellow
Write-Host "  Descargados: $($summary.downloaded)" -ForegroundColor Green
Write-Host "  Pendientes: $($summary.pending)" -ForegroundColor Red
Write-Host ""

$totalDownloaded = 0
$totalFailed = 0
$batchNum = $startBatch

for ($i = 1; $i -le $maxBatches; $i++) {
    Write-Host "[$i/$maxBatches] Batch $batchNum..." -NoNewline
    
    try {
        $result = Invoke-RestMethod -Uri "http://localhost:5265/api/documents/download-batch?batchNumber=$batchNum&batchSize=$batchSize&delayMs=$delayMs" -Method POST -ErrorAction Stop
        
        $totalDownloaded += $result.downloaded
        $totalFailed += $result.failed
        
        Write-Host " OK" -ForegroundColor Green
        Write-Host "  Descargados: $($result.downloaded) | Fallidos: $($result.failed)" -ForegroundColor Gray
        
        # Si no hay documentos procesados, no quedan pendientes
        if ($result.totalDocs -eq 0) {
            Write-Host ""
            Write-Host "  No hay mas documentos pendientes!" -ForegroundColor Green
            break
        }
        
        $batchNum++
        Start-Sleep -Seconds 2
    }
    catch {
        Write-Host " ERROR" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        Start-Sleep -Seconds 5
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  REPROCESAMIENTO COMPLETADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "En esta sesion:" -ForegroundColor Yellow
Write-Host "  Descargados: $totalDownloaded" -ForegroundColor Green
Write-Host "  Fallidos: $totalFailed" -ForegroundColor Red
Write-Host ""

# Resumen final
$summaryFinal = Invoke-RestMethod -Uri "http://localhost:5265/api/documents/summary" -Method GET
Write-Host "Estado final:" -ForegroundColor Yellow
Write-Host "  Total documentos: $($summaryFinal.totalDocuments)" -ForegroundColor White
Write-Host "  Descargados: $($summaryFinal.downloaded) ($([math]::Round($summaryFinal.downloaded/$summaryFinal.totalDocuments*100, 1))%)" -ForegroundColor Green
Write-Host "  Pendientes: $($summaryFinal.pending)" -ForegroundColor Red
Write-Host "  Con reintentos: $($summaryFinal.withRetries)" -ForegroundColor Magenta
Write-Host "  Espacio: $($summaryFinal.totalGB) GB" -ForegroundColor Cyan
Write-Host ""

if ($summaryFinal.pending -gt 0) {
    Write-Host "Quedan $($summaryFinal.pending) documentos pendientes." -ForegroundColor Yellow
    Write-Host "Puedes volver a ejecutar este script para reintentarlos." -ForegroundColor Yellow
} else {
    Write-Host "Todos los documentos han sido descargados!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
