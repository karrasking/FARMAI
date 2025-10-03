-- ============================================
-- PASO 8: CREAR ÍNDICES OPTIMIZADOS PARA GRAFO
-- ============================================
-- Se crean CONCURRENTLY para no bloquear
-- Tiempo estimado: 1-2 horas (en background)
-- ============================================

\echo '=== PASO 8: CREANDO ÍNDICES OPTIMIZADOS ==='
\echo ''

-- Verificar índices existentes primero
\echo '1. ÍNDICES EXISTENTES'
SELECT 
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename IN ('graph_node', 'graph_edge')
ORDER BY tablename, indexname;

\echo ''
\echo '2. CREANDO NUEVOS ÍNDICES (CONCURRENTLY)...'
\echo ''

-- 2.1 GIN en props para búsquedas en JSONB
\echo '2.1. GIN en graph_node.props...'
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_graph_node_props_gin 
ON graph_node USING gin(props);

\echo '2.2. GIN en graph_edge.props...'
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_graph_edge_props_gin 
ON graph_edge USING gin(props);

-- 2.2 Búsqueda inversa de aristas
\echo '2.3. Índice búsqueda inversa (dst)...'
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_graph_edge_dst 
ON graph_edge (dst_type, dst_key);

-- 2.3 Índice por tipo de relación
\echo '2.4. Índice por tipo de relación...'
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_graph_edge_rel 
ON graph_edge (rel);

-- 2.4 Full-text search en nombres (español)
\echo '2.5. Full-text search en español...'
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_graph_node_name_ft 
ON graph_node USING gin(to_tsvector('spanish', COALESCE(props->>'nombre', '')))
WHERE props ? 'nombre';

-- 2.5 Trigram para fuzzy search
\echo '2.6. Trigram para fuzzy search...'
-- Primero verificar si extensión pg_trgm está instalada
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_trgm') THEN
    CREATE EXTENSION pg_trgm;
    RAISE NOTICE 'Extensión pg_trgm creada';
  ELSE
    RAISE NOTICE 'Extensión pg_trgm ya existe';
  END IF;
END $$;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_graph_node_name_trgm 
ON graph_node USING gin((props->>'nombre') gin_trgm_ops)
WHERE props ? 'nombre';

-- 2.6 Índice combinado node_type + node_key
\echo '2.7. Índice combinado type+key...'
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_graph_node_type_key 
ON graph_node (node_type, node_key);

-- 2.7 Índice para jerarquías (ATC, DCP, etc.)
\echo '2.8. Índice para jerarquías...'
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_graph_edge_hierarchy 
ON graph_edge (src_type, src_key, rel)
WHERE rel IN ('SUBCLASE_DE', 'PADRE_DE', 'HIJO_DE', 'PERTENECE_A');

\echo ''
\echo '3. ÍNDICES CREADOS EXITOSAMENTE'
SELECT 
  schemaname,
  tablename,
  indexname,
  pg_size_pretty(pg_relation_size(indexname::regclass)) as size
FROM pg_indexes
WHERE tablename IN ('graph_node', 'graph_edge')
  AND indexname LIKE 'idx_graph%'
ORDER BY tablename, indexname;

\echo ''
\echo '=== PASO 8 COMPLETADO ==='
