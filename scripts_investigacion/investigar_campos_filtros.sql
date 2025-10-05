-- Investigar campos disponibles para filtros

-- 1. Ver todas las columnas de Medicamentos
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'Medicamentos'
ORDER BY ordinal_position;

-- 2. Buscar medicamentos con campo cpresc en JSON
SELECT 
    "NRegistro",
    "Nombre",
    ("RawJson"::jsonb -> 'cpresc') as condicion_prescripcion,
    ("RawJson"::jsonb -> 'cpresc' ->> 'nombre') as cpresc_nombre
FROM "Medicamentos"
WHERE ("RawJson"::jsonb -> 'cpresc') IS NOT NULL
LIMIT 10;

-- 3. Contar medicamentos por condición de prescripción
SELECT 
    ("RawJson"::jsonb -> 'cpresc' ->> 'nombre') as condicion,
    COUNT(*) as total
FROM "Medicamentos"
WHERE ("RawJson"::jsonb -> 'cpresc') IS NOT NULL
GROUP BY ("RawJson"::jsonb -> 'cpresc' ->> 'nombre')
ORDER BY total DESC;

-- 4. Verificar estadísticas de los campos que ya tenemos
SELECT 
    'Comercializado' as campo,
    COUNT(*) FILTER (WHERE "Comercializado" = true) as "true",
    COUNT(*) FILTER (WHERE "Comercializado" = false) as "false",
    COUNT(*) FILTER (WHERE "Comercializado" IS NULL) as "null"
FROM "Medicamentos"
UNION ALL
SELECT 
    'Biosimilar',
    COUNT(*) FILTER (WHERE "Biosimilar" = true),
    COUNT(*) FILTER (WHERE "Biosimilar" = false),
    COUNT(*) FILTER (WHERE "Biosimilar" IS NULL)
FROM "Medicamentos";
