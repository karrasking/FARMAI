SET search_path TO public;
WITH meds AS (
  SELECT gn.node_key AS nregistro
  FROM graph_node gn
  WHERE gn.node_type='Medicamento'
    AND NOT EXISTS (
      SELECT 1 FROM graph_edge ge
      WHERE ge.src_type='Medicamento' AND ge.rel='TIENE_PRESENTACION' AND ge.src_key=gn.node_key
    )
)
SELECT m.nregistro, p."CodNacion" AS cn
FROM meds m
LEFT JOIN "PrescripcionStaging_NUEVA" p ON p."NRegistro"=m.nregistro
ORDER BY m.nregistro;
