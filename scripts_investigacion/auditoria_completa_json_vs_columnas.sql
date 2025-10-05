-- AUDITORÍA COMPLETA: JSON vs COLUMNAS DE LA TABLA
-- ====================================================
-- Verificar qué campos del JSON están o NO están propagados a columnas

-- 1. Ver un JSON completo para saber QUÉ CAMPOS TIENE
SELECT 
    "NRegistro",
    "Nombre",
    jsonb_object_keys("RawJson"::jsonb) as json_keys
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL 
  AND "RawJson"::text != '{}'
LIMIT 1;

-- 2. Ver un JSON COMPLETO para análisis manual
SELECT 
    "NRegistro",
    "Nombre",
    jsonb_pretty("RawJson"::jsonb) as json_completo
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL 
  AND "RawJson"::text != '{}'
LIMIT 1;

-- 3. MAPEO DE CAMPOS JSON → COLUMNAS TABLA
-- =========================================
-- Listar todos los campos que SÍ están propagados:

SELECT 'CAMPOS PROPAGADOS' as tipo, campo_json, columna_tabla, 'SI' as propagado
FROM (VALUES
    ('nregistro', 'NRegistro'),
    ('nombre', 'Nombre'),
    ('labtitular', 'Laboratorio'),
    ('cpresc', 'Comercializado'),
    ('conduc', 'AfectaConduccion'),
    ('triangulo', 'TrianguloNegro'),
    ('huerfano', 'Huerfano'),
    ('biosimilar', 'Biosimilar'),
    ('psum', 'Psum'),
    ('fotos', 'Fotos'),
    ('materialesInf', 'MaterialesInformativos')
) AS mapped(campo_json, columna_tabla);

-- 4. CONTAR VALORES ÚNICOS en campos del JSON que podrían no estar propagados
SELECT 
    'commercialised' as campo,
    COUNT(DISTINCT "RawJson"::jsonb ->> 'commercialised') as valores_unicos,
    array_agg(DISTINCT "RawJson"::jsonb ->> 'commercialised') as valores
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL AND "RawJson"::text != '{}'
UNION ALL
SELECT 
    'ema',
    COUNT(DISTINCT "RawJson"::jsonb ->> 'ema'),
    array_agg(DISTINCT "RawJson"::jsonb ->> 'ema')
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL AND "RawJson"::text != '{}'
UNION ALL
SELECT 
    'notas',
    COUNT(DISTINCT "RawJson"::jsonb ->> 'notas'),
    array_agg(DISTINCT "RawJson"::jsonb ->> 'notas')
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL AND "RawJson"::text != '{}'
UNION ALL
SELECT 
    'receta',
    COUNT(DISTINCT "RawJson"::jsonb ->> 'receta'),
    array_agg(DISTINCT "RawJson"::jsonb ->> 'receta')
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL AND "RawJson"::text != '{}'
UNION ALL
SELECT 
    'generico',
    COUNT(DISTINCT "RawJson"::jsonb ->> 'generico'),
    array_agg(DISTINCT "RawJson"::jsonb ->> 'generico')
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL AND "RawJson"::text != '{}'
UNION ALL
SELECT 
    'comerc',
    COUNT(DISTINCT "RawJson"::jsonb ->> 'comerc'),
    array_agg(DISTINCT "RawJson"::jsonb ->> 'comerc')
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL AND "RawJson"::text != '{}'
UNION ALL
SELECT 
    'docs',
    COUNT(DISTINCT ("RawJson"::jsonb -> 'docs')::text),
    ARRAY['[array]']
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL AND "RawJson"::text != '{}';

-- 5. Ver lista de TODOS los campos posibles del JSON
SELECT DISTINCT
    jsonb_object_keys("RawJson"::jsonb) as campo_json,
    COUNT(*) as apariciones
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL 
  AND "RawJson"::text != '{}'
GROUP BY jsonb_object_keys("RawJson"::jsonb)
ORDER BY apariciones DESC;
