-- Verificar si 60605 está vinculado a alguna sustancia CAFEINA

-- 1. Ver si 60605 tiene alguna de estas sustancias (1903, 1907, 1909)
SELECT 
    ms."NRegistro",
    ms."SustanciaId",
    sa."Nombre",
    ms."Cantidad",
    ms."Unidad"
FROM "MedicamentoSustancia" ms
JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
WHERE ms."NRegistro" = '60605'
  AND ms."SustanciaId" IN (1903, 1907, 1909);

-- 2. Ver TODAS las sustancias que tiene 60605 (sin filtro)
SELECT 
    ms."NRegistro",
    ms."SustanciaId",
    sa."Nombre",
    ms."Cantidad",
    ms."Unidad",
    ms."Orden"
FROM "MedicamentoSustancia" ms
LEFT JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
WHERE ms."NRegistro" = '60605'
ORDER BY ms."Orden";

-- 3. Verificar si hay algo raro con los IDs
SELECT 
    'Total sustancias en 60605' as info,
    COUNT(*) as cantidad
FROM "MedicamentoSustancia"
WHERE "NRegistro" = '60605';
