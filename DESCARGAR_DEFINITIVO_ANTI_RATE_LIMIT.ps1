# Script DEFINITIVO para descargar TODOS los documentos disponibles
# Diseñado específicamente para evitar HTTP 429 (Rate Limit)
# Optimizado para máximo éxito con mínimo tiempo

# === CONFIGURACIÓN ===
$maxBatches = 50
$batchSize = 50           # ← MÁS PEQUEÑO = más seguro
$baseDelayMs = 2000       # ← 2 segundos entre docs
$maxDelayMs = 3000        # ← Hasta 3 segundos (aleatorio)
$delayBetweenBatches = 60 # ← 60 segundos entre batches
$maxConsecutiveFailures = 3
$pauseOnRateLimit = 300   # ← 5 minutos de pausa si detecta rate limit

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DESCARGA DEFINITIVA ANTI-RATE-LIMIT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuracion ULTRA-SEGURA:" -ForegroundColor Yellow
Write-Host "  Batch size: $batchSize docs" -ForegroundColor Gray
Write-Host "  Delay entre docs: $baseDelayMs-$maxDelayMs ms" -ForegroundColor Gray
Write-Host "  Delay entre batches: $delayBetweenBatches segundos" -ForegroundColor Gray
Write-Host "  Pausa si rate limit: $pauseOnRateLimit segundos" -ForegroundColor Gray
Write-Host ""

