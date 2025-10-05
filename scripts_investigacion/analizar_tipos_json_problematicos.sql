-- Script para investigar tipos de datos problemáticos en RawJson
-- Objetivo: Entender qué valores causan el error de parsing

-- 1. Analizar estructura de ATCs
WITH atc_analysis AS (
    SELECT 
        "NRegistro",
        jsonb_array_elements("RawJson"::jsonb -> 'atcs') as atc_item
    FROM "Medicamentos"
    WHERE "RawJson" IS NOT NULL 
      AND "RawJson" != '{}'
      AND "RawJson"::jsonb -> 'atcs' IS NOT NULL
    LIMIT 1000
)
SELECT 
    'ATCs' as campo,
    jsonb_typeof(atc_item -> 'id') as tipo_id,
    jsonb_typeof(atc_item -> 'nivel') as tipo_nivel,
    COUNT(*) as cantidad,
    MIN(atc_item -> 'id') as ejemplo_id,
    MIN(atc_item -> 'nivel') as ejemplo_nivel
FROM atc_analysis
GROUP BY jsonb_typeof(atc_item -> 'id'), jsonb_typeof(atc_item -> 'nivel')
ORDER BY cantidad DESC;

-- 2. Analizar VTM
SELECT 
    'VTM' as campo,
    jsonb_typeof("RawJson"::jsonb -> 'vtm' -> 'id') as tipo_id,
    COUNT(*) as cantidad,
    MIN("RawJson"::jsonb -> 'vtm' -> 'id') as ejemplo
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL 
  AND "RawJson" != '{}'
  AND "RawJson"::jsonb -> 'vtm' IS NOT NULL
GROUP BY jsonb_typeof("RawJson"::jsonb -> 'vtm' -> 'id')
ORDER BY cantidad DESC;

-- 3. Analizar Vías de Administración
WITH via_analysis AS (
    SELECT 
        "NRegistro",
        jsonb_array_elements("RawJson"::jsonb -> 'viasAdministracion') as via_item
    FROM "Medicamentos"
    WHERE "RawJson" IS NOT NULL 
      AND "RawJson" != '{}'
      AND "RawJson"::jsonb -> 'viasAdministracion' IS NOT NULL
    LIMIT 1000
)
SELECT 
    'Vías Admin' as campo,
    jsonb_typeof(via_item -> 'id') as tipo_id,
    COUNT(*) as cantidad,
    MIN(via_item -> 'id') as ejemplo
FROM via_analysis
GROUP BY jsonb_typeof(via_item -> 'id')
ORDER BY cantidad DESC;

-- 4. Analizar Principios Activos
WITH pa_analysis AS (
    SELECT 
        "NRegistro",
        jsonb_array_elements("RawJson"::jsonb -> 'principiosActivos') as pa_item
    FROM "Medicamentos"
    WHERE "RawJson" IS NOT NULL 
      AND "RawJson" != '{}'
      AND "RawJson"::jsonb -> 'principiosActivos' IS NOT NULL
    LIMIT 1000
)
SELECT 
    'Principios Activos' as campo,
    jsonb_typeof(pa_item -> 'id') as tipo_id,
    COUNT(*) as cantidad,
    MIN(pa_item -> 'id') as ejemplo
FROM pa_analysis
GROUP BY jsonb_typeof(pa_item -> 'id')
ORDER BY cantidad DESC;

-- 5. Analizar Excipientes
WITH exc_analysis AS (
    SELECT 
        "NRegistro",
        jsonb_array_elements("RawJson"::jsonb -> 'excipientes') as exc_item
    FROM "Medicamentos"
    WHERE "RawJson" IS NOT NULL 
      AND "RawJson" != '{}'
      AND "RawJson"::jsonb -> 'excipientes' IS NOT NULL
    LIMIT 1000
)
SELECT 
    'Excipientes' as campo,
    jsonb_typeof(exc_item -> 'id') as tipo_id,
    jsonb_typeof(exc_item -> 'orden') as tipo_orden,
    COUNT(*) as cantidad,
    MIN(exc_item -> 'id') as ejemplo_id,
    MIN(exc_item -> 'orden') as ejemplo_orden
FROM exc_analysis
GROUP BY jsonb_typeof(exc_item -> 'id'), jsonb_typeof(exc_item -> 'orden')
ORDER BY cantidad DESC;

-- 6. Buscar casos específicos de strings donde esperamos números
WITH problematic_cases AS (
    SELECT 
        "NRegistro",
        "Nombre",
        CASE 
            WHEN jsonb_typeof("RawJson"::jsonb -> 'vtm' -> 'id') = 'string' THEN 'VTM.id es string'
            WHEN EXISTS (
                SELECT 1 FROM jsonb_array_elements("RawJson"::jsonb -> 'atcs') as atc
                WHERE jsonb_typeof(atc -> 'nivel') = 'string'
            ) THEN 'ATC.nivel es string'
            WHEN EXISTS (
                SELECT 1 FROM jsonb_array_elements("RawJson"::jsonb -> 'viasAdministracion') as via
                WHERE jsonb_typeof(via -> 'id') = 'string'
            ) THEN 'Via.id es string'
            ELSE 'OK'
        END as problema
    FROM "Medicamentos"
    WHERE "RawJson" IS NOT NULL 
      AND "RawJson" != '{}'
)
SELECT 
    problema,
    COUNT(*) as cantidad,
    MIN("NRegistro") as ejemplo_nregistro,
    MIN("Nombre") as ejemplo_nombre
FROM problematic_cases
WHERE problema != 'OK'
GROUP BY problema
ORDER BY cantidad DESC;

-- 7. Resumen general
SELECT 
    'Total medicamentos' as metrica,
    COUNT(*) as valor
FROM "Medicamentos"
UNION ALL
SELECT 
    'Con RawJson no vacío',
    COUNT(*)
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL AND "RawJson" != '{}'
UNION ALL
SELECT 
    'Con ATCs',
    COUNT(*)
FROM "Medicamentos"
WHERE "RawJson"::jsonb -> 'atcs' IS NOT NULL
UNION ALL
SELECT 
    'Con VTM',
    COUNT(*)
FROM "Medicamentos"
WHERE "RawJson"::jsonb -> 'vtm' IS NOT NULL;
