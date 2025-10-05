-- Comparar cobertura de datos JSON vs Tablas Relacionales
-- Objetivo: Ver dónde vale la pena implementar fallback

-- 1. RESUMEN GENERAL: Comparar JSON vs Tablas
SELECT 
    'Principios Activos' as entidad,
    COUNT(DISTINCT "NRegistro") FILTER (WHERE "RawJson"::jsonb -> 'principiosActivos' IS NOT NULL 
        AND jsonb_array_length("RawJson"::jsonb -> 'principiosActivos') > 0) as con_json,
    (SELECT COUNT(DISTINCT "NRegistro") FROM "MedicamentoSustancia") as con_tabla,
    COUNT(*) as total_meds
FROM "Medicamentos"
UNION ALL
SELECT 
    'Excipientes',
    COUNT(DISTINCT "NRegistro") FILTER (WHERE "RawJson"::jsonb -> 'excipientes' IS NOT NULL 
        AND jsonb_array_length("RawJson"::jsonb -> 'excipientes') > 0),
    (SELECT COUNT(DISTINCT "NRegistro") FROM "MedicamentoExcipiente"),
    COUNT(*)
FROM "Medicamentos"
UNION ALL
SELECT 
    'ATCs',
    COUNT(DISTINCT "NRegistro") FILTER (WHERE "RawJson"::jsonb -> 'atcs' IS NOT NULL 
        AND jsonb_array_length("RawJson"::jsonb -> 'atcs') > 0),
    0, -- TODO: verificar nombre correcto de tabla
    COUNT(*)
FROM "Medicamentos"
UNION ALL
SELECT 
    'VTM',
    COUNT(DISTINCT "NRegistro") FILTER (WHERE "RawJson"::jsonb -> 'vtm' IS NOT NULL 
        AND "RawJson"::jsonb -> 'vtm' -> 'id' IS NOT NULL),
    0, -- No hay tabla directa
    COUNT(*)
FROM "Medicamentos"
UNION ALL
SELECT 
    'Vías Admin',
    COUNT(DISTINCT "NRegistro") FILTER (WHERE "RawJson"::jsonb -> 'viasAdministracion' IS NOT NULL 
        AND jsonb_array_length("RawJson"::jsonb -> 'viasAdministracion') > 0),
    (SELECT COUNT(DISTINCT "NRegistro") FROM "MedicamentoVia"),
    COUNT(*)
FROM "Medicamentos"
UNION ALL
SELECT 
    'Documentos',
    COUNT(DISTINCT "NRegistro") FILTER (WHERE "RawJson"::jsonb -> 'docs' IS NOT NULL 
        AND jsonb_array_length("RawJson"::jsonb -> 'docs') > 0),
    (SELECT COUNT(DISTINCT "NRegistro") FROM "Documento"),
    COUNT(*)
FROM "Medicamentos"
UNION ALL
SELECT 
    'Presentaciones',
    COUNT(DISTINCT "NRegistro") FILTER (WHERE "RawJson"::jsonb -> 'presentaciones' IS NOT NULL 
        AND jsonb_array_length("RawJson"::jsonb -> 'presentaciones') > 0),
    (SELECT COUNT(DISTINCT "NRegistro") FROM "Presentacion"),
    COUNT(*)
FROM "Medicamentos";

-- 2. Identificar medicamentos SIN datos en JSON pero CON datos en tabla
-- Principios Activos
SELECT 'PAs sin JSON pero con tabla' as caso, COUNT(*) as cantidad
FROM (
    SELECT DISTINCT ms."NRegistro"
    FROM "MedicamentoSustancia" ms
    LEFT JOIN "Medicamentos" m ON ms."NRegistro" = m."NRegistro"
    WHERE m."RawJson"::jsonb -> 'principiosActivos' IS NULL
       OR jsonb_array_length(m."RawJson"::jsonb -> 'principiosActivos') = 0
) sub;

-- Excipientes
SELECT 'Excipientes sin JSON pero con tabla' as caso, COUNT(*) as cantidad
FROM (
    SELECT DISTINCT me."NRegistro"
    FROM "MedicamentoExcipiente" me
    LEFT JOIN "Medicamentos" m ON me."NRegistro" = m."NRegistro"
    WHERE m."RawJson"::jsonb -> 'excipientes' IS NULL
       OR jsonb_array_length(m."RawJson"::jsonb -> 'excipientes') = 0
) sub;

