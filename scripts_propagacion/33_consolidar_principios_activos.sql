-- ============================================================
-- CONSOLIDAR PRINCIPIOS ACTIVOS A UN SOLO TIPO
-- Paso 1: Actualizar nombres en PrincipioActivo desde SustanciaActiva
-- Paso 2: Eliminar tipos duplicados
-- ============================================================

-- 1. Estado inicial
SELECT 'ESTADO INICIAL' as paso;
SELECT node_type, COUNT(*) as total
FROM graph_node
WHERE node_type IN ('PrincipioActivo', 'Sustancia', 'SustanciaActiva')
GROUP BY node_type;

-- 2. Actualizar nombres en PrincipioActivo desde SustanciaActiva
UPDATE graph_node pa
SET props = props || jsonb_build_object('nombre', sa.props->>'nombre')
FROM graph_node sa
WHERE pa.node_type = 'PrincipioActivo'
  AND sa.node_type = 'SustanciaActiva'
  AND pa.node_key = sa.node_key
  AND sa.props ? 'nombre'
  AND sa.props->>'nombre' IS NOT NULL
  AND sa.props->>'nombre' != '';

-- 3. Verificar actualización
SELECT COUNT(*) as principios_activos_con_nombre
FROM graph_node
WHERE node_type = 'PrincipioActivo'
  AND props ? 'nombre'
  AND props->>'nombre' IS NOT NULL;

-- 4. Ejemplo de nodos actualizados
SELECT node_type, node_key, props->>'nombre' as nombre
FROM graph_node
WHERE node_type = 'PrincipioActivo'
  AND props ? 'nombre'
LIMIT 5;

-- 5. Eliminar nodos duplicados (Sustancia y SustanciaActiva)
DELETE FROM graph_node
WHERE node_type IN ('Sustancia', 'SustanciaActiva');

-- 6. Estado final
SELECT 'ESTADO FINAL' as paso;
SELECT node_type, COUNT(*) as total
FROM graph_node
WHERE node_type IN ('PrincipioActivo', 'Sustancia', 'SustanciaActiva')
GROUP BY node_type;

-- 7. Verificar relaciones intactas
SELECT rel, COUNT(*) as total
FROM graph_edge
WHERE dst_type = 'PrincipioActivo'
GROUP BY rel;

SELECT '✅ CONSOLIDACIÓN COMPLETADA - AHORA SOLO EXISTE PrincipioActivo' as resultado;
