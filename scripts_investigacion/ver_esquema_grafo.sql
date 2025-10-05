-- Ver esquema de graph_edge
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'graph_edge'
ORDER BY ordinal_position;

-- Ver sample de aristas PA
SELECT * FROM graph_edge 
WHERE edge_type = 'CONTIENE_PA'
LIMIT 3;

-- Contar PA en grafo
SELECT COUNT(*) as total_aristas_pa
FROM graph_edge
WHERE edge_type = 'CONTIENE_PA';
