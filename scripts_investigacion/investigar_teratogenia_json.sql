-- INVESTIGACIÓN TERATOGENIA EN JSON DE CIMA

-- 1. Ver sample de JSON completo
SELECT 
    "NRegistro",
    "Json"
FROM "MedicamentoDetalleRaw"
LIMIT 1;

-- 2. Buscar menciones de embarazo/lactancia en JSON
SELECT 
    COUNT(*) as "Total",
    COUNT(*) FILTER (WHERE "Json"::text ILIKE '%embarazo%') as "ConEmbarazo",
    COUNT(*) FILTER (WHERE "Json"::text ILIKE '%lactancia%') as "ConLactancia",
    COUNT(*) FILTER (WHERE "Json"::text ILIKE '%terato%') as "ConTeratogenia",
    COUNT(*) FILTER (WHERE "Json"::text ILIKE '%gestacion%') as "ConGestacion"
FROM "MedicamentoDetalleRaw";

-- 3. Ver keys disponibles en JSON
SELECT DISTINCT jsonb_object_keys("Json")
FROM "MedicamentoDetalleRaw"
LIMIT 20;

-- 4. Sample de medicamento con mención de embarazo
SELECT 
    "NRegistro",
    "Json"->>'nombre' as "Nombre",
    "Json"
FROM "MedicamentoDetalleRaw"
WHERE "Json"::text ILIKE '%embarazo%'
LIMIT 1;
