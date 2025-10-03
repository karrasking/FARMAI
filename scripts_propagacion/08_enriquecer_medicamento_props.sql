-- ============================================
-- PASO 5: Enriquecer Medicamento.props
-- ============================================
-- Propósito: Añadir metadatos API a medicamentos
-- Updates esperados: ~20,000
-- ============================================

BEGIN;

-- Actualizar props de Medicamento con metadatos de API
UPDATE graph_node gn
SET props = props || jsonb_build_object(
  'fuente', 'cima_api',
  'ultima_actualizacion', mdr."FetchedAt",
  'hash_contenido', mdr."RowHash",
  'http_status', COALESCE(mdr."HttpStatus", 200)
)
FROM "MedicamentoDetalleRaw" mdr
WHERE gn.node_type = 'Medicamento'
  AND gn.node_key = mdr."NRegistro";

COMMIT;

-- Verificar
SELECT 
  COUNT(*) as total_actualizados,
  COUNT(CASE WHEN props ? 'fuente' THEN 1 END) as con_fuente,
  COUNT(CASE WHEN props ? 'ultima_actualizacion' THEN 1 END) as con_fecha,
  COUNT(CASE WHEN props ? 'hash_contenido' THEN 1 END) as con_hash
FROM graph_node
WHERE node_type = 'Medicamento';

-- Ejemplos
SELECT 
  node_key as nregistro,
  props->>'nombre' as nombre,
  props->>'fuente' as fuente,
  (props->>'ultima_actualizacion')::timestamp as ultima_act,
  LEFT(props->>'hash_contenido', 16) as hash
FROM graph_node
WHERE node_type = 'Medicamento'
  AND props ? 'fuente'
ORDER BY RANDOM()
LIMIT 5;
