-- Dar permisos correctos para biomarcadores

-- Ver usuarios existentes
SELECT usename FROM pg_user;

-- Dar permisos al usuario ETL que usa la API
GRANT SELECT ON "MedicamentoBiomarcador" TO farmai_etl_user;
GRANT SELECT ON "Biomarcador" TO farmai_etl_user;

-- Verificar permisos
SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name = 'MedicamentoBiomarcador';
