-- ============================================
-- VERIFICACIÓN PREVIA: SustanciaActiva
-- ============================================

\echo '=== ANÁLISIS SITUACIÓN ACTUAL ==='
\echo ''

-- 1. Estado tablas involucradas
\echo '1. CONTEO DE REGISTROS'
SELECT 'SustanciaActiva (destino)' as tabla, COUNT(*) as registros FROM "SustanciaActiva"
UNION ALL
SELECT 'PrincipiosActivos (origen)', COUNT(*) FROM "PrincipiosActivos"
UNION ALL
SELECT 'PrincipioActivoStaging', COUNT(*) FROM "PrincipioActivoStaging"
UNION ALL
SELECT 'MedicamentoSustancia (FKs rotas)', COUNT(*) FROM "MedicamentoSustancia";

\echo ''
\echo '2. ESTRUCTURA SustanciaActiva'
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'SustanciaActiva'
ORDER BY ordinal_position;

\echo ''
\echo '3. ESTRUCTURA PrincipiosActivos (ORIGEN)'
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'PrincipiosActivos'
ORDER BY ordinal_position;

\echo ''
\echo '4. CONSTRAINTS Y FKs'
SELECT 
  tc.constraint_name,
  tc.constraint_type,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
LEFT JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'SustanciaActiva'
ORDER BY tc.constraint_type, tc.constraint_name;

\echo ''
\echo '5. FKs QUE APUNTAN A SustanciaActiva (ROTAS)'
SELECT 
  tc.table_name,
  COUNT(*) as registros_con_fk
FROM information_schema.table_constraints AS tc
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name = 'SustanciaActiva'
GROUP BY tc.table_name;

\echo ''
\echo '6. EJEMPLOS DE PrincipiosActivos'
SELECT * FROM "PrincipiosActivos" LIMIT 5;

\echo ''
\echo '7. NODOS SustanciaActiva EN GRAFO'
SELECT COUNT(*) as nodos_sustancia_en_grafo
FROM graph_node
WHERE node_type IN ('SustanciaActiva', 'Sustancia', 'PrincipioActivo');
