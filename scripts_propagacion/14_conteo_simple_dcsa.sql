-- Conteo simple
SELECT 
  (SELECT COUNT(*) FROM "DcsaDicStaging") as dcsa_staging,
  (SELECT COUNT(*) FROM "DcpDicStaging") as dcp_staging,
  (SELECT COUNT(*) FROM "DcpfDicStaging") as dcpf_staging;

-- Nodos en grafo
SELECT 
  node_type,
  COUNT(*) as total
FROM graph_node
WHERE node_type IN ('DCP', 'DCPF', 'DCSA')
GROUP BY node_type
ORDER BY node_type;
