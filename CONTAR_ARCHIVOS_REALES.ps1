# Contar archivos PDF reales en cada carpeta

$basePath = "C:\Users\Victor\Desktop\FARMAI\Farmai.Api\bin\Debug\net8.0\_data\documentos"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CONTEO DE ARCHIVOS REALES EN DISCO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que la carpeta base existe
if (-not (Test-Path $basePath)) {
    Write-Host "ERROR: La carpeta base no existe: $basePath" -ForegroundColor Red
    Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Write-Host "Carpeta base: $basePath" -ForegroundColor White
Write-Host ""

# Contar fichas técnicas
$fichasPath = Join-Path $basePath "fichas"
if (Test-Path $fichasPath) {
    $fichas = @(Get-ChildItem -Path $fichasPath -Filter "*.pdf" -File)
    $fichasCount = $fichas.Count
    Write-Host "Fichas Técnicas (fichas/):" -ForegroundColor Yellow
    Write-Host "  Total: $fichasCount PDFs" -ForegroundColor Green
} else {
    $fichasCount = 0
    Write-Host "Fichas Técnicas (fichas/): CARPETA NO EXISTE" -ForegroundColor Red
}

# Contar prospectos
$prospectosPath = Join-Path $basePath "prospectos"
if (Test-Path $prospectosPath) {
    $prospectos = @(Get-ChildItem -Path $prospectosPath -Filter "*.pdf" -File)
    $prospectosCount = $prospectos.Count
    Write-Host "Prospectos (prospectos/):" -ForegroundColor Yellow
    Write-Host "  Total: $prospectosCount PDFs" -ForegroundColor Green
} else {
    $prospectosCount = 0
    Write-Host "Prospectos (prospectos/): CARPETA NO EXISTE" -ForegroundColor Red
}

# Contar otros (IPEs)
$otrosPath = Join-Path $basePath "otros"
if (Test-Path $otrosPath) {
    $otros = @(Get-ChildItem -Path $otrosPath -Filter "*.pdf" -File)
    $otrosCount = $otros.Count
    Write-Host "IPE (otros/):" -ForegroundColor Yellow
    Write-Host "  Total: $otrosCount PDFs" -ForegroundColor Green
} else {
    $otrosCount = 0
    Write-Host "IPE (otros/): CARPETA NO EXISTE" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESUMEN TOTAL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalReal = $fichasCount + $prospectosCount + $otrosCount

Write-Host "Fichas:     $fichasCount PDFs" -ForegroundColor White
Write-Host "Prospectos: $prospectosCount PDFs" -ForegroundColor White
Write-Host "IPE:        $otrosCount PDFs" -ForegroundColor White
Write-Host "----------------------------" -ForegroundColor Gray
Write-Host "TOTAL REAL: $totalReal PDFs" -ForegroundColor Cyan
Write-Host ""

# Calcular espacio
if ($totalReal -gt 0) {
    $allFiles = @()
    if ($fichasCount -gt 0) { $allFiles += $fichas }
    if ($prospectosCount -gt 0) { $allFiles += $prospectos }
    if ($otrosCount -gt 0) { $allFiles += $otros }
    
    $totalBytes = ($allFiles | Measure-Object -Property Length -Sum).Sum
    $totalGB = [math]::Round($totalBytes / 1GB, 2)
    
    Write-Host "Espacio usado: $totalGB GB" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
