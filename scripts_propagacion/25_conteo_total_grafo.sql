-- ============================================================
-- CONTEO TOTAL DE NODOS Y ARISTAS EN GRAFO
-- ============================================================

-- 1. Total de nodos por tipo
SELECT 
    node_type,
    COUNT(*) as cantidad
FROM graph_node
GROUP BY node_type
ORDER BY cantidad DESC;

-- 2. Total general de nodos
SELECT COUNT(*) as total_nodos FROM graph_node;

-- 3. Total de aristas por tipo de relación
SELECT 
    rel,
    COUNT(*) as cantidad
FROM graph_edge
GROUP BY rel
ORDER BY cantidad DESC;

-- 4. Total general de aristas
SELECT COUNT(*) as total_aristas FROM graph_edge;

-- 5. Resumen de aristas por src_type → dst_type
SELECT 
    src_type || ' → ' || dst_type as flujo,
    COUNT(*) as cantidad
FROM graph_edge
GROUP BY src_type, dst_type
ORDER BY cantidad DESC
LIMIT 30;

-- 6. Verificar salud del grafo
SELECT 
    'Nodos totales' as metrica,
    COUNT(*)::text as valor
FROM graph_node
UNION ALL
SELECT 
    'Aristas totales',
    COUNT(*)::text
FROM graph_edge
UNION ALL
SELECT 
    'Tipos de nodos distintos',
    COUNT(DISTINCT node_type)::text
FROM graph_node
UNION ALL
SELECT 
    'Tipos de relaciones distintas',
    COUNT(DISTINCT rel)::text
FROM graph_edge;
