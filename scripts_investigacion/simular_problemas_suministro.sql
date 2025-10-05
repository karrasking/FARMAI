-- ========================================
-- SIMULACIÓN FASE 4: PROBLEMAS SUMINISTRO
-- ========================================
-- ESTE SCRIPT NO MODIFICA LA BD
-- Solo muestra qué se insertaría

-- 1. EXTRACCIÓN: Parsear JSON a estructura tabla
WITH problemas_parsed AS (
    SELECT 
        pres->>'cn' as cn,
        mdr."NRegistro",
        to_timestamp((pres->'detalleProblemaSuministro'->>'fini')::bigint / 1000.0) as fecha_inicio,
        CASE 
            WHEN pres->'detalleProblemaSuministro'->>'ffin' IS NOT NULL
            THEN to_timestamp((pres->'detalleProblemaSuministro'->>'ffin')::bigint / 1000.0)
            ELSE NULL
        END as fecha_fin,
        (pres->'detalleProblemaSuministro'->>'activo')::boolean as activo,
        pres->'detalleProblemaSuministro'->>'observ' as observaciones
    FROM "MedicamentoDetalleRaw" mdr,
    jsonb_array_elements(mdr."Json"->'presentaciones') as pres
    WHERE pres->'detalleProblemaSuministro' IS NOT NULL
)
-- 2. ESTADÍSTICAS GENERALES
SELECT 
    'TOTAL PROBLEMAS A INSERTAR' as "Metrica",
    COUNT(*)::text as "Valor"
FROM problemas_parsed
UNION ALL
SELECT 
    'Problemas Activos',
    COUNT(*) FILTER (WHERE activo = true)::text
FROM problemas_parsed
UNION ALL
SELECT 
    'Problemas Inactivos',
    COUNT(*) FILTER (WHERE activo = false)::text
FROM problemas_parsed
UNION ALL
SELECT 
    'Con Fecha Fin definida',
    COUNT(*) FILTER (WHERE fecha_fin IS NOT NULL)::text
FROM problemas_parsed
UNION ALL
SELECT 
    'Sin Fecha Fin (indefinido)',
    COUNT(*) FILTER (WHERE fecha_fin IS NULL)::text
FROM problemas_parsed;

-- 3. CALIDAD: Verificar integridad datos
WITH problemas_parsed AS (
    SELECT 
        pres->>'cn' as cn,
        mdr."NRegistro",
        to_timestamp((pres->'detalleProblemaSuministro'->>'fini')::bigint / 1000.0) as fecha_inicio,
        CASE 
            WHEN pres->'detalleProblemaSuministro'->>'ffin' IS NOT NULL
            THEN to_timestamp((pres->'detalleProblemaSuministro'->>'ffin')::bigint / 1000.0)
            ELSE NULL
        END as fecha_fin,
        (pres->'detalleProblemaSuministro'->>'activo')::boolean as activo,
        pres->'detalleProblemaSuministro'->>'observ' as observaciones
    FROM "MedicamentoDetalleRaw" mdr,
    jsonb_array_elements(mdr."Json"->'presentaciones') as pres
    WHERE pres->'detalleProblemaSuministro' IS NOT NULL
)
SELECT 
    'CN NULL o vacío' as "Problema",
    COUNT(*) as "Cantidad"
FROM problemas_parsed
WHERE cn IS NULL OR cn = ''
UNION ALL
SELECT 
    'FechaInicio NULL',
    COUNT(*)
FROM problemas_parsed
WHERE fecha_inicio IS NULL
UNION ALL
SELECT 
    'Activo NULL',
    COUNT(*)
FROM problemas_parsed
WHERE activo IS NULL
UNION ALL
SELECT 
    'CN no existe en Presentacion',
    COUNT(*)
FROM problemas_parsed pp
WHERE NOT EXISTS (
    SELECT 1 FROM "Presentacion" p
    WHERE p."CN" = pp.cn
)
UNION ALL
SELECT 
    'NRegistro no existe en Medicamentos',
    COUNT(*)
FROM problemas_parsed pp
WHERE NOT EXISTS (
    SELECT 1 FROM "Medicamentos" m
    WHERE m."NRegistro" = pp."NRegistro"
);

