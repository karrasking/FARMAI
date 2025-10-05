-- Ver el JSON directo de los que contienen "materiales"
-- =======================================================

-- 1. Ver JSON completo de 3 medicamentos con "materiales"
SELECT 
    "NRegistro",
    "Nombre",
    "RawJson"::text
FROM "Medicamentos"
WHERE "RawJson"::text LIKE '%materiales%'
LIMIT 3;

-- 2. Ver contexto alrededor de "materiales" (substring)
SELECT 
    "NRegistro",
    "Nombre",
    substring("RawJson"::text from position('materiales' in "RawJson"::text) - 50 for 150) as contexto
FROM "Medicamentos"
WHERE "RawJson"::text LIKE '%materiales%'
LIMIT 5;
