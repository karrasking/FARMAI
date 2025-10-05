-- ========================================
-- INVESTIGACIÓN FASE 4: PROBLEMAS SUMINISTRO
-- ========================================

-- 1. Ver si existe tabla para problemas suministro
SELECT 
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
AND (
    table_name ILIKE '%suministro%'
    OR table_name ILIKE '%psum%'
    OR table_name ILIKE '%problema%'
    OR table_name ILIKE '%desabastecimiento%'
)
ORDER BY table_name;

-- 2. Buscar campo psum en JSON CIMA
SELECT 
    COUNT(*) as "TotalMedicamentos",
    COUNT(*) FILTER (WHERE "Json" ? 'psum') as "ConCampoPsum",
    COUNT(*) FILTER (WHERE ("Json"->>'psum')::boolean = true) as "PsumTrue",
    COUNT(*) FILTER (WHERE ("Json"->>'psum')::boolean = false) as "PsumFalse"
FROM "MedicamentoDetalleRaw";

-- 3. Ver sample de medicamentos con psum=true
SELECT 
    "NRegistro",
    "Json"->>'nombre' as "Nombre",
    "Json"->>'psum' as "Psum",
    "Json"->'estado' as "Estado"
FROM "MedicamentoDetalleRaw"
WHERE ("Json"->>'psum')::boolean = true
LIMIT 10;

-- 4. Ver si hay información adicional de psum en presentaciones
SELECT 
    mdr."NRegistro",
    mdr."Json"->>'nombre' as "Medicamento",
    pres->>'cn' as "CN",
    pres->>'nombre' as "Presentacion",
    pres->>'psum' as "PsumPresentacion",
    pres->'estado' as "EstadoPresentacion"
FROM "MedicamentoDetalleRaw" mdr,
jsonb_array_elements(mdr."Json"->'presentaciones') as pres
WHERE pres ? 'psum'
AND (pres->>'psum')::boolean = true
LIMIT 10;

-- 5. Conteo por nivel
SELECT 
    'Nivel Medicamento' as "Nivel",
    COUNT(*) FILTER (WHERE ("Json"->>'psum')::boolean = true) as "ConProblema"
FROM "MedicamentoDetalleRaw"
UNION ALL
SELECT 
    'Nivel Presentación',
    COUNT(*)
FROM "MedicamentoDetalleRaw" mdr,
jsonb_array_elements(mdr."Json"->'presentaciones') as pres
WHERE (pres->>'psum')::boolean = true;

-- 6. Ver estructura completa de un medicamento con psum
SELECT 
    "NRegistro",
    jsonb_pretty("Json") as "JSONCompleto"
FROM "MedicamentoDetalleRaw"
WHERE ("Json"->>'psum')::boolean = true
LIMIT 1;

-- 7. Buscar en PrescripcionStaging
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'PrescripcionStaging'
AND column_name ILIKE '%psum%'
   OR column_name ILIKE '%suministro%'
   OR column_name ILIKE '%desabast%';

-- 8. Ver si hay flags relacionados
SELECT DISTINCT "Nombre"
FROM "Flag"
WHERE "Nombre" ILIKE '%suministro%'
   OR "Nombre" ILIKE '%desabast%'
   OR "Nombre" ILIKE '%psum%';
