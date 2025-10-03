SET search_path TO public;
INSERT INTO graph_edge (src_type,src_key,rel,dst_type,dst_key,props)
SELECT 'Medicamento', p."NRegistro", 'TIENE_PRESENTACION', 'Presentacion', p."CodNacion", '{}'::jsonb
FROM "PrescripcionStaging_NUEVA" p
JOIN graph_node gm ON gm.node_type='Medicamento'  AND gm.node_key=p."NRegistro"
JOIN graph_node gp ON gp.node_type='Presentacion' AND gp.node_key=p."CodNacion"
LEFT JOIN graph_edge ge
       ON ge.src_type='Medicamento' AND ge.src_key=p."NRegistro"
      AND ge.rel='TIENE_PRESENTACION'
      AND ge.dst_type='Presentacion' AND ge.dst_key=p."CodNacion"
WHERE ge.src_key IS NULL;
