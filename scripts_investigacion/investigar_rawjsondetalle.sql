-- Investigar campo RawJsonDetalle

-- 1. Ver RawJsonDetalle de OZEMPIC
SELECT 
    "NRegistro",
    "Nombre",
    "RawJsonDetalle"
FROM "Medicamentos"
WHERE "Nombre" LIKE '%OZEMPIC%'
LIMIT 1;

-- 2. Contar cuántos tienen RawJsonDetalle no vacío
SELECT 
    COUNT(*) as total,
    COUNT(CASE WHEN "RawJsonDetalle" IS NOT NULL AND "RawJsonDetalle"::text != '{}' THEN 1 END) as con_detalle,
    COUNT(CASE WHEN "RawJsonDetalle"::text LIKE '%docs%' THEN 1 END) as con_docs_en_detalle
FROM "Medicamentos";

-- 3. Ver si RawJsonDetalle tiene URLs
SELECT 
    "NRegistro",
    "Nombre",
    CASE WHEN "RawJsonDetalle"::text LIKE '%urlHtmlFichaTecnica%' THEN 'Tiene FT' ELSE 'No FT' END as ft,
    CASE WHEN "RawJsonDetalle"::text LIKE '%urlHtmlProspecto%' THEN 'Tiene P' ELSE 'No P' END as p
FROM "Medicamentos"
WHERE "Nombre" LIKE '%OZEMPIC%'
LIMIT 1;
