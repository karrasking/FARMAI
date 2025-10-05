# Probar endpoint de materiales CIMA para uno de los 147
Write-Host "Probando API CIMA para materiales del medicamento 85358..." -ForegroundColor Cyan

$nregistro = "85358"

Write-Host "`n1. Intentando endpoint /materiales..." -ForegroundColor Yellow
try {
    $response1 = Invoke-RestMethod -Uri "https://cima.aemps.es/cima/rest/materiales/$nregistro" -Method Get -ErrorAction SilentlyContinue
    Write-Host "OK en /materiales" -ForegroundColor Green
    $response1 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error en /materiales: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2. Intentando endpoint /medicamento..." -ForegroundColor Yellow
try {
    $response2 = Invoke-RestMethod -Uri "https://cima.aemps.es/cima/rest/medicamento?nregistro=$nregistro" -Method Get
    Write-Host "OK en /medicamento" -ForegroundColor Green
    
    if ($response2.materiales) {
        Write-Host "`nMATERIALES ENCONTRADOS:" -ForegroundColor Green
        $response2.materiales | ConvertTo-Json -Depth 10
    } else {
        Write-Host "`nNO tiene campo materiales" -ForegroundColor Red
    }
    
    if ($response2.materialesInf -ne $null) {
        Write-Host "`nCampo materialesInf: $($response2.materialesInf)" -ForegroundColor Cyan
    }
    
    Write-Host "`nJSON completo:" -ForegroundColor Cyan
    $response2 | ConvertTo-Json -Depth 15
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
