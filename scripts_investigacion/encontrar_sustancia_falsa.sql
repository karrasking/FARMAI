-- ¡Encontrar la sustancia que causa el falso positivo!

-- Ver TODAS las sustancias de 60605 con sus IDs
SELECT 
    ms."NRegistro",
    ms."SustanciaId",
    sa."Nombre" as sustancia_nombre,
    ms."Cantidad",
    ms."Unidad",
    ms."Orden",
    -- ¿Contiene "cafe"?
    CASE WHEN sa."Nombre" ILIKE '%cafe%' THEN '⚠️ AQUI ESTA EL PROBLEMA' ELSE 'OK' END as check_cafe
FROM "MedicamentoSustancia" ms
JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
WHERE ms."NRegistro" = '60605'
ORDER BY ms."Orden";

-- Ver TODAS las sustancias que tienen "cafe" en el nombre
SELECT "Id", "Nombre"
FROM "SustanciaActiva"
WHERE "Nombre" ILIKE '%cafe%'
LIMIT 20;
