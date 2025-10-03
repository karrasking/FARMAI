-- ============================================
-- PASO 9: NORMALIZAR RELACIONES PRINCIPIO ACTIVO
-- ============================================
-- Unificar CONTINE, CONTINE_PA → PERTENECE_A_PRINCIPIO_ACTIVO
-- Total: 75,219 aristas (3 duplicados → 1)
-- ============================================

\echo '=== PASO 9: NORMALIZANDO RELACIONES PA ==='
\echo ''

-- 1. Estado actual
\echo '1. ESTADO ACTUAL (ANTES)'
SELECT 
  rel,
  COUNT(*) as total
FROM graph_edge
WHERE rel IN ('CONTINE', 'CONTINE_PA', 'PERTENECE_A_PRINCIPIO_ACTIVO')
GROUP BY rel
ORDER BY rel;

\echo ''
\echo '2. VERIFICANDO DUPLICADOS'
-- Verificar que las 3 relaciones son idénticas
SELECT 
  COUNT(DISTINCT (src_type, src_key, dst_type, dst_key)) as combinaciones_unicas,
  COUNT(*) / 3 as esperado_por_relacion
FROM graph_edge
WHERE rel IN ('CONTINE', 'CONTINE_PA', 'PERTENECE_A_PRINCIPIO_ACTIVO');

BEGIN;

\echo ''
\echo '3. ELIMINANDO RELACIONES OBSOLETAS...'
-- Eliminar CONTINE y CONTINE_PA (mantener PERTENECE_A_PRINCIPIO_ACTIVO)
DELETE FROM graph_edge
WHERE rel IN ('CONTINE', 'CONTINE_PA');

\echo ''
\echo '4. ESTADO FINAL (DESPUÉS)'
SELECT 
  rel,
  COUNT(*) as total
FROM graph_edge
WHERE rel = 'PERTENECE_A_PRINCIPIO_ACTIVO'
GROUP BY rel;

\echo ''
\echo '5. VERIFICACIÓN INTEGRIDAD'
-- Verificar que todas las relaciones Med→PA están presentes
SELECT 
  'Total Med-SustanciaActiva esperados' as metrica,
  COUNT(*) as valor
FROM "MedicamentoSustancia"

UNION ALL

SELECT 
  'Total aristas PERTENECE_A_PRINCIPIO_ACTIVO',
  COUNT(*)
FROM graph_edge
WHERE rel = 'PERTENECE_A_PRINCIPIO_ACTIVO';

\echo ''
\echo '6. EJEMPLOS'
SELECT 
  ge.src_type,
  LEFT(ge.src_key, 15) as med_id,
  ge.rel,
  ge.dst_type,
  LEFT(gn.props->>'nombre', 30) as sustancia
FROM graph_edge ge
JOIN graph_node gn ON gn.node_type = ge.dst_type AND gn.node_key = ge.dst_key
WHERE ge.rel = 'PERTENECE_A_PRINCIPIO_ACTIVO'
LIMIT 5;

COMMIT;

\echo ''
\echo '=== PASO 9 COMPLETADO ==='
