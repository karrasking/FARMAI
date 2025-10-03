-- ============================================================
-- ENRIQUECER ARISTAS CONTIENE_PA CON COMPOSICIÓN DETALLADA
-- Añadir props de PrincipioActivoStaging (26,606 registros)
-- ============================================================

-- 1. Ver estado actual de aristas PERTENECE_A_PRINCIPIO_ACTIVO
SELECT 
    COUNT(*) as total_aristas,
    COUNT(CASE WHEN props ? 'codigo_raw' THEN 1 END) as con_codigo_raw,
    COUNT(CASE WHEN props ? 'cantidad_raw' THEN 1 END) as con_cantidad
FROM graph_edge
WHERE rel = 'PERTENECE_A_PRINCIPIO_ACTIVO';

-- 2. Enriquecer aristas con datos de PrincipioActivoStaging
UPDATE graph_edge ge
SET props = props || jsonb_build_object(
    'codigo_raw', pas."CodigoRaw",
    'nombre_raw', pas."NombreRaw",
    'unidad_raw', pas."UnidadRaw",
    'cantidad_raw', pas."CantidadRaw",
    'orden', pas."Orden",
    'nombre_canon', pas."NombreCanon"
)
FROM "PrincipioActivoStaging" pas
WHERE ge.rel = 'PERTENECE_A_PRINCIPIO_ACTIVO'
  AND ge.src_key = pas."NRegistro"
  AND ge.dst_key = pas."SustanciaId"::text
  AND pas."CodigoRaw" IS NOT NULL;

-- 3. Verificar resultado
SELECT 
    COUNT(*) as total_aristas,
    COUNT(CASE WHEN props ? 'codigo_raw' THEN 1 END) as con_codigo_raw,
    COUNT(CASE WHEN props ? 'cantidad_raw' THEN 1 END) as con_cantidad,
    COUNT(CASE WHEN props ? 'nombre_raw' THEN 1 END) as con_nombre_raw,
    COUNT(CASE WHEN props ? 'orden' THEN 1 END) as con_orden
FROM graph_edge
WHERE rel = 'PERTENECE_A_PRINCIPIO_ACTIVO';

-- 4. Ejemplo de arista enriquecida
SELECT 
    src_key as nregistro,
    dst_key as sustancia_id,
    props->>'codigo_raw' as codigo,
    props->>'nombre_raw' as nombre,
    props->>'cantidad_raw' as cantidad,
    props->>'unidad_raw' as unidad,
    props->>'orden' as orden,
    props->>'nombre_canon' as nombre_canon
FROM graph_edge
WHERE rel = 'PERTENECE_A_PRINCIPIO_ACTIVO'
  AND props ? 'codigo_raw'
LIMIT 10;

-- 5. Estadísticas de composición
SELECT 
    COUNT(DISTINCT src_key) as medicamentos_con_composicion_detallada
FROM graph_edge
WHERE rel = 'PERTENECE_A_PRINCIPIO_ACTIVO'
  AND props ? 'cantidad_raw';

SELECT '✅ ARISTAS CONTIENE_PA ENRIQUECIDAS CON COMPOSICIÓN DETALLADA' as resultado;
