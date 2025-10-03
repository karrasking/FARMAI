\set ON_ERROR_STOP on
SET search_path TO public;

-- DCPF -> DCP (diccionario)
INSERT INTO graph_edge (src_type,src_key,rel,dst_type,dst_key,props)
SELECT DISTINCT 'DCPF', d."CodigoDcpf", 'PERTENECE_A_DCP', 'DCP', d."CodigoDcp", '{}'::jsonb
FROM "DcpfDicStaging" d
JOIN graph_node s ON s.node_type='DCPF' AND s.node_key=d."CodigoDcpf"
JOIN graph_node t ON t.node_type='DCP'  AND t.node_key=d."CodigoDcp"
ON CONFLICT (src_type,src_key,rel,dst_type,dst_key) DO NOTHING;

-- DCP -> DCSA (diccionario)
INSERT INTO graph_edge (src_type,src_key,rel,dst_type,dst_key,props)
SELECT DISTINCT 'DCP', d."CodigoDcp", 'PERTENECE_A_DCSA', 'DCSA', d."CodigoDcsa", '{}'::jsonb
FROM "DcpDicStaging" d
JOIN graph_node s ON s.node_type='DCP'  AND s.node_key=d."CodigoDcp"
JOIN graph_node t ON t.node_type='DCSA' AND t.node_key=d."CodigoDcsa"
WHERE COALESCE(d."CodigoDcsa",'') <> ''
ON CONFLICT (src_type,src_key,rel,dst_type,dst_key) DO NOTHING;

-- Fallback por Prescripcion: DCPF -> DCP
INSERT INTO graph_edge (src_type,src_key,rel,dst_type,dst_key,props)
SELECT DISTINCT 'DCPF', p."CodDcpf", 'PERTENECE_A_DCP', 'DCP', p."CodDcp", '{}'::jsonb
FROM "PrescripcionStaging_NUEVA" p
JOIN graph_node s ON s.node_type='DCPF' AND s.node_key=p."CodDcpf"
JOIN graph_node t ON t.node_type='DCP'  AND t.node_key=p."CodDcp"
WHERE NOT EXISTS (
  SELECT 1 FROM graph_edge e
  WHERE e.src_type='DCPF' AND e.src_key=p."CodDcpf"
    AND e.rel='PERTENECE_A_DCP' AND e.dst_type='DCP' AND e.dst_key=p."CodDcp"
);

-- Fallback por Prescripcion: DCP -> DCSA
INSERT INTO graph_edge (src_type,src_key,rel,dst_type,dst_key,props)
SELECT DISTINCT 'DCP', p."CodDcp", 'PERTENECE_A_DCSA', 'DCSA', p."CodDcsa", '{}'::jsonb
FROM "PrescripcionStaging_NUEVA" p
JOIN graph_node s ON s.node_type='DCP'  AND s.node_key=p."CodDcp"
JOIN graph_node t ON t.node_type='DCSA' AND t.node_key=p."CodDcsa"
WHERE COALESCE(p."CodDcsa",'') <> ''
  AND NOT EXISTS (
    SELECT 1 FROM graph_edge e
    WHERE e.src_type='DCP' AND e.src_key=p."CodDcp"
      AND e.rel='PERTENECE_A_DCSA' AND e.dst_type='DCSA' AND e.dst_key=p."CodDcsa"
  );
