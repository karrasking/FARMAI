-- ============================================
-- ANÁLISIS PREVIO AL PASO 2
-- Conteo de aristas a crear (sin ejecutar nada)
-- ============================================

\echo '=== CONTEO DE ARISTAS PARA PASO 2 ==='
\echo ''

-- 1. Medicamentos → SituacionRegistro
\echo '1. MEDICAMENTOS → SITUACION REGISTRO'
SELECT 
  ps."CodSitReg" as codigo_situacion,
  sr.props->>'nombre' as situacion,
  COUNT(*) as total_medicamentos
FROM "PrescripcionStaging" ps
LEFT JOIN graph_node sr ON sr.node_type = 'SituacionRegistro' AND sr.node_key = ps."CodSitReg"::text
WHERE ps."CodSitReg" IS NOT NULL
GROUP BY ps."CodSitReg", sr.props->>'nombre'
ORDER BY ps."CodSitReg";

\echo ''
\echo '2. PRESENTACIONES → SITUACION REGISTRO'
-- 2. Presentaciones → SituacionRegistro
SELECT 
  ps."CodSitRegPresen" as codigo_situacion,
  sr.props->>'nombre' as situacion,
  COUNT(*) as total_presentaciones
FROM "PrescripcionStaging" ps
LEFT JOIN graph_node sr ON sr.node_type = 'SituacionRegistro' AND sr.node_key = ps."CodSitRegPresen"::text
WHERE ps."CodSitRegPresen" IS NOT NULL
GROUP BY ps."CodSitRegPresen", sr.props->>'nombre'
ORDER BY ps."CodSitRegPresen";

\echo ''
\echo '3. RESUMEN TOTAL'
-- 3. Totales
SELECT 
  'Medicamentos → SituacionRegistro' as tipo_arista,
  COUNT(*) as total_aristas
FROM "PrescripcionStaging"
WHERE "CodSitReg" IS NOT NULL

UNION ALL

SELECT 
  'Presentaciones → SituacionRegistro',
  COUNT(*)
FROM "PrescripcionStaging"
WHERE "CodSitRegPresen" IS NOT NULL

UNION ALL

SELECT 
  'TOTAL',
  (SELECT COUNT(*) FROM "PrescripcionStaging" WHERE "CodSitReg" IS NOT NULL) +
  (SELECT COUNT(*) FROM "PrescripcionStaging" WHERE "CodSitRegPresen" IS NOT NULL);

\echo ''
\echo '4. VERIFICACIÓN DE INTEGRIDAD'
-- 4. Verificar que todos los códigos existen en los nodos
SELECT 
  'Códigos de Med sin nodo' as problema,
  COUNT(DISTINCT ps."CodSitReg") as cantidad
FROM "PrescripcionStaging" ps
WHERE ps."CodSitReg" IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM graph_node gn 
    WHERE gn.node_type = 'SituacionRegistro' 
    AND gn.node_key = ps."CodSitReg"::text
  )

UNION ALL

SELECT 
  'Códigos de Pres sin nodo',
  COUNT(DISTINCT ps."CodSitRegPresen")
FROM "PrescripcionStaging" ps
WHERE ps."CodSitRegPresen" IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM graph_node gn 
    WHERE gn.node_type = 'SituacionRegistro' 
    AND gn.node_key = ps."CodSitRegPresen"::text
  );

\echo ''
\echo '5. EJEMPLOS DE ARISTAS (10 primeros)'
-- 5. Ejemplos
SELECT 
  'Medicamento' as tipo_origen,
  m."Nombre" as nombre_origen,
  ps."NRegistro" as key_origen,
  sr.props->>'nombre' as situacion_destino,
  ps."FechaSitReg" as fecha
FROM "PrescripcionStaging" ps
JOIN "Medicamentos" m ON m."NRegistro" = ps."NRegistro"
LEFT JOIN graph_node sr ON sr.node_type = 'SituacionRegistro' AND sr.node_key = ps."CodSitReg"::text
WHERE ps."CodSitReg" IS NOT NULL
LIMIT 10;
