-- ============================================================
-- BUSCAR IBUPROFENO COMPLETO
-- ============================================================

-- 1. Buscar ibuprofeno en Medicamentos primero
SELECT 
    "NRegistro",
    "Nombre"
FROM "Medicamentos"
WHERE "Nombre" ILIKE '%ibuprofeno%'
  AND "Nombre" NOT ILIKE '%pseudoefedrina%'
  AND "Nombre" NOT ILIKE '%codeina%'
LIMIT 5;

-- 2. Ahora buscar en PrescripcionStaging por nombre comercial
SELECT 
    "NRegistro",
    "DesNomco",
    "DesPrese",
    "DesDosific"
FROM "PrescripcionStaging"
WHERE "DesNomco" ILIKE '%ibuprofeno%'
  OR "NRegistro" IN (
      SELECT "NRegistro" 
      FROM "Medicamentos" 
      WHERE "Nombre" ILIKE '%ibuprofeno%'
      LIMIT 5
  )
LIMIT 10;

-- 3. Obtener un NRegistro específico de ibuprofeno simple
\set nregistro_ibuprofeno '\'(SELECT "NRegistro" FROM "Medicamentos" WHERE "Nombre" ILIKE \'%ibuprofeno 600%\' AND "Nombre" NOT ILIKE \'%codeina%\' LIMIT 1)\''

-- 4. Ver TODOS los campos de ese ibuprofeno en PrescripcionStaging
SELECT 
    "NRegistro",
    "DesNomco",
    "DesPrese",
    "DesDosific",
    "SwPsicotropo",
    "SwEstupefaciente",
    "SwAfectaConduccion",
    "SwGenerico",
    "SwReceta"
FROM "PrescripcionStaging"
WHERE "NRegistro" IN (
    SELECT "NRegistro" 
    FROM "Medicamentos" 
    WHERE "Nombre" ILIKE '%ibuprofeno 600%' 
      AND "Nombre" NOT ILIKE '%codeina%'
    LIMIT 1
);
