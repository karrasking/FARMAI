# Ejecutar verificación de cafeína en 60605
# BD: localhost:5433 farmai_db farmai_user

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "VERIFICANDO CAFEINA EN BD" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$env:PGPASSWORD = "Iaforeverfree"

$queries = @(
    "-- 1. Excipientes de 60605",
    "SELECT me.""NRegistro"", e.""Id"" as excipiente_id, e.""Nombre"" as excipiente_nombre, me.""Cantidad"", me.""Unidad"", me.""Orden"" FROM ""MedicamentoExcipiente"" me JOIN ""Excipiente"" e ON me.""ExcipienteId"" = e.""Id""::bigint WHERE me.""NRegistro"" = '60605' ORDER BY me.""Orden"";",
    
    "-- 2. Excipientes con 'cafe'",
    "SELECT ""Id"", ""Nombre"" FROM ""Excipiente"" WHERE ""Nombre"" ILIKE '%cafe%' LIMIT 10;",
    
    "-- 3. Match 60605 con cafe",
    "SELECT me.""NRegistro"", m.""Nombre"" as medicamento, e.""Nombre"" as excipiente FROM ""MedicamentoExcipiente"" me JOIN ""Medicamento"" m ON me.""NRegistro"" = m.""NRegistro"" JOIN ""Excipiente"" e ON me.""ExcipienteId"" = e.""Id""::bigint WHERE me.""NRegistro"" = '60605' AND e.""Nombre"" ILIKE '%cafe%';"
)

for ($i = 0; $i -lt $queries.Length; $i += 2) {
    Write-Host $queries[$i] -ForegroundColor Yellow
    $result = psql -h 127.0.0.1 -p 5433 -U farmai_user -d farmai_db -c $queries[$i+1] -t
    Write-Host $result -ForegroundColor Green
    Write-Host ""
    Write-Host "-------------------------------------------" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "=========================================" -ForegroundColor Cyan
