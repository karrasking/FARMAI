# Script de diagnóstico rápido para descargas

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DIAGNÓSTICO DE DESCARGAS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar si la API está corriendo
Write-Host "1. Verificando API Backend..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:5265/api/documents/summary" -Method GET -ErrorAction Stop
    Write-Host "  [OK] API respondiendo correctamente" -ForegroundColor Green
    Write-Host "  Total docs: $($health.totalDocuments)" -ForegroundColor Gray
    Write-Host "  Descargados: $($health.downloaded)" -ForegroundColor Gray
    Write-Host "  Pendientes: $($health.pending)" -ForegroundColor Gray
}
catch {
    Write-Host "  [ERROR] API NO responde en puerto 5265" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "SOLUCION:" -ForegroundColor Yellow
    Write-Host "  1. Abrir nueva terminal" -ForegroundColor White
    Write-Host "  2. cd Farmai.Api" -ForegroundColor White
    Write-Host "  3. dotnet run" -ForegroundColor White
    Write-Host ""
    exit
}

# 2. Verificar PostgreSQL
Write-Host ""
Write-Host "2. Verificando PostgreSQL..." -ForegroundColor Yellow
try {
    $env:PGPASSWORD="Iaforeverfree"
    $pgResult = psql -h 127.0.0.1 -p 5433 -U farmai_user -d farmai_db -c "SELECT 1;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] PostgreSQL conectando correctamente" -ForegroundColor Green
    } else {
        Write-Host "  [ERROR] PostgreSQL no responde" -ForegroundColor Red
        Write-Host "  SOLUCION: docker-compose up -d postgres" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "  [ERROR] No se puede conectar a PostgreSQL" -ForegroundColor Red
}

# 3. Probar descarga de UN documento
Write-Host ""
Write-Host "3. Probando descarga de 1 documento..." -ForegroundColor Yellow
try {
    $testUrl = "http://localhost:5265/api/documents/download-batch?batchNumber=1&batchSize=1&delayMs=100"
    $testResult = Invoke-RestMethod -Uri $testUrl -Method POST -TimeoutSec 30 -ErrorAction Stop
    
    Write-Host "  [OK] Descarga de prueba completada" -ForegroundColor Green
    Write-Host "  Descargados: $($testResult.downloaded)" -ForegroundColor Gray
    Write-Host "  Fallidos: $($testResult.failed)" -ForegroundColor Gray
    
    if ($testResult.failed -gt 0) {
        Write-Host ""
        Write-Host "  [ALERTA] Hay documentos fallando" -ForegroundColor Yellow
        Write-Host "  Posibles causas:" -ForegroundColor White
        Write-Host "    1. Rate limiting de CIMA (demasiadas peticiones)" -ForegroundColor Gray
        Write-Host "    2. URLs 404 (documentos no disponibles)" -ForegroundColor Gray
        Write-Host "    3. Timeout de red" -ForegroundColor Gray
    }
}
catch {
    Write-Host "  [ERROR] Fallo al descargar documento de prueba" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Ver últimos documentos fallidos
Write-Host ""
Write-Host "4. Consultando documentos fallidos en BD..." -ForegroundColor Yellow
try {
    $env:PGPASSWORD="Iaforeverfree"
    $query = @"
SELECT 
    "TipoDocumento",
    COUNT(*) as cantidad,
    COUNT(*) FILTER (WHERE "EstaDescargado" = false AND "Reintentos" > 0) as con_reintentos,
    MAX("Reintentos") as max_reintentos
FROM "Documento"
WHERE "EstaDescargado" = false
GROUP BY "TipoDocumento"
ORDER BY cantidad DESC;
"@
    
    psql -h 127.0.0.1 -p 5433 -U farmai_user -d farmai_db -c $query
}
catch {
    Write-Host "  [ERROR] No se pudo consultar BD" -ForegroundColor Red
}

# 5. Ver sample de URLs que están fallando
Write-Host ""
Write-Host "5. Sample de URLs fallidas..." -ForegroundColor Yellow
try {
    $env:PGPASSWORD="Iaforeverfree"
    $query = @"
SELECT 
    "NRegistro",
    "TipoDocumento",
    "Url",
    "Reintentos"
FROM "Documento"
WHERE "EstaDescargado" = false
  AND "Reintentos" > 0
ORDER BY "Reintentos" DESC
LIMIT 5;
"@
    
    psql -h 127.0.0.1 -p 5433 -U farmai_user -d farmai_db -c $query
}
catch {
    Write-Host "  [ERROR] No se pudo consultar BD" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FIN DIAGNÓSTICO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
