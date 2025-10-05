-- ========================================
-- INVESTIGACIÓN EXHAUSTIVA: LABORATORIOS
-- ========================================

-- 1. TODAS las tablas con "lab" o "laboratorio"
SELECT 
    table_name,
    table_type,
    (SELECT COUNT(*) FROM information_schema.columns 
     WHERE table_name = t.table_name) as num_columnas
FROM information_schema.tables t
WHERE table_schema = 'public'
AND (table_name ILIKE '%lab%' OR table_name ILIKE '%laboratorio%')
ORDER BY table_name;

-- 2. Estructura tabla Laboratorio (si existe)
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'Laboratorio'
ORDER BY ordinal_position;

-- 3. Conteo tabla Laboratorio
SELECT 'Laboratorio' as "Tabla", COUNT(*) as "Registros"
FROM "Laboratorio";

-- 4. Sample de Laboratorio
SELECT *
FROM "Laboratorio"
LIMIT 10;

-- 5. Buscar en JSON: labtitular vs labcomercializador
SELECT 
    COUNT(*) as "TotalMedicamentos",
    COUNT(*) FILTER (WHERE "Json" ? 'labtitular') as "ConLabTitular",
    COUNT(*) FILTER (WHERE "Json" ? 'labcomercializador') as "ConLabComercializador",
    COUNT(*) FILTER (WHERE "Json"->>'labtitular' != "Json"->>'labcomercializador') as "DiferentesTitularComercializador"
FROM "MedicamentoDetalleRaw";

-- 6. Sample de medicamento con ambos laboratorios
SELECT 
    "NRegistro",
    "Json"->>'nombre' as "Medicamento",
    "Json"->>'labtitular' as "LabTitular",
    "Json"->>'labcomercializador' as "LabComercializador"
FROM "MedicamentoDetalleRaw"
WHERE "Json"->>'labtitular' != "Json"->>'labcomercializador'
LIMIT 10;

-- 7. Laboratorios ÚNICOS en JSON (titular)
WITH labs_titular AS (
    SELECT DISTINCT "Json"->>'labtitular' as nombre
    FROM "MedicamentoDetalleRaw"
    WHERE "Json" ? 'labtitular'
)
SELECT COUNT(*) as "LaboratoriosTitularesUnicos"
FROM labs_titular
WHERE nombre IS NOT NULL AND nombre != '';

-- 8. Laboratorios ÚNICOS en JSON (comercializador)
WITH labs_comerc AS (
    SELECT DISTINCT "Json"->>'labcomercializador' as nombre
    FROM "MedicamentoDetalleRaw"
    WHERE "Json" ? 'labcomercializador'
)
SELECT COUNT(*) as "LaboratoriosComercializadoresUnicos"
FROM labs_comerc
WHERE nombre IS NOT NULL AND nombre != '';

-- 9. Laboratorios en Medicamentos (tabla principal)
SELECT 
    COUNT(DISTINCT "Laboratorio") as "LaboratoriosEnMedicamentos"
FROM "Medicamentos"
WHERE "Laboratorio" IS NOT NULL;

-- 10. Top 20 laboratorios por volumen de medicamentos (JSON)
SELECT 
    "Json"->>'labtitular' as "Laboratorio",
    COUNT(*) as "NumMedicamentos"
FROM "MedicamentoDetalleRaw"
WHERE "Json" ? 'labtitular'
GROUP BY "Json"->>'labtitular'
ORDER BY COUNT(*) DESC
LIMIT 20;

-- 11. Laboratorios que son solo comercializadores (no titulares)
WITH labs_titular AS (
    SELECT DISTINCT "Json"->>'labtitular' as nombre
    FROM "MedicamentoDetalleRaw"
    WHERE "Json" ? 'labtitular'
),
labs_comerc AS (
    SELECT DISTINCT "Json"->>'labcomercializador' as nombre
    FROM "MedicamentoDetalleRaw"
    WHERE "Json" ? 'labcomercializador'
)
SELECT lc.nombre as "SoloComercializador"
FROM labs_comerc lc
WHERE lc.nombre IS NOT NULL
AND lc.nombre != ''
AND NOT EXISTS (
    SELECT 1 FROM labs_titular lt
    WHERE lt.nombre = lc.nombre
)
LIMIT 20;

-- 12. Verificar tabla Laboratorio en grafo
SELECT 
    COUNT(*) as "NodosLaboratorio"
FROM graph_node
WHERE node_type = 'Laboratorio';

-- 13. Sample nodos Laboratorio del grafo
SELECT 
    node_id,
    properties
FROM graph_node
WHERE node_type = 'Laboratorio'
LIMIT 10;

-- 14. Relaciones Medicamento → Laboratorio en grafo
SELECT 
    rel,
    COUNT(*) as "Cantidad"
FROM graph_edge
WHERE (src_type = 'Medicamento' AND dst_type = 'Laboratorio')
   OR (src_type = 'Laboratorio' AND dst_type = 'Medicamento')
GROUP BY rel;
