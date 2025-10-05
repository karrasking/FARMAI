-- Investigar el JSON que ya tenemos

-- 1. Ver un ejemplo de JSON que SÍ tiene docs
SELECT 
    "NRegistro",
    "Json"
FROM "MedicamentoDetalleRaw"
WHERE "Json"::text LIKE '%"docs"%'
LIMIT 1;

-- 2. Ver un ejemplo de JSON que NO tiene docs
SELECT 
    "NRegistro",
    "Json"
FROM "MedicamentoDetalleRaw"
WHERE "Json"::text NOT LIKE '%"docs"%'
LIMIT 1;

-- 3. Verificar relación MedicamentoDetalleRaw vs Medicamentos
SELECT 
    'En MedicamentoDetalleRaw' as tabla,
    COUNT(*) as cantidad
FROM "MedicamentoDetalleRaw"
UNION ALL
SELECT 
    'En tabla Medicamentos',
    COUNT(*)
FROM "Medicamentos";

-- 4. Medicamentos que ESTAN en tabla principal pero NO en DetalleRaw
SELECT 
    'Meds sin JSON en DetalleRaw' as metrica,
    COUNT(*) as cantidad
FROM "Medicamentos" m
LEFT JOIN "MedicamentoDetalleRaw" r ON r."NRegistro" = m."NRegistro"
WHERE r."NRegistro" IS NULL;
