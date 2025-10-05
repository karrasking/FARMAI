-- CORREGIR SUSTANCIA ID 1909
-- El JSON dice "MEPIVACAINA HIDROCLORURO" pero la tabla tiene "CAFEINA ANHIDRA"

-- 1. Ver estado actual
SELECT "Id", "Nombre", "Codigo"
FROM "SustanciaActiva"
WHERE "Id" = 1909;

-- 2. Ver cuántos medicamentos usan este ID
SELECT COUNT(DISTINCT "NRegistro") as medicamentos_afectados
FROM "MedicamentoSustancia"
WHERE "SustanciaId" = 1909;

-- 3. CORREGIR el nombre
UPDATE "SustanciaActiva"
SET "Nombre" = 'MEPIVACAINA HIDROCLORURO'
WHERE "Id" = 1909;

-- 4. Verificar corrección
SELECT "Id", "Nombre", "Codigo"
FROM "SustanciaActiva"
WHERE "Id" = 1909;

-- 5. Verificar que 60605 ya no aparezca con "cafeina"
SELECT 
    ms."NRegistro",
    sa."Nombre" as sustancia
FROM "MedicamentoSustancia" ms
JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
WHERE ms."NRegistro" = '60605';
