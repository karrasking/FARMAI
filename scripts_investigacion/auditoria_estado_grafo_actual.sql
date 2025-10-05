-- AUDITORÍA COMPLETA DEL GRAFO ACTUAL
-- ======================================
-- Ver qué nodos y aristas tenemos actualmente en AGE

-- 1. Ver todos los TIPOS DE NODOS en el grafo
SELECT 
    'TIPOS DE NODOS' as categoria,
    label as tipo_nodo,
    COUNT(*) as cantidad
FROM cypher('farmai', $$
    MATCH (n)
    RETURN labels(n)[0] as label
$$) as (label agtype)
GROUP BY label
ORDER BY cantidad DESC;

-- 2. Ver todos los TIPOS DE RELACIONES en el grafo
SELECT 
    'TIPOS DE RELACIONES' as categoria,
    rel_type as tipo_relacion,
    COUNT(*) as cantidad
FROM cypher('farmai', $$
    MATCH ()-[r]->()
    RETURN type(r) as rel_type
$$) as (rel_type agtype)
GROUP BY rel_type
ORDER BY cantidad DESC;

-- 3. RESUMEN COMPLETO del grafo
SELECT 
    'RESUMEN GRAFO' as titulo,
    (SELECT COUNT(*) FROM cypher('farmai', $$ MATCH (n) RETURN n $$) as (n agtype)) as total_nodos,
    (SELECT COUNT(*) FROM cypher('farmai', $$ MATCH ()-[r]->() RETURN r $$) as (r agtype)) as total_relaciones,
    (SELECT COUNT(DISTINCT label) FROM cypher('farmai', $$ MATCH (n) RETURN labels(n)[0] as label $$) as (label agtype)) as tipos_nodos,
    (SELECT COUNT(DISTINCT rel_type) FROM cypher('farmai', $$ MATCH ()-[r]->() RETURN type(r) as rel_type $$) as (rel_type agtype)) as tipos_relaciones;

-- 4. Ver PROPIEDADES de los nodos Medicamento
SELECT 
    'PROPIEDADES MEDICAMENTO' as tipo,
    jsonb_object_keys(properties::jsonb) as propiedad,
    COUNT(*) as apariciones
FROM cypher('farmai', $$
    MATCH (m:Medicamento)
    RETURN properties(m) as properties
$$) as (properties agtype)
WHERE properties::text != '{}'
GROUP BY propiedad
ORDER BY apariciones DESC;

-- 5. Ejemplo de UN medicamento con todas sus propiedades
SELECT 
    'EJEMPLO MEDICAMENTO GRAFO' as tipo,
    jsonb_pretty(properties::jsonb) as props
FROM cypher('farmai', $$
    MATCH (m:Medicamento)
    RETURN properties(m) as properties
    LIMIT 1
$$) as (properties agtype);

-- 6. Ver qué FLAGS están en el grafo
SELECT 
    'FLAGS EN GRAFO' as categoria,
    CASE 
        WHEN properties::jsonb ? 'AfectaConduccion' THEN 'AfectaConduccion'
        WHEN properties::jsonb ? 'TrianguloNegro' THEN 'TrianguloNegro'
        WHEN properties::jsonb ? 'Huerfano' THEN 'Huerfano'
        WHEN properties::jsonb ? 'Biosimilar' THEN 'Biosimilar'
        WHEN properties::jsonb ? 'Comercializado' THEN 'Comercializado'
        WHEN properties::jsonb ? 'Psum' THEN 'Psum'
        ELSE 'otros'
    END as flag_name,
    COUNT(*) as medicamentos_con_flag
FROM cypher('farmai', $$
    MATCH (m:Medicamento)
    RETURN properties(m) as properties
$$) as (properties agtype)
WHERE properties::text != '{}'
GROUP BY flag_name
ORDER BY medicamentos_con_flag DESC;

-- 7. Comparar: ¿Tenemos los 4 NUEVOS campos en el grafo?
SELECT 
    'CAMPOS NUEVOS EN GRAFO?' as pregunta,
    COUNT(CASE WHEN properties::jsonb ? 'AutorizadoPorEma' THEN 1 END) as tiene_ema,
    COUNT(CASE WHEN properties::jsonb ? 'TieneNotas' THEN 1 END) as tiene_notas,
    COUNT(CASE WHEN properties::jsonb ? 'RequiereReceta' THEN 1 END) as tiene_receta,
    COUNT(CASE WHEN properties::jsonb ? 'EsGenerico' THEN 1 END) as tiene_generico,
    COUNT(*) as total_medicamentos_grafo
FROM cypher('farmai', $$
    MATCH (m:Medicamento)
    RETURN properties(m) as properties
$$) as (properties agtype);

-- 8. Ver relaciones de ejemplo
SELECT 
    'EJEMPLO RELACIONES' as tipo,
    source_label,
    rel_type,
    target_label,
    COUNT(*) as cantidad
FROM cypher('farmai', $$
    MATCH (s)-[r]->(t)
    RETURN labels(s)[0] as source_label, type(r) as rel_type, labels(t)[0] as target_label
$$) as (source_label agtype, rel_type agtype, target_label agtype)
GROUP BY source_label, rel_type, target_label
ORDER BY cantidad DESC
LIMIT 20;
