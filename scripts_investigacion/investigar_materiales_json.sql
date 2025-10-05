-- FASE 6: INVESTIGAR MATERIALES INFORMATIVOS
-- =====================================================
-- Objetivo: Analizar el campo 'materiales' en RawJsonDetalle

-- 1. Contar cuántos medicamentos tienen materiales
SELECT 
    COUNT(*) as total_medicamentos,
    COUNT(CASE WHEN "RawJsonDetalle" IS NOT NULL THEN 1 END) as con_json,
    COUNT(CASE WHEN "RawJsonDetalle"::text LIKE '%"materiales"%' THEN 1 END) as con_campo_materiales,
    ROUND(100.0 * COUNT(CASE WHEN "RawJsonDetalle"::text LIKE '%"materiales"%' THEN 1 END) / COUNT(*), 2) as porcentaje
FROM "Medicamentos";

-- 2. Ver sample de medicamentos CON materiales
SELECT 
    "NRegistro",
    "Nombre",
    "RawJsonDetalle"::jsonb -> 'materiales' as materiales
FROM "Medicamentos"
WHERE "RawJsonDetalle"::text LIKE '%"materiales"%'
  AND "RawJsonDetalle"::jsonb -> 'materiales' IS NOT NULL
  AND jsonb_array_length("RawJsonDetalle"::jsonb -> 'materiales') > 0
LIMIT 5;

-- 3. Contar total de materiales
SELECT 
    COUNT(*) as medicamentos_con_materiales,
    SUM(jsonb_array_length("RawJsonDetalle"::jsonb -> 'materiales')) as total_materiales,
    ROUND(AVG(jsonb_array_length("RawJsonDetalle"::jsonb -> 'materiales')), 2) as promedio_materiales_por_med
FROM "Medicamentos"
WHERE "RawJsonDetalle"::text LIKE '%"materiales"%'
  AND "RawJsonDetalle"::jsonb -> 'materiales' IS NOT NULL
  AND jsonb_array_length("RawJsonDetalle"::jsonb -> 'materiales') > 0;

-- 4. Ver estructura completa de UN material
SELECT 
    "NRegistro",
    "Nombre",
    jsonb_pretty("RawJsonDetalle"::jsonb -> 'materiales' -> 0) as primer_material
FROM "Medicamentos"
WHERE "RawJsonDetalle"::text LIKE '%"materiales"%'
  AND "RawJsonDetalle"::jsonb -> 'materiales' IS NOT NULL
  AND jsonb_array_length("RawJsonDetalle"::jsonb -> 'materiales') > 0
LIMIT 1;

-- 5. Investigar tipos de materiales únicos
SELECT 
    jsonb_array_elements("RawJsonDetalle"::jsonb -> 'materiales') ->> 'tipo' as tipo_material,
    COUNT(*) as cantidad
FROM "Medicamentos"
WHERE "RawJsonDetalle"::text LIKE '%"materiales"%'
  AND "RawJsonDetalle"::jsonb -> 'materiales' IS NOT NULL
  AND jsonb_array_length("RawJsonDetalle"::jsonb -> 'materiales') > 0
GROUP BY tipo_material
ORDER BY cantidad DESC;

-- 6. Ver todos los campos de materiales
SELECT DISTINCT
    jsonb_object_keys(jsonb_array_elements("RawJsonDetalle"::jsonb -> 'materiales')) as campo
FROM "Medicamentos"
WHERE "RawJsonDetalle"::text LIKE '%"materiales"%'
  AND "RawJsonDetalle"::jsonb -> 'materiales' IS NOT NULL
  AND jsonb_array_length("RawJsonDetalle"::jsonb -> 'materiales') > 0;
