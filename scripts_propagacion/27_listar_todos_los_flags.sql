-- ============================================================
-- LISTAR TODOS LOS FLAGS DISPONIBLES EN EL SISTEMA
-- ============================================================

-- 1. FLAGS EN MEDICAMENTOS (tabla principal)
SELECT 
    'Medicamentos' as tabla,
    column_name as flag,
    data_type,
    (SELECT COUNT(*) FROM "Medicamentos" WHERE column_name = 'AfectaConduccion' AND "AfectaConduccion" = true) as count_true
FROM information_schema.columns
WHERE table_name = 'Medicamentos'
  AND data_type = 'boolean'
ORDER BY column_name;

-- 2. Conteo real de cada flag boolean en Medicamentos
SELECT 
    'AfectaConduccion' as flag,
    COUNT(*) FILTER (WHERE "AfectaConduccion" = true) as count_true,
    COUNT(*) FILTER (WHERE "AfectaConduccion" = false) as count_false,
    COUNT(*) FILTER (WHERE "AfectaConduccion" IS NULL) as count_null
FROM "Medicamentos"
UNION ALL
SELECT 
    'TrianguloNegro',
    COUNT(*) FILTER (WHERE "TrianguloNegro" = true),
    COUNT(*) FILTER (WHERE "TrianguloNegro" = false),
    COUNT(*) FILTER (WHERE "TrianguloNegro" IS NULL)
FROM "Medicamentos"
UNION ALL
SELECT 
    'Huerfano',
    COUNT(*) FILTER (WHERE "Huerfano" = true),
    COUNT(*) FILTER (WHERE "Huerfano" = false),
    COUNT(*) FILTER (WHERE "Huerfano" IS NULL)
FROM "Medicamentos"
UNION ALL
SELECT 
    'Biosimilar',
    COUNT(*) FILTER (WHERE "Biosimilar" = true),
    COUNT(*) FILTER (WHERE "Biosimilar" = false),
    COUNT(*) FILTER (WHERE "Biosimilar" IS NULL)
FROM "Medicamentos"
UNION ALL
SELECT 
    'MaterialesInformativos',
    COUNT(*) FILTER (WHERE "MaterialesInformativos" = true),
    COUNT(*) FILTER (WHERE "MaterialesInformativos" = false),
    COUNT(*) FILTER (WHERE "MaterialesInformativos" IS NULL)
FROM "Medicamentos"
UNION ALL
SELECT 
    'Comercializado',
    COUNT(*) FILTER (WHERE "Comercializado" = true),
    COUNT(*) FILTER (WHERE "Comercializado" = false),
    COUNT(*) FILTER (WHERE "Comercializado" IS NULL)
FROM "Medicamentos"
UNION ALL
SELECT 
    'Generico',
    COUNT(*) FILTER (WHERE "Generico" = true),
    COUNT(*) FILTER (WHERE "Generico" = false),
    COUNT(*) FILTER (WHERE "Generico" IS NULL)
FROM "Medicamentos"
UNION ALL
SELECT 
    'Receta',
    COUNT(*) FILTER (WHERE "Receta" = true),
    COUNT(*) FILTER (WHERE "Receta" = false),
    COUNT(*) FILTER (WHERE "Receta" IS NULL)
FROM "Medicamentos"
UNION ALL
SELECT 
    'Fotos',
    COUNT(*) FILTER (WHERE "Fotos" = true),
    COUNT(*) FILTER (WHERE "Fotos" = false),
    COUNT(*) FILTER (WHERE "Fotos" IS NULL)
FROM "Medicamentos"
UNION ALL
SELECT 
    'Psum',
    COUNT(*) FILTER (WHERE "Psum" = true),
    COUNT(*) FILTER (WHERE "Psum" = false),
    COUNT(*) FILTER (WHERE "Psum" IS NULL)
FROM "Medicamentos";

-- 3. FLAGS EN PrescripcionStaging
SELECT 
    'SwPsicotropo' as flag,
    COUNT(*) FILTER (WHERE "SwPsicotropo" = true) as count_true,
    COUNT(*) FILTER (WHERE "SwPsicotropo" = false) as count_false,
    COUNT(*) FILTER (WHERE "SwPsicotropo" IS NULL) as count_null
FROM "PrescripcionStaging"
UNION ALL
SELECT 
    'SwEstupefaciente',
    COUNT(*) FILTER (WHERE "SwEstupefaciente" = true),
    COUNT(*) FILTER (WHERE "SwEstupefaciente" = false),
    COUNT(*) FILTER (WHERE "SwEstupefaciente" IS NULL)
FROM "PrescripcionStaging"
UNION ALL
SELECT 
    'SwAfectaConduccion',
    COUNT(*) FILTER (WHERE "SwAfectaConduccion" = true),
    COUNT(*) FILTER (WHERE "SwAfectaConduccion" = false),
    COUNT(*) FILTER (WHERE "SwAfectaConduccion" IS NULL)
FROM "PrescripcionStaging"
UNION ALL
SELECT 
    'SwTrianguloNegro',
    COUNT(*) FILTER (WHERE "SwTrianguloNegro" = true),
    COUNT(*) FILTER (WHERE "SwTrianguloNegro" = false),
    COUNT(*) FILTER (WHERE "SwTrianguloNegro" IS NULL)
FROM "PrescripcionStaging";

-- 4. Ver qué medicamentos tienen Psicotropo=true en PrescripcionStaging
SELECT 
    ps."NRegistro",
    m."Nombre",
    ps."SwPsicotropo",
    ps."SwEstupefaciente"
FROM "PrescripcionStaging" ps
LEFT JOIN "Medicamentos" m ON ps."NRegistro" = m."NRegistro"
WHERE ps."SwPsicotropo" = true
   OR ps."SwEstupefaciente" = true
LIMIT 20;

-- 5. FLAGS YA EN GRAFO
SELECT 
    node_key as flag_en_grafo,
    props->>'nombre' as nombre,
    props->>'descripcion' as descripcion
FROM graph_node
WHERE node_type = 'Flag' OR node_type = 'FlagEstado'
ORDER BY node_type, node_key;

-- 6. Otros campos boolean en Medicamentos que podrían ser flags
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'Medicamentos'
  AND data_type = 'boolean'
ORDER BY column_name;
