-- ============================================================
-- BUSCAR IBUPROFENO EN PRESCRIPCIONSTAGING Y MOSTRAR XML COMPLETO
-- ============================================================

-- 1. Buscar ibuprofe en los datos
SELECT 
    "NRegistro",
    "Nombre"
FROM "PrescripcionStaging"
WHERE "Nombre" ILIKE '%ibuprofeno%'
LIMIT 10;

-- 2. Seleccionar uno y ver TODO el XML
SELECT 
    "NRegistro",
    "Nombre",
    "XmlContent"
FROM "PrescripcionStaging"
WHERE "Nombre" ILIKE '%ibuprofeno%'
LIMIT 1;

-- 3. Ver TODOS los campos estructurados de un ibuprofeno
SELECT *
FROM "PrescripcionStaging"
WHERE "Nombre" ILIKE '%ibuprofeno%'
LIMIT 1;
