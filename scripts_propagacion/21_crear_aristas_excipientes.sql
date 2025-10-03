-- ============================================================
-- CREAR ARISTAS MED → EXCIPIENTE EN GRAFO
-- Con detalles: cantidad, unidad, obligatorio, orden
-- ============================================================

-- Verificar estado antes
SELECT 
    'ANTES - Nodos Excipiente' as estado,
    COUNT(*) as cantidad
FROM graph_node 
WHERE node_type = 'Excipiente'
UNION ALL
SELECT 
    'ANTES - Aristas Med→Excipiente',
    COUNT(*)
FROM graph_edge 
WHERE rel = 'CONTIENE_EXCIPIENTE';

-- Crear las aristas Med → Excipiente
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Medicamento',
    me."NRegistro",
    'CONTIENE_EXCIPIENTE',
    'Excipiente',
    me."ExcipienteId"::text,
    jsonb_build_object(
        'cantidad', me."Cantidad",
        'unidad', me."Unidad",
        'obligatorio', me."Obligatorio",
        'orden', me."Orden"
    )
FROM "MedicamentoExcipiente" me
WHERE EXISTS (
    SELECT 1 FROM graph_node gn
    WHERE gn.node_type = 'Medicamento'
      AND gn.node_key = me."NRegistro"
)
ON CONFLICT DO NOTHING;

-- Verificar estado después
SELECT 
    'DESPUES - Aristas Med→Excipiente' as estado,
    COUNT(*) as cantidad
FROM graph_edge 
WHERE rel = 'CONTIENE_EXCIPIENTE';

-- Top 10 excipientes más utilizados (en grafo)
SELECT 
    e."Nombre",
    COUNT(*) as uso_count
FROM graph_edge ge
JOIN "Excipiente" e ON ge.dst_key = e."Id"::text
WHERE ge.rel = 'CONTIENE_EXCIPIENTE'
  AND ge.dst_type = 'Excipiente'
GROUP BY e."Nombre"
ORDER BY uso_count DESC
LIMIT 10;

-- Verificar medicamentos con más excipientes
SELECT 
    gn.props->>'nombre' as medicamento,
    COUNT(*) as num_excipientes
FROM graph_edge ge
JOIN graph_node gn ON ge.src_key = gn.node_key AND gn.node_type = 'Medicamento'
WHERE ge.rel = 'CONTIENE_EXCIPIENTE'
GROUP BY gn.props->>'nombre'
ORDER BY num_excipientes DESC
LIMIT 10;

-- Muestra de aristas con propiedades
SELECT 
    ge.src_key as nregistro,
    gn_med.props->>'nombre' as medicamento,
    gn_exc.props->>'nombre' as excipiente,
    ge.props->>'cantidad' as cantidad,
    ge.props->>'unidad' as unidad,
    ge.props->>'obligatorio' as obligatorio,
    ge.props->>'orden' as orden
FROM graph_edge ge
JOIN graph_node gn_med ON ge.src_key = gn_med.node_key AND gn_med.node_type = 'Medicamento'
JOIN graph_node gn_exc ON ge.dst_key = gn_exc.node_key AND gn_exc.node_type = 'Excipiente'
WHERE ge.rel = 'CONTIENE_EXCIPIENTE'
LIMIT 20;

SELECT '✅ ARISTAS MED → EXCIPIENTE CREADAS' as resultado;
