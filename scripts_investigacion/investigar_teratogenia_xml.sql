-- INVESTIGACIÓN TERATOGENIA EN XML
-- Verificar si existe información de teratogenia en RawJsonDetalle o prescripción

-- 1. Buscar en MedicamentoDetalleRaw (JSON de API CIMA)
SELECT 
    COUNT(*) as "TotalRegistros",
    COUNT(*) FILTER (WHERE "RawJsonDetalle"::text ILIKE '%terato%') as "ConTeratogenia",
    COUNT(*) FILTER (WHERE "RawJsonDetalle"::text ILIKE '%embarazo%') as "ConEmbarazo",
    COUNT(*) FILTER (WHERE "RawJsonDetalle"::text ILIKE '%lactancia%') as "ConLactancia"
FROM "MedicamentoDetalleRaw";

-- 2. Sample de medicamentos que mencionan embarazo/lactancia
SELECT 
    "NRegistro",
    "RawJsonDetalle"::jsonb->'embarazo' as "InfoEmbarazo",
    "RawJsonDetalle"::jsonb->'lactancia' as "InfoLactancia"
FROM "MedicamentoDetalleRaw"
WHERE "RawJsonDetalle"::text ILIKE '%embarazo%'
   OR "RawJsonDetalle"::text ILIKE '%lactancia%'
LIMIT 5;

-- 3. Buscar en PrescripcionStaging (XML parseado)
SELECT 
    COUNT(*) as "TotalPrescripciones"
FROM "PrescripcionStaging";

-- 4. Ver estructura de un registro de PrescripcionStaging
SELECT 
    column_name,
    data_type,
    character_maximum_length
FROM information_schema.columns
WHERE table_name = 'PrescripcionStaging'
AND column_name ILIKE '%terato%'
   OR column_name ILIKE '%embarazo%'
   OR column_name ILIKE '%lactancia%';

-- 5. Sample de datos en PrescripcionStaging relacionados
SELECT 
    "CN",
    "NRegistro",
    "Nombre"
FROM "PrescripcionStaging"
LIMIT 5;
