-- INVESTIGACIÓN PROFUNDA: PRINCIPIOS ACTIVOS
-- ==============================================
-- Objetivo: Analizar el 2% faltante de PA y ver si son medicamentos descatalogados

-- 1. Estado general de PA en BD
SELECT 
    COUNT(DISTINCT "NRegistro") as total_medicamentos,
    COUNT(DISTINCT CASE WHEN EXISTS (
        SELECT 1 FROM graph_edge ge 
        WHERE ge.source_id = m."NRegistro"::text 
        AND ge.edge_type = 'CONTIENE_PA'
    ) THEN "NRegistro" END) as con_pa_en_grafo,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN EXISTS (
        SELECT 1 FROM graph_edge ge 
        WHERE ge.source_id = m."NRegistro"::text 
        AND ge.edge_type = 'CONTIENE_PA'
    ) THEN "NRegistro" END) / COUNT(DISTINCT "NRegistro"), 2) as porcentaje_cobertura
FROM "Medicamentos" m;

-- 2. Medicamentos SIN PA en grafo - analizados
SELECT 
    m."NRegistro",
    m."Nombre",
    m."LabTitular",
    m."RawJson"::jsonb -> 'principiosActivos' as pas_en_json,
    m."RawJson"::jsonb -> 'estado' ->> 'aut' as fecha_autorizacion,
    m."RawJson"::jsonb -> 'comerc' as comercializado,
    CASE 
        WHEN m."RawJson"::jsonb -> 'principiosActivos' IS NULL THEN 'SIN_PA_EN_JSON'
        WHEN jsonb_array_length(m."RawJson"::jsonb -> 'principiosActivos') = 0 THEN 'ARRAY_VACIO'
        ELSE 'TIENE_PA_EN_JSON'
    END as estado_pa
FROM "Medicamentos" m
WHERE NOT EXISTS (
    SELECT 1 FROM graph_edge ge 
    WHERE ge.source_id = m."NRegistro"::text 
    AND ge.edge_type = 'CONTIENE_PA'
)
LIMIT 20;

-- 3. Contar por motivo de falta de PA
SELECT 
    CASE 
        WHEN m."RawJson"::jsonb -> 'principiosActivos' IS NULL THEN 'SIN_PA_EN_JSON'
        WHEN jsonb_array_length(m."RawJson"::jsonb -> 'principiosActivos') = 0 THEN 'ARRAY_VACIO'
        WHEN NOT EXISTS (
            SELECT 1 FROM graph_edge ge 
            WHERE ge.source_id = m."NRegistro"::text 
            AND ge.edge_type = 'CONTIENE_PA'
        ) THEN 'NO_PROPAGADO_A_GRAFO'
        ELSE 'OK'
    END as motivo,
    COUNT(*) as cantidad
FROM "Medicamentos" m
GROUP BY motivo
ORDER BY cantidad DESC;

-- 4. Ver sample de cada categoría problemática
-- 4a. Sin PA en JSON
SELECT 
    "NRegistro",
    "Nombre",
    "LabTitular",
    "RawJson"::jsonb -> 'comerc' as comercializado
FROM "Medicamentos"
WHERE "RawJson"::jsonb -> 'principiosActivos' IS NULL
LIMIT 5;

-- 4b. Array vacío en JSON
SELECT 
    "NRegistro",
    "Nombre", 
    "LabTitular",
    "RawJson"::jsonb -> 'comerc' as comercializado
FROM "Medicamentos"
WHERE "RawJson"::jsonb -> 'principiosActivos' IS NOT NULL
  AND jsonb_array_length("RawJson"::jsonb -> 'principiosActivos') = 0
LIMIT 5;

-- 5. Verificar si los problemáticos están comercializados
SELECT 
    (m."RawJson"::jsonb ->> 'comerc')::boolean as comercializado,
    COUNT(*) as cantidad,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as porcentaje
FROM "Medicamentos" m
WHERE NOT EXISTS (
    SELECT 1 FROM graph_edge ge 
    WHERE ge.source_id = m."NRegistro"::text 
    AND ge.edge_type = 'CONTIENE_PA'
)
GROUP BY comercializado;
