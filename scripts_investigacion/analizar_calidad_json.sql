-- Analizar calidad de los JSON que tenemos

-- 1. JSON vacíos
SELECT 
    'JSON vacíos {}' as tipo,
    COUNT(*) as cantidad
FROM "MedicamentoDetalleRaw"
WHERE "Json"::text = '{}';

-- 2. JSON con contenido pero sin docs
SELECT 
    'JSON completo SIN docs' as tipo,
    COUNT(*) as cantidad
FROM "MedicamentoDetalleRaw"
WHERE "Json"::text != '{}'
  AND "Json"::text NOT LIKE '%"docs"%';

-- 3. JSON con docs
SELECT 
    'JSON CON docs' as tipo,
    COUNT(*) as cantidad
FROM "MedicamentoDetalleRaw"
WHERE "Json"::text LIKE '%"docs"%';

-- 4. Ver un ejemplo de JSON completo SIN docs
SELECT 
    "NRegistro",
    LENGTH("Json"::text) as tam,
    "Json"::text LIKE '%nregistro%' as tiene_nreg,
    "Json"::text LIKE '%nombre%' as tiene_nombre,
    "Json"::text LIKE '%docs%' as tiene_docs
FROM "MedicamentoDetalleRaw"
WHERE "Json"::text != '{}'
  AND "Json"::text NOT LIKE '%"docs"%'
LIMIT 5;
