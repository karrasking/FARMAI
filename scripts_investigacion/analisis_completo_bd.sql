-- ============================================================
-- ANÁLISIS EXHAUSTIVO COMPLETO DE LA BASE DE DATOS FARMAI
-- Investigar TODAS las tablas, relaciones, origen y destino
-- ============================================================

-- 1. LISTAR TODAS LAS TABLAS CON TAMAÑO Y REGISTROS
SELECT 
    'INVENTARIO COMPLETO TABLAS' as seccion,
    table_name,
    pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) as size,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as num_columnas
FROM information_schema.tables t
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY pg_total_relation_size(quote_ident(table_name)) DESC;

-- 2. FOREIGN KEYS - TODAS LAS RELACIONES
SELECT 
    'TODAS LAS FOREIGN KEYS' as seccion,
    tc.table_name as tabla_origen,
    kcu.column_name as columna_origen,
    ccu.table_name AS tabla_referenciada,
    ccu.column_name AS columna_referenciada,
    tc.constraint_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name, ccu.table_name;

-- 3. VISTAS MATERIALIZADAS
SELECT 
    'VISTAS MATERIALIZADAS' as seccion,
    schemaname,
    matviewname,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || matviewname)) as size
FROM pg_matviews
ORDER BY matviewname;

-- 4. VISTAS NORMALES
SELECT 
    'VISTAS NORMALES' as seccion,
    schemaname,
    viewname
FROM pg_views
WHERE schemaname = 'public'
ORDER BY viewname;

-- 5. ÍNDICES PRINCIPALES
SELECT 
    'ÍNDICES PRINCIPALES' as seccion,
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as size
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('Medicamentos', 'graph_node', 'graph_edge', 'PrescripcionStaging')
ORDER BY tablename, indexname;

-- 6. GRAFO - TIPOS DE NODOS
SELECT 
    'GRAFO - TIPOS NODOS' as seccion,
    node_type,
    COUNT(*) as total,
    pg_size_pretty(SUM(LENGTH(props::text))::bigint) as size_props
FROM graph_node
GROUP BY node_type
ORDER BY total DESC;

-- 7. GRAFO - TIPOS DE RELACIONES  
SELECT 
    'GRAFO - TIPOS RELACIONES' as seccion,
    rel,
    COUNT(*) as total,
    COUNT(DISTINCT src_type) as tipos_origen,
    COUNT(DISTINCT dst_type) as tipos_destino
FROM graph_edge
GROUP BY rel
ORDER BY total DESC;

-- 8. TABLAS STAGING
SELECT 'TABLAS STAGING' as seccion;
SELECT table_name, 
       pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) as size
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name LIKE '%Staging%'
ORDER BY table_name;

-- 9. TABLAS DICCIONARIO
SELECT 'TABLAS DICCIONARIO' as seccion;
SELECT table_name,
       pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) as size
FROM information_schema.tables
WHERE table_schema = 'public'
  AND (table_name LIKE '%Dic%' OR table_name LIKE '%Dict%')
ORDER BY table_name;

-- 10. TABLAS TEMPORALES
SELECT 'TABLAS TEMPORALES' as seccion;
SELECT table_name,
       pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) as size
FROM information_schema.tables
WHERE table_schema = 'public'
  AND (table_name LIKE '%Temp%' OR table_name LIKE '%tmp%')
ORDER BY table_name;
