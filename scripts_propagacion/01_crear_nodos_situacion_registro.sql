-- ============================================
-- PASO 1: Crear Nodos SituacionRegistro
-- ============================================
-- Propósito: Añadir 3 nodos para estados regulatorios
-- Seguridad: ALTA - Solo inserta, no modifica nada
-- Tiempo estimado: <1 segundo
-- ============================================

BEGIN;

-- Verificar que no existan ya
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM graph_node WHERE node_type = 'SituacionRegistro') THEN
        RAISE NOTICE 'ADVERTENCIA: Ya existen nodos SituacionRegistro';
    END IF;
END $$;

-- Insertar los 3 estados desde la tabla staging
INSERT INTO graph_node (node_type, node_key, props)
SELECT 
  'SituacionRegistro',
  "Codigo"::text,
  jsonb_build_object(
    'nombre', "Nombre",
    'nombre_canon', "NombreCanon",
    'descripcion', CASE 
      WHEN "Codigo" = 1 THEN 'Medicamento autorizado para comercialización'
      WHEN "Codigo" = 3 THEN 'Registro anulado'
      WHEN "Codigo" = 4 THEN 'Comercialización suspendida'
      ELSE 'Estado no especificado'
    END
  )
FROM "SituacionRegistroDicStaging"
ON CONFLICT (node_type, node_key) DO UPDATE
  SET props = EXCLUDED.props;

-- Verificar resultado
DO $$
DECLARE
  v_count int;
BEGIN
  SELECT COUNT(*) INTO v_count 
  FROM graph_node 
  WHERE node_type = 'SituacionRegistro';
  
  RAISE NOTICE 'Nodos SituacionRegistro creados: %', v_count;
  
  IF v_count != 3 THEN
    RAISE EXCEPTION 'ERROR: Se esperaban 3 nodos, se crearon %', v_count;
  END IF;
END $$;

-- Mostrar resultado
SELECT 
  node_key as codigo,
  props->>'nombre' as nombre,
  props->>'descripcion' as descripcion
FROM graph_node
WHERE node_type = 'SituacionRegistro'
ORDER BY node_key;

COMMIT;

-- ============================================
-- RESULTADO ESPERADO:
-- codigo | nombre     | descripcion
-- -------+------------+------------------------------------------
--    1   | Autorizado | Medicamento autorizado para comercialización
--    3   | Anulado    | Registro anulado
--    4   | Suspenso   | Comercialización suspendida
-- ============================================
