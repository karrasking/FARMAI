-- Verificar el nombre COMPLETO y la composición de 60605

SELECT 
    "NRegistro",
    "Nombre",
    "Dosis",
    "LabTitular"
FROM "Medicamentos"
WHERE "NRegistro" = '60605';

-- ¿Qué sustancias tiene?
SELECT 
    ms."NRegistro",
    sa."Nombre" as sustancia,
    ms."Cantidad",
    ms."Unidad"
FROM "MedicamentoSustancia" ms
JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
WHERE ms."NRegistro" = '60605';

-- Buscar otros ISOGAINE
SELECT 
    "NRegistro",
    "Nombre"
FROM "Medicamentos"
WHERE "Nombre" ILIKE '%ISOGAINE%'
ORDER BY "NRegistro";
