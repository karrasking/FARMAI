\set ON_ERROR_STOP on
SET search_path TO public;
SELECT g.node_type, g.node_key, g.props->>'nombre' AS nombre
FROM graph_node g
WHERE g.node_type IN ('DCP','DCPF','DCSA')
ORDER BY g.node_type, g.node_key
LIMIT 30;
