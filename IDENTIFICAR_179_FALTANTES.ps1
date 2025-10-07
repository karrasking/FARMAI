# Script para identificar los 179 documentos marcados como descargados pero sin archivo físico

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  IDENTIFICANDO 179 ARCHIVOS FALTANTES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$env:PGPASSWORD = "Iaforeverfree"

# Consultar BD para obtener TODOS los documentos descargados
Write-Host "Consultando base de datos..." -ForegroundColor Yellow
Write-Host "Esto puede tomar 1-2 minutos..." -ForegroundColor Gray
Write-Host ""

$query = 'SELECT \"NRegistro\", \"Tipo\", \"LocalPath\", \"UrlPdf\", \"FileName\" FROM \"Documento\" WHERE \"Downloaded\" = true;'
$result = & psql -h 127.0.0.1 -p 5433 -U farmai_user -d farmai_db -t -A -F "|" -c $query

if (-not $result) {
    Write-Host "ERROR: No se pudo consultar la BD" -ForegroundColor Red
    exit
}

Write-Host "Total registros en BD: $($result.Count)" -ForegroundColor Green
Write-Host ""

# Verificar cada archivo
Write-Host "Verificando existencia física de archivos..." -ForegroundColor Yellow
$faltantes = @()
$encontrados = 0
$contador = 0

foreach ($line in $result) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    
    $contador++
    if ($contador % 5000 -eq 0) {
        Write-Host "  Procesados: $contador / $($result.Count)" -ForegroundColor Gray
    }
    
    $parts = $line -split '\|'
    if ($parts.Count -lt 5) { continue }
    
    $nregistro = $parts[0]
    $tipo = $parts[1]
    $localpath = $parts[2]
    $urlpdf = $parts[3]
    $filename = $parts[4]
    
    # Verificar si el archivo existe
    if (Test-Path $localpath) {
        $encontrados++
    } else {
        $faltantes += [PSCustomObject]@{
            NRegistro = $nregistro
            Tipo = [int]$tipo
            LocalPath = $localpath
            UrlPdf = $urlpdf
            FileName = $filename
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESULTADO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Archivos encontrados: $encontrados" -ForegroundColor Green
Write-Host "Archivos FALTANTES: $($faltantes.Count)" -ForegroundColor Red
Write-Host ""

if ($faltantes.Count -eq 0) {
    Write-Host "¡Perfecto! No hay archivos faltantes." -ForegroundColor Green
    Write-Host ""
    Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# Agrupar por tipo
$fichas = @($faltantes | Where-Object { $_.Tipo -eq 1 })
$prospectos = @($faltantes | Where-Object { $_.Tipo -eq 2 })
$ipes = @($faltantes | Where-Object { $_.Tipo -eq 3 })

Write-Host "Desglose por tipo:" -ForegroundColor Yellow
Write-Host "  Fichas Técnicas: $($fichas.Count)" -ForegroundColor White
Write-Host "  Prospectos: $($prospectos.Count)" -ForegroundColor White
Write-Host "  IPE: $($ipes.Count)" -ForegroundColor White
Write-Host ""

# Guardar lista de faltantes en CSV
$csvPath = "LISTA_179_FALTANTES.csv"
$faltantes | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
Write-Host "Lista guardada en: $csvPath" -ForegroundColor Green
Write-Host ""

# Mostrar primeros 10 ejemplos
Write-Host "Primeros 10 ejemplos de archivos faltantes:" -ForegroundColor Yellow
$faltantes | Select-Object -First 10 | ForEach-Object {
    $tipoNombre = switch ($_.Tipo) {
        1 { "Ficha" }
        2 { "Prospecto" }
        3 { "IPE" }
    }
    Write-Host "  - [$tipoNombre] $($_.NRegistro)" -ForegroundColor White
}
Write-Host ""

# Generar script SQL para marcar como NO descargados
$sqlFile = "scripts_propagacion/55_corregir_179_faltantes.sql"
$sqlContent = "-- Marcar como NO descargados los $($faltantes.Count) archivos que no existen físicamente`n`n"

foreach ($item in $faltantes) {
    $sqlContent += "UPDATE `"Documento`"`n"
    $sqlContent += "SET `"Downloaded`" = false,`n"
    $sqlContent += "    `"DownloadedAt`" = NULL,`n"
    $sqlContent += "    `"LocalPath`" = NULL,`n"
    $sqlContent += "    `"UrlLocal`" = NULL,`n"
    $sqlContent += "    `"FileName`" = NULL,`n"
    $sqlContent += "    `"FileHash`" = NULL,`n"
    $sqlContent += "    `"FileSize`" = NULL,`n"
    $sqlContent += "    `"DownloadAttempts`" = 0`n"
    $sqlContent += "WHERE `"NRegistro`" = '$($item.NRegistro)' AND `"Tipo`" = $($item.Tipo);`n`n"
}

$sqlContent += "`n-- Verificar resultado`n"
$sqlContent += "SELECT `n"
$sqlContent += "    'RESULTADO' as estado,`n"
$sqlContent += "    COUNT(*) FILTER (WHERE `"Downloaded`" = true) as descargados,`n"
$sqlContent += "    COUNT(*) FILTER (WHERE `"Downloaded`" = false) as pendientes`n"
$sqlContent += "FROM `"Documento`";`n"

Set-Content -Path $sqlFile -Value $sqlContent -Encoding UTF8

Write-Host "Script SQL generado: $sqlFile" -ForegroundColor Green
Write-Host ""

# Generar script PowerShell para re-descargar
$psFile = "REDESCARGAR_179_FALTANTES.ps1"
$psContent = @"
# Re-descargar los $($faltantes.Count) archivos faltantes

`$env:PGPASSWORD = "Iaforeverfree"

Write-Host "Re-descargando $($faltantes.Count) archivos faltantes..." -ForegroundColor Yellow
Write-Host ""

# Primero, marcar como NO descargados
Write-Host "1. Marcando como NO descargados..." -ForegroundColor Cyan
& psql -h 127.0.0.1 -p 5433 -U farmai_user -d farmai_db -f scripts_propagacion/55_corregir_179_faltantes.sql

Write-Host ""
Write-Host "2. Esperando 5 segundos..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "3. Iniciando descarga via API..." -ForegroundColor Cyan
Write-Host "   Esto puede tardar varios minutos..." -ForegroundColor Gray
Write-Host ""

try {
    `$response = Invoke-WebRequest -Uri "http://localhost:5000/api/documents/download-batch?maxDocs=200" -Method POST
    Write-Host "Descarga completada!" -ForegroundColor Green
    Write-Host `$response.Content
} catch {
    Write-Host "ERROR: `$_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
`$null = `$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
"@

Set-Content -Path $psFile -Value $psContent -Encoding UTF8
Write-Host "Script re-descarga generado: $psFile" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ARCHIVOS GENERADOS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. $csvPath - Lista de los $($faltantes.Count) faltantes" -ForegroundColor White
Write-Host "2. $sqlFile - Script SQL para marcarlos" -ForegroundColor White
Write-Host "3. $psFile - Script para re-descargarlos" -ForegroundColor White
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Ejecutar: powershell -File $psFile" -ForegroundColor White
Write-Host "  2. O manualmente:" -ForegroundColor White
Write-Host "     a) psql ... -f $sqlFile" -ForegroundColor Gray
Write-Host "     b) Llamar API de descarga" -ForegroundColor Gray
Write-Host ""

Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
