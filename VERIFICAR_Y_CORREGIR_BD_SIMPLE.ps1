# Verificar archivos físicos vs BD de forma simple

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VERIFICACION BD vs DISCO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Variables
$env:PGPASSWORD = "Iaforeverfree"
$basePath = "C:\Users\Victor\Desktop\FARMAI\Farmai.Api\bin\Debug\net8.0\_data\documentos"

# Contar archivos en disco
Write-Host "Contando archivos en disco..." -ForegroundColor Yellow
$fichas = @(Get-ChildItem -Path "$basePath\fichas_tecnicas" -Filter "*.pdf" -File).Count
$prospectos = @(Get-ChildItem -Path "$basePath\prospectos" -Filter "*.pdf" -File).Count
$otros = @(Get-ChildItem -Path "$basePath\otros" -Filter "*.pdf" -File).Count
$totalDisco = $fichas + $prospectos + $otros

Write-Host "Fichas técnicas: $fichas PDFs" -ForegroundColor White
Write-Host "Prospectos: $prospectos PDFs" -ForegroundColor White
Write-Host "IPE: $otros PDFs" -ForegroundColor White
Write-Host "TOTAL DISCO: $totalDisco PDFs" -ForegroundColor Cyan
Write-Host ""

# Consultar BD
Write-Host "Consultando base de datos..." -ForegroundColor Yellow
$queryTotal = 'SELECT COUNT(*) FROM "Documento" WHERE "Downloaded" = true;'
$resultBD = & psql -h 127.0.0.1 -p 5433 -U farmai_user -d farmai_db -t -A -c $queryTotal
$totalBD = [int]$resultBD.Trim()

Write-Host "TOTAL BD: $totalBD registros" -ForegroundColor Cyan
Write-Host ""

# Calcular discrepancia
$diferencia = $totalBD - $totalDisco

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESULTADO" -ForegroundColor Cyan  
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($diferencia -eq 0) {
    Write-Host "PERFECTO: BD coincide con disco" -ForegroundColor Green
} else {
    Write-Host "DISCREPANCIA ENCONTRADA: $diferencia archivos" -ForegroundColor Red
    Write-Host "La BD tiene $diferencia registros marcados como descargados" -ForegroundColor Yellow
    Write-Host "pero los archivos NO existen fisicamente en disco" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Estos son fallos de descarga que necesitan correccion" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
