-- Analizar los 147 medicamentos que SÍ tienen materiales
-- ========================================================

-- 1. Ver estructura completa de materiales
SELECT 
    "NRegistro",
    "Nombre",
    jsonb_pretty("RawJson"::jsonb -> 'materiales') as materiales_json
FROM "Medicamentos"
WHERE "RawJson"::text LIKE '%"materiales"%'
  AND "RawJson"::jsonb -> 'materiales' IS NOT NULL
LIMIT 2;

-- 2. Contar cuántos materiales hay en total
SELECT 
    COUNT(*) as medicamentos_con_materiales,
    SUM(jsonb_array_length("RawJson"::jsonb -> 'materiales')) as total_materiales,
    ROUND(AVG(jsonb_array_length("RawJson"::jsonb -> 'materiales')), 2) as promedio_por_med,
    MAX(jsonb_array_length("RawJson"::jsonb -> 'materiales')) as max_materiales
FROM "Medicamentos"
WHERE "RawJson"::text LIKE '%"materiales"%'
  AND "RawJson"::jsonb -> 'materiales' IS NOT NULL
  AND jsonb_array_length("RawJson"::jsonb -> 'materiales') > 0;

-- 3. Ver todos los campos de un material
SELECT DISTINCT
    jsonb_object_keys(jsonb_array_elements("RawJson"::jsonb -> 'materiales')) as campo
FROM "Medicamentos"
WHERE "RawJson"::text LIKE '%"materiales"%'
  AND "RawJson"::jsonb -> 'materiales' IS NOT NULL
  AND jsonb_array_length("RawJson"::jsonb -> 'materiales') > 0;

-- 4. Ver tipos de materiales
SELECT 
    jsonb_array_elements("RawJson"::jsonb -> 'materiales') ->> 'tipo' as tipo,
    COUNT(*) as cantidad
FROM "Medicamentos"
WHERE "RawJson"::text LIKE '%"materiales"%'
  AND "RawJson"::jsonb -> 'materiales' IS NOT NULL
  AND jsonb_array_length("RawJson"::jsonb -> 'materiales') > 0
GROUP BY tipo
ORDER BY cantidad DESC;

-- 5. Ver URLs de ejemplo
SELECT 
    m."NRegistro",
    m."Nombre",
    mat ->> 'tipo' as tipo,
    mat ->> 'url' as url,
    mat ->> 'nombreFichero' as nombre_fichero
FROM "Medicamentos" m,
     jsonb_array_elements(m."RawJson"::jsonb -> 'materiales') as mat
WHERE m."RawJson"::text LIKE '%"materiales"%'
  AND m."RawJson"::jsonb -> 'materiales' IS NOT NULL
LIMIT 10;

-- 6. Contar por laboratorio
SELECT 
    "LabTitular",
    COUNT(DISTINCT "NRegistro") as medicamentos_con_materiales
FROM "Medicamentos"
WHERE "RawJson"::text LIKE '%"materiales"%'
  AND "RawJson"::jsonb -> 'materiales' IS NOT NULL
  AND "LabTitular" IS NOT NULL
GROUP BY "LabTitular"
ORDER BY medicamentos_con_materiales DESC
LIMIT 10;
