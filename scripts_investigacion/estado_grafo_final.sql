-- ESTADO FINAL DEL GRAFO - NOMBRES CORRECTOS
-- ============================================

-- 1. RESUMEN DEL GRAFO
SELECT 
    '🎯 RESUMEN GRAFO' as titulo,
    COUNT(*) as total_nodos,
    COUNT(DISTINCT node_type) as tipos_nodos
FROM graph_node;

SELECT 
    '🎯 RESUMEN ARISTAS' as titulo,
    COUNT(*) as total_aristas,
    COUNT(DISTINCT rel) as tipos_relaciones
FROM graph_edge;

-- 2. Ver UN nodo Medicamento de ejemplo
SELECT 
    'EJEMPLO MEDICAMENTO GRAFO' as tipo,
    node_key,
    name,
    jsonb_pretty(props) as propiedades
FROM graph_node
WHERE node_type = 'Medicamento'
LIMIT 1;

-- 3. Ver QUÉ PROPIEDADES tienen los nodos Medicamento
SELECT 
    'PROPIEDADES EN MEDICAMENTO' as tipo,
    jsonb_object_keys(props) as propiedad,
    COUNT(*) as medicamentos_con_esta_prop
FROM graph_node
WHERE node_type = 'Medicamento'
  AND props IS NOT NULL
  AND props::text != '{}'
GROUP BY propiedad
ORDER BY medicamentos_con_esta_prop DESC;

-- 4. Verificar los 4 NUEVOS campos en el grafo
SELECT 
    '⚠️ NUEVOS CAMPOS EN GRAFO?' as pregunta,
    COUNT(CASE WHEN props ? 'AutorizadoPorEma' THEN 1 END) as tiene_ema,
    COUNT(CASE WHEN props ? 'TieneNotas' THEN 1 END) as tiene_notas,
    COUNT(CASE WHEN props ? 'RequiereReceta' THEN 1 END) as tiene_receta,
    COUNT(CASE WHEN props ? 'EsGenerico' THEN 1 END) as tiene_generico,
    COUNT(*) as total_medicamentos_grafo
FROM graph_node
WHERE node_type = 'Medicamento';

-- 5. Ver campos ACTUALES que SÍ están en el grafo
SELECT 
    '✅ CAMPOS ACTUALES EN GRAFO' as estado,
    COUNT(CASE WHEN props ? 'AfectaConduccion' THEN 1 END) as tiene_conduccion,
    COUNT(CASE WHEN props ? 'TrianguloNegro' THEN 1 END) as tiene_triangulo,
    COUNT(CASE WHEN props ? 'Huerfano' THEN 1 END) as tiene_huerfano,
    COUNT(CASE WHEN props ? 'Biosimilar' THEN 1 END) as tiene_biosimilar,
    COUNT(CASE WHEN props ? 'Comercializado' THEN 1 END) as tiene_comercializado,
    COUNT(CASE WHEN props ? 'Psum' THEN 1 END) as tiene_psum,
    COUNT(*) as total_medicamentos
FROM graph_node
WHERE node_type = 'Medicamento';

-- 6. Tipos de relaciones en el grafo
SELECT 
    'TIPOS DE RELACIONES' as categoria,
    rel as relacion,
    COUNT(*) as cantidad
FROM graph_edge
GROUP BY rel
ORDER BY cantidad DESC
LIMIT 20;

-- 7. Comparar: TABLA vs GRAFO
SELECT 
    'COMPARACIÓN TABLA vs GRAFO' as titulo,
    (SELECT COUNT(*) FROM "Medicamentos") as medicamentos_tabla,
    (SELECT COUNT(*) FROM graph_node WHERE node_type = 'Medicamento') as medicamentos_grafo,
    (SELECT COUNT(*) FROM "Medicamentos") - (SELECT COUNT(*) FROM graph_node WHERE node_type = 'Medicamento') as diferencia;
