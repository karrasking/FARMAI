# Script para probar la búsqueda multi-criterio

Write-Host "================================" -ForegroundColor Cyan
Write-Host "PRUEBAS BÚSQUEDA MULTI-CRITERIO" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:5265/api/medicamentos/search"

# 1. Buscar por principio activo "ibuprofeno"
Write-Host "1️⃣  Buscando por principio activo 'ibuprofeno'..." -ForegroundColor Yellow
$response1 = Invoke-RestMethod -Uri "$baseUrl`?q=ibuprofeno&limit=5"
Write-Host "   ✅ Encontrados: $($response1.total) medicamentos" -ForegroundColor Green
Write-Host "   Primeros resultados:" -ForegroundColor Gray
$response1.results | Select-Object -First 3 | Format-Table nombre, laboratorio

# 2. Buscar por excipiente "lactosa"
Write-Host "2️⃣  Buscando por excipiente 'lactosa'..." -ForegroundColor Yellow
$response2 = Invoke-RestMethod -Uri "$baseUrl`?q=lactosa&limit=5"
Write-Host "   ✅ Encontrados: $($response2.total) medicamentos CON LACTOSA" -ForegroundColor Green
Write-Host "   (Útil para intolerantes a lactosa)" -ForegroundColor Gray

# 3. Buscar por biomarcador "CYP2D6"
Write-Host "3️⃣  Buscando por biomarcador 'CYP2D6'..." -ForegroundColor Yellow
$response3 = Invoke-RestMethod -Uri "$baseUrl`?q=CYP2D6&limit=5"
Write-Host "   ✅ Encontrados: $($response3.total) medicamentos" -ForegroundColor Green
Write-Host "   (Requieren test farmacogenético)" -ForegroundColor Gray

# 4. Buscar biosimilares
Write-Host "4️⃣  Buscando biosimilares..." -ForegroundColor Yellow
$response4 = Invoke-RestMethod -Uri "$baseUrl`?biosimilar=true&limit=5"
Write-Host "   ✅ Encontrados: $($response4.total) biosimilares" -ForegroundColor Green

# 5. Buscar hospitalarios
Write-Host "5️⃣  Buscando medicamentos hospitalarios..." -ForegroundColor Yellow
$response5 = Invoke-RestMethod -Uri "$baseUrl`?hospitalario=true&limit=5"
Write-Host "   ✅ Encontrados: $($response5.total) hospitalarios" -ForegroundColor Green

Write-Host ""
Write-Host "✅ TODAS LAS PRUEBAS COMPLETADAS" -ForegroundColor Green
Write-Host ""
