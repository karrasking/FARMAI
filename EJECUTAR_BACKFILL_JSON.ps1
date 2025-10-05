# EJECUTAR BACKFILL MASIVO DE JSON
# ==================================
# Este script ejecutará el backfill de 20K medicamentos desde API CIMA
# Tiempo estimado: 2-3 horas

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "BACKFILL MASIVO: Obtener JSON completo para 20,271 medicamentos" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

Write-Host "`nINFORMACIÓN:" -ForegroundColor Yellow
Write-Host "  - Medicamentos pendientes: ~20,124" -ForegroundColor White
Write-Host "  - API: https://cima.aemps.es/cima/rest/medicamento" -ForegroundColor White
Write-Host "  - Rate limit: 100ms entre requests (10 req/seg)" -ForegroundColor White
Write-Host "  - Tiempo estimado: 2-3 horas" -ForegroundColor White

Write-Host "`nADVERTENCIA:" -ForegroundColor Red
Write-Host "  Este proceso tomará VARIAS HORAS" -ForegroundColor White
Write-Host "  Se recomienda ejecutar cuando tengas tiempo disponible" -ForegroundColor White
Write-Host "  El proceso mostrará progreso en tiempo real" -ForegroundColor White

$respuesta = Read-Host "`n¿Deseas continuar? (s/n)"

if ($respuesta -ne 's') {
    Write-Host "`nCancelado por el usuario" -ForegroundColor Red
    exit
}

Write-Host "`nEjecutando backfill..." -ForegroundColor Green
Write-Host "----------------------------------------------------------------------`n" -ForegroundColor Gray

# Ejecutar script Python
python etl/python/backfill_rawjson_completo.py

Write-Host "`n----------------------------------------------------------------------" -ForegroundColor Gray
Write-Host "Backfill completado. Presiona cualquier tecla para salir..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
