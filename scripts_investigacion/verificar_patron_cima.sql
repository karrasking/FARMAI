-- Verificar si TODOS los medicamentos pueden tener URLs usando patrón CIMA

-- 1. Ver NRegistro de OZEMPIC
SELECT 
    "NRegistro",
    "Nombre",
    'https://cima.aemps.es/cima/pdfs/ft/' || "NRegistro" || '/FT_' || "NRegistro" || '.pdf' as url_ft_construida,
    'https://cima.aemps.es/cima/pdfs/p/' || "NRegistro" || '/P_' || "NRegistro" || '.pdf' as url_p_construida
FROM "Medicamentos"
WHERE "Nombre" LIKE '%OZEMPIC%'
LIMIT 1;

-- 2. Comparar medicamentos con docs en BD vs sin docs
-- Los que TIENEN docs en JSON
SELECT 
    "NRegistro",
    "Nombre",
    "RawJson"::text LIKE '%"docs"%' as tiene_docs_json
FROM "Medicamentos"
WHERE "NRegistro" IN ('81807', '62974', '1171251003IP')  -- ibuprofeno y ozempic
ORDER BY "NRegistro";

-- 3. Ver cuántos NRegistro son válidos (no NULL, no vacíos)
SELECT 
    COUNT(*) as total,
    COUNT(CASE WHEN "NRegistro" IS NOT NULL AND "NRegistro" != '' THEN 1 END) as con_nregistro_valido
FROM "Medicamentos";
