-- Verificar si 60605 tiene algún excipiente con "cafeina"

-- 1. Ver TODOS los excipientes de ISOGAINE 60605
SELECT 
    me."NRegistro",
    e."Id" as excipiente_id,
    e."Nombre" as excipiente_nombre,
    me."Cantidad",
    me."Unidad",
    me."Orden"
FROM "MedicamentoExcipiente" me
JOIN "Excipiente" e ON me."ExcipienteId" = e."Id"::bigint
WHERE me."NRegistro" = '60605'
ORDER BY me."Orden";

-- 2. Buscar si hay ALGÚN excipiente con "cafe" en el nombre
SELECT 
    "Id",
    "Nombre"
FROM "Excipiente"
WHERE "Nombre" ILIKE '%cafe%'
LIMIT 20;

-- 3. Ver si 60605 tiene ALGÚN match en excipientes con "cafe"
SELECT 
    me."NRegistro",
    m."Nombre" as medicamento,
    e."Nombre" as excipiente
FROM "MedicamentoExcipiente" me
JOIN "Medicamentos" m ON me."NRegistro" = m."NRegistro"
JOIN "Excipiente" e ON me."ExcipienteId" = e."Id"::bigint
WHERE me."NRegistro" = '60605'
  AND e."Nombre" ILIKE '%cafe%';

-- 4. Ver qué otros medicamentos SI tienen excipientes con "cafeina"
SELECT 
    m."NRegistro",
    m."Nombre",
    e."Nombre" as excipiente_cafeina
FROM "MedicamentoExcipiente" me
JOIN "Medicamentos" m ON me."NRegistro" = m."NRegistro"
JOIN "Excipiente" e ON me."ExcipienteId" = e."Id"::bigint
WHERE e."Nombre" ILIKE '%cafe%'
LIMIT 10;
