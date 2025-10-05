# Investigar ISOGAINE 60605 con puerto correcto 5265
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "INVESTIGANDO ISOGAINE (60605)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$url = "http://localhost:5265/api/medicamentos/60605/detalle"

try {
    Write-Host "Consultando: $url" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri $url -Method Get
    
    Write-Host ""
    Write-Host "NOMBRE: $($response.nombre)" -ForegroundColor Green
    Write-Host "LAB: $($response.labTitular)" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "--- PRINCIPIOS ACTIVOS ---" -ForegroundColor Yellow
    if ($response.principiosActivos -and $response.principiosActivos.Count -gt 0) {
        foreach ($pa in $response.principiosActivos) {
            Write-Host "  - $($pa.nombre) ($($pa.cantidad) $($pa.unidad))" -ForegroundColor White
        }
    } else {
        Write-Host "  (Sin principios activos)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "--- EXCIPIENTES ---" -ForegroundColor Yellow
    if ($response.excipientes -and $response.excipientes.Count -gt 0) {
        $encontrado = $false
        foreach ($exc in $response.excipientes) {
            if ($exc.nombre -like "*cafe*") {
                Write-Host "  - $($exc.nombre) ⚠️ AQUI ESTA LA CAFEINA!" -ForegroundColor Red
                $encontrado = $true
            } else {
                Write-Host "  - $($exc.nombre)" -ForegroundColor White
            }
        }
        
        if ($encontrado) {
            Write-Host ""
            Write-Host "SOLUCION: La cafeina ESTA como excipiente" -ForegroundColor Green
            Write-Host "Problema: NO se ve bien en el detalle del modal" -ForegroundColor Red
        }
    } else {
        Write-Host "  (Sin excipientes)" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
