-- ============================================
-- PASO 3: Crear Nodos FlagEstado
-- ============================================
-- Propósito: Añadir 4 nodos para flags especiales
-- Seguridad: ALTA - Solo inserta, no modifica nada
-- Tiempo estimado: <1 segundo
-- ============================================

BEGIN;

-- Insertar los 4 estados de flag
INSERT INTO graph_node (node_type, node_key, props)
VALUES 
  ('FlagEstado', 'EN_CUARENTENA', jsonb_build_object(
    'nombre', 'En Cuarentena',
    'descripcion', 'Medicamento con problemas de calidad de datos',
    'severidad', 'alta'
  )),
  ('FlagEstado', 'NO_ENCONTRADO', jsonb_build_object(
    'nombre', 'No Encontrado',
    'descripcion', 'No encontrado en API CIMA',
    'severidad', 'media'
  )),
  ('FlagEstado', 'SIN_DETALLE', jsonb_build_object(
    'nombre', 'Sin Detalle',
    'descripcion', 'Sin detalle y sin prescripción',
    'severidad', 'alta'
  )),
  ('FlagEstado', 'ACTIVO', jsonb_build_object(
    'nombre', 'Activo',
    'descripcion', 'Medicamento activo y disponible',
    'severidad', 'ninguna'
  ))
ON CONFLICT (node_type, node_key) DO UPDATE
  SET props = EXCLUDED.props;

COMMIT;

-- Verificar
SELECT 
  node_key as codigo,
  props->>'nombre' as nombre,
  props->>'descripcion' as descripcion,
  props->>'severidad' as severidad
FROM graph_node
WHERE node_type = 'FlagEstado'
ORDER BY node_key;
