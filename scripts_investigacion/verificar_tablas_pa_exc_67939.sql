-- ============================================================================
-- VERIFICAR TABLAS DE PA Y EXCIPIENTES - Medicamento 67939
-- ============================================================================

-- 1. TABLA MedicamentoSustancia (Principios Activos)
-- ============================================================================
SELECT 
    'MedicamentoSustancia' as tabla,
    ms.*
FROM "MedicamentoSustancia" ms
WHERE ms."NRegistro" = '67939';

-- 2. TABLA MedicamentoExcipiente
-- ============================================================================
SELECT 
    'MedicamentoExcipiente' as tabla,
    me.*
FROM "MedicamentoExcipiente" me
WHERE me."NRegistro" = '67939';

-- 3. DETALLES DE LA SUSTANCIA ACTIVA (JOIN con tabla maestra)
-- ============================================================================
SELECT 
    ms."NRegistro",
    ms."Fuerza",
    ms."Unidad",
    sa."Codigo",
    sa."Nombre" as nombre_sustancia
FROM "MedicamentoSustancia" ms
LEFT JOIN "SustanciaActiva" sa ON ms."SustanciaActivaId" = sa."Codigo"
WHERE ms."NRegistro" = '67939';

-- 4. DETALLES DE EXCIPIENTES (JOIN con tabla maestra)
-- ============================================================================
SELECT 
    me."NRegistro",
    me."Cantidad",
    me."Unidad",
    me."Orden",
    e."Codigo",
    e."Nombre" as nombre_excipiente
FROM "MedicamentoExcipiente" me
LEFT JOIN "Excipiente" e ON me."ExcipienteId" = e."Codigo"
WHERE me."NRegistro" = '67939';

-- 5. CONTEO EN TODAS LAS FUENTES PARA 67939
-- ============================================================================
SELECT 
    'Principios Activos en MedicamentoSustancia' as fuente,
    COUNT(*) as cantidad
FROM "MedicamentoSustancia"
WHERE "NRegistro" = '67939'
UNION ALL
SELECT 
    'Excipientes en MedicamentoExcipiente',
    COUNT(*)
FROM "MedicamentoExcipiente"
WHERE "NRegistro" = '67939'
UNION ALL
SELECT 
    'PA en Grafo',
    COUNT(*)
FROM graph_edge
WHERE src_type = 'Medicamento' 
  AND src_key = '67939' 
  AND rel = 'CONTIENE_PA'
UNION ALL
SELECT 
    'Excipientes en Grafo',
    COUNT(*)
FROM graph_edge
WHERE src_type = 'Medicamento' 
  AND src_key = '67939' 
  AND rel = 'CONTIENE_EXCIPIENTE';

-- 6. ESTRUCTURA DE TABLA MedicamentoSustancia
-- ============================================================================
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'MedicamentoSustancia'
ORDER BY ordinal_position;

-- 7. ESTRUCTURA DE TABLA MedicamentoExcipiente
-- ============================================================================
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'MedicamentoExcipiente'
ORDER BY ordinal_position;

-- 8. CONTEO GLOBAL DE REGISTROS
-- ============================================================================
SELECT 
    'MedicamentoSustancia' as tabla,
    COUNT(*) as total_registros,
    COUNT(DISTINCT "NRegistro") as medicamentos_distintos
FROM "MedicamentoSustancia"
UNION ALL
SELECT 
    'MedicamentoExcipiente',
    COUNT(*),
    COUNT(DISTINCT "NRegistro")
FROM "MedicamentoExcipiente"
UNION ALL
SELECT 
    'SustanciaActiva (maestra)',
    COUNT(*),
    COUNT(DISTINCT "Codigo")
FROM "SustanciaActiva"
UNION ALL
SELECT 
    'Excipiente (maestra)',
    COUNT(*),
    COUNT(DISTINCT "Codigo")
FROM "Excipiente";
