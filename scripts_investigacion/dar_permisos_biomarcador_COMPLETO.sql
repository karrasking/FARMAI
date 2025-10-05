-- Dar permisos COMPLETOS para biomarcadores

-- Dar permisos a AMBAS tablas necesarias
GRANT SELECT ON "MedicamentoBiomarcador" TO farmai_etl_user;
GRANT SELECT ON "Biomarcador" TO farmai_etl_user;

-- Verificar permisos en AMBAS tablas
SELECT 
    table_name,
    grantee, 
    privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name IN ('MedicamentoBiomarcador', 'Biomarcador')
  AND grantee = 'farmai_etl_user'
ORDER BY table_name;
