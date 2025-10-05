# Script para probar el endpoint de detalle de medicamento
# Prueba con Paracetamol 500mg

$nregistro = "53289"  # Paracetamol 500mg - común y completo

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PROBANDO ENDPOINT DETALLE MEDICAMENTO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔍 Consultando medicamento: $nregistro" -ForegroundColor Yellow
Write-Host ""

try {
    $url = "http://localhost:5265/api/medicamentos/$nregistro/detalle"
    Write-Host "📡 URL: $url" -ForegroundColor Gray
    Write-Host ""
    
    $response = Invoke-RestMethod -Uri $url -Method Get
    
    Write-Host "✅ RESPUESTA EXITOSA" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 INFORMACIÓN BÁSICA:" -ForegroundColor Cyan
    Write-Host "  • N° Registro: $($response.nregistro)"
    Write-Host "  • Nombre: $($response.nombre)"
    Write-Host "  • Lab Titular: $($response.labTitular)"
    Write-Host "  • Comercializado: $($response.comercializado)"
    Write-Host "  • Genérico: $($response.esGenerico)"
    Write-Host "  • Requiere Receta: $($response.requiereReceta)"
    Write-Host ""
    
    Write-Host "💊 COMPOSICIÓN:" -ForegroundColor Cyan
    Write-Host "  • Principios Activos: $($response.principiosActivos.Count)"
    Write-Host "  • Excipientes: $($response.excipientes.Count)"
    Write-Host ""
    
    Write-Host "📦 PRESENTACIONES:" -ForegroundColor Cyan
    Write-Host "  • Total: $($response.presentaciones.Count)"
    Write-Host ""
    
    Write-Host "📄 DOCUMENTOS:" -ForegroundColor Cyan
    Write-Host "  • Total: $($response.documentos.Count)"
    Write-Host ""
    
    Write-Host "🎨 FOTOS:" -ForegroundColor Cyan
    Write-Host "  • Total: $($response.fotos.Count)"
    Write-Host ""
    
    Write-Host "🔗 CLASIFICACIÓN:" -ForegroundColor Cyan
    Write-Host "  • Códigos ATC: $($response.atc.Count)"
    Write-Host "  • Vías Admin: $($response.viasAdministracion.Count)"
    Write-Host ""
    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ ENDPOINT FUNCIONAL AL 100%" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎯 SIGUIENTE PASO:" -ForegroundColor Yellow
    Write-Host "  1. Asegúrate de tener el backend corriendo:" -ForegroundColor White
    Write-Host "     cd Farmai.Api && dotnet run" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. Inicia el dashboard:" -ForegroundColor White
    Write-Host "     cd farmai-dashboard && npm run dev" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. Busca un medicamento y haz click en 'Ver Detalle'" -ForegroundColor White
    Write-Host ""
    Write-Host "  ✅ El modal debería aparecer con todos los datos!" -ForegroundColor Green
    Write-Host ""
    
    # Mostrar JSON completo (opcional)
    Write-Host "📝 JSON COMPLETO (primeras 1000 líneas):" -ForegroundColor Cyan
    $json = $response | ConvertTo-Json -Depth 10
    $lines = $json -split "`n"
    $lines[0..([Math]::Min(50, $lines.Count-1))] | ForEach-Object { Write-Host $_ -ForegroundColor DarkGray }
    if ($lines.Count > 50) {
        Write-Host "... (JSON truncado, total: $($lines.Count) líneas)" -ForegroundColor DarkGray
    }
    
} catch {
    Write-Host "❌ ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 POSIBLES CAUSAS:" -ForegroundColor Yellow
    Write-Host "  1. El backend no está corriendo (dotnet run en Farmai.Api)" -ForegroundColor White
    Write-Host "  2. El puerto 5265 está ocupado" -ForegroundColor White
    Write-Host "  3. El medicamento $nregistro no existe en la BD" -ForegroundColor White
    Write-Host ""
}

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
