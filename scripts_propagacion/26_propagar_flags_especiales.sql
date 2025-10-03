-- ============================================================
-- PROPAGAR FLAGS ESPECIALES AL GRAFO
-- AfectaConduccion, TrianguloNegro, Huerfano, Biosimilar
-- ============================================================

-- 1. Verificar nodos Flag existentes
SELECT * FROM graph_node WHERE node_type = 'Flag' OR node_type = 'FlagEstado';

-- 2. Crear nodos para los nuevos flags
INSERT INTO graph_node (node_type, node_key, props)
VALUES 
    ('Flag', 'AFECTA_CONDUCCION', jsonb_build_object('nombre', 'Afecta Conducción', 'descripcion', 'Medicamento que afecta la capacidad de conducir')),
    ('Flag', 'TRIANGULO_NEGRO', jsonb_build_object('nombre', 'Triángulo Negro', 'descripcion', 'Medicamento bajo seguimiento adicional')),
    ('Flag', 'HUERFANO', jsonb_build_object('nombre', 'Huérfano', 'descripcion', 'Medicamento huérfano para enfermedades raras')),
    ('Flag', 'BIOSIMILAR', jsonb_build_object('nombre', 'Biosimilar', 'descripcion', 'Medicamento biosimilar')),
    ('Flag', 'MATERIALES_INFORMATIVOS', jsonb_build_object('nombre', 'Materiales Informativos', 'descripcion', 'Requiere materiales informativos adicionales'))
ON CONFLICT DO NOTHING;

-- 3. Verificar cuántos se crearon
SELECT COUNT(*) as total_flags FROM graph_node WHERE node_type = 'Flag';

-- 4. Crear aristas Med → Flag para AfectaConduccion
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Medicamento',
    "NRegistro",
    'TIENE_FLAG',
    'Flag',
    'AFECTA_CONDUCCION',
    jsonb_build_object('activo', true)
FROM "Medicamentos"
WHERE "AfectaConduccion" = true
ON CONFLICT DO NOTHING;

-- 5. Crear aristas Med → Flag para TrianguloNegro
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Medicamento',
    "NRegistro",
    'TIENE_FLAG',
    'Flag',
    'TRIANGULO_NEGRO',
    jsonb_build_object('activo', true)
FROM "Medicamentos"
WHERE "TrianguloNegro" = true
ON CONFLICT DO NOTHING;

-- 6. Crear aristas Med → Flag para Huerfano
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Medicamento',
    "NRegistro",
    'TIENE_FLAG',
    'Flag',
    'HUERFANO',
    jsonb_build_object('activo', true)
FROM "Medicamentos"
WHERE "Huerfano" = true
ON CONFLICT DO NOTHING;

-- 7. Crear aristas Med → Flag para Biosimilar
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Medicamento',
    "NRegistro",
    'TIENE_FLAG',
    'Flag',
    'BIOSIMILAR',
    jsonb_build_object('activo', true)
FROM "Medicamentos"
WHERE "Biosimilar" = true
ON CONFLICT DO NOTHING;

-- 8. Crear aristas Med → Flag para MaterialesInformativos
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Medicamento',
    "NRegistro",
    'TIENE_FLAG',
    'Flag',
    'MATERIALES_INFORMATIVOS',
    jsonb_build_object('activo', true)
FROM "Medicamentos"
WHERE "MaterialesInformativos" = true
ON CONFLICT DO NOTHING;

-- 9. Verificar conteos finales
SELECT 
    'AFECTA_CONDUCCION' as flag,
    COUNT(*) as aristas
FROM graph_edge
WHERE dst_type = 'Flag' AND dst_key = 'AFECTA_CONDUCCION'
UNION ALL
SELECT 
    'TRIANGULO_NEGRO',
    COUNT(*)
FROM graph_edge
WHERE dst_type = 'Flag' AND dst_key = 'TRIANGULO_NEGRO'
UNION ALL
SELECT 
    'HUERFANO',
    COUNT(*)
FROM graph_edge
WHERE dst_type = 'Flag' AND dst_key = 'HUERFANO'
UNION ALL
SELECT 
    'BIOSIMILAR',
    COUNT(*)
FROM graph_edge
WHERE dst_type = 'Flag' AND dst_key = 'BIOSIMILAR'
UNION ALL
SELECT 
    'MATERIALES_INFORMATIVOS',
    COUNT(*)
FROM graph_edge
WHERE dst_type = 'Flag' AND dst_key = 'MATERIALES_INFORMATIVOS';

-- 10. Total aristas TIENE_FLAG después
SELECT COUNT(*) as total_tiene_flag 
FROM graph_edge 
WHERE rel = 'TIENE_FLAG';

-- 11. Muestra de medicamentos con flags
SELECT 
    gn.props->>'nombre' as medicamento,
    array_agg(DISTINCT ge.dst_key) as flags
FROM graph_edge ge
JOIN graph_node gn ON ge.src_key = gn.node_key AND gn.node_type = 'Medicamento'
WHERE ge.rel = 'TIENE_FLAG' 
  AND ge.dst_type = 'Flag'
GROUP BY gn.props->>'nombre'
HAVING COUNT(*) > 1
LIMIT 20;

SELECT '✅ FLAGS ESPECIALES PROPAGADOS AL GRAFO' as resultado;
