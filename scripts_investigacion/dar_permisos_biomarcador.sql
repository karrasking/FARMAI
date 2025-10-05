-- Dar permisos a la tabla MedicamentoBiomarcador

-- Ver usuario actual de la aplicación
SELECT current_user;

-- Dar permisos al usuario de la API
GRANT SELECT ON "MedicamentoBiomarcador" TO farmai_api_user;
GRANT SELECT ON "Biomarcador" TO farmai_api_user;

-- Verificar permisos
SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name = 'MedicamentoBiomarcador';
