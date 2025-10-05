-- Verificar cuántos medicamentos tienen "docs" en su RawJson

-- 1. Total de medicamentos con RawJson no nulo
SELECT 
    COUNT(*) as total_meds,
    COUNT(CASE WHEN "RawJson" IS NOT NULL THEN 1 END) as con_raw_json,
    COUNT(CASE WHEN "RawJson" IS NULL THEN 1 END) as sin_raw_json
FROM "Medicamentos";

-- 2. Medicamentos con "docs" en el JSON
SELECT 
    'Medicamentos con array docs en JSON' as metrica,
    COUNT(*) as cantidad
FROM "Medicamentos"
WHERE "RawJson"::text LIKE '%"docs"%';

-- 3. Muestra de medicamentos SIN "docs" en JSON
SELECT 
    "NRegistro",
    "Nombre",
    CASE 
        WHEN "RawJson"::text LIKE '%"docs"%' THEN 'Tiene docs'
        ELSE 'NO tiene docs'
    END as tiene_docs
FROM "Medicamentos"
LIMIT 10;

-- 4. Proporción
SELECT 
    COUNT(*) as total,
    COUNT(CASE WHEN "RawJson"::text LIKE '%"docs"%' THEN 1 END) as con_docs,
    COUNT(CASE WHEN "RawJson"::text NOT LIKE '%"docs"%' THEN 1 END) as sin_docs,
    ROUND(100.0 * COUNT(CASE WHEN "RawJson"::text LIKE '%"docs"%' THEN 1 END) / COUNT(*), 2) as porcentaje_con_docs
FROM "Medicamentos";
