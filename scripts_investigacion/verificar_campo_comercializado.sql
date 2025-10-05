-- VERIFICAR ESTADO CAMPO COMERCIALIZADO EN TABLA
-- =================================================

-- 1. Ver cuántos tienen el campo NULL
SELECT 
    COUNT(*) as total,
    COUNT("Comercializado") as con_valor,
    COUNT(*) - COUNT("Comercializado") as nulls,
    ROUND(100.0 * COUNT("Comercializado") / COUNT(*), 2) as porcentaje_poblado
FROM "Medicamentos";

-- 2. Ver distribución de valores
SELECT 
    "Comercializado",
    COUNT(*) as cantidad
FROM "Medicamentos"
GROUP BY "Comercializado"
ORDER BY cantidad DESC;

-- 3. Ver sample de los que tienen valor
SELECT "NRegistro", "Nombre", "Comercializado"
FROM "Medicamentos"
WHERE "Comercializado" IS NOT NULL
LIMIT 10;

-- 4. Ver sample de los que NO tienen valor (NULLs)
SELECT "NRegistro", "Nombre", "Comercializado", 
       "RawJson"::jsonb ->> 'comerc' as comerc_en_json
FROM "Medicamentos"
WHERE "Comercializado" IS NULL
LIMIT 10;

-- 5. Contar cuántos tienen el valor en JSON pero NO en tabla
SELECT 
    COUNT(*) as total_con_json_no_tabla
FROM "Medicamentos"
WHERE "Comercializado" IS NULL
  AND "RawJson"::jsonb ? 'comerc';
