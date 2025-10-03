-- ============================================================
-- ANÁLISIS DE DEPENDENCIAS ANTES DE DROPEAR TABLAS
-- Verificar foreign keys, vistas, triggers, etc.
-- ============================================================

-- 1. Ver si las tablas existen
SELECT 'EXISTENCIA DE TABLAS' as seccion;
SELECT table_name, 
       pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) as size
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('PrescripcionStaging_NUEVA', 'PrescripcionStaging_NUEVO', 
                     'AtcXmlTemp', 'PrincipiosActivosXmlTemp')
ORDER BY table_name;

-- 2. Contar registros
SELECT 'PRESCRIPCION STAGING_NUEVA' as tabla, COUNT(*) as registros 
FROM "PrescripcionStaging_NUEVA";

SELECT 'PRESCRIPCION STAGING_NUEVO' as tabla, COUNT(*) as registros 
FROM "PrescripcionStaging_NUEVO";

SELECT 'AtcXmlTemp' as tabla, COUNT(*) as registros 
FROM "AtcXmlTemp";

SELECT 'PrincipiosActivosXmlTemp' as tabla, COUNT(*) as registros 
FROM "PrincipiosActivosXmlTemp";

-- 3. Foreign Keys que REFERENCIAN estas tablas
SELECT 'FOREIGN KEYS ENTRANTES' as seccion;
SELECT
    tc.table_name as tabla_origen, 
    kcu.column_name as columna_origen,
    ccu.table_name AS tabla_referenciada,
    ccu.column_name AS columna_referenciada,
    tc.constraint_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name IN ('PrescripcionStaging_NUEVA', 'PrescripcionStaging_NUEVO', 
                         'AtcXmlTemp', 'PrincipiosActivosXmlTemp');

-- 4. Foreign Keys que SALEN de estas tablas
SELECT 'FOREIGN KEYS SALIENTES' as seccion;
SELECT
    tc.table_name as tabla_origen, 
    kcu.column_name as columna_origen,
    ccu.table_name AS tabla_referenciada,
    ccu.column_name AS columna_referenciada,
    tc.constraint_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name IN ('PrescripcionStaging_NUEVA', 'PrescripcionStaging_NUEVO', 
                        'AtcXmlTemp', 'PrincipiosActivosXmlTemp');

-- 5. Vistas que usan estas tablas
SELECT 'VISTAS QUE USAN ESTAS TABLAS' as seccion;
SELECT DISTINCT table_name as vista
FROM information_schema.view_table_usage
WHERE view_schema = 'public'
  AND table_name IN ('PrescripcionStaging_NUEVA', 'PrescripcionStaging_NUEVO', 
                     'AtcXmlTemp', 'PrincipiosActivosXmlTemp');

-- 6. Triggers en estas tablas
SELECT 'TRIGGERS' as seccion;
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE event_object_table IN ('PrescripcionStaging_NUEVA', 'PrescripcionStaging_NUEVO', 
                              'AtcXmlTemp', 'PrincipiosActivosXmlTemp');

SELECT '✅ ANÁLISIS DE DEPENDENCIAS COMPLETADO' as resultado;
