-- ============================================
-- VERIFICACIÓN DEL PASO 2
-- ============================================

\echo '=== VERIFICACIÓN DE ARISTAS CREADAS ==='
\echo ''

-- 1. Conteo total
\echo '1. CONTEO TOTAL DE ARISTAS'
SELECT 
  src_type as origen,
  dst_type as destino,
  rel as relacion,
  COUNT(*) as total
FROM graph_edge
WHERE dst_type = 'SituacionRegistro'
  AND rel = 'TIENE_SITUACION_REGISTRO'
GROUP BY src_type, dst_type, rel;

\echo ''
\echo '2. DISTRIBUCIÓN POR SITUACIÓN'
-- 2. Por situación
SELECT 
  ge.src_type as origen,
  gn.props->>'nombre' as situacion,
  COUNT(*) as total
FROM graph_edge ge
JOIN graph_node gn ON gn.node_type = 'SituacionRegistro' AND gn.node_key = ge.dst_key
WHERE ge.dst_type = 'SituacionRegistro'
  AND ge.rel = 'TIENE_SITUACION_REGISTRO'
GROUP BY ge.src_type, gn.props->>'nombre'
ORDER BY ge.src_type, gn.props->>'nombre';

\echo ''
\echo '3. EJEMPLOS ALEATORIOS'
-- 3. Ejemplos
SELECT 
  ge.src_type,
  LEFT(ge.src_key, 20) as id,
  gn.props->>'nombre' as situacion,
  (ge.props->>'fecha')::date as fecha
FROM graph_edge ge
JOIN graph_node gn ON gn.node_type = 'SituacionRegistro' AND gn.node_key = ge.dst_key
WHERE ge.dst_type = 'SituacionRegistro'
  AND ge.rel = 'TIENE_SITUACION_REGISTRO'
ORDER BY RANDOM()
LIMIT 15;
