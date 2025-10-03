-- ============================================
-- INVESTIGACIÓN: MedicamentoSustancia
-- ============================================

\echo '=== ANÁLISIS MEDICAMENTO-SUSTANCIA ==='
\echo ''

-- 1. Estructura
\echo '1. ESTRUCTURA MedicamentoSustancia'
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'MedicamentoSustancia'
ORDER BY ordinal_position;

\echo ''
\echo '2. CONSTRAINTS FK'
SELECT 
  tc.constraint_name,
  tc.constraint_type,
  kcu.column_name,
  ccu.table_name AS foreign_table,
  ccu.column_name AS foreign_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
LEFT JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'MedicamentoSustancia'
ORDER BY tc.constraint_type;

\echo ''
\echo '3. ANÁLISIS DE SUSTANCIAID'
SELECT 
  'Total registros' as metrica,
  COUNT(*) as valor
FROM "MedicamentoSustancia"
UNION ALL
SELECT 
  'Con SustanciaId NULL',
  COUNT(*)
FROM "MedicamentoSustancia"
WHERE "SustanciaId" IS NULL
UNION ALL
SELECT 
  'Con SustanciaId NOT NULL',
  COUNT(*)
FROM "MedicamentoSustancia"
WHERE "SustanciaId" IS NOT NULL
UNION ALL
SELECT 
  'SustanciaId sin match en SustanciaActiva',
  COUNT(*)
FROM "MedicamentoSustancia" ms
LEFT JOIN "SustanciaActiva" sa ON sa."Id" = ms."SustanciaId"
WHERE ms."SustanciaId" IS NOT NULL
  AND sa."Id" IS NULL;

\echo ''
\echo '4. EJEMPLOS SustanciaId huérfanos'
SELECT 
  ms."NRegistro",
  ms."SustanciaId",
  ms."NombreRaw",
  ms."CodigoRaw"
FROM "MedicamentoSustancia" ms
LEFT JOIN "SustanciaActiva" sa ON sa."Id" = ms."SustanciaId"
WHERE ms."SustanciaId" IS NOT NULL
  AND sa."Id" IS NULL
LIMIT 10;

\echo ''
\echo '5. DISTRIBUCIÓN SustanciaId'
SELECT 
  CASE 
    WHEN "SustanciaId" IS NULL THEN 'NULL'
    WHEN "SustanciaId" < 0 THEN 'Negativo'
    WHEN "SustanciaId" = 0 THEN 'Zero'
    ELSE 'Positivo'
  END as categoria,
  COUNT(*) as total
FROM "MedicamentoSustancia"
GROUP BY 
  CASE 
    WHEN "SustanciaId" IS NULL THEN 'NULL'
    WHEN "SustanciaId" < 0 THEN 'Negativo'
    WHEN "SustanciaId" = 0 THEN 'Zero'
    ELSE 'Positivo'
  END
ORDER BY total DESC;

\echo ''
\echo '6. ARISTAS EN GRAFO Med->PA'
SELECT 
  rel,
  COUNT(*) as total
FROM graph_edge
WHERE (src_type = 'Medicamento' AND dst_type IN ('SustanciaActiva', 'Sustancia', 'PrincipioActivo'))
   OR (src_type = 'Presentacion' AND dst_type IN ('SustanciaActiva', 'Sustancia', 'PrincipioActivo'))
GROUP BY rel;
