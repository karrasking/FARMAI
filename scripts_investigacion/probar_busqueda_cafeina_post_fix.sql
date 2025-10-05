-- Probar que 60605 YA NO aparece al buscar "cafeina"

-- 1. Verificar que 60605 tiene MEPIVACAINA (correcto)
SELECT 
    ms."NRegistro",
    sa."Nombre" as sustancia
FROM "MedicamentoSustancia" ms
JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
WHERE ms."NRegistro" = '60605';

-- 2. Buscar medicamentos que SÍ tienen cafeína (los 3 IDs reales)
SELECT 
    ms."NRegistro",
    m."Nombre",
    sa."Nombre" as principio_activo
FROM "MedicamentoSustancia" ms
JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
JOIN "Medicamentos" m ON ms."NRegistro" = m."NRegistro"
WHERE sa."Nombre" ILIKE '%cafeina%'
LIMIT 10;

-- 3. Verificar que 60605 NO esté en la búsqueda de cafeina
SELECT 
    m."NRegistro",
    m."Nombre",
    'MATCH' as encontrado
FROM "Medicamentos" m
WHERE EXISTS (
    SELECT 1
    FROM "MedicamentoSustancia" ms
    JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
    WHERE ms."NRegistro" = m."NRegistro"
      AND sa."Nombre" ILIKE '%cafeina%'
)
AND m."NRegistro" = '60605';
-- Si devuelve 0 rows = FIX EXITOSO ✅
