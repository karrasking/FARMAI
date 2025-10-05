# Script para ejecutar análisis de tipos problemáticos en JSON
Write-Host "=== INVESTIGANDO TIPOS DE DATOS EN JSON ===" -ForegroundColor Cyan
Write-Host ""

$outputFile = "RESULTADO_ANALISIS_TIPOS_JSON.txt"

# Ejecutar el script SQL y guardar resultados
Write-Host "Ejecutando análisis SQL..." -ForegroundColor Yellow
$env:PGPASSWORD = "Iaforeverfree"
psql -h localhost -p 5433 -U farmai_etl_user -d farmai_db -f scripts_investigacion/analizar_tipos_json_problematicos.sql > $outputFile 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Análisis completado exitosamente" -ForegroundColor Green
    Write-Host ""
    Write-Host "📄 Resultados guardados en: $outputFile" -ForegroundColor Green
    Write-Host ""
    Write-Host "Mostrando primeras líneas..." -ForegroundColor Yellow
    Write-Host ""
    Get-Content $outputFile -Head 50
} else {
    Write-Host "❌ Error al ejecutar el análisis" -ForegroundColor Red
    Get-Content $outputFile
}

Write-Host ""
Write-Host "Para ver el archivo completo:" -ForegroundColor Cyan
Write-Host "  notepad $outputFile" -ForegroundColor White
