-- Investigación CN simplificada y eficiente

-- 1. Total de presentaciones
SELECT COUNT(*) as total_presentaciones
FROM "Presentacion";

-- 2. Contar medicamentos que tienen CN en su JSON
SELECT COUNT(*) as meds_con_cn_en_json
FROM "Medicamentos"
WHERE "RawJson"::text LIKE '%"cn":"%';

-- 3. Buscar por CN específico directo en JSON (método más rápido)
SELECT 
    "NRegistro",
    "Nombre"
FROM "Medicamentos"
WHERE "RawJson"::text LIKE '%"cn":"659726"%'
LIMIT 5;

-- 4. Probar búsqueda por CN parcial
SELECT 
    "NRegistro",
    "Nombre"
FROM "Medicamentos"  
WHERE "RawJson"::text LIKE '%"cn":"6597%'
LIMIT 10;

-- 5. Ver los CNs de un medicamento de ibuprofeno
SELECT 
    "NRegistro",
    "Nombre",
    jsonb_array_elements("RawJson"::jsonb->'presentaciones')->>'cn' as cn
FROM "Medicamentos"
WHERE "Nombre" ILIKE '%IBUPROFENO NORMON 600%'
LIMIT 1;
