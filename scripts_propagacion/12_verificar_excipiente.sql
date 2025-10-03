-- ============================================
-- VERIFICACIÓN: Excipiente
-- ============================================

\echo '=== ANÁLISIS EXCIPIENTE ==='
\echo ''

-- 1. Conteos
\echo '1. CONTEO DE REGISTROS'
SELECT 'Excipiente (destino)' as tabla, COUNT(*) as registros FROM "Excipiente"
UNION ALL
SELECT 'ExcipientesDeclObligDicStaging (origen)', COUNT(*) FROM "ExcipientesDeclObligDicStaging"
UNION ALL
SELECT 'MedicamentoExcipiente (FKs)', COUNT(*) FROM "MedicamentoExcipiente";

\echo ''
\echo '2. ESTRUCTURA Excipiente'
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'Excipiente'
ORDER BY ordinal_position;

\echo ''
\echo '3. ESTRUCTURA ExcipientesDeclObligDicStaging'
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'ExcipientesDeclObligDicStaging'
ORDER BY ordinal_position;

\echo ''
\echo '4. ANÁLISIS FK EN MedicamentoExcipiente'
SELECT 
  'Total registros' as metrica,
  COUNT(*) as valor
FROM "MedicamentoExcipiente"
UNION ALL
SELECT 
  'Con ExcipienteId NULL',
  COUNT(*)
FROM "MedicamentoExcipiente"
WHERE "ExcipienteId" IS NULL
UNION ALL
SELECT 
  'Con ExcipienteId NOT NULL',
  COUNT(*)
FROM "MedicamentoExcipiente"
WHERE "ExcipienteId" IS NOT NULL
UNION ALL
SELECT 
  'ExcipienteId sin match en Excipiente',
  COUNT(*)
FROM "MedicamentoExcipiente" me
LEFT JOIN "Excipiente" e ON e."Id" = me."ExcipienteId"
WHERE me."ExcipienteId" IS NOT NULL
  AND e."Id" IS NULL;

\echo ''
\echo '5. EJEMPLOS ExcipientesDeclObligDicStaging'
SELECT * FROM "ExcipientesDeclObligDicStaging" LIMIT 10;

\echo ''
\echo '6. NODOS Excipiente EN GRAFO'
SELECT COUNT(*) as nodos_excipiente_en_grafo
FROM graph_node
WHERE node_type = 'Excipiente';

\echo ''
\echo '7. ARISTAS Med->Excipiente EN GRAFO'
SELECT 
  rel,
  COUNT(*) as total
FROM graph_edge
WHERE dst_type = 'Excipiente'
GROUP BY rel;
