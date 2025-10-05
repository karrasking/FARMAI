# Script ULTRA-LENTO para evitar rate limiting
# Configurado para máxima seguridad y éxito
# Tiempo estimado: 4-5 horas para 3,856 docs

$maxBatches = 40
$batchSize = 100      # ← Reducido de 500 a 100
$delayMs = 1000       # ← Aumentado de 200ms a 1000ms (1 segundo)
$maxDelayMs = 1500    # ← Delay máximo para randomización
$delayBetweenBatches = 30  # ← 30 segundos entre batches (vs 2)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DESCARGA ULTRA-LENTA (ANTI-RATE-LIMIT)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuracion:" -ForegroundColor Yellow
Write-Host "  Batch size: $batchSize docs" -ForegroundColor Gray
Write-Host "  Delay base: $delayMs ms" -ForegroundColor Gray
Write-Host "  Delay max: $maxDelayMs ms" -ForegroundColor Gray
Write-Host "  Delay entre batches: $delayBetweenBatches s" -ForegroundColor Gray
Write-Host "  Tiempo estimado: 4-5 horas" -ForegroundColor Gray
Write-Host ""

# Ver estado inicial
$summary = Invoke-RestMethod -Uri "http://localhost:5265/api/documents/summary" -Method GET
Write-Host "Estado inicial:" -ForegroundColor Yellow
Write-Host "  Descargados: $($summary.downloaded) / $($summary.totalDocuments)" -ForegroundColor Green
Write-Host "  Pendientes: $($summary.pending)" -ForegroundColor Red
Write-Host "  Tasa actual: $([math]::Round($summary.downloaded/$summary.totalDocuments*100, 2))%" -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date
$totalDownloaded = 0
$totalFailed = 0
$batchNum = 1

Write-Host "Iniciando descarga..." -ForegroundColor Green
Write-Host "NOTA: Este proceso es MUY lento por diseño (evita rate limiting)" -ForegroundColor Yellow
Write-Host ""

for ($i = 1; $i -le $maxBatches; $i++) {
    $batchStart = Get-Date
    
    # Calcular delay aleatorio entre delayMs y maxDelayMs
    $randomDelay = Get-Random -Minimum $delayMs -Maximum $maxDelayMs
    
    Write-Host "[$i/$maxBatches] Batch $batchNum (delay ~$randomDelay ms)..." -NoNewline
    
    try {
        $url = "http://localhost:5265/api/documents/download-batch?batchNumber=$batchNum&batchSize=$batchSize&delayMs=$randomDelay"
        $result = Invoke-RestMethod -Uri $url -Method POST -ErrorAction Stop
        
        $batchDuration = (Get-Date) - $batchStart
        $totalDownloaded += $result.downloaded
        $totalFailed += $result.failed
        
        $successRate = if ($result.totalDocs -gt 0) { 
            [math]::Round($result.downloaded / $result.totalDocs * 100, 1) 
        } else { 0 }
        
        Write-Host " OK ($successRate% exito)" -ForegroundColor Green
        Write-Host "  Descargados: $($result.downloaded) | Fallidos: $($result.failed) | Tiempo: $([int]$batchDuration.TotalSeconds)s" -ForegroundColor Gray
        
        # Si no hay documentos, terminamos
        if ($result.totalDocs -eq 0) {
            Write-Host ""
            Write-Host "  No hay mas documentos pendientes!" -ForegroundColor Green
            break
        }
        
        # Estadísticas cada 5 batches
        if ($i % 5 -eq 0) {
            $elapsed = (Get-Date) - $startTime
            $docsPerHour = if ($elapsed.TotalHours -gt 0) { 
                [int]($totalDownloaded / $elapsed.TotalHours) 
            } else { 0 }
            
            # Obtener estado actual de BD
            $currentSummary = Invoke-RestMethod -Uri "http://localhost:5265/api/documents/summary" -Method GET
            
            Write-Host ""
            Write-Host "  === PROGRESO ===" -ForegroundColor Cyan
            Write-Host "  Batches procesados: $i" -ForegroundColor White
            Write-Host "  Total descargados ahora: $totalDownloaded" -ForegroundColor Green
            Write-Host "  Total fallidos ahora: $totalFailed" -ForegroundColor Red
            Write-Host "  Pendientes BD: $($currentSummary.pending)" -ForegroundColor Yellow
            Write-Host "  Docs/hora: $docsPerHour" -ForegroundColor Magenta
            Write-Host "  Tiempo transcurrido: $([math]::Round($elapsed.TotalMinutes, 1)) min" -ForegroundColor Gray
            if ($currentSummary.pending -gt 0 -and $docsPerHour -gt 0) {
                $remaining = $currentSummary.pending / $docsPerHour
                Write-Host "  Tiempo restante estimado: $([math]::Round($remaining * 60, 0)) min" -ForegroundColor Gray
            }
            Write-Host ""
        }
        
        $batchNum++
        
        # Delay largo entre batches (dar tiempo a CIMA para "olvidar")
        if ($i -lt $maxBatches -and $result.totalDocs -gt 0) {
            Write-Host "  Esperando $delayBetweenBatches segundos antes del siguiente batch..." -ForegroundColor DarkGray
            Start-Sleep -Seconds $delayBetweenBatches
        }
    }
    catch {
        Write-Host " ERROR" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Esperando 60 segundos antes de continuar..." -ForegroundColor Yellow
        Start-Sleep -Seconds 60
    }
}

$totalDuration = (Get-Date) - $startTime

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DESCARGA COMPLETADA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "En esta sesion:" -ForegroundColor Yellow
Write-Host "  Descargados: $totalDownloaded" -ForegroundColor Green
Write-Host "  Fallidos: $totalFailed" -ForegroundColor Red
Write-Host "  Tiempo total: $([math]::Round($totalDuration.TotalMinutes, 1)) min ($([math]::Round($totalDuration.TotalHours, 2)) horas)" -ForegroundColor Gray
Write-Host ""

# Resumen final
$summaryFinal = Invoke-RestMethod -Uri "http://localhost:5265/api/documents/summary" -Method GET
Write-Host "Estado final:" -ForegroundColor Yellow
Write-Host "  Total documentos: $($summaryFinal.totalDocuments)" -ForegroundColor White
Write-Host "  Descargados: $($summaryFinal.downloaded) ($([math]::Round($summaryFinal.downloaded/$summaryFinal.totalDocuments*100, 2))%)" -ForegroundColor Green
Write-Host "  Pendientes: $($summaryFinal.pending)" -ForegroundColor Red
Write-Host "  Espacio: $($summaryFinal.totalGB) GB" -ForegroundColor Cyan
Write-Host ""

if ($summaryFinal.pending -gt 0) {
    Write-Host "Quedan $($summaryFinal.pending) documentos pendientes." -ForegroundColor Yellow
    Write-Host "Recomendacion: Espera 2-3 horas y ejecuta de nuevo este script." -ForegroundColor Yellow
    Write-Host "O ejecuta por la noche cuando CIMA tenga menos trafico." -ForegroundColor Yellow
} else {
    Write-Host "TODOS los documentos disponibles han sido descargados!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
