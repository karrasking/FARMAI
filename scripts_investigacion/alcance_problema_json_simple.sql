-- ============================================================================
-- ALCANCE DEL PROBLEMA: JSON sin PA/Excipientes
-- Versión simplificada
-- ============================================================================

-- 1. CONTEO TOTAL DE MEDICAMENTOS
-- ============================================================================
SELECT 
    'Total Medicamentos' as categoria,
    COUNT(*) as cantidad
FROM "Medicamentos";

-- 2. MEDICAMENTOS CON JSON
-- ============================================================================
SELECT 
    'Con RawJson no vacío' as categoria,
    COUNT(*) as cantidad
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL AND "RawJson" != '';

-- 3. MEDICAMENTOS SIN CLAVE principiosActivos EN JSON
-- ============================================================================
SELECT 
    'Sin clave principiosActivos' as categoria,
    COUNT(*) as cantidad
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL 
  AND "RawJson" != ''
  AND NOT ("RawJson"::jsonb ? 'principiosActivos');

-- 4. MEDICAMENTOS SIN CLAVE excipientes EN JSON
-- ============================================================================
SELECT 
    'Sin clave excipientes' as categoria,
    COUNT(*) as cantidad
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL 
  AND "RawJson" != ''
  AND NOT ("RawJson"::jsonb ? 'excipientes');

-- 5. MEDICAMENTOS SIN PA NI EXCIPIENTES EN JSON
-- ============================================================================
SELECT 
    'Sin PA ni Excipientes' as categoria,
    COUNT(*) as cantidad
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL 
  AND "RawJson" != ''
  AND (
      NOT ("RawJson"::jsonb ? 'principiosActivos')
      OR NOT ("RawJson"::jsonb ? 'excipientes')
  );

-- 6. MEDICAMENTOS CON PA EN GRAFO
-- ============================================================================
SELECT 
    'Con PA en Grafo' as categoria,
    COUNT(DISTINCT src_key) as cantidad
FROM graph_edge
WHERE src_type = 'Medicamento' 
  AND rel = 'CONTIENE_PA';

-- 7. MEDICAMENTOS CON EXCIPIENTES EN GRAFO
-- ============================================================================
SELECT 
    'Con Excipientes en Grafo' as categoria,
    COUNT(DISTINCT src_key) as cantidad
FROM graph_edge
WHERE src_type = 'Medicamento' 
  AND rel = 'CONTIENE_EXCIPIENTE';

-- 8. EJEMPLOS DE MEDICAMENTOS PROBLEMÁTICOS
-- ============================================================================
SELECT 
    "NRegistro",
    LEFT("Nombre", 50) as nombre_corto,
    "LabTitular",
    CASE WHEN "RawJson"::jsonb ? 'principiosActivos' THEN 'SI' ELSE 'NO' END as tiene_pa_json,
    CASE WHEN "RawJson"::jsonb ? 'excipientes' THEN 'SI' ELSE 'NO' END as tiene_exc_json,
    (SELECT COUNT(*) FROM graph_edge WHERE src_type = 'Medicamento' AND src_key = m."NRegistro" AND rel = 'CONTIENE_PA') as pa_en_grafo,
    (SELECT COUNT(*) FROM graph_edge WHERE src_type = 'Medicamento' AND src_key = m."NRegistro" AND rel = 'CONTIENE_EXCIPIENTE') as exc_en_grafo
FROM "Medicamentos" m
WHERE "RawJson" IS NOT NULL 
  AND "RawJson" != ''
  AND (
      NOT ("RawJson"::jsonb ? 'principiosActivos')
      OR NOT ("RawJson"::jsonb ? 'excipientes')
  )
LIMIT 20;

-- 9. VERIFICAR EXISTENCIA DE TABLAS DE RESPALDO
-- ============================================================================
SELECT 
    table_name as tabla,
    pg_size_pretty(pg_total_relation_size(quote_ident(table_name)::regclass)) as tamaño
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
  AND (
      table_name LIKE '%Sustancia%'
      OR table_name LIKE '%Excipiente%'
      OR table_name = 'graph_node'
      OR table_name = 'graph_edge'
  )
ORDER BY table_name;
