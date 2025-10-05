-- Investigar tabla MedicamentoPresentacion

-- 1. Estructura de la tabla
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'MedicamentoPresentacion'
ORDER BY ordinal_position;

-- 2. Ver ejemplos de datos
SELECT *
FROM "MedicamentoPresentacion"
LIMIT 10;

-- 3. Buscar medicamento por CN usando JOIN
SELECT 
    m."NRegistro",
    m."Nombre",
    p."CN",
    p."Nombre" as presentacion_nombre
FROM "Medicamentos" m
JOIN "MedicamentoPresentacion" mp ON m."NRegistro" = mp."NRegistro"
JOIN "Presentacion" p ON mp."CN" = p."CN"
WHERE p."CN" = '659726'
LIMIT 5;

-- 4. Probar búsqueda por CN parcial
SELECT 
    m."NRegistro",
    m."Nombre",
    p."CN"
FROM "Medicamentos" m
JOIN "MedicamentoPresentacion" mp ON m."NRegistro" = mp."NRegistro"
JOIN "Presentacion" p ON mp."CN" = p."CN"
WHERE p."CN" LIKE '6597%'
LIMIT 10;

-- 5. Contar cuántos medicamentos tienen CNs asignados
SELECT COUNT(DISTINCT m."NRegistro") as medicamentos_con_cn
FROM "Medicamentos" m
JOIN "MedicamentoPresentacion" mp ON m."NRegistro" = mp."NRegistro";
