# Doble verificación manual de los 179 archivos
# Verificar que NO están en: C:\Users\Victor\Desktop\FARMAI\Farmai.Api\bin\Debug\net8.0\_data\documentos

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DOBLE VERIFICACIÓN MANUAL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$basePath = "C:\Users\Victor\Desktop\FARMAI\Farmai.Api\bin\Debug\net8.0\_data\documentos"

Write-Host "Carpeta base: $basePath" -ForegroundColor Yellow
Write-Host ""

# Leer el CSV generado
$csvPath = "LISTA_179_FALTANTES.csv"

if (-not (Test-Path $csvPath)) {
    Write-Host "ERROR: No se encontró $csvPath" -ForegroundColor Red
    Write-Host "Ejecuta primero: IDENTIFICAR_179_FALTANTES.ps1" -ForegroundColor Yellow
    exit
}

$faltantes = Import-Csv -Path $csvPath

Write-Host "Archivos en CSV: $($faltantes.Count)" -ForegroundColor Green
Write-Host ""

# Verificar primeros 10
Write-Host "Verificando primeros 10 ejemplos:" -ForegroundColor Yellow
Write-Host ""

$ejemplos = $faltantes | Select-Object -First 10

foreach ($item in $ejemplos) {
    $tipoNombre = switch ($item.Tipo) {
        "1" { "Ficha" }
        "2" { "Prospecto" }
        "3" { "IPE" }
    }
    
    $existe = Test-Path $item.LocalPath
    $color = if ($existe) { "Red" } else { "Green" }
    $estado = if ($existe) { "EXISTE (¡PROBLEMA!)" } else { "NO EXISTE (OK)" }
    
    Write-Host "  [$tipoNombre] $($item.NRegistro): " -ForegroundColor White -NoNewline
    Write-Host $estado -ForegroundColor $color
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VERIFICACIÓN COMPLETA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar TODOS
$errores = 0
foreach ($item in $faltantes) {
    if (Test-Path $item.LocalPath) {
        $errores++
    }
}

if ($errores -gt 0) {
    Write-Host "¡PROBLEMA! $errores archivos SÍ existen en disco" -ForegroundColor Red
    Write-Host "El script de identificación tiene un error" -ForegroundColor Red
} else {
    Write-Host "✅ CONFIRMADO: Los 179 archivos NO existen en disco" -ForegroundColor Green
    Write-Host "✅ Es seguro ejecutar la re-descarga" -ForegroundColor Green
}

Write-Host ""
Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
