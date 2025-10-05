# Script para investigar medicamento 67939
$env:PGPASSWORD = "postgres"
psql -h localhost -p 5433 -U postgres -d farmai_db -f scripts_investigacion/investigar_medicamento_67939.sql
