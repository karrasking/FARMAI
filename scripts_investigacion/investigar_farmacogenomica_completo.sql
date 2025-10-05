-- INVESTIGACIÓN COMPLETA: FARMACOGENÓMICA EN FARMAI

-- =====================================================
-- PARTE 1: ESTRUCTURA Y DATOS DE BIOMARCADORES
-- =====================================================

-- 1.1 Ver estructura de tabla Biomarcador
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'Biomarcador'
ORDER BY ordinal_position;

-- 1.2 Contar biomarcadores totales
SELECT COUNT(*) as total_biomarcadores
FROM "Biomarcador";

-- 1.3 Ver ejemplos de biomarcadores
SELECT *
FROM "Biomarcador"
LIMIT 20;

-- =====================================================
-- PARTE 2: RELACIÓN MEDICAMENTO-BIOMARCADOR
-- =====================================================

-- 2.1 Ver estructura de MedicamentoBiomarcador
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'MedicamentoBiomarcador'
ORDER BY ordinal_position;

-- 2.2 Contar medicamentos con biomarcadores
SELECT COUNT(DISTINCT "NRegistro") as meds_con_biomarcadores
FROM "MedicamentoBiomarcador";

-- 2.3 Estadísticas de biomarcadores por medicamento
SELECT 
    COUNT(*) as num_medicamentos,
    COUNT(DISTINCT mb."BiomarcadorId") as num_biomarcadores_distintos
FROM "MedicamentoBiomarcador" mb;

-- 2.4 Top 10 biomarcadores más usados
SELECT 
    b."Nombre",
    b."Id",
    COUNT(mb."NRegistro") as num_medicamentos
FROM "Biomarcador" b
JOIN "MedicamentoBiomarcador" mb ON b."Id" = mb."BiomarcadorId"
GROUP BY b."Id", b."Nombre"
ORDER BY num_medicamentos DESC
LIMIT 10;

-- =====================================================
-- PARTE 3: EJEMPLOS CONCRETOS DE MEDICAMENTOS
-- =====================================================

-- 3.1 Medicamento ejemplo con biomarcadores (si existe)
SELECT 
    m."NRegistro",
    m."Nombre",
    b."Nombre" as biomarcador,
    b."Id" as biomarcador_id
FROM "Medicamentos" m
JOIN "MedicamentoBiomarcador" mb ON m."NRegistro" = mb."NRegistro"
JOIN "Biomarcador" b ON mb."BiomarcadorId" = b."Id"
LIMIT 5;

-- 3.2 Buscar medicamentos con CYP2D6 (metabolizador común)
SELECT 
    m."NRegistro",
    m."Nombre",
    b."Nombre" as biomarcador
FROM "Medicamentos" m
JOIN "MedicamentoBiomarcador" mb ON m."NRegistro" = mb."NRegistro"
JOIN "Biomarcador" b ON mb."BiomarcadorId" = b."Id"
WHERE b."Nombre" ILIKE '%CYP2D6%'
LIMIT 10;

-- 3.3 Buscar medicamentos con HLA (inmunogenética)
SELECT 
    m."NRegistro",
    m."Nombre",
    b."Nombre" as biomarcador
FROM "Medicamentos" m
JOIN "MedicamentoBiomarcador" mb ON m."NRegistro" = mb."NRegistro"
JOIN "Biomarcador" b ON mb."BiomarcadorId" = b."Id"
WHERE b."Nombre" ILIKE '%HLA%'
LIMIT 10;

-- =====================================================
-- PARTE 4: INVESTIGAR SI HAY INFO EN JSON
-- =====================================================

-- 4.1 Buscar "biomarcador" en RawJson
SELECT 
    "NRegistro",
    "Nombre",
    "RawJson"::text LIKE '%biomarcador%' as tiene_biomarcador_json,
    "RawJson"::text LIKE '%CYP%' as tiene_cyp_json,
    "RawJson"::text LIKE '%HLA%' as tiene_hla_json
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL
  AND ("RawJson"::text ILIKE '%biomarcador%' 
    OR "RawJson"::text ILIKE '%CYP%'
    OR "RawJson"::text ILIKE '%HLA%')
LIMIT 10;

-- 4.2 Ver JSON completo de un medicamento con biomarcador
SELECT 
    m."NRegistro",
    m."Nombre",
    m."RawJson"
FROM "Medicamentos" m
JOIN "MedicamentoBiomarcador" mb ON m."NRegistro" = mb."NRegistro"
WHERE m."RawJson" IS NOT NULL
LIMIT 1;

-- =====================================================
-- PARTE 5: ANÁLISIS DE CAMPOS ADICIONALES
-- =====================================================

-- 5.1 Ver si hay campos de texto/notas en Biomarcador
SELECT 
    *
FROM "Biomarcador"
WHERE "Nombre" IS NOT NULL
LIMIT 5;

-- 5.2 Longitud promedio de nombres de biomarcadores
SELECT 
    AVG(LENGTH("Nombre")) as longitud_promedio,
    MAX(LENGTH("Nombre")) as longitud_maxima,
    MIN(LENGTH("Nombre")) as longitud_minima
FROM "Biomarcador";

-- =====================================================
-- PARTE 6: CRUCES CON OTRAS TABLAS
-- =====================================================

-- 6.1 Biomarcadores + Principios Activos
SELECT DISTINCT
    m."NRegistro",
    m."Nombre" as medicamento,
    b."Nombre" as biomarcador,
    sa."Nombre" as principio_activo
FROM "Medicamentos" m
JOIN "MedicamentoBiomarcador" mb ON m."NRegistro" = mb."NRegistro"
JOIN "Biomarcador" b ON mb."BiomarcadorId" = b."Id"
LEFT JOIN "MedicamentoSustancia" ms ON m."NRegistro" = ms."NRegistro"
LEFT JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
WHERE sa."Nombre" IS NOT NULL
LIMIT 10;

-- 6.2 Distribución por ATC
SELECT 
    ma."Codigo" as atc_codigo,
    a."Nombre" as atc_nombre,
    COUNT(DISTINCT mb."NRegistro") as num_medicamentos_con_biomarcadores
FROM "MedicamentoBiomarcador" mb
JOIN "MedicamentoAtc" ma ON mb."NRegistro" = ma."NRegistro"
LEFT JOIN "Atc" a ON ma."Codigo" = a."Codigo"
GROUP BY ma."Codigo", a."Nombre"
ORDER BY num_medicamentos_con_biomarcadores DESC
LIMIT 10;

-- =====================================================
-- RESUMEN FINAL
-- =====================================================

SELECT 
    'RESUMEN' as tipo,
    (SELECT COUNT(*) FROM "Biomarcador") as total_biomarcadores,
    (SELECT COUNT(DISTINCT "NRegistro") FROM "MedicamentoBiomarcador") as medicamentos_con_biomarcadores,
    (SELECT COUNT(*) FROM "Medicamentos") as total_medicamentos,
    ROUND((SELECT COUNT(DISTINCT "NRegistro") FROM "MedicamentoBiomarcador")::numeric / 
          (SELECT COUNT(*) FROM "Medicamentos")::numeric * 100, 2) as porcentaje_cobertura;
