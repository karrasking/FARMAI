-- Investigar medicamento 81807 (COULDINA CON IBUPROFENO) en PostgreSQL
-- Este medicamento está causando error de parsing

-- 1. Info básica
SELECT 
    "NRegistro",
    "Nombre",
    CASE 
        WHEN "RawJson" IS NULL THEN 'NULL'
        WHEN "RawJson" = '' OR "RawJson" = '{}' THEN 'EMPTY'
        ELSE 'OK'
    END AS estado_json,
    LENGTH("RawJson") as len_rawjson,
    "LabTitular",
    "Comercializado"
FROM "Medicamentos"
WHERE "NRegistro" = '81807';

-- 2. Ver estructura completa del JSON formateado
SELECT 
    "NRegistro",
    "Nombre",
    jsonb_pretty("RawJson"::jsonb) as json_formateado
FROM "Medicamentos"
WHERE "NRegistro" = '81807';

-- 3. Analizar específicamente los ATCs (donde posiblemente está el error en línea 220)
SELECT 
    "NRegistro",
    jsonb_pretty("RawJson"::jsonb -> 'atcs') as atcs_content,
    jsonb_typeof("RawJson"::jsonb -> 'atcs') as atcs_type,
    jsonb_array_length("RawJson"::jsonb -> 'atcs') as atcs_count
FROM "Medicamentos"
WHERE "NRegistro" = '81807'
  AND "RawJson"::jsonb -> 'atcs' IS NOT NULL;

-- 4. Examinar cada ATC individualmente
WITH atc_items AS (
    SELECT 
        "NRegistro",
        jsonb_array_elements("RawJson"::jsonb -> 'atcs') as atc,
        generate_series(1, jsonb_array_length("RawJson"::jsonb -> 'atcs')) as idx
    FROM "Medicamentos"
    WHERE "NRegistro" = '81807'
)
SELECT 
    idx,
    jsonb_typeof(atc -> 'nivel') as tipo_nivel,
    atc -> 'nivel' as valor_nivel,
    jsonb_typeof(atc -> 'codigo') as tipo_codigo,
    atc -> 'codigo' as valor_codigo,
    jsonb_pretty(atc) as atc_completo
FROM atc_items
ORDER BY idx;

-- 5. Analizar VTM (otra posible fuente de error)
SELECT 
    "NRegistro",
    jsonb_typeof("RawJson"::jsonb -> 'vtm') as vtm_type,
    jsonb_typeof("RawJson"::jsonb -> 'vtm' -> 'id') as vtm_id_type,
    "RawJson"::jsonb -> 'vtm' -> 'id' as vtm_id_value,
    jsonb_pretty("RawJson"::jsonb -> 'vtm') as vtm_content
FROM "Medicamentos"
WHERE "NRegistro" = '81807'
  AND "RawJson"::jsonb -> 'vtm' IS NOT NULL;

-- 6. Analizar vías de administración
SELECT 
    "NRegistro",
    jsonb_array_length("RawJson"::jsonb -> 'viasAdministracion') as vias_count,
    jsonb_pretty("RawJson"::jsonb -> 'viasAdministracion') as vias_content
FROM "Medicamentos"
WHERE "NRegistro" = '81807'
  AND "RawJson"::jsonb -> 'viasAdministracion' IS NOT NULL;

-- 7. Buscar TODOS los campos numéricos en el JSON
SELECT 
    "NRegistro",
    "RawJson"::jsonb -> 'estado' -> 'aut' as fecha_autorizacion,
    jsonb_typeof("RawJson"::jsonb -> 'estado' -> 'aut') as tipo_fecha_aut
FROM "Medicamentos"
WHERE "NRegistro" = '81807';
