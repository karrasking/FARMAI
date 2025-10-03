-- ============================================================
-- ACTUALIZAR NOMBRES EN NODOS EXCIPIENTE
-- ============================================================

-- Ver estado antes
SELECT 
    'ANTES - Excipientes sin nombre' as estado,
    COUNT(*) as cantidad
FROM graph_node 
WHERE node_type = 'Excipiente' 
  AND (props IS NULL OR NOT props ? 'nombre');

-- Actualizar nodos Excipiente con nombres
UPDATE graph_node gn
SET props = COALESCE(props, '{}'::jsonb) || jsonb_build_object('nombre', e."Nombre")
FROM "Excipiente" e
WHERE gn.node_type = 'Excipiente'
  AND gn.node_key = e."Id"::text;

-- Ver estado después
SELECT 
    'DESPUES - Excipientes sin nombre' as estado,
    COUNT(*) as cantidad
FROM graph_node 
WHERE node_type = 'Excipiente' 
  AND (props IS NULL OR NOT props ? 'nombre');

-- Muestra de nodos actualizados
SELECT 
    node_key,
    props->>'nombre' as nombre_excipiente
FROM graph_node
WHERE node_type = 'Excipiente'
LIMIT 20;

-- Ahora sí, verificar aristas con nombres
SELECT 
    ge.src_key as nregistro,
    gn_med.props->>'nombre' as medicamento,
    gn_exc.props->>'nombre' as excipiente,
    ge.props->>'cantidad' as cantidad,
    ge.props->>'unidad' as unidad,
    ge.props->>'obligatorio' as obligatorio
FROM graph_edge ge
JOIN graph_node gn_med ON ge.src_key = gn_med.node_key AND gn_med.node_type = 'Medicamento'
JOIN graph_node gn_exc ON ge.dst_key = gn_exc.node_key AND gn_exc.node_type = 'Excipiente'
WHERE ge.rel = 'CONTIENE_EXCIPIENTE'
  AND gn_med.props ? 'nombre'
LIMIT 20;

SELECT '✅ NOMBRES DE EXCIPIENTES ACTUALIZADOS' as resultado;
