-- ============================================
-- PASO 6: Enriquecer Presentacion.props
-- ============================================
-- Propósito: Añadir contenido detallado a presentaciones
-- Updates esperados: ~29,000
-- ============================================

BEGIN;

-- Actualizar props de Presentacion con contenido
UPDATE graph_node gn
SET props = props || jsonb_build_object(
  'envase', pc."Envase",
  'cantidad_raw', pc."CantidadRaw",
  'cantidad_num', pc."CantidadNum",
  'unidad', pc."Unidad",
  'notas', pc."Notas"
)
FROM "PresentacionContenido" pc
WHERE gn.node_type = 'Presentacion'
  AND gn.node_key = pc."CN"
  AND pc."Secuencia" = 1;

COMMIT;

-- Verificar
SELECT 
  COUNT(*) as total_presentaciones,
  COUNT(CASE WHEN props ? 'envase' THEN 1 END) as con_envase,
  COUNT(CASE WHEN props ? 'unidad' THEN 1 END) as con_unidad,
  COUNT(CASE WHEN props ? 'cantidad_num' THEN 1 END) as con_cantidad
FROM graph_node
WHERE node_type = 'Presentacion';

-- Ejemplos
SELECT 
  node_key as cn,
  props->>'nombre' as nombre,
  props->>'envase' as envase,
  props->>'cantidad_raw' as cantidad,
  props->>'unidad' as unidad
FROM graph_node
WHERE node_type = 'Presentacion'
  AND props ? 'envase'
ORDER BY RANDOM()
LIMIT 5;
