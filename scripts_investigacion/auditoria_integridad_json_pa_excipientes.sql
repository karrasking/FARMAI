-- ============================================================================
-- AUDITORÍA DE INTEGRIDAD: Principios Activos y Excipientes en JSON
-- Fecha: 05/10/2025
-- Propósito: Verificar completitud y posibles corrupciones en RawJson
-- ============================================================================

-- 1. MEDICAMENTOS CON/SIN PRINCIPIOS ACTIVOS EN JSON
-- ============================================================================
WITH json_stats AS (
    SELECT 
        "NRegistro",
        "Nombre",
        CASE 
            WHEN "RawJson" IS NULL OR "RawJson" = '' THEN 'SIN_JSON'
            WHEN "RawJson"::jsonb ? 'principiosActivos' THEN
                CASE 
                    WHEN jsonb_array_length(("RawJson"::jsonb)->'principiosActivos') = 0 THEN 'JSON_PA_VACIO'
                    ELSE 'JSON_PA_OK'
                END
            ELSE 'JSON_SIN_PA'
        END as estado_pa,
        CASE 
            WHEN "RawJson" IS NULL OR "RawJson" = '' THEN 0
            WHEN "RawJson"::jsonb ? 'principiosActivos' THEN 
                jsonb_array_length(("RawJson"::jsonb)->'principiosActivos')
            ELSE 0
        END as num_pa
    FROM "Medicamentos"
)
SELECT 
    estado_pa,
    COUNT(*) as cantidad,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as porcentaje,
    MIN(num_pa) as min_pa,
    MAX(num_pa) as max_pa,
    ROUND(AVG(num_pa), 2) as avg_pa
FROM json_stats
GROUP BY estado_pa
ORDER BY cantidad DESC;

-- 2. MEDICAMENTOS CON/SIN EXCIPIENTES EN JSON
-- ============================================================================
WITH json_stats AS (
    SELECT 
        "NRegistro",
        "Nombre",
        CASE 
            WHEN "RawJson" IS NULL OR "RawJson" = '' THEN 'SIN_JSON'
            WHEN "RawJson"::jsonb ? 'excipientes' THEN
                CASE 
                    WHEN jsonb_array_length(("RawJson"::jsonb)->'excipientes') = 0 THEN 'JSON_EXC_VACIO'
                    ELSE 'JSON_EXC_OK'
                END
            ELSE 'JSON_SIN_EXC'
        END as estado_exc,
        CASE 
            WHEN "RawJson" IS NULL OR "RawJson" = '' THEN 0
            WHEN "RawJson"::jsonb ? 'excipientes' THEN 
                jsonb_array_length(("RawJson"::jsonb)->'excipientes')
            ELSE 0
        END as num_exc
    FROM "Medicamentos"
)
SELECT 
    estado_exc,
    COUNT(*) as cantidad,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as porcentaje,
    MIN(num_exc) as min_exc,
    MAX(num_exc) as max_exc,
    ROUND(AVG(num_exc), 2) as avg_exc
FROM json_stats
GROUP BY estado_exc
ORDER BY cantidad DESC;

