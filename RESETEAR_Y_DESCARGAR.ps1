# Script para resetear reintentos y descargar pendientes
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESETEAR Y DESCARGAR" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Reseteando reintentos de documentos pendientes..." -ForegroundColor Yellow
$env:PGPASSWORD="Iaforeverfree"
$query = "UPDATE ``"Documento``" SET ``"DownloadAttempts``" = 0, ``"LastAttemptAt``" = NULL WHERE ``"Downloaded``" = false AND (``"HttpStatus``" IS NULL OR ``"HttpStatus``" != 404);"
psql -h 127.0.0.1 -p 5433 -U farmai_user -d farmai_db -c $query

Write-Host ""
Write-Host "Iniciando descargas con batches de 500..." -ForegroundColor Green
Write-Host ""
.\DESCARGAR_RESTANTES.ps1
