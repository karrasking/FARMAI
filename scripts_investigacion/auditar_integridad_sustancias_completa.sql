-- AUDITORÍA COMPLETA: Comparar JSON vs Tabla SustanciaActiva

-- 1. Ver todas las tablas relacionadas con sustancias
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name ILIKE '%sustancia%'
ORDER BY table_name;

-- 2. Estructura de SustanciaActiva
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'SustanciaActiva'
ORDER BY ordinal_position;

-- 3. AUDITORÍA: Comparar JSON vs SustanciaActiva
-- Encontrar TODOS los IDs donde el nombre en JSON NO coincide con la tabla
WITH json_pas AS (
    SELECT DISTINCT
        (jsonb_array_elements(m."RawJson"::jsonb -> 'principiosActivos') ->> 'id')::bigint as id_json,
        jsonb_array_elements(m."RawJson"::jsonb -> 'principiosActivos') ->> 'nombre' as nombre_json
    FROM "Medicamentos" m
    WHERE m."RawJson" IS NOT NULL
      AND m."RawJson"::jsonb -> 'principiosActivos' IS NOT NULL
)
SELECT 
    jp.id_json,
    jp.nombre_json as nombre_en_json,
    sa."Nombre" as nombre_en_tabla,
    CASE 
        WHEN jp.nombre_json = sa."Nombre" THEN '✅ OK'
        ELSE '❌ CORRUPTO'
    END as estado
FROM json_pas jp
LEFT JOIN "SustanciaActiva" sa ON jp.id_json = sa."Id"
WHERE jp.nombre_json != sa."Nombre" OR sa."Nombre" IS NULL
ORDER BY jp.id_json
LIMIT 50;

-- 4. Contar total de inconsistencias
WITH json_pas AS (
    SELECT DISTINCT
        (jsonb_array_elements(m."RawJson"::jsonb -> 'principiosActivos') ->> 'id')::bigint as id_json,
        jsonb_array_elements(m."RawJson"::jsonb -> 'principiosActivos') ->> 'nombre' as nombre_json
    FROM "Medicamentos" m
    WHERE m."RawJson" IS NOT NULL
      AND m."RawJson"::jsonb -> 'principiosActivos' IS NOT NULL
)
SELECT 
    COUNT(*) as total_inconsistencias
FROM json_pas jp
LEFT JOIN "SustanciaActiva" sa ON jp.id_json = sa."Id"
WHERE jp.nombre_json != sa."Nombre" OR sa."Nombre" IS NULL;
