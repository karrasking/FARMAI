-- ============================================================
-- ANÁLISIS COMPLETO DE PRINCIPIOS ACTIVOS
-- Identificar duplicación y planificar consolidación
-- ============================================================

-- 1. Tipos de nodos PA
SELECT node_type, COUNT(*) as total
FROM graph_node
WHERE node_type IN ('PrincipioActivo', 'Sustancia', 'SustanciaActiva')
GROUP BY node_type
ORDER BY total DESC;

-- 2. Relaciones por tipo de nodo PA
SELECT dst_type as tipo_nodo, rel, COUNT(*) as total
FROM graph_edge
WHERE dst_type IN ('PrincipioActivo', 'Sustancia', 'SustanciaActiva')
GROUP BY dst_type, rel
ORDER BY dst_type, total DESC;

-- 3. Ejemplo de nodos de cada tipo
SELECT node_type, node_key, props->>'nombre' as nombre
FROM graph_node
WHERE node_type = 'PrincipioActivo'
LIMIT 3;

SELECT node_type, node_key, props->>'nombre' as nombre
FROM graph_node
WHERE node_type = 'Sustancia'
LIMIT 3;

SELECT node_type, node_key, props->>'nombre' as nombre
FROM graph_node
WHERE node_type = 'SustanciaActiva'
LIMIT 3;

-- 4. Análisis pa_unmatched
SELECT COUNT(*) as total_sin_mapear FROM pa_unmatched;

SELECT "CodigoRaw", "NombreRaw", COUNT(*) as medicamentos
FROM pa_unmatched
GROUP BY "CodigoRaw", "NombreRaw"
ORDER BY medicamentos DESC
LIMIT 10;

-- 5. Verificar overlap entre tipos
SELECT 
    COUNT(DISTINCT CASE WHEN node_type = 'PrincipioActivo' THEN node_key END) as principio_activo,
    COUNT(DISTINCT CASE WHEN node_type = 'Sustancia' THEN node_key END) as sustancia,
    COUNT(DISTINCT CASE WHEN node_type = 'SustanciaActiva' THEN node_key END) as sustancia_activa
FROM graph_node
WHERE node_type IN ('PrincipioActivo', 'Sustancia', 'SustanciaActiva');

-- 6. Verificar si hay keys duplicados entre tipos
SELECT node_key, COUNT(DISTINCT node_type) as tipos_count
FROM graph_node
WHERE node_type IN ('PrincipioActivo', 'Sustancia', 'SustanciaActiva')
GROUP BY node_key
HAVING COUNT(DISTINCT node_type) > 1;
