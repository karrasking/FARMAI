SET search_path TO public;

-- 1) Medicamento (por si faltan)
INSERT INTO graph_node (node_type,node_key,props)
SELECT 'Medicamento', p."NRegistro", '{}'::jsonb
FROM "PrescripcionStaging_NUEVA" p
WHERE p."NRegistro" IS NOT NULL
ON CONFLICT DO NOTHING;

-- 2) Nodos DCP / DCPF / DCSA desde prescripción
INSERT INTO graph_node (node_type,node_key,props)
SELECT 'DCP', p."CodDcp", '{}'::jsonb
FROM "PrescripcionStaging_NUEVA" p
WHERE NULLIF(p."CodDcp",'') IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO graph_node (node_type,node_key,props)
SELECT 'DCPF', p."CodDcpf", '{}'::jsonb
FROM "PrescripcionStaging_NUEVA" p
WHERE NULLIF(p."CodDcpf",'') IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO graph_node (node_type,node_key,props)
SELECT 'DCSA', p."CodDcsa", '{}'::jsonb
FROM "PrescripcionStaging_NUEVA" p
WHERE NULLIF(p."CodDcsa",'') IS NOT NULL
ON CONFLICT DO NOTHING;

-- 3) Añadir nombre desde los diccionarios existentes (según tus columnas reales)
UPDATE graph_node gn
SET props = COALESCE(gn.props,'{}'::jsonb) || jsonb_build_object('nombre', d."Nombre")
FROM "DcpDicStaging" d
WHERE gn.node_type='DCP'
  AND gn.node_key = NULLIF(d."CodigoDcp",'');

UPDATE graph_node gn
SET props = COALESCE(gn.props,'{}'::jsonb) || jsonb_build_object('nombre', d."Nombre")
FROM "DcpfDicStaging" d
WHERE gn.node_type='DCPF'
  AND gn.node_key = NULLIF(d."CodigoDcpf",'');

UPDATE graph_node gn
SET props = COALESCE(gn.props,'{}'::jsonb) || jsonb_build_object('nombre', d."Nombre")
FROM "DcsaDicStaging" d
WHERE gn.node_type='DCSA'
  AND gn.node_key = NULLIF(d."CodigoDcsa",'');

-- 4) Aristas Medicamento -> DCP/DCPF/DCSA
INSERT INTO graph_edge (src_type,src_key,rel,dst_type,dst_key,props)
SELECT 'Medicamento', p."NRegistro", 'PERTENECE_A_DCP', 'DCP', p."CodDcp", '{}'
FROM "PrescripcionStaging_NUEVA" p
WHERE NULLIF(p."CodDcp",'') IS NOT NULL
ON CONFLICT (src_type,src_key,rel,dst_type,dst_key) DO NOTHING;

INSERT INTO graph_edge (src_type,src_key,rel,dst_type,dst_key,props)
SELECT 'Medicamento', p."NRegistro", 'PERTENECE_A_DCPF', 'DCPF', p."CodDcpf", '{}'
FROM "PrescripcionStaging_NUEVA" p
WHERE NULLIF(p."CodDcpf",'') IS NOT NULL
ON CONFLICT (src_type,src_key,rel,dst_type,dst_key) DO NOTHING;

INSERT INTO graph_edge (src_type,src_key,rel,dst_type,dst_key,props)
SELECT 'Medicamento', p."NRegistro", 'PERTENECE_A_DCSA', 'DCSA', p."CodDcsa", '{}'
FROM "PrescripcionStaging_NUEVA" p
WHERE NULLIF(p."CodDcsa",'') IS NOT NULL
ON CONFLICT (src_type,src_key,rel,dst_type,dst_key) DO NOTHING;
