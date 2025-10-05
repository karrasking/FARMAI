-- Investigar qué campos JSON están disponibles
-- ================================================

-- 1. Verificar campos JSON en tabla Medicamentos
SELECT 
    COUNT(*) as total,
    COUNT("RawJson") as con_rawjson,
    COUNT("RawJsonDetalle") as con_rawjsondetalle,
    COUNT(CASE WHEN "RawJson" IS NOT NULL AND "RawJson"::text != '' THEN 1 END) as rawjson_no_vacio,
    COUNT(CASE WHEN "RawJsonDetalle" IS NOT NULL AND "RawJsonDetalle"::text != '' THEN 1 END) as rawjsondetalle_no_vacio
FROM "Medicamentos";

-- 2. Ver sample de RawJson (si existe)
SELECT 
    "NRegistro",
    "Nombre",
    substring("RawJson"::text, 1, 200) as rawjson_preview
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL 
  AND "RawJson"::text != ''
LIMIT 3;

-- 3. Buscar campo "materiales" en RawJson
SELECT 
    COUNT(*) as meds_con_rawjson,
    COUNT(CASE WHEN "RawJson"::text LIKE '%materiales%' THEN 1 END) as con_materiales_en_text
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL 
  AND "RawJson"::text != '';

-- 4. Ver medicamento completo de ejemplo (OZEMPIC)
SELECT 
    "NRegistro",
    "Nombre",
    "LabTitular",
    "RawJson" IS NOT NULL as tiene_rawjson,
    "RawJsonDetalle" IS NOT NULL as tiene_rawjsondetalle,
    length("RawJson"::text) as tam_rawjson
FROM "Medicamentos"
WHERE "Nombre" LIKE '%OZEMPIC%'
LIMIT 1;
