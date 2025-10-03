-- pc_to_graph.sql
-- 1) Nodos Presentacion (por si faltan)
INSERT INTO graph_node (node_type,node_key,props)
SELECT 'Presentacion', pr."CN", jsonb_build_object('nombre', pr."Nombre")
FROM "Presentacion" pr
LEFT JOIN graph_node gn
  ON gn.node_type='Presentacion' AND gn.node_key=pr."CN"
WHERE gn.node_key IS NULL
ON CONFLICT DO NOTHING;

-- 2) Aristas Presentacion -> Envase / UnidadContenido
INSERT INTO graph_edge (src_type,src_key,rel,dst_type,dst_key,props)
SELECT 'Presentacion', pc."CN", 'USA_ENVASE', 'Envase', pc."EnvaseId"::text, '{}'
FROM "PresentacionContenido" pc
WHERE pc."EnvaseId" IS NOT NULL
ON CONFLICT (src_type,src_key,rel,dst_type,dst_key) DO NOTHING;

INSERT INTO graph_edge (src_type,src_key,rel,dst_type,dst_key,props)
SELECT 'Presentacion', pc."CN", 'TIENE_UNIDAD', 'UnidadContenido', pc."UnidadId"::text, '{}'
FROM "PresentacionContenido" pc
WHERE pc."UnidadId" IS NOT NULL
ON CONFLICT (src_type,src_key,rel,dst_type,dst_key) DO NOTHING;

-- 3) Nodos Medicamento (faltantes)
INSERT INTO graph_node (node_type,node_key,props)
SELECT 'Medicamento', p."NRegistro", '{}'::jsonb
FROM "PrescripcionStaging_NUEVA" p
WHERE p."NRegistro" IS NOT NULL
ON CONFLICT DO NOTHING;

-- 4) Aristas Medicamento -> Presentacion
INSERT INTO graph_edge (src_type,src_key,rel,dst_type,dst_key,props)
SELECT 'Medicamento', p."NRegistro", 'TIENE_PRESENTACION', 'Presentacion', p."CodNacion", '{}'
FROM "PrescripcionStaging_NUEVA" p
JOIN graph_node gm ON gm.node_type='Medicamento'  AND gm.node_key=p."NRegistro"
JOIN graph_node gp ON gp.node_type='Presentacion' AND gp.node_key=p."CodNacion"
ON CONFLICT (src_type,src_key,rel,dst_type,dst_key) DO NOTHING;

-- 5) Enriquecer props de TIENE_PRESENTACION con (contenido, unidad)
UPDATE graph_edge ge
SET props = COALESCE(ge.props,'{}'::jsonb)
           || jsonb_build_object('contenido', pc."CantidadRaw", 'unidad', pc."Unidad")
FROM "PresentacionContenido" pc
WHERE ge.src_type='Medicamento'
  AND ge.dst_type='Presentacion'
  AND ge.rel='TIENE_PRESENTACION'
  AND ge.dst_key = pc."CN";
