-- ============================================================
-- PROPAGAR VTM (VIRTUAL THERAPEUTIC MOIETY) AL GRAFO
-- 8 agrupaciones virtuales de medicamentos
-- ============================================================

-- 1. Estado inicial
SELECT 'ANTES' as momento;
SELECT COUNT(*) as nodos_vtm FROM graph_node WHERE node_type = 'Vtm';

-- 2. Crear nodos Vtm
INSERT INTO graph_node (node_type, node_key, props)
SELECT
    'Vtm',
    "Id"::text,
    jsonb_build_object(
        'nombre', "Nombre",
        'id', "Id"
    )
FROM "Vtm"
ON CONFLICT (node_type, node_key) DO NOTHING;

-- 3. Estado final
SELECT 'DESPUÉS' as momento;
SELECT COUNT(*) as nodos_vtm FROM graph_node WHERE node_type = 'Vtm';

-- 4. Ejemplos
SELECT node_key, props->>'nombre' as nombre
FROM graph_node
WHERE node_type = 'Vtm';

SELECT '✅ VTM PROPAGADOS AL GRAFO (8 agrupaciones virtuales)' as resultado;
