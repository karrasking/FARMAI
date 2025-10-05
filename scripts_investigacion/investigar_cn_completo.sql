-- Investigación completa de Código Nacional (CN)

-- 1. Ver estructura de tabla Presentacion
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'Presentacion'
ORDER BY ordinal_position;

-- 2. Contar presentaciones totales con CN
SELECT COUNT(*) as total_presentaciones_con_cn
FROM "Presentacion"
WHERE "CN" IS NOT NULL AND "CN" != '';

-- 3. Ver ejemplos de CNs
SELECT "CN"
FROM "Presentacion"
LIMIT 10;

-- 4. Ver cuántos medicamentos tienen presentaciones con CN
SELECT COUNT(DISTINCT m."NRegistro") as medicamentos_con_cn
FROM "Medicamentos" m
WHERE EXISTS (
    SELECT 1 
    FROM "Presentacion" p
    WHERE m."RawJson"::text LIKE '%"cn":"' || p."CN" || '"%'
);

-- 5. Buscar un medicamento por CN (ejemplo)
SELECT 
    m."NRegistro",
    m."Nombre",
    p."CN"
FROM "Medicamentos" m
CROSS JOIN "Presentacion" p
WHERE m."RawJson"::text LIKE '%"cn":"' || p."CN" || '"%'
  AND p."CN" = '659726'
LIMIT 5;

-- 6. Ver CNs directamente del JSON de un medicamento
SELECT 
    "NRegistro",
    "Nombre",
    "RawJson"::jsonb->'presentaciones'->0->'cn' as primer_cn,
    jsonb_array_length("RawJson"::jsonb->'presentaciones') as num_presentaciones
FROM "Medicamentos"
WHERE "RawJson"::jsonb->'presentaciones' IS NOT NULL
LIMIT 10;

-- 7. Contar medicamentos que tienen presentaciones en JSON
SELECT COUNT(*) as meds_con_presentaciones_json
FROM "Medicamentos"
WHERE "RawJson"::jsonb->'presentaciones' IS NOT NULL;

-- 8. Ver todos los CNs de un medicamento específico (ejemplo ibuprofeno)
SELECT 
    m."NRegistro",
    m."Nombre",
    jsonb_array_elements(m."RawJson"::jsonb->'presentaciones')->>'cn' as cn
FROM "Medicamentos" m
WHERE m."Nombre" ILIKE '%IBUPROFENO NORMON 600%'
LIMIT 20;

-- 9. Intentar buscar por CN parcial
SELECT COUNT(*) as resultados_cn_parcial
FROM "Medicamentos"
WHERE "RawJson"::text LIKE '%"cn":"65972%';

-- 10. Ver patrón de CN en JSON
SELECT 
    "NRegistro",
    "Nombre",
    substring("RawJson"::text from '"cn":"([0-9]+)"' for 100) as patron_cn
FROM "Medicamentos"
WHERE "RawJson"::text LIKE '%"cn":"%'
LIMIT 10;
