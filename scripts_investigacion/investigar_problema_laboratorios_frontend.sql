-- ========================================
-- INVESTIGAR: Por qué frontend no muestra laboratorios
-- ========================================

-- 1. Ver estructura tabla Medicamentos (¿tiene columna Laboratorio?)
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'Medicamentos'
ORDER BY ordinal_position;

-- 2. Ver sample de Medicamentos
SELECT *
FROM "Medicamentos"
LIMIT 5;

-- 3. Verificar relaciones en grafo
SELECT 
    src_type,
    rel,
    dst_type,
    COUNT(*) as "Cantidad"
FROM graph_edge
WHERE src_type = 'Medicamento' OR dst_type = 'Medicamento'
GROUP BY src_type, rel, dst_type
ORDER BY src_type, rel;

-- 4. Verificar cómo obtener laboratorio de un medicamento
-- Opción A: Desde grafo
SELECT 
    gn_med.node_key as "NRegistro",
    gn_med.properties->>'Nombre' as "Medicamento",
    ge.rel as "TipoRelacion",
    gn_lab.properties->>'Nombre' as "Laboratorio"
FROM graph_node gn_med
JOIN graph_edge ge ON ge.src_key = gn_med.node_key AND ge.src_type = 'Medicamento'
JOIN graph_node gn_lab ON gn_lab.node_key = ge.dst_key AND gn_lab.node_type = 'Laboratorio'
WHERE gn_med.node_type = 'Medicamento'
AND ge.dst_type = 'Laboratorio'
LIMIT 10;

-- 5. Conteo laboratorios por tipo de relación
SELECT 
    ge.rel as "TipoRelacion",
    COUNT(DISTINCT ge.dst_key) as "LaboratoriosUnicos",
    COUNT(*) as "TotalRelaciones"
FROM graph_edge ge
WHERE ge.src_type = 'Medicamento'
AND ge.dst_type = 'Laboratorio'
GROUP BY ge.rel;

-- 6. Verificar vistas materializadas con laboratorios
SELECT 
    table_name
FROM information_schema.views
WHERE table_schema = 'public'
AND (table_name ILIKE '%lab%' OR table_name ILIKE '%medicamento%')
ORDER BY table_name;

-- 7. Ver si hay vista que combine Medicamento + Laboratorio
\d "vMedicamento"

-- 8. Sample de medicamento con AMBOS laboratorios (titular + comercializador)
SELECT 
    gn_med.node_key as "NRegistro",
    gn_med.properties->>'Nombre' as "Medicamento",
    titular.properties->>'Nombre' as "LabTitular",
    comerc.properties->>'Nombre' as "LabComercializador"
FROM graph_node gn_med
LEFT JOIN (
    SELECT src_key, dst_key
    FROM graph_edge
    WHERE rel = 'LAB_TITULAR' AND dst_type = 'Laboratorio'
) et ON et.src_key = gn_med.node_key
LEFT JOIN graph_node titular ON titular.node_key = et.dst_key
LEFT JOIN (
    SELECT src_key, dst_key
    FROM graph_edge
    WHERE rel = 'LAB_COMERCIALIZA' AND dst_type = 'Laboratorio'
) ec ON ec.src_key = gn_med.node_key
LEFT JOIN graph_node comerc ON comerc.node_key = ec.dst_key
WHERE gn_med.node_type = 'Medicamento'
AND titular.properties->>'Nombre' != comerc.properties->>'Nombre'
LIMIT 10;

-- 9. ¿Cuántos medicamentos tienen laboratorios en el grafo?
SELECT 
    'Con Lab Titular' as "Tipo",
    COUNT(DISTINCT src_key) as "Medicamentos"
FROM graph_edge
WHERE rel = 'LAB_TITULAR'
UNION ALL
SELECT 
    'Con Lab Comercializador',
    COUNT(DISTINCT src_key)
FROM graph_edge
WHERE rel = 'LAB_COMERCIALIZA'
UNION ALL
SELECT 
    'Sin ningún laboratorio',
    COUNT(*)
FROM graph_node gn
WHERE gn.node_type = 'Medicamento'
AND NOT EXISTS (
    SELECT 1 FROM graph_edge ge
    WHERE ge.src_key = gn.node_key
    AND ge.dst_type = 'Laboratorio'
);

-- 10. Comparar JSON vs Grafo
SELECT 
    'JSON: Medicamentos con labtitular' as "Fuente",
    COUNT(*) as "Cantidad"
FROM "MedicamentoDetalleRaw"
WHERE "Json" ? 'labtitular'
UNION ALL
SELECT 
    'Grafo: Medicamentos con LAB_TITULAR',
    COUNT(DISTINCT src_key)
FROM graph_edge
WHERE rel = 'LAB_TITULAR';
