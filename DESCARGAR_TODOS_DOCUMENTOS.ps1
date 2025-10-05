# Script para descargar todos los documentos (88 batches de 500)
# Total: 43,922 documentos
# Tiempo estimado: 2.5-3 horas

$totalBatches = 88
$batchSize = 500
$delayMs = 200

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DESCARGA MASIVA DE DOCUMENTOS FARMAI" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total batches: $totalBatches" -ForegroundColor Yellow
Write-Host "Documentos por batch: $batchSize" -ForegroundColor Yellow
Write-Host "Delay entre docs: ${delayMs}ms" -ForegroundColor Yellow
Write-Host "Tiempo estimado: 2.5-3 horas" -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date
$totalDownloaded = 0
$totalFailed = 0

for ($i = 1; $i -le $totalBatches; $i++) {
    $batchStart = Get-Date
    
    Write-Host "[$i/$totalBatches] Descargando batch $i..." -NoNewline
    
    try {
        $result = Invoke-RestMethod `
            -Uri "http://localhost:5265/api/documents/download-batch?batchNumber=$i&batchSize=$batchSize&delayMs=$delayMs" `
            -Method POST `
            -ErrorAction Stop
        
        $batchDuration = (Get-Date) - $batchStart
        $totalDownloaded += $result.downloaded
        $totalFailed += $result.failed
        
        Write-Host " OK" -ForegroundColor Green
        Write-Host "  └─ Descargados: $($result.downloaded) | Fallidos: $($result.failed) | Tiempo: $([int]$batchDuration.TotalSeconds)s" -ForegroundColor Gray
        
        # Estadísticas acumuladas cada 10 batches
        if ($i % 10 -eq 0) {
            $elapsed = (Get-Date) - $startTime
            $avgTimePerBatch = $elapsed.TotalSeconds / $i
            $remaining = ($totalBatches - $i) * $avgTimePerBatch
            
            Write-Host ""
            Write-Host "  📊 PROGRESO: $i/$totalBatches batches ($([math]::Round($i/$totalBatches*100, 1))%)" -ForegroundColor Cyan
            Write-Host "  ✓ Total descargados: $totalDownloaded" -ForegroundColor Green
            Write-Host "  ✗ Total fallidos: $totalFailed" -ForegroundColor Red
            Write-Host "  ⏱ Tiempo transcurrido: $([math]::Round($elapsed.TotalMinutes, 1)) min" -ForegroundColor Yellow
            Write-Host "  ⏰ Tiempo restante estimado: $([math]::Round($remaining/60, 1)) min" -ForegroundColor Yellow
            Write-Host ""
        }
        
        # Pequeño delay entre batches
        if ($i -lt $totalBatches) {
            Start-Sleep -Seconds 2
        }
    }
    catch {
        Write-Host " ERROR" -ForegroundColor Red
        Write-Host "  └─ $($_.Exception.Message)" -ForegroundColor Red
        
        # Intentar continuar con el siguiente batch
        Write-Host "  └─ Continuando con siguiente batch..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }
}

$totalDuration = (Get-Date) - $startTime

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ✅ DESCARGA COMPLETADA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total descargados: $totalDownloaded" -ForegroundColor Green
Write-Host "Total fallidos: $totalFailed" -ForegroundColor Red
$mins = [math]::Round($totalDuration.TotalMinutes, 1)
$hrs = [math]::Round($totalDuration.TotalHours, 2)
Write-Host "Tiempo total: $mins minutos - $hrs horas" -ForegroundColor Yellow
Write-Host ""
Write-Host "Archivos guardados en:" -ForegroundColor Cyan
Write-Host "  Farmai.Api/bin/Debug/net8.0/_data/documentos/" -ForegroundColor Gray
Write-Host ""

# Resumen final de BD
Write-Host "Obteniendo resumen final de BD..." -ForegroundColor Cyan
try {
    $summary = Invoke-RestMethod -Uri "http://localhost:5265/api/documents/summary" -Method GET
    Write-Host ""
    Write-Host "📊 RESUMEN FINAL:" -ForegroundColor Cyan
    Write-Host "  Total documentos: $($summary.totalDocuments)" -ForegroundColor White
    Write-Host "  Descargados: $($summary.downloaded)" -ForegroundColor Green
    Write-Host "  Pendientes: $($summary.pending)" -ForegroundColor Yellow
    Write-Host "  Con reintentos: $($summary.withRetries)" -ForegroundColor Magenta
    Write-Host "  Fallidos (3+ intentos): $($summary.failed)" -ForegroundColor Red
    Write-Host "  Espacio ocupado: $($summary.totalMB) MB ($($summary.totalGB) GB)" -ForegroundColor Cyan
}
catch {
    Write-Host "No se pudo obtener resumen final" -ForegroundColor Red
}

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
