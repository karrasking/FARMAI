# Verificar archivos físicos vs BD y corregir discrepancias

$basePath = "C:\Users\Victor\Desktop\FARMAI\Farmai.Api\bin\Debug\net8.0\_data\documentos"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VERIFICACIÓN DE INTEGRIDAD BD vs DISCO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Conectar a BD y obtener todos los registros marcados como descargados
$env:PGPASSWORD = "Iaforeverfree"
$query = "SELECT `"NRegistro`", `"Tipo`", `"FileName`", `"LocalPath`" FROM `"Documento`" WHERE `"Downloaded`" = true;"

Write-Host "Consultando base de datos..." -ForegroundColor Yellow
$result = & psql -h 127.0.0.1 -p 5433 -U farmai_user -d farmai_db -t -A -F "|" -c $query

if (-not $result) {
    Write-Host "ERROR: No se pudo consultar la BD" -ForegroundColor Red
    exit
}

Write-Host "Registros en BD marcados como descargados: $($result.Count)" -ForegroundColor Green
Write-Host ""

# Verificar cada archivo
Write-Host "Verificando existencia de archivos..." -ForegroundColor Yellow
$missing = @()
$found = 0

foreach ($line in $result) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    
    $parts = $line -split '\|'
    if ($parts.Count -lt 4) { continue }
    
    $nregistro = $parts[0]
    $tipo = $parts[1]
    $filename = $parts[2]
    $localpath = $parts[3]
    
    # Verificar si el archivo existe
    if (Test-Path $localpath) {
        $found++
    } else {
        $missing += @{
            NRegistro = $nregistro
            Tipo = $tipo
            FileName = $filename
            LocalPath = $localpath
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESULTADO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Archivos encontrados: $found" -ForegroundColor Green
Write-Host "Archivos FALTANTES: $($missing.Count)" -ForegroundColor Red
Write-Host ""

if ($missing.Count -eq 0) {
    Write-Host "¡Perfecto! Todos los archivos existen. No hay nada que corregir." -ForegroundColor Green
    Write-Host ""
    Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# Mostrar algunos ejemplos
Write-Host "Ejemplos de archivos faltantes:" -ForegroundColor Yellow
$missing | Select-Object -First 10 | ForEach-Object {
    Write-Host "  - $($_.NRegistro) (Tipo $($_.Tipo))" -ForegroundColor White
}
Write-Host ""

# Generar script SQL de corrección
$sqlFile = "scripts_propagacion/55_corregir_bd_archivos_faltantes.sql"
$sqlContent = @"
-- Corregir BD: marcar como NO descargados los archivos que no existen físicamente
-- Total a corregir: $($missing.Count) registros

"@

foreach ($item in $missing) {
    $sqlContent += @"
UPDATE "Documento"
SET "Downloaded" = false,
    "DownloadedAt" = NULL,
    "LocalPath" = NULL,
    "UrlLocal" = NULL,
    "FileName" = NULL,
    "FileHash" = NULL,
    "FileSize" = NULL,
    "HttpStatus" = NULL,
    "DownloadAttempts" = 0
WHERE "NRegistro" = '$($item.NRegistro)' AND "Tipo" = $($item.Tipo);

"@
}

$sqlContent += @"

-- Verificar resultado
SELECT 
    'CORRECCIÓN COMPLETADA' as estado,
    COUNT(*) FILTER (WHERE "Downloaded" = true) as descargados_bd,
    COUNT(*) FILTER (WHERE "Downloaded" = false) as pendientes_bd
FROM "Documento";
"@

Set-Content -Path $sqlFile -Value $sqlContent -Encoding UTF8

Write-Host "Script SQL generado: $sqlFile" -ForegroundColor Green
Write-Host ""
Write-Host "¿Ejecutar corrección ahora? (S/N)" -ForegroundColor Yellow
$respuesta = Read-Host

if ($respuesta -eq "S" -or $respuesta -eq "s") {
    Write-Host ""
    Write-Host "Ejecutando corrección..." -ForegroundColor Yellow
    & psql -h 127.0.0.1 -p 5433 -U farmai_user -d farmai_db -f $sqlFile
    Write-Host ""
    Write-Host "¡Corrección completada!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Corrección cancelada. Ejecuta manualmente:" -ForegroundColor Yellow
    Write-Host "  psql -h 127.0.0.1 -p 5433 -U farmai_user -d farmai_db -f $sqlFile" -ForegroundColor White
}

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
