# Script para probar el fallback de PA y Excipientes con medicamento 67939
Write-Host "=== PROBANDO FALLBACK PARA MEDICAMENTO 67939 ===" -ForegroundColor Green
Write-Host ""
Write-Host "Este medicamento tiene JSON VACIO pero datos en tablas relacionales" -ForegroundColor Yellow
Write-Host "Esperamos ver: 1 PA + 5 Excipientes" -ForegroundColor Yellow
Write-Host ""

# Invocar el endpoint
$response = Invoke-RestMethod -Uri "http://localhost:5177/api/Medicamentos/67939/detalle" -Method Get

Write-Host "=== PRINCIPIOS ACTIVOS ===" -ForegroundColor Cyan
if ($response.principiosActivos.Count -gt 0) {
    Write-Host "✅ Encontrados: $($response.principiosActivos.Count)" -ForegroundColor Green
    foreach ($pa in $response.principiosActivos) {
        Write-Host "  - $($pa.nombre): $($pa.cantidad) $($pa.unidad)" -ForegroundColor White
    }
} else {
    Write-Host "❌ NO se encontraron principios activos" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== EXCIPIENTES ===" -ForegroundColor Cyan
if ($response.excipientes.Count -gt 0) {
    Write-Host "✅ Encontrados: $($response.excipientes.Count)" -ForegroundColor Green
    foreach ($exc in $response.excipientes) {
        $cantInfo = if ($exc.cantidad) { "$($exc.cantidad) $($exc.unidad)" } else { "N/A" }
        Write-Host "  - $($exc.nombre): $cantInfo" -ForegroundColor White
    }
} else {
    Write-Host "❌ NO se encontraron excipientes" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Magenta
Write-Host "Medicamento: $($response.nombre)" -ForegroundColor White
Write-Host "Laboratorio: $($response.labTitular)" -ForegroundColor White
Write-Host "Total PA: $($response.principiosActivos.Count)" -ForegroundColor White
Write-Host "Total Excipientes: $($response.excipientes.Count)" -ForegroundColor White

if ($response.principiosActivos.Count -gt 0 -and $response.excipientes.Count -gt 0) {
    Write-Host ""
    Write-Host "🎉 ¡FALLBACK FUNCIONANDO CORRECTAMENTE!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "⚠️ Algo salió mal con el fallback" -ForegroundColor Yellow
}