-- 3. EJEMPLOS DE MEDICAMENTOS SIN PA EN JSON
-- ============================================================================
SELECT 
    "NRegistro",
    "Nombre",
    "LabTitular",
    LENGTH("RawJson") as json_size,
    CASE 
        WHEN "RawJson"::jsonb ? 'principiosActivos' THEN 'Tiene clave pero vacío'
        ELSE 'No tiene clave'
    END as problema
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL 
  AND "RawJson" != ''
  AND (
      NOT ("RawJson"::jsonb ? 'principiosActivos')
      OR jsonb_array_length(("RawJson"::jsonb->'principiosActivos') = 0
  )
LIMIT 10;

-- 4. EJEMPLOS DE MEDICAMENTOS SIN EXCIPIENTES EN JSON
-- ============================================================================
SELECT 
    "NRegistro",
    "Nombre",
    "LabTitular",
    LENGTH("RawJson") as json_size,
    CASE 
        WHEN "RawJson"::jsonb ? 'excipientes' THEN 'Tiene clave pero vacío'
        ELSE 'No tiene clave'
    END as problema
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL 
  AND "RawJson" != ''
  AND (
      NOT ("RawJson"::jsonb ? 'excipientes')
      OR jsonb_array_length(("RawJson"::jsonb->'excipientes') = 0
  )
LIMIT 10;

-- 5. VERIFICAR EXISTENCIA DE TABLAS DE RESPALDO
-- ============================================================================
SELECT 
    table_name,
    CASE 
        WHEN table_name LIKE '%PrincipioActivo%' THEN 'RESPALDO PA'
        WHEN table_name LIKE '%Excipiente%' THEN 'RESPALDO EXC'
        WHEN table_name LIKE '%Presentacion%' THEN 'RESPALDO PRES'
        WHEN table_name LIKE '%Via%' THEN 'RESPALDO VIA'
        WHEN table_name LIKE '%Atc%' THEN 'RESPALDO ATC'
        ELSE 'OTRO'
    END as tipo_respaldo,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as num_columnas
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
  AND (
      table_name LIKE '%PrincipioActivo%'
      OR table_name LIKE '%Excipiente%'
      OR table_name LIKE '%Presentacion%'
      OR table_name LIKE '%Via%'
      OR table_name LIKE '%Atc%'
      OR table_name LIKE '%Sustancia%'
  )
ORDER BY tipo_respaldo, table_name;

-- 6. COMPARAR JSON VS TABLAS NORMALIZADAS - PRINCIPIOS ACTIVOS
-- ============================================================================
SELECT 
    'En JSON pero no en grafo' as situacion,
    COUNT(DISTINCT m."NRegistro") as cantidad_medicamentos
FROM "Medicamentos" m
WHERE m."RawJson"::jsonb ? 'principiosActivos'
  AND jsonb_array_length((m."RawJson"::jsonb)->'principiosActivos') > 0
  AND NOT EXISTS (
      SELECT 1 FROM graph_edge ge
      WHERE ge.src_type = 'Medicamento'
        AND ge.src_key = m."NRegistro"
        AND ge.rel = 'CONTIENE_PA'
  )
UNION ALL
SELECT 
    'En grafo pero no en JSON' as situacion,
    COUNT(DISTINCT ge.src_key) as cantidad_medicamentos
FROM graph_edge ge
WHERE ge.src_type = 'Medicamento'
  AND ge.rel = 'CONTIENE_PA'
  AND NOT EXISTS (
      SELECT 1 FROM "Medicamentos" m
      WHERE m."NRegistro" = ge.src_key
        AND m."RawJson"::jsonb ? 'principiosActivos'
        AND jsonb_array_length((m."RawJson"::jsonb)->'principiosActivos') > 0
  );

-- 7. COMPARAR JSON VS TABLAS NORMALIZADAS - EXCIPIENTES
-- ============================================================================
SELECT 
    'En JSON pero no en grafo' as situacion,
    COUNT(DISTINCT m."NRegistro") as cantidad_medicamentos
FROM "Medicamentos" m
WHERE m."RawJson"::jsonb ? 'excipientes'
  AND jsonb_array_length((m."RawJson"::jsonb)->'excipientes') > 0
  AND NOT EXISTS (
      SELECT 1 FROM graph_edge ge
      WHERE ge.src_type = 'Medicamento'
        AND ge.src_key = m."NRegistro"
        AND ge.rel = 'CONTIENE_EXCIPIENTE'
  )
UNION ALL
SELECT 
    'En grafo pero no en JSON' as situacion,
    COUNT(DISTINCT ge.src_key) as cantidad_medicamentos
FROM graph_edge ge
WHERE ge.src_type = 'Medicamento'
  AND ge.rel = 'CONTIENE_EXCIPIENTE'
  AND NOT EXISTS (
      SELECT 1 FROM "Medicamentos" m
      WHERE m."NRegistro" = ge.src_key
        AND m."RawJson"::jsonb ? 'excipientes'
        AND jsonb_array_length((m."RawJson"::jsonb)->'excipientes') > 0
  );

-- 8. DETALLE DE MEDICAMENTOS PROBLEMÁTICOS (SIN PA NI EXC EN JSON)
-- ============================================================================
SELECT 
    m."NRegistro",
    m."Nombre",
    m."LabTitular",
    LENGTH(m."RawJson") as json_size_bytes,
    CASE WHEN m."RawJson"::jsonb ? 'principiosActivos' THEN 'SI' ELSE 'NO' END as tiene_clave_pa,
    CASE WHEN m."RawJson"::jsonb ? 'excipientes' THEN 'SI' ELSE 'NO' END as tiene_clave_exc,
    (SELECT COUNT(*) FROM graph_edge WHERE src_type = 'Medicamento' AND src_key = m."NRegistro" AND rel = 'CONTIENE_PA') as pa_en_grafo,
    (SELECT COUNT(*) FROM graph_edge WHERE src_type = 'Medicamento' AND src_key = m."NRegistro" AND rel = 'CONTIENE_EXCIPIENTE') as exc_en_grafo
FROM "Medicamentos" m
WHERE m."RawJson" IS NOT NULL
  AND m."RawJson" != ''
  AND (
      NOT (m."RawJson"::jsonb ? 'principiosActivos')
      OR NOT (m."RawJson"::jsonb ? 'excipientes')
  )
LIMIT 20;

-- 9. RESUMEN EJECUTIVO
-- ============================================================================
SELECT 
    'Medicamentos totales' as metrica,
    COUNT(*) as cantidad
FROM "Medicamentos"
UNION ALL
SELECT 
    'Con RawJson completo',
    COUNT(*)
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL AND "RawJson" != ''
UNION ALL
SELECT 
    'Con PA en JSON',
    COUNT(*)
FROM "Medicamentos"
WHERE "RawJson"::jsonb ? 'principiosActivos'
  AND jsonb_array_length(("RawJson"::jsonb)->'principiosActivos') > 0
UNION ALL
SELECT 
    'Con Excipientes en JSON',
    COUNT(*)
FROM "Medicamentos"
WHERE "RawJson"::jsonb ? 'excipientes'
  AND jsonb_array_length(("RawJson"::jsonb)->'excipientes') > 0
UNION ALL
SELECT 
    'Con PA en Grafo',
    COUNT(DISTINCT src_key)
FROM graph_edge
WHERE src_type = 'Medicamento' AND rel = 'CONTIENE_PA'
UNION ALL
SELECT 
    'Con Excipientes en Grafo',
    COUNT(DISTINCT src_key)
FROM graph_edge
WHERE src_type = 'Medicamento' AND rel = 'CONTIENE_EXCIPIENTE';