-- Vías
SELECT 'Vías sin JSON pero con tabla' as caso, COUNT(*) as cantidad
FROM (
    SELECT DISTINCT mv."NRegistro"
    FROM "MedicamentoVia" mv
    LEFT JOIN "Medicamentos" m ON mv."NRegistro" = m."NRegistro"
    WHERE m."RawJson"::jsonb -> 'viasAdministracion' IS NULL
       OR jsonb_array_length(m."RawJson"::jsonb -> 'viasAdministracion') = 0
) sub;

-- Documentos
SELECT 'Documentos sin JSON pero con tabla' as caso, COUNT(*) as cantidad
FROM (
    SELECT DISTINCT d."NRegistro"
    FROM "Documento" d
    LEFT JOIN "Medicamentos" m ON d."NRegistro" = m."NRegistro"
    WHERE m."RawJson"::jsonb -> 'docs' IS NULL
       OR jsonb_array_length(m."RawJson"::jsonb -> 'docs') = 0
) sub;

-- 3. Identificar medicamentos CON JSON pero SIN tabla (casos raros)
SELECT 'PAs con JSON pero sin tabla' as caso, COUNT(*) as cantidad
FROM (
    SELECT m."NRegistro"
    FROM "Medicamentos" m
    WHERE m."RawJson"::jsonb -> 'principiosActivos' IS NOT NULL
      AND jsonb_array_length(m."RawJson"::jsonb -> 'principiosActivos') > 0
      AND NOT EXISTS (
          SELECT 1 FROM "MedicamentoSustancia" ms 
          WHERE ms."NRegistro" = m."NRegistro"
      )
) sub;

SELECT 'Excipientes con JSON pero sin tabla' as caso, COUNT(*) as cantidad
FROM (
    SELECT m."NRegistro"
    FROM "Medicamentos" m
    WHERE m."RawJson"::jsonb -> 'excipientes' IS NOT NULL
      AND jsonb_array_length(m."RawJson"::jsonb -> 'excipientes') > 0
      AND NOT EXISTS (
          SELECT 1 FROM "MedicamentoExcipiente" me 
          WHERE me."NRegistro" = m."NRegistro"
      )
) sub;

-- 4. Ejemplos de medicamentos que se beneficiarían del fallback
SELECT 
    'Ejemplos necesitan fallback PA' as tipo,
    m."NRegistro",
    m."Nombre",
    (SELECT COUNT(*) FROM "MedicamentoSustancia" ms WHERE ms."NRegistro" = m."NRegistro") as pas_en_tabla
FROM "Medicamentos" m
WHERE (m."RawJson"::jsonb -> 'principiosActivos' IS NULL
   OR jsonb_array_length(m."RawJson"::jsonb -> 'principiosActivos') = 0)
  AND EXISTS (SELECT 1 FROM "MedicamentoSustancia" ms WHERE ms."NRegistro" = m."NRegistro")
LIMIT 5;

SELECT 
    'Ejemplos necesitan fallback Excipientes' as tipo,
    m."NRegistro",
    m."Nombre",
    (SELECT COUNT(*) FROM "MedicamentoExcipiente" me WHERE me."NRegistro" = m."NRegistro") as excs_en_tabla
FROM "Medicamentos" m
WHERE (m."RawJson"::jsonb -> 'excipientes' IS NULL
   OR jsonb_array_length(m."RawJson"::jsonb -> 'excipientes') = 0)
  AND EXISTS (SELECT 1 FROM "MedicamentoExcipiente" me WHERE me."NRegistro" = m."NRegistro")
LIMIT 5;

-- 5. Porcentajes de cobertura
SELECT 
    'COBERTURA %' as metrica,
    ROUND(100.0 * COUNT(*) FILTER (WHERE "RawJson"::jsonb -> 'principiosActivos' IS NOT NULL) / COUNT(*), 2) as pa_json_pct,
    ROUND(100.0 * (SELECT COUNT(DISTINCT "NRegistro") FROM "MedicamentoSustancia") / COUNT(*), 2) as pa_tabla_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE "RawJson"::jsonb -> 'viasAdministracion' IS NOT NULL) / COUNT(*), 2) as via_json_pct,
    ROUND(100.0 * (SELECT COUNT(DISTINCT "NRegistro") FROM "MedicamentoVia") / COUNT(*), 2) as via_tabla_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE "RawJson"::jsonb -> 'docs' IS NOT NULL) / COUNT(*), 2) as doc_json_pct,
    ROUND(100.0 * (SELECT COUNT(DISTINCT "NRegistro") FROM "Documento") / COUNT(*), 2) as doc_tabla_pct
FROM "Medicamentos";
