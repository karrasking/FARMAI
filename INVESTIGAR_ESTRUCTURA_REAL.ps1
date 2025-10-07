# Investigar estructura REAL de carpetas en disco

$basePath = "C:\Users\Victor\Desktop\FARMAI\Farmai.Api\bin\Debug\net8.0\_data\documentos"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ESTRUCTURA REAL DE CARPETAS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que la carpeta base existe
if (-not (Test-Path $basePath)) {
    Write-Host "ERROR: La carpeta base no existe: $basePath" -ForegroundColor Red
    Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Write-Host "Carpeta base existe: $basePath" -ForegroundColor Green
Write-Host ""

# Listar todas las subcarpetas
Write-Host "SUBCARPETAS ENCONTRADAS:" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow
$folders = Get-ChildItem -Path $basePath -Directory | Sort-Object Name

if ($folders.Count -eq 0) {
    Write-Host "  (No hay subcarpetas)" -ForegroundColor Red
} else {
    foreach ($folder in $folders) {
        $pdfCount = @(Get-ChildItem -Path $folder.FullName -Filter "*.pdf" -File).Count
        Write-Host "  - $($folder.Name)\" -ForegroundColor White -NoNewline
        Write-Host " ($pdfCount PDFs)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CONTEO DETALLADO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalPdfs = 0
foreach ($folder in $folders) {
    $pdfs = @(Get-ChildItem -Path $folder.FullName -Filter "*.pdf" -File)
    $count = $pdfs.Count
    $totalPdfs += $count
    
    if ($count -gt 0) {
        $sizeGB = [math]::Round(($pdfs | Measure-Object -Property Length -Sum).Sum / 1GB, 2)
        Write-Host "$($folder.Name):" -ForegroundColor Yellow
        Write-Host "  Archivos: $count PDFs" -ForegroundColor White
        Write-Host "  Tamaño: $sizeGB GB" -ForegroundColor White
        Write-Host ""
    }
}

Write-Host "----------------------------" -ForegroundColor Gray
Write-Host "TOTAL: $totalPdfs PDFs" -ForegroundColor Cyan
Write-Host ""

# Listar primeros 3 archivos de cada carpeta para ver formato
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MUESTRA DE ARCHIVOS (primeros 3)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($folder in $folders) {
    $sampleFiles = Get-ChildItem -Path $folder.FullName -Filter "*.pdf" -File | Select-Object -First 3
    if ($sampleFiles) {
        Write-Host "$($folder.Name)\:" -ForegroundColor Yellow
        foreach ($file in $sampleFiles) {
            Write-Host "  - $($file.Name)" -ForegroundColor White
        }
        Write-Host ""
    }
}

Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
