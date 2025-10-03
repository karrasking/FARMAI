-- ============================================================
-- PROPAGAR ALIASES AL GRAFO
-- Crear nodos Alias y relaciones TIENE_ALIAS
-- ============================================================

-- 1. Estado inicial
SELECT 'ANTES' as momento;
SELECT COUNT(*) as nodos_alias_existentes 
FROM graph_node 
WHERE node_type = 'Alias';

-- 2. Crear nodos Alias desde AliasExcipiente
INSERT INTO graph_node (node_type, node_key, props)
SELECT DISTINCT
    'Alias',
    LOWER("Alias"),
    jsonb_build_object(
        'alias', "Alias",
        'canon', "AliasCanon",
        'tipo', 'excipiente'
    )
FROM "AliasExcipiente"
ON CONFLICT (node_type, node_key) DO NOTHING;

-- 3. Crear nodos Alias desde AliasSustancia
INSERT INTO graph_node (node_type, node_key, props)
SELECT DISTINCT
    'Alias',
    LOWER("Alias"),
    jsonb_build_object(
        'alias', "Alias",
        'canon', "Canon",
        'tipo', 'sustancia'
    )
FROM "AliasSustancia"
ON CONFLICT (node_type, node_key) DO NOTHING;

-- 4. Crear relaciones Excipiente -> Alias
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT
    'Excipiente',
    ae."ExcipienteId"::text,
    'TIENE_ALIAS',
    'Alias',
    LOWER(ae."Alias"),
    jsonb_build_object('tipo', 'excipiente')
FROM "AliasExcipiente" ae
WHERE ae."ExcipienteId" IS NOT NULL
ON CONFLICT (src_type, src_key, rel, dst_type, dst_key) DO NOTHING;

-- 5. Crear relaciones PrincipioActivo -> Alias (desde AliasSustancia)
-- Nota: Canon en AliasSustancia se mapea a PrincipioActivo por nombre
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT
    'PrincipioActivo',
    gn.node_key,
    'TIENE_ALIAS',
    'Alias',
    LOWER(as2."Alias"),
    jsonb_build_object('tipo', 'sustancia')
FROM "AliasSustancia" as2
JOIN graph_node gn 
    ON gn.node_type = 'PrincipioActivo'
    AND UPPER(gn.props->>'nombre') = UPPER(as2."Canon")
ON CONFLICT (src_type, src_key, rel, dst_type, dst_key) DO NOTHING;

-- 6. Estado final
SELECT 'DESPUÉS' as momento;
SELECT COUNT(*) as nodos_alias_totales 
FROM graph_node 
WHERE node_type = 'Alias';

SELECT rel, COUNT(*) as total
FROM graph_edge
WHERE rel = 'TIENE_ALIAS'
GROUP BY rel;

-- 7. Ejemplos
SELECT gn.node_key, gn.props->>'alias' as alias_text, gn.props->>'canon' as canon
FROM graph_node gn
WHERE node_type = 'Alias'
LIMIT 10;

SELECT '✅ ALIASES PROPAGADOS AL GRAFO' as resultado;
