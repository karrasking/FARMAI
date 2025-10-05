# Script para verificar tablas de PA y Excipientes
$env:PGPASSWORD = "postgres"
psql -h localhost -p 5433 -U postgres -d farmai_db -f scripts_investigacion/verificar_tablas_pa_exc_67939.sql
