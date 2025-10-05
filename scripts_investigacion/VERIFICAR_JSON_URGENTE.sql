-- VERIFICACIÓN URGENTE: ¿TIENEN TODOS LOS MEDICAMENTOS SU JSON?
-- ===================================================================

-- 1. Conteo simple y claro
SELECT 
    COUNT(*) as total_medicamentos,
    COUNT(CASE WHEN "RawJson" IS NOT NULL AND "RawJson"::text != '{}' THEN 1 END) as con_json_completo,
    COUNT(CASE WHEN "RawJson" IS NULL OR "RawJson"::text = '{}' THEN 1 END) as sin_json_o_vacio,
    ROUND(100.0 * COUNT(CASE WHEN "RawJson" IS NOT NULL AND "RawJson"::text != '{}' THEN 1 END) / COUNT(*), 2) as porcentaje_con_json
FROM "Medicamentos";

-- 2. Ver 5 medicamentos CON JSON
SELECT 'CON JSON' as tipo, "NRegistro", "Nombre", 
       LENGTH("RawJson"::text) as tamaño_json
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL AND "RawJson"::text != '{}'
LIMIT 5;

-- 3. Ver 5 medicamentos SIN JSON o vacío
SELECT 'SIN JSON' as tipo, "NRegistro", "Nombre",
       COALESCE("RawJson"::text, 'NULL') as rawjson_value
FROM "Medicamentos"
WHERE "RawJson" IS NULL OR "RawJson"::text = '{}'
LIMIT 5;
