# Re-descargar los 179 archivos faltantes

$env:PGPASSWORD = "Iaforeverfree"

Write-Host "Re-descargando 179 archivos faltantes..." -ForegroundColor Yellow
Write-Host ""

# Primero, marcar como NO descargados
Write-Host "1. Marcando como NO descargados..." -ForegroundColor Cyan
& psql -h 127.0.0.1 -p 5433 -U farmai_user -d farmai_db -f scripts_propagacion/55_corregir_179_faltantes.sql

Write-Host ""
Write-Host "2. Esperando 5 segundos..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "3. Iniciando descarga via API..." -ForegroundColor Cyan
Write-Host "   Esto puede tardar varios minutos..." -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://localhost:5265/api/documents/download-batch?batchSize=200&delayMs=200" -Method POST
    Write-Host "Descarga completada!" -ForegroundColor Green
    Write-Host $response.Content
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
