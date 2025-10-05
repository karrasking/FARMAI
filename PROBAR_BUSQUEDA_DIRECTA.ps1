# Script para probar búsqueda directa en el API
# Verifica si el backend está funcionando

$url = "http://localhost:5265/api/medicamentos/search?q=paracetamol&limit=5"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PROBANDO ENDPOINT DE BUSQUEDA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "URL: $url" -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $url -Method Get
    
    Write-Host "✅ RESPUESTA EXITOSA" -ForegroundColor Green
    Write-Host ""
    Write-Host "Total encontrado: $($response.total)" -ForegroundColor White
    Write-Host "Resultados mostrados: $($response.count)" -ForegroundColor White
    Write-Host ""
    
    if ($response.count -gt 0) {
        Write-Host "📋 PRIMEROS RESULTADOS:" -ForegroundColor Cyan
        foreach ($med in $response.results) {
            Write-Host "  • $($med.nombre) (N° $($med.nregistro))" -ForegroundColor White
        }
    } else {
        Write-Host "❌ NO HAY RESULTADOS - PROBLEMA CON LA BD O BACKEND" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ ERROR DE CONEXION:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 POSIBLES CAUSAS:" -ForegroundColor Yellow
    Write-Host "  1. El backend NO está corriendo (dotnet run)" -ForegroundColor White
    Write-Host "  2. El puerto 5265 es incorrecto" -ForegroundColor White
    Write-Host "  3. Firewall bloqueando la conexión" -ForegroundColor White
}

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
