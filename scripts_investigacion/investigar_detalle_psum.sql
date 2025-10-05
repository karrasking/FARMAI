-- ========================================
-- INVESTIGACIÓN DETALLADA: detalleProblemaSuministro
-- ========================================

-- 1. Ver estructura completa del campo detalleProblemaSuministro
SELECT 
    pres->>'cn' as "CN",
    pres->'detalleProblemaSuministro'->>'cn' as "DetalleCN",
    to_timestamp((pres->'detalleProblemaSuministro'->>'fini')::bigint / 1000.0) as "FechaInicio",
    (pres->'detalleProblemaSuministro'->>'activo')::boolean as "Activo",
    LEFT(pres->'detalleProblemaSuministro'->>'observ', 100) as "Observaciones"
FROM "MedicamentoDetalleRaw" mdr,
jsonb_array_elements(mdr."Json"->'presentaciones') as pres
WHERE pres->'detalleProblemaSuministro' IS NOT NULL
LIMIT 20;

-- 2. Conteo de problemas activos vs inactivos
SELECT 
    'Activos' as "Estado",
    COUNT(*) as "Cantidad"
FROM "MedicamentoDetalleRaw" mdr,
jsonb_array_elements(mdr."Json"->'presentaciones') as pres
WHERE pres->'detalleProblemaSuministro' IS NOT NULL
AND (pres->'detalleProblemaSuministro'->>'activo')::boolean = true
UNION ALL
SELECT 
    'Inactivos',
    COUNT(*)
FROM "MedicamentoDetalleRaw" mdr,
jsonb_array_elements(mdr."Json"->'presentaciones') as pres
WHERE pres->'detalleProblemaSuministro' IS NOT NULL
AND (pres->'detalleProblemaSuministro'->>'activo')::boolean = false;

-- 3. Ver todas las keys disponibles en detalleProblemaSuministro
SELECT DISTINCT jsonb_object_keys(pres->'detalleProblemaSuministro') as "Campo"
FROM "MedicamentoDetalleRaw" mdr,
jsonb_array_elements(mdr."Json"->'presentaciones') as pres
WHERE pres->'detalleProblemaSuministro' IS NOT NULL;

-- 4. Ver problemas más recientes
SELECT 
    mdr."NRegistro",
    mdr."Json"->>'nombre' as "Medicamento",
    pres->>'cn' as "CN",
    to_timestamp((pres->'detalleProblemaSuministro'->>'fini')::bigint / 1000.0) as "FechaInicio",
    (pres->'detalleProblemaSuministro'->>'activo')::boolean as "Activo",
    pres->'detalleProblemaSuministro'->>'observ' as "Observaciones"
FROM "MedicamentoDetalleRaw" mdr,
jsonb_array_elements(mdr."Json"->'presentaciones') as pres
WHERE pres->'detalleProblemaSuministro' IS NOT NULL
AND (pres->'detalleProblemaSuministro'->>'activo')::boolean = true
ORDER BY (pres->'detalleProblemaSuministro'->>'fini')::bigint DESC
LIMIT 10;

-- 5. Verificar si ffin (fecha fin) existe
SELECT 
    pres->'detalleProblemaSuministro'->>'ffin' as "FechaFin",
    COUNT(*) as "Cantidad"
FROM "MedicamentoDetalleRaw" mdr,
jsonb_array_elements(mdr."Json"->'presentaciones') as pres
WHERE pres->'detalleProblemaSuministro' IS NOT NULL
GROUP BY pres->'detalleProblemaSuministro'->>'ffin';

-- 6. Ver sample observaciones completas
SELECT DISTINCT 
    pres->'detalleProblemaSuministro'->>'observ' as "Observacion"
FROM "MedicamentoDetalleRaw" mdr,
jsonb_array_elements(mdr."Json"->'presentaciones') as pres
WHERE pres->'detalleProblemaSuministro' IS NOT NULL
AND pres->'detalleProblemaSuministro'->>'observ' IS NOT NULL
LIMIT 10;
