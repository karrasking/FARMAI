\set ON_ERROR_STOP on
SET search_path TO public;
SELECT 'DCPF->DCP' AS what, COUNT(*) FROM graph_edge
 WHERE src_type='DCPF' AND dst_type='DCP'  AND rel='PERTENECE_A_DCP';
SELECT 'DCP->DCSA' AS what, COUNT(*) FROM graph_edge
 WHERE src_type='DCP'  AND dst_type='DCSA' AND rel='PERTENECE_A_DCSA';
