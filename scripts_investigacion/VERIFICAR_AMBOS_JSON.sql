-- VERIFICAR AMBOS CAMPOS JSON
-- ==============================

-- 1. Estado de RawJson
SELECT 
    'RawJson' as campo,
    COUNT(*) as total,
    COUNT(CASE WHEN "RawJson" IS NOT NULL AND "RawJson"::text != '{}' THEN 1 END) as con_datos,
    COUNT(CASE WHEN "RawJson" IS NULL OR "RawJson"::text = '{}' THEN 1 END) as vacio_o_null
FROM "Medicamentos";

-- 2. Estado de RawJsonDetalle
SELECT 
    'RawJsonDetalle' as campo,
    COUNT(*) as total,
    COUNT(CASE WHEN "RawJsonDetalle" IS NOT NULL AND "RawJsonDetalle"::text != '{}' THEN 1 END) as con_datos,
    COUNT(CASE WHEN "RawJsonDetalle" IS NULL OR "RawJsonDetalle"::text = '{}' THEN 1 END) as vacio_o_null
FROM "Medicamentos";

-- 3. Ver medicamento con AMBOS JSON
SELECT 
    "NRegistro",
    "Nombre",
    LENGTH("RawJson"::text) as tamaño_rawjson,
    LENGTH("RawJsonDetalle"::text) as tamaño_rawjsondetalle
FROM "Medicamentos"
WHERE "NRegistro" = 'BE114572'  -- DIANE 35 que estaba "vacío"
LIMIT 1;

-- 4. Ver contenido de ambos JSON de ese medicamento
SELECT 
    "NRegistro",
    "RawJson",
    "RawJsonDetalle"
FROM "Medicamentos"
WHERE "NRegistro" = 'BE114572'
LIMIT 1;
