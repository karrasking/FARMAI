-- INVESTIGACIÓN EXHAUSTIVA DE PERMISOS - BIOMARCADORES

-- =====================================================
-- PARTE 1: ¿QUÉ USUARIO ESTÁ USANDO EL API?
-- =====================================================

-- Ver conexión actual
SELECT current_user, current_database(), session_user;

-- Ver rol efectivo y todos los roles heredados
SELECT 
    r.rolname as role_name,
    r.rolsuper as is_superuser,
    r.rolinherit as can_inherit,
    r.rolcreaterole as can_create_roles,
    r.rolcreatedb as can_create_db
FROM pg_roles r
WHERE r.rolname = 'farmai_etl_user';

-- Ver memberships (roles heredados)
SELECT 
    member.rolname as member_role,
    target.rolname as inherited_role
FROM pg_auth_members m
JOIN pg_roles member ON m.member = member.oid
JOIN pg_roles target ON m.roleid = target.oid
WHERE member.rolname = 'farmai_etl_user';

-- =====================================================
-- PARTE 2: OWNERSHIP DE LAS TABLAS
-- =====================================================

-- Ver quién es el owner de cada tabla relevante
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables
WHERE tablename IN ('MedicamentoBiomarcador', 'Biomarcador', 
                     'MedicamentoSustancia', 'SustanciaActiva',
                     'MedicamentoExcipiente', 'Excipiente',
                     'Medicamentos')
ORDER BY tablename;

-- =====================================================
-- PARTE 3: PERMISOS EXPLÍCITOS EN LAS TABLAS
-- =====================================================

-- Ver TODOS los permisos en tablas de biomarcadores
SELECT 
    grantee,
    table_schema,
    table_name,
    privilege_type,
    is_grantable
FROM information_schema.table_privileges
WHERE table_name IN ('MedicamentoBiomarcador', 'Biomarcador')
ORDER BY table_name, grantee, privilege_type;

-- =====================================================
-- PARTE 4: PERMISOS A NIVEL DE SCHEMA
-- =====================================================

-- Ver permisos en el schema public
SELECT 
    nspname as schema_name,
    nspowner::regrole as owner,
    nspacl as acl
FROM pg_namespace
WHERE nspname = 'public';

-- =====================================================
-- PARTE 5: VERIFICAR DEFAULT PRIVILEGES
-- =====================================================

-- Ver privilegios por defecto
SELECT 
    defaclrole::regrole as grantor,
    defaclnamespace::regnamespace as schema,
    defaclobjtype as object_type,
    defaclacl as privileges
FROM pg_default_acl
WHERE defaclnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

-- =====================================================
-- PARTE 6: COMPARACIÓN CON OTRAS TABLAS QUE FUNCIONAN
-- =====================================================

-- Comparar permisos: MedicamentoSustancia (FUNCIONA) vs MedicamentoBiomarcador (FALLA)
SELECT 
    'MedicamentoSustancia' as tabla,
    grantee,
    privilege_type
FROM information_schema.table_privileges
WHERE table_name = 'MedicamentoSustancia'
  AND grantee = 'farmai_etl_user'

UNION ALL

SELECT 
    'MedicamentoBiomarcador' as tabla,
    grantee,
    privilege_type
FROM information_schema.table_privileges
WHERE table_name = 'MedicamentoBiomarcador'
  AND grantee = 'farmai_etl_user'

ORDER BY tabla, privilege_type;

-- =====================================================
-- PARTE 7: VERIFICAR SI HAY POLÍTICAS RLS
-- =====================================================

-- Row Level Security puede bloquear acceso
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename IN ('MedicamentoBiomarcador', 'Biomarcador')
ORDER BY tablename;

-- Ver políticas RLS si existen
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE tablename IN ('MedicamentoBiomarcador', 'Biomarcador');

-- =====================================================
-- PARTE 8: INFORMACIÓN COMPLETA DE LA TABLA
-- =====================================================

-- Ver OID y namespace de las tablas
SELECT 
    c.relname as table_name,
    c.relowner::regrole as owner,
    c.relnamespace::regnamespace as schema,
    c.relacl as acl
FROM pg_class c
WHERE c.relname IN ('MedicamentoBiomarcador', 'Biomarcador')
  AND c.relkind = 'r';

-- =====================================================
-- RESUMEN EJECUTIVO
-- =====================================================

SELECT 'DIAGNÓSTICO COMPLETO' as seccion;

-- Owner check
SELECT 
    'OWNERSHIP' as check_tipo,
    tablename,
    tableowner,
    CASE 
        WHEN tableowner = 'farmai_etl_user' THEN '✅ CORRECTO'
        ELSE '⚠️ PROBLEMA: Owner diferente'
    END as status
FROM pg_tables
WHERE tablename IN ('MedicamentoBiomarcador', 'Biomarcador');

-- Permission check
SELECT 
    'PERMISOS' as check_tipo,
    table_name,
    COUNT(*) as num_permisos,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Tiene permisos'
        ELSE '❌ SIN PERMISOS'
    END as status
FROM information_schema.table_privileges
WHERE table_name IN ('MedicamentoBiomarcador', 'Biomarcador')
  AND grantee = 'farmai_etl_user'
GROUP BY table_name;
