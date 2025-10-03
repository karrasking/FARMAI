\set ON_ERROR_STOP on
SET search_path TO public;
SELECT g.node_key
FROM graph_node g
LEFT JOIN "DcpfDicStaging" d ON d."CodigoDcpf" = g.node_key
WHERE g.node_type='DCPF' AND COALESCE(d."Nombre",'')=''
LIMIT 50;
