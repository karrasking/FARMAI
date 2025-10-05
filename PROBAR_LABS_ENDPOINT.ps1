# Probar endpoint de laboratorios
Write-Host "Probando endpoint de laboratorios..." -ForegroundColor Cyan

$response = Invoke-RestMethod -Uri "http://localhost:5265/api/dashboard/laboratorios" -Method Get

Write-Host "`nRespuesta completa:" -ForegroundColor Yellow
$response | ConvertTo-Json -Depth 10

Write-Host "`n`nTop 3 Combinados:" -ForegroundColor Green
$response.topCombinados | Select-Object -First 3 | ConvertTo-Json
