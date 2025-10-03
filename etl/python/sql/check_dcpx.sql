SET search_path TO public;

SELECT 'DCP nodos'  AS what, COUNT(*) FROM graph_node WHERE node_type='DCP';
SELECT 'DCPF nodos' AS what, COUNT(*) FROM graph_node WHERE node_type='DCPF';
SELECT 'DCSA nodos' AS what, COUNT(*) FROM graph_node WHERE node_type='DCSA';

SELECT 'Med->DCP'   AS what, COUNT(*) FROM graph_edge WHERE rel='PERTENECE_A_DCP';
SELECT 'Med->DCPF'  AS what, COUNT(*) FROM graph_edge WHERE rel='PERTENECE_A_DCPF';
SELECT 'Med->DCSA'  AS what, COUNT(*) FROM graph_edge WHERE rel='PERTENECE_A_DCSA';
