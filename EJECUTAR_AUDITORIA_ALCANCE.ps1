# Script para investigar alcance del problema de JSON incompleto
$env:PGPASSWORD = "postgres"
psql -h localhost -p 5433 -U postgres -d farmai_db -f scripts_investigacion/alcance_problema_json_simple.sql
