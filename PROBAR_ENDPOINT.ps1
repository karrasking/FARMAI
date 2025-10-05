# Probar endpoint de búsqueda con curl
Write-Host "Probando endpoint de búsqueda de TAMIFLU..." -ForegroundColor Cyan

$response = Invoke-RestMethod -Uri "http://localhost:5265/api/medicamentos/search?q=tamiflu" -Method Get

Write-Host "`nRespuesta completa:" -ForegroundColor Yellow
$response | ConvertTo-Json -Depth 10

Write-Host "`n`nPrimer resultado:" -ForegroundColor Green
$response.results[0] | ConvertTo-Json -Depth 5
