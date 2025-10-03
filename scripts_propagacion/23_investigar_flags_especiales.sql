-- ============================================================
-- INVESTIGAR FLAGS ESPECIALES: Triángulos, Conducción, Gluten, etc.
-- ============================================================

-- 1. Verificar columnas en tabla Medicamentos relacionadas con flags
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'Medicamentos'
  AND (
    column_name ILIKE '%triangulo%'
    OR column_name ILIKE '%conduccion%'
    OR column_name ILIKE '%gluten%'
    OR column_name ILIKE '%lactosa%'
    OR column_name ILIKE '%alergen%'
    OR column_name ILIKE '%dopaje%'
    OR column_name ILIKE '%conducir%'
    OR column_name ILIKE '%psicotropo%'
    OR column_name ILIKE '%estupefaciente%'
  )
ORDER BY ordinal_position;

-- 2. Ver todas las columnas de Medicamentos (para ver qué hay)
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'Medicamentos'
ORDER BY ordinal_position;

-- 3. Buscar en PrescripcionStaging que tiene más campos
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'PrescripcionStaging'
  AND (
    column_name ILIKE '%triangulo%'
    OR column_name ILIKE '%conduccion%'
    OR column_name ILIKE '%gluten%'
    OR column_name ILIKE '%lactosa%'
    OR column_name ILIKE '%dopaje%'
    OR column_name ILIKE '%psicotropo%'
    OR column_name ILIKE '%estupefaciente%'
  )
ORDER BY ordinal_position;

-- 4. Ver muestra de flags en PrescripcionStaging
SELECT 
    "NRegistro",
    "Triangulo",
    "Conduccion",
    "TrianguloColor",
    "CondicionEmbalaje"
FROM "PrescripcionStaging"
WHERE "Triangulo" IS NOT NULL 
   OR "Conduccion" IS NOT NULL
LIMIT 20;

-- 5. Contar medicamentos por tipo de triángulo
SELECT 
    "Triangulo",
    COUNT(*) as cantidad
FROM "PrescripcionStaging"
WHERE "Triangulo" IS NOT NULL
GROUP BY "Triangulo"
ORDER BY cantidad DESC;

-- 6. Contar medicamentos por afectación a conducción
SELECT 
    "Conduccion",
    COUNT(*) as cantidad
FROM "PrescripcionStaging"
WHERE "Conduccion" IS NOT NULL
GROUP BY "Conduccion"
ORDER BY cantidad DESC;

-- 7. Ver si hay info de gluten/lactosa en otras tablas
SELECT 'ExcipientesDecl' as tabla, COUNT(*) as count
FROM "ExcipientesDeclObligDicStaging"
WHERE "Nombre" ILIKE '%lactosa%'
UNION ALL
SELECT 'ExcipientesDecl', COUNT(*)
FROM "ExcipientesDeclObligDicStaging"
WHERE "Nombre" ILIKE '%gluten%';

-- 8. Buscar excipientes relacionados con alergias comunes
SELECT "Nombre", "CodExcipiente"
FROM "ExcipientesDeclObligDicStaging"
WHERE "Nombre" ILIKE '%lactosa%'
   OR "Nombre" ILIKE '%gluten%'
   OR "Nombre" ILIKE '%cacahuete%'
   OR "Nombre" ILIKE '%soja%'
   OR "Nombre" ILIKE '%sulfito%'
ORDER BY "Nombre";
