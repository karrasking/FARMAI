-- SOLUCIÓN DEFINITIVA: Cambiar ownership de tablas de biomarcadores

-- El problema: Estas tablas son propiedad de 'postgres'
-- mientras que todas las demás son de 'farmai_user'

-- Cambiar owner a farmai_user (mismo que el resto de tablas)
ALTER TABLE "Biomarcador" OWNER TO farmai_user;
ALTER TABLE "MedicamentoBiomarcador" OWNER TO farmai_user;

-- Verificar que el cambio fue exitoso
SELECT 
    tablename,
    tableowner,
    CASE 
        WHEN tableowner = 'farmai_user' THEN '✅ CORRECTO'
        ELSE '❌ INCORRECTO'
    END as status
FROM pg_tables
WHERE tablename IN ('Biomarcador', 'MedicamentoBiomarcador', 'MedicamentoSustancia')
ORDER BY tablename;

-- Verificar permisos heredados por default privileges
SELECT 
    'VERIFICACIÓN FINAL' as tipo,
    grantee,
    table_name,
    privilege_type
FROM information_schema.table_privileges
WHERE table_name IN ('Biomarcador', 'MedicamentoBiomarcador')
  AND grantee IN ('farmai_user', 'farmai_etl_user')
ORDER BY table_name, grantee;
