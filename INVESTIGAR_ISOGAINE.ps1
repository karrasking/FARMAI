# Investigar por qué ISOGAINE aparece al buscar "cafeína"
# Ejecutar cada query por separado para ver los resultados

$queries = @(
    "-- 1. Info básica`nSELECT nregistro, nombre, labtitular FROM medicamento WHERE nregistro = '60605';",
    
    "-- 2. Buscar cafeina en columnas`nSELECT nregistro, nombre, labtitular, CASE WHEN nombre ILIKE '%cafeina%' THEN 'en_nombre' END, CASE WHEN labtitular ILIKE '%cafeina%' THEN 'en_lab' END, rawjsondetalle::text ILIKE '%cafeina%' as en_json FROM medicamento WHERE nregistro = '60605';",
    
    "-- 3. Principios activos`nSELECT ms.nregistro, s.nombre as principio_activo, ms.cantidad, ms.unidad FROM medicamento_sustancia ms JOIN sustancia s ON ms.sustancia_id = s.id WHERE ms.nregistro = '60605';",
    
    "-- 4. Excipientes`nSELECT me.nregistro, e.nombre as excipiente, me.cantidad, me.unidad, me.orden FROM medicamento_excipiente me JOIN excipiente e ON me.excipiente_id = e.id WHERE me.nregistro = '60605' ORDER BY me.orden;",
    
    "-- 5. Buscar 'cafe' en JSON completo`nSELECT nregistro, nombre, LENGTH(rawjsondetalle::text) as json_size, POSITION('cafe' IN LOWER(rawjsondetalle::text)) as posicion_cafe FROM medicamento WHERE nregistro = '60605';"
)

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "INVESTIGANDO ISOGAINE (60605) y CAFEINA" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($query in $queries) {
    Write-Host $query -ForegroundColor Yellow
    Write-Host ""
    
    $result = psql -h localhost -U postgres -d farmai -c $query -t
    Write-Host $result -ForegroundColor Green
    Write-Host ""
    Write-Host "-------------------------------------------" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "ANALISIS COMPLETO" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
