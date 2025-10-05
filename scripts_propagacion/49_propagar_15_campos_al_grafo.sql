-- PROPAGAR 15 CAMPOS AL GRAFO
-- =============================
-- Actualizar nodos Medicamento en graph_node con todos los campos de negocio

-- 1. VER ESTADO ANTES
SELECT 
    'ANTES - Campos en Grafo' as momento,
    COUNT(CASE WHEN props ? 'Comercializado' THEN 1 END) as tiene_comercializado,
    COUNT(CASE WHEN props ? 'AfectaConduccion' THEN 1 END) as tiene_conduccion,
    COUNT(CASE WHEN props ? 'TrianguloNegro' THEN 1 END) as tiene_triangulo,
    COUNT(CASE WHEN props ? 'Huerfano' THEN 1 END) as tiene_huerfano,
    COUNT(CASE WHEN props ? 'Biosimilar' THEN 1 END) as tiene_biosimilar,
    COUNT(CASE WHEN props ? 'Psum' THEN 1 END) as tiene_psum,
    COUNT(CASE WHEN props ? 'AutorizadoPorEma' THEN 1 END) as tiene_ema,
    COUNT(CASE WHEN props ? 'RequiereReceta' THEN 1 END) as tiene_receta,
    COUNT(CASE WHEN props ? 'EsGenerico' THEN 1 END) as tiene_generico,
    COUNT(*) as total
FROM graph_node
WHERE node_type = 'Medicamento';

-- 2. PROPAGAR TODOS LOS 15 CAMPOS
UPDATE graph_node gn
SET props = gn.props || jsonb_build_object(
    'Comercializado', m."Comercializado",
    'AfectaConduccion', m."AfectaConduccion",
    'TrianguloNegro', m."TrianguloNegro",
    'Huerfano', m."Huerfano",
    'Biosimilar', m."Biosimilar",
    'Psum', m."Psum",
    'Fotos', m."Fotos",
    'MaterialesInformativos', m."MaterialesInformativos",
    'AutorizadoPorEma', m."AutorizadoPorEma",
    'TieneNotas', m."TieneNotas",
    'RequiereReceta', m."RequiereReceta",
    'EsGenerico', m."EsGenerico",
    'LabTitular', m."LabTitular",
    'Nombre', m."Nombre",
    'NRegistro', m."NRegistro"
)
FROM "Medicamentos" m
WHERE gn.node_type = 'Medicamento'
  AND gn.node_key = m."NRegistro";

-- 3. VER ESTADO DESPUÉS
SELECT 
    'DESPUES - Campos en Grafo' as momento,
    COUNT(CASE WHEN props ? 'Comercializado' THEN 1 END) as tiene_comercializado,
    COUNT(CASE WHEN props ? 'AfectaConduccion' THEN 1 END) as tiene_conduccion,
    COUNT(CASE WHEN props ? 'TrianguloNegro' THEN 1 END) as tiene_triangulo,
    COUNT(CASE WHEN props ? 'Huerfano' THEN 1 END) as tiene_huerfano,
    COUNT(CASE WHEN props ? 'Biosimilar' THEN 1 END) as tiene_biosimilar,
    COUNT(CASE WHEN props ? 'Psum' THEN 1 END) as tiene_psum,
    COUNT(CASE WHEN props ? 'AutorizadoPorEma' THEN 1 END) as tiene_ema,
    COUNT(CASE WHEN props ? 'RequiereReceta' THEN 1 END) as tiene_receta,
    COUNT(CASE WHEN props ? 'EsGenerico' THEN 1 END) as tiene_generico,
    COUNT(CASE WHEN props ? 'LabTitular' THEN 1 END) as tiene_laboratorio,
    COUNT(CASE WHEN props ? 'Nombre' THEN 1 END) as tiene_nombre,
    COUNT(*) as total
FROM graph_node
WHERE node_type = 'Medicamento';

-- 4. Ver UN ejemplo de nodo actualizado
SELECT 
    'EJEMPLO NODO ACTUALIZADO' as tipo,
    node_key as nregistro,
    jsonb_pretty(props) as propiedades_completas
FROM graph_node
WHERE node_type = 'Medicamento'
  AND props ? 'Nombre'
LIMIT 1;

-- 5. DISTRIBUCIÓN de valores en el grafo
SELECT 
    'DISTRIBUCION Comercializado' as campo,
    props->>'Comercializado' as valor,
    COUNT(*) as cantidad
FROM graph_node
WHERE node_type = 'Medicamento'
  AND props ? 'Comercializado'
GROUP BY props->>'Comercializado'
UNION ALL
SELECT 
    'DISTRIBUCION EsGenerico',
    props->>'EsGenerico',
    COUNT(*)
FROM graph_node
WHERE node_type = 'Medicamento'
  AND props ? 'EsGenerico'
GROUP BY props->>'EsGenerico'
UNION ALL
SELECT 
    'DISTRIBUCION RequiereReceta',
    props->>'RequiereReceta',
    COUNT(*)
FROM graph_node
WHERE node_type = 'Medicamento'
  AND props ? 'RequiereReceta'
GROUP BY props->>'RequiereReceta'
ORDER BY campo, valor DESC NULLS LAST;

-- 6. COMPARAR: Tabla vs Grafo ahora
SELECT 
    'COMPARACION FINAL' as titulo,
    'Tabla' as fuente,
    COUNT("Comercializado") as comercializados,
    COUNT("EsGenerico") as genericos,
    COUNT("RequiereReceta") as con_receta
FROM "Medicamentos"
UNION ALL
SELECT 
    'COMPARACION FINAL',
    'Grafo',
    COUNT(CASE WHEN props->>'Comercializado' = 'true' THEN 1 END),
    COUNT(CASE WHEN props->>'EsGenerico' = 'true' THEN 1 END),
    COUNT(CASE WHEN props->>'RequiereReceta' = 'true' THEN 1 END)
FROM graph_node
WHERE node_type = 'Medicamento';

-- 7. RESUMEN FINAL
SELECT 
    '🎉 PROPAGACION COMPLETA AL GRAFO' as titulo,
    (SELECT COUNT(*) FROM graph_node WHERE node_type = 'Medicamento') as nodos_medicamento,
    (SELECT COUNT(*) FROM graph_node WHERE node_type = 'Medicamento' AND props ? 'Comercializado') as con_comercializado,
    (SELECT COUNT(*) FROM graph_node WHERE node_type = 'Medicamento' AND props ? 'EsGenerico') as con_generico,
    (SELECT COUNT(*) FROM graph_node WHERE node_type = 'Medicamento' AND props ? 'RequiereReceta') as con_receta,
    (SELECT COUNT(*) FROM graph_node WHERE node_type = 'Medicamento' AND props ? 'Nombre') as con_nombre;