# Estado inicial
try {
    $summary = Invoke-RestMethod -Uri "http://localhost:5265/api/documents/summary" -Method GET -ErrorAction Stop
    Write-Host "Estado inicial:" -ForegroundColor Yellow
    Write-Host "  Total: $($summary.totalDocuments)" -ForegroundColor White
    Write-Host "  Descargados: $($summary.downloaded) ($([math]::Round($summary.downloaded/$summary.totalDocuments*100, 2))%)" -ForegroundColor Green
    Write-Host "  Pendientes: $($summary.pending)" -ForegroundColor Red
    Write-Host ""
    
    if ($summary.pending -eq 0) {
        Write-Host "No hay documentos pendientes!" -ForegroundColor Green
        Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }
} catch {
    Write-Host "ERROR: No se puede conectar al backend API" -ForegroundColor Red
    Write-Host "Asegurate de que el backend este corriendo en puerto 5265" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Ejecuta: cd Farmai.Api && dotnet run" -ForegroundColor White
    Write-Host ""
    Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

$startTime = Get-Date
$totalDownloaded = 0
$totalFailed = 0
$consecutiveFailures = 0
$batchNum = 1

Write-Host "Iniciando descarga DEFINITIVA..." -ForegroundColor Green
Write-Host "Este proceso es LENTO por diseño para garantizar éxito" -ForegroundColor Yellow
Write-Host ""

for ($i = 1; $i -le $maxBatches; $i++) {
    $batchStart = Get-Date
    
    # Delay aleatorio
    $randomDelay = Get-Random -Minimum $baseDelayMs -Maximum $maxDelayMs
    
    Write-Host "[$i/$maxBatches] Batch $batchNum (delay ~$randomDelay ms)..." -NoNewline
    
    try {
        $url = "http://localhost:5265/api/documents/download-batch?batchNumber=$batchNum&batchSize=$batchSize&delayMs=$randomDelay"
        $result = Invoke-RestMethod -Uri $url -Method POST -TimeoutSec 300 -ErrorAction Stop
        
        $batchDuration = (Get-Date) - $batchStart
        $totalDownloaded += $result.downloaded
        $totalFailed += $result.failed
        
        # Calcular tasa de éxito
        $successRate = if ($result.totalDocs -gt 0) { 
            [math]::Round($result.downloaded / $result.totalDocs * 100, 1) 
        } else { 0 }
        
        # Color según éxito
        $color = if ($successRate -ge 80) { "Green" } elseif ($successRate -ge 50) { "Yellow" } else { "Red" }
        
        Write-Host " OK ($successRate% exito)" -ForegroundColor $color
        Write-Host "  Descargados: $($result.downloaded) | Fallidos: $($result.failed) | Tiempo: $([int]$batchDuration.TotalSeconds)s" -ForegroundColor Gray
        
        # Si el batch tuvo muy bajo éxito, podría ser rate limiting
        if ($successRate -lt 20 -and $result.totalDocs -gt 0) {
            $consecutiveFailures++
            Write-Host "  ALERTA: Batch con bajo exito ($successRate%)" -ForegroundColor Yellow
            
            if ($consecutiveFailures -ge $maxConsecutiveFailures) {
                Write-Host ""
                Write-Host "  RATE LIMIT DETECTADO!" -ForegroundColor Red
                Write-Host "  Pausando $pauseOnRateLimit segundos para que CIMA nos olvide..." -ForegroundColor Yellow
                Write-Host ""
                
                Start-Sleep -Seconds $pauseOnRateLimit
                $consecutiveFailures = 0
                continue
            }
        } else {
            $consecutiveFailures = 0
        }
        
        # Si no hay documentos, terminamos
        if ($result.totalDocs -eq 0) {
            Write-Host ""
            Write-Host "  No hay mas documentos pendientes!" -ForegroundColor Green
            break
        }
        
        # Estadísticas cada 3 batches
        if ($i % 3 -eq 0) {
            $elapsed = (Get-Date) - $startTime
            $docsPerHour = if ($elapsed.TotalHours -gt 0) { 
                [int]($totalDownloaded / $elapsed.TotalHours) 
            } else { 0 }
            
            # Estado actual
            $currentSummary = Invoke-RestMethod -Uri "http://localhost:5265/api/documents/summary" -Method GET
            
            Write-Host ""
            Write-Host "  === PROGRESO ===" -ForegroundColor Cyan
            Write-Host "  Batches completados: $i" -ForegroundColor White
            Write-Host "  Descargados en sesion: $totalDownloaded" -ForegroundColor Green
            Write-Host "  Fallidos en sesion: $totalFailed" -ForegroundColor Red
            Write-Host "  Pendientes en BD: $($currentSummary.pending)" -ForegroundColor Yellow
            Write-Host "  Progreso total: $($currentSummary.downloaded)/$($currentSummary.totalDocuments) ($([math]::Round($currentSummary.downloaded/$currentSummary.totalDocuments*100, 2))%)" -ForegroundColor Cyan
            Write-Host "  Velocidad: $docsPerHour docs/hora" -ForegroundColor Magenta
            Write-Host "  Tiempo transcurrido: $([math]::Round($elapsed.TotalMinutes, 1)) min" -ForegroundColor Gray
            
            if ($currentSummary.pending -gt 0 -and $docsPerHour -gt 0) {
                $remainingHours = $currentSummary.pending / $docsPerHour
                $remainingMins = [math]::Round($remainingHours * 60, 0)
                Write-Host "  Tiempo restante estimado: $remainingMins min" -ForegroundColor Gray
            }
            Write-Host ""
        }
        
        $batchNum++
        
        # Delay entre batches
        if ($i -lt $maxBatches -and $result.totalDocs -gt 0) {
            Write-Host "  Pausa de $delayBetweenBatches seg antes del siguiente batch..." -ForegroundColor DarkGray
            Start-Sleep -Seconds $delayBetweenBatches
        }
    }
    catch {
        Write-Host " ERROR" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $consecutiveFailures++
        
        if ($consecutiveFailures -ge $maxConsecutiveFailures) {
            Write-Host "  Demasiados errores consecutivos. Pausando 2 minutos..." -ForegroundColor Yellow
            Start-Sleep -Seconds 120
            $consecutiveFailures = 0
        } else {
            Write-Host "  Esperando 30 segundos antes de continuar..." -ForegroundColor Yellow
            Start-Sleep -Seconds 30
        }
    }
}

$totalDuration = (Get-Date) - $startTime

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DESCARGA COMPLETADA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Resumen de la sesion:" -ForegroundColor Yellow
Write-Host "  Descargados: $totalDownloaded" -ForegroundColor Green
Write-Host "  Fallidos: $totalFailed" -ForegroundColor Red
Write-Host "  Batches procesados: $batchNum" -ForegroundColor White
Write-Host "  Tiempo total: $([math]::Round($totalDuration.TotalMinutes, 1)) min ($([math]::Round($totalDuration.TotalHours, 2)) horas)" -ForegroundColor Gray
Write-Host ""

# Estado final
try {
    $summaryFinal = Invoke-RestMethod -Uri "http://localhost:5265/api/documents/summary" -Method GET
    Write-Host "Estado final de la BD:" -ForegroundColor Yellow
    Write-Host "  Total documentos: $($summaryFinal.totalDocuments)" -ForegroundColor White
    Write-Host "  Descargados: $($summaryFinal.downloaded) ($([math]::Round($summaryFinal.downloaded/$summaryFinal.totalDocuments*100, 2))%)" -ForegroundColor Green
    Write-Host "  Pendientes: $($summaryFinal.pending)" -ForegroundColor Red
    Write-Host "  Espacio usado: $($summaryFinal.totalGB) GB" -ForegroundColor Cyan
    Write-Host ""
    
    if ($summaryFinal.pending -gt 0) {
        Write-Host "Quedan $($summaryFinal.pending) documentos pendientes." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Recomendaciones:" -ForegroundColor Cyan
        Write-Host "  1. Esperar 2-3 horas antes de reintentar (rate limit)" -ForegroundColor White
        Write-Host "  2. Ejecutar por la noche (menos trafico en CIMA)" -ForegroundColor White
        Write-Host "  3. Resetear reintentos y volver a ejecutar:" -ForegroundColor White
        Write-Host "     psql -h 127.0.0.1 -p 5433 -U farmai_user -d farmai_db -f scripts_propagacion/53_resetear_reintentos.sql" -ForegroundColor Gray
        Write-Host "     .\DESCARGAR_DEFINITIVO_ANTI_RATE_LIMIT.ps1" -ForegroundColor Gray
    } else {
        Write-Host "EXITO TOTAL!" -ForegroundColor Green
        Write-Host "Todos los documentos disponibles han sido descargados!" -ForegroundColor Green
    }
} catch {
    Write-Host "No se pudo obtener estado final de BD" -ForegroundColor Red
}

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
