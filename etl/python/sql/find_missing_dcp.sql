\set ON_ERROR_STOP on
SET search_path TO public;
SELECT g.node_key
FROM graph_node g
LEFT JOIN "DcpDicStaging" d ON d."CodigoDcp" = g.node_key
WHERE g.node_type='DCP' AND COALESCE(d."Nombre",'')=''
LIMIT 50;
