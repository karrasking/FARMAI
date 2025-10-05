-- ESTADO REAL DEL GRAFO - TABLAS CORRECTAS
-- ===========================================
-- Ver qué hay en graph_node y graph_edge

-- 1. Ver estructura de graph_node
SELECT 
    'COLUMNAS graph_node' as tipo,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'graph_node'
ORDER BY ordinal_position;

-- 2. Ver estructura de graph_edge  
SELECT 
    'COLUMNAS graph_edge' as tipo,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'graph_edge'
ORDER BY ordinal_position;

-- 3. Contar nodos totales
SELECT 
    'CONTEO NODOS' as tipo,
    COUNT(*) as total_nodos,
    COUNT(DISTINCT node_type) as tipos_distintos
FROM graph_node;

-- 4. Contar nodos por tipo
SELECT 
    'NODOS POR TIPO' as categoria,
    node_type as tipo,
    COUNT(*) as cantidad
FROM graph_node
GROUP BY node_type
ORDER BY cantidad DESC;

-- 5. Ver UN nodo Medicamento de ejemplo
SELECT 
    'EJEMPLO NODO MEDICAMENTO' as tipo,
    node_id,
    node_type,
    jsonb_pretty(properties::jsonb) as propiedades
FROM graph_node
WHERE node_type = 'Medicamento'
LIMIT 1;

-- 6. Ver QUÉ PROPIEDADES tienen los nodos Medicamento
SELECT 
    'PROPIEDADES EN MEDICAMENTO' as tipo,
    jsonb_object_keys(properties::jsonb) as propiedad,
    COUNT(*) as apariciones
FROM graph_node
WHERE node_type = 'Medicamento'
  AND properties IS NOT NULL
  AND properties::text != '{}'
GROUP BY propiedad
ORDER BY apariciones DESC;

-- 7. Verificar los 4 NUEVOS campos en el grafo
SELECT 
    'NUEVOS CAMPOS EN GRAFO?' as pregunta,
    COUNT(CASE WHEN properties::jsonb ? 'AutorizadoPorEma' THEN 1 END) as tiene_ema,
    COUNT(CASE WHEN properties::jsonb ? 'TieneNotas' THEN 1 END) as tiene_notas,
    COUNT(CASE WHEN properties::jsonb ? 'RequiereReceta' THEN 1 END) as tiene_receta,
    COUNT(CASE WHEN properties::jsonb ? 'EsGenerico' THEN 1 END) as tiene_generico,
    COUNT(*) as total_medicamentos_grafo
FROM graph_node
WHERE node_type = 'Medicamento';

-- 8. Contar aristas totales
SELECT 
    'CONTEO ARISTAS' as tipo,
    COUNT(*) as total_aristas,
    COUNT(DISTINCT edge_type) as tipos_distintos
FROM graph_edge;

-- 9. Contar aristas por tipo
SELECT 
    'ARISTAS POR TIPO' as categoria,
    edge_type as tipo,
    COUNT(*) as cantidad
FROM graph_edge
GROUP BY edge_type
ORDER BY cantidad DESC;

-- 10. Resumen completo del grafo
SELECT 
    'RESUMEN GRAFO COMPLETO' as titulo,
    (SELECT COUNT(*) FROM graph_node) as total_nodos,
    (SELECT COUNT(DISTINCT node_type) FROM graph_node) as tipos_nodos,
    (SELECT COUNT(*) FROM graph_edge) as total_aristas,
    (SELECT COUNT(DISTINCT edge_type) FROM graph_edge) as tipos_aristas;
