\set ON_ERROR_STOP on
SET search_path TO public;

-- 0) Totales
SELECT 'nodes_total' AS what, COUNT(*) AS n FROM graph_node;
SELECT 'edges_total' AS what, COUNT(*) AS n FROM graph_edge;

-- 1) Nodos por tipo
SELECT 'nodes_by_type' AS what, node_type, COUNT(*) AS n
FROM graph_node GROUP BY 2 ORDER BY 2;

-- 2) Aristas por relación
SELECT 'edges_by_rel' AS what, rel, COUNT(*) AS n
FROM graph_edge GROUP BY 2 ORDER BY 2;

-- 3) Cobertura Presentaciones
SELECT 'presentaciones' AS what, COUNT(*) AS n FROM "Presentacion";
SELECT 'presentacion_contenido_rows' AS what, COUNT(*) AS n FROM "PresentacionContenido";
SELECT 'med_tiene_presentacion' AS what, COUNT(*) AS n
FROM graph_edge
WHERE src_type='Medicamento' AND rel='TIENE_PRESENTACION' AND dst_type='Presentacion';
SELECT 'presentacion_usa_envase' AS what, COUNT(*) AS n FROM graph_edge WHERE rel='USA_ENVASE';
SELECT 'presentacion_tiene_unidad' AS what, COUNT(*) AS n FROM graph_edge WHERE rel='TIENE_UNIDAD';

-- 4) ¿Presentaciones sin contenido?
SELECT 'presentaciones_sin_contenido' AS what, COUNT(*) AS n
FROM "Presentacion" p
LEFT JOIN "PresentacionContenido" pc ON pc."CN"=p."CN"
WHERE pc."CN" IS NULL;

-- 5) ¿Contenido sin arista med->presentacion?
WITH cn_all AS (SELECT DISTINCT "CN" FROM "PresentacionContenido"),
cn_arista AS (
  SELECT DISTINCT dst_key::varchar AS "CN"
  FROM graph_edge
  WHERE src_type='Medicamento' AND rel='TIENE_PRESENTACION' AND dst_type='Presentacion'
)
SELECT 'cn_contenido_sin_arista_med_pres' AS what, COUNT(*) AS n
FROM cn_all a LEFT JOIN cn_arista b USING ("CN") WHERE b."CN" IS NULL;

-- 6) DCP/DCPF/DCSA nodos y enlaces
SELECT 'dcp_nodes' AS what, COUNT(*) AS n FROM graph_node WHERE node_type='DCP';
SELECT 'dcpf_nodes' AS what, COUNT(*) AS n FROM graph_node WHERE node_type='DCPF';
SELECT 'dcsa_nodes' AS what, COUNT(*) AS n FROM graph_node WHERE node_type='DCSA';
SELECT 'edges_pert_a_dcp' AS what, COUNT(*) AS n FROM graph_edge WHERE rel='PERTENECE_A_DCP';
SELECT 'edges_pert_a_dcpf' AS what, COUNT(*) AS n FROM graph_edge WHERE rel='PERTENECE_A_DCPF';
SELECT 'edges_pert_a_dcsa' AS what, COUNT(*) AS n FROM graph_edge WHERE rel='PERTENECE_A_DCSA';

-- 7) Medicamentos con/ sin presentacion
SELECT 'med_con_presentacion' AS what, COUNT(DISTINCT src_key) AS n
FROM graph_edge
WHERE src_type='Medicamento' AND rel='TIENE_PRESENTACION';
SELECT 'med_total' AS what, COUNT(*) AS n FROM graph_node WHERE node_type='Medicamento';
SELECT 'med_sin_presentacion' AS what,
  (SELECT COUNT(*) FROM graph_node WHERE node_type='Medicamento')
  - (SELECT COUNT(DISTINCT src_key) FROM graph_edge WHERE src_type='Medicamento' AND rel='TIENE_PRESENTACION') AS n;

-- 8) Distribución de grado (presentaciones por medicamento)
SELECT 'grado_med' AS what, width_bucket(cnt, 1, 10, 10) AS bucket, COUNT(*) AS meds
FROM (
  SELECT src_key, COUNT(*) AS cnt
  FROM graph_edge
  WHERE src_type='Medicamento' AND rel='TIENE_PRESENTACION'
  GROUP BY 1
) t
GROUP BY 2 ORDER BY 2;

-- 9) Reglas de integridad rápida (no debería haber huérfanos porque hay FK, pero comprobamos)
SELECT 'edges_con_src_inexistente' AS what, COUNT(*) AS n
FROM graph_edge e
LEFT JOIN graph_node gn ON (gn.node_type=e.src_type AND gn.node_key=e.src_key)
WHERE gn.node_key IS NULL;

SELECT 'edges_con_dst_inexistente' AS what, COUNT(*) AS n
FROM graph_edge e
LEFT JOIN graph_node gn ON (gn.node_type=e.dst_type AND gn.node_key=e.dst_key)
WHERE gn.node_key IS NULL;

-- 10) Top relaciones por volumen (TOP 10)
SELECT 'top_rels' AS what, rel, COUNT(*) AS n
FROM graph_edge GROUP BY 2 ORDER BY 3 DESC, 2 ASC LIMIT 10;

-- 11) Top nodos con más grado saliente (TOP 10 Medicamento -> Presentación)
SELECT 'top_meds_por_presentaciones' AS what, src_key AS nregistro, COUNT(*) AS presentaciones
FROM graph_edge
WHERE src_type='Medicamento' AND rel='TIENE_PRESENTACION'
GROUP BY 2 ORDER BY 3 DESC LIMIT 10;

-- 12) Top presentaciones con más 'usa envase' (debería ser 1)
SELECT 'top_presentaciones_usa_envase' AS what, src_key AS cn, COUNT(*) AS envases
FROM graph_edge
WHERE src_type='Presentacion' AND rel='USA_ENVASE'
GROUP BY 2 ORDER BY 3 DESC LIMIT 10;
