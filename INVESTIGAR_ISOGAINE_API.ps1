# Investigar ISOGAINE N°60605 a través del endpoint de la API

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "INVESTIGANDO ISOGAINE (60605)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Obtener el detalle completo del medicamento
Write-Host "Obteniendo detalle del medicamento 60605..." -ForegroundColor Yellow
$url = "http://localhost:5000/api/medicamentos/60605/detalle"

try {
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
        foreach ($exc in $response.excipientes) {
            $cafeina = ""
            if ($exc.nombre -like "*cafe*") { 
                $cafeina = " ⚠️ AQUI ESTA!" 
            }
            Write-Host "  - $($exc.nombre)$cafeina" -ForegroundColor White
        }
    } else {
        Write-Host "  (Sin excipientes)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "--- BUSCANDO 'CAFE' EN TODO EL OBJETO ---" -ForegroundColor Yellow
    $jsonString = $response | ConvertTo-Json -Depth 10
    if ($jsonString -match "cafe") {
        Write-Host "SE ENCONTRO 'cafe' en algun campo" -ForegroundColor Green
        Write-Host ""
        
        # Mostrar donde
        $lines = $jsonString -split "`n"
        foreach ($line in $lines) {
            if ($line -match "cafe") {
                Write-Host "  $line" -ForegroundColor Cyan
            }
        }
    } else {
        Write-Host "NO se encontro 'cafe' en el objeto" -ForegroundColor Red
    }
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Esta el backend ejecutandose en http://localhost:5000?" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "FIN DE INVESTIGACION" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
