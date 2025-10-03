-- ============================================
-- VERIFICACIÓN: DcsaDicStaging (VACÍA)
-- ============================================

\echo '=== ANÁLISIS DCSA (Descriptor Clase SubActiva) ==='
\echo ''

-- 1. Conteos
\echo '1. CONTEO DE REGISTROS'
SELECT 'DcsaDicStaging (destino VACÍO)' as tabla, COUNT(*) as registros FROM "DcsaDicStaging"
UNION ALL
SELECT 'DcpDicStaging (depende de DCSA)', COUNT(*) FROM "DcpDicStaging"
UNION ALL
SELECT 'DcpfDicStaging', COUNT(*) FROM "DcpfDicStaging";

\echo ''
\echo '2. ESTRUCTURA DcsaDicStaging'
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'DcsaDicStaging'
ORDER BY ordinal_position;

\echo ''
\echo '3. ESTRUCTURA DcpDicStaging (depende de DCSA)'
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'DcpDicStaging'
ORDER BY ordinal_position;

\echo ''
\echo '4. FK DcpDicStaging -> DcsaDicStaging'
SELECT 
  tc.constraint_name,
  kcu.column_name,
  ccu.table_name AS foreign_table,
  ccu.column_name AS foreign_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
LEFT JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'DcpDicStaging'
  AND tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name = 'DcsaDicStaging';

\echo ''
\echo '5. ANÁLISIS DcpDicStaging.CodigoDcsa (FK rota)'
SELECT 
  'Total DCP' as metrica,
  COUNT(*) as valor
FROM "DcpDicStaging"
UNION ALL
SELECT 
  'Con CodigoDcsa NULL',
  COUNT(*)
FROM "DcpDicStaging"
WHERE "CodigoDcsa" IS NULL
UNION ALL
SELECT 
  'Con CodigoDcsa NOT NULL',
  COUNT(*)
FROM "DcpDicStaging"
WHERE "CodigoDcsa" IS NOT NULL
UNION ALL
SELECT 
  'CodigoDcsa huérfano (apunta a tabla vacía)',
  COUNT(*)
FROM "DcpDicStaging" dcp
LEFT JOIN "DcsaDicStaging" dcsa ON dcsa."Codigo" = dcp."CodigoDcsa"
WHERE dcp."CodigoDcsa" IS NOT NULL
  AND dcsa."Codigo" IS NULL;

\echo ''
\echo '6. EJEMPLOS DcpDicStaging'
SELECT * FROM "DcpDicStaging" LIMIT 5;

\echo ''
\echo '7. NODOS DCP/DCSA EN GRAFO'
SELECT 
  node_type,
  COUNT(*) as total
FROM graph_node
WHERE node_type IN ('Dcp', 'Dcpf', 'Dcsa', 'DCP', 'DCPF', 'DCSA')
GROUP BY node_type;