-- 4. DUPLICADOS: Verificar unicidad CN
WITH problemas_parsed AS (
    SELECT 
        pres->>'cn' as cn
    FROM "MedicamentoDetalleRaw" mdr,
    jsonb_array_elements(mdr."Json"->'presentaciones') as pres
    WHERE pres->'detalleProblemaSuministro' IS NOT NULL
)
SELECT 
    'DUPLICADOS POR CN' as "Metrica",
    (COUNT(*) - COUNT(DISTINCT cn))::text as "Cantidad"
FROM problemas_parsed;

-- 5. SAMPLE: Ver primeros 10 que se insertarían
WITH problemas_parsed AS (
    SELECT 
        pres->>'cn' as cn,
        mdr."NRegistro",
        mdr."Json"->>'nombre' as medicamento,
        to_timestamp((pres->'detalleProblemaSuministro'->>'fini')::bigint / 1000.0) as fecha_inicio,
        CASE 
            WHEN pres->'detalleProblemaSuministro'->>'ffin' IS NOT NULL
            THEN to_timestamp((pres->'detalleProblemaSuministro'->>'ffin')::bigint / 1000.0)
            ELSE NULL
        END as fecha_fin,
        (pres->'detalleProblemaSuministro'->>'activo')::boolean as activo,
        LEFT(pres->'detalleProblemaSuministro'->>'observ', 80) as observaciones
    FROM "MedicamentoDetalleRaw" mdr,
    jsonb_array_elements(mdr."Json"->'presentaciones') as pres
    WHERE pres->'detalleProblemaSuministro' IS NOT NULL
)
SELECT 
    cn as "CN",
    "NRegistro",
    LEFT(medicamento, 40) as "Medicamento",
    fecha_inicio::date as "Inicio",
    fecha_fin::date as "Fin",
    activo as "Activo",
    observaciones as "Observaciones"
FROM problemas_parsed
ORDER BY fecha_inicio DESC
LIMIT 10;

-- 6. DISTRIBUCIÓN TEMPORAL: Problemas por año
WITH problemas_parsed AS (
    SELECT 
        to_timestamp((pres->'detalleProblemaSuministro'->>'fini')::bigint / 1000.0) as fecha_inicio
    FROM "MedicamentoDetalleRaw" mdr,
    jsonb_array_elements(mdr."Json"->'presentaciones') as pres
    WHERE pres->'detalleProblemaSuministro' IS NOT NULL
)
SELECT 
    EXTRACT(YEAR FROM fecha_inicio) as "Año",
    COUNT(*) as "ProblemasIniciados",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as "Porcentaje"
FROM problemas_parsed
GROUP BY EXTRACT(YEAR FROM fecha_inicio)
ORDER BY "Año" DESC
LIMIT 10;

-- 7. TOP 10 MEDICAMENTOS con más presentaciones con problemas
WITH problemas_parsed AS (
    SELECT 
        mdr."NRegistro",
        mdr."Json"->>'nombre' as medicamento,
        COUNT(*) as num_problemas
    FROM "MedicamentoDetalleRaw" mdr,
    jsonb_array_elements(mdr."Json"->'presentaciones') as pres
    WHERE pres->'detalleProblemaSuministro' IS NOT NULL
    GROUP BY mdr."NRegistro", mdr."Json"->>'nombre'
)
SELECT 
    "NRegistro",
    LEFT(medicamento, 60) as "Medicamento",
    num_problemas as "NumProblemas"
FROM problemas_parsed
ORDER BY num_problemas DESC
LIMIT 10;

-- 8. ESTIMACIÓN TIEMPO: Calcular duración
WITH problemas_parsed AS (
    SELECT COUNT(*) as total
    FROM "MedicamentoDetalleRaw" mdr,
    jsonb_array_elements(mdr."Json"->'presentaciones') as pres
    WHERE pres->'detalleProblemaSuministro' IS NOT NULL
)
SELECT 
    total as "TotalRegistros",
    ROUND(total / 1000.0, 2) as "TiempoEstimado_Segundos",
    ROUND(total / 1000.0 / 60.0, 2) as "TiempoEstimado_Minutos"
FROM problemas_parsed;
