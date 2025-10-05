-- ============================================================================
-- INVESTIGACIÓN COMPLETA: Medicamento NRegistro 67939
-- Fecha: 05/10/2025
-- ============================================================================

-- 1. INFORMACIÓN BÁSICA
-- ============================================================================
SELECT 
    "NRegistro",
    "Nombre",
    "LabTitular",
    "Generico",
    "Receta",
    "Dosis",
    LENGTH("RawJson") as json_size_bytes,
    "UpdatedAt"
FROM "Medicamentos"
WHERE "NRegistro" = '67939';

-- 2. VERIFICAR EXISTENCIA DE CLAVES EN JSON
-- ============================================================================
SELECT 
    "NRegistro",
    "Nombre",
    CASE WHEN "RawJson"::jsonb ? 'principiosActivos' THEN 'SI' ELSE 'NO' END as tiene_pa,
    CASE WHEN "RawJson"::jsonb ? 'excipientes' THEN 'SI' ELSE 'NO' END as tiene_exc,
    CASE WHEN "RawJson"::jsonb ? 'presentaciones' THEN 'SI' ELSE 'NO' END as tiene_pres,
    CASE WHEN "RawJson"::jsonb ? 'viasAdministracion' THEN 'SI' ELSE 'NO' END as tiene_vias,
    CASE WHEN "RawJson"::jsonb ? 'atcs' THEN 'SI' ELSE 'NO' END as tiene_atc,
    CASE WHEN "RawJson"::jsonb ? 'docs' THEN 'SI' ELSE 'NO' END as tiene_docs,
    CASE WHEN "RawJson"::jsonb ? 'fotos' THEN 'SI' ELSE 'NO' END as tiene_fotos
FROM "Medicamentos"
WHERE "NRegistro" = '67939';

-- 3. CONTAR ELEMENTOS EN ARRAYS JSON
-- ============================================================================
SELECT 
    "NRegistro",
    "Nombre",
    CASE 
        WHEN "RawJson"::jsonb ? 'principiosActivos' THEN 
            jsonb_array_length(("RawJson"::jsonb)->'principiosActivos')
        ELSE 0 
    END as num_pa,
    CASE 
        WHEN "RawJson"::jsonb ? 'excipientes' THEN 
            jsonb_array_length(("RawJson"::jsonb)->'excipientes')
        ELSE 0 
    END as num_exc,
    CASE 
        WHEN "RawJson"::jsonb ? 'presentaciones' THEN 
            jsonb_array_length(("RawJson"::jsonb)->'presentaciones')
        ELSE 0 
    END as num_pres,
    CASE 
        WHEN "RawJson"::jsonb ? 'viasAdministracion' THEN 
            jsonb_array_length(("RawJson"::jsonb)->'viasAdministracion')
        ELSE 0 
    END as num_vias,
    CASE 
        WHEN "RawJson"::jsonb ? 'atcs' THEN 
            jsonb_array_length(("RawJson"::jsonb)->'atcs')
        ELSE 0 
    END as num_atc
FROM "Medicamentos"
WHERE "NRegistro" = '67939';

-- 4. EXTRAER PRINCIPIOS ACTIVOS DEL JSON
-- ============================================================================
SELECT 
    pa->>'id' as pa_id,
    pa->>'nombre' as pa_nombre,
    pa->>'cantidad' as pa_cantidad,
    pa->>'unidad' as pa_unidad
FROM "Medicamentos",
     jsonb_array_elements(("RawJson"::jsonb)->'principiosActivos') as pa
WHERE "NRegistro" = '67939';

-- 5. EXTRAER EXCIPIENTES DEL JSON
-- ============================================================================
SELECT 
    exc->>'id' as exc_id,
    exc->>'nombre' as exc_nombre,
    exc->>'cantidad' as exc_cantidad,
    exc->>'unidad' as exc_unidad,
    exc->>'orden' as exc_orden
FROM "Medicamentos",
     jsonb_array_elements(("RawJson"::jsonb)->'excipientes') as exc
WHERE "NRegistro" = '67939'
ORDER BY (exc->>'orden')::int;

-- 6. BUSCAR EN GRAFO - PRINCIPIOS ACTIVOS
-- ============================================================================
SELECT 
    ge.rel as relacion,
    ge.dst_type as tipo_destino,
    ge.dst_key as clave_destino,
    gn.props->>'nombre' as nombre_pa
FROM graph_edge ge
LEFT JOIN graph_node gn ON gn.node_type = ge.dst_type AND gn.node_key = ge.dst_key
WHERE ge.src_type = 'Medicamento'
  AND ge.src_key = '67939'
  AND ge.rel = 'CONTIENE_PA';

-- 7. BUSCAR EN GRAFO - EXCIPIENTES
-- ============================================================================
SELECT 
    ge.rel as relacion,
    ge.dst_type as tipo_destino,
    ge.dst_key as clave_destino,
    gn.props->>'nombre' as nombre_excipiente
FROM graph_edge ge
LEFT JOIN graph_node gn ON gn.node_type = ge.dst_type AND gn.node_key = ge.dst_key
WHERE ge.src_type = 'Medicamento'
  AND ge.src_key = '67939'
  AND ge.rel = 'CONTIENE_EXCIPIENTE';

-- 8. BUSCAR EN TABLAS NORMALIZADAS - MedicamentoSustancia
-- ============================================================================
SELECT 
    ms."NRegistro",
    ms."Codigo" as codigo_sustancia,
    ms."Fuerza",
    ms."Unidad"
FROM "MedicamentoSustancia" ms
WHERE ms."NRegistro" = '67939';

-- 9. VER JSON COMPLETO (PRETTIFIED)
-- ============================================================================
SELECT 
    "NRegistro",
    "Nombre",
    jsonb_pretty("RawJson"::jsonb) as json_formateado
FROM "Medicamentos"
WHERE "NRegistro" = '67939';

-- 10. RESUMEN COMPARATIVO: JSON vs GRAFO vs TABLAS
-- ============================================================================
SELECT 
    'Principios Activos en JSON' as origen,
    COUNT(*) as cantidad
FROM "Medicamentos",
     jsonb_array_elements(("RawJson"::jsonb)->'principiosActivos') as pa
WHERE "NRegistro" = '67939'
UNION ALL
SELECT 
    'Principios Activos en Grafo',
    COUNT(*)
FROM graph_edge
WHERE src_type = 'Medicamento'
  AND src_key = '67939'
  AND rel = 'CONTIENE_PA'
UNION ALL
SELECT 
    'Principios Activos en MedicamentoSustancia',
    COUNT(*)
FROM "MedicamentoSustancia"
WHERE "NRegistro" = '67939'
UNION ALL
SELECT 
    'Excipientes en JSON',
    COUNT(*)
FROM "Medicamentos",
     jsonb_array_elements(("RawJson"::jsonb)->'excipientes') as exc
WHERE "NRegistro" = '67939'
UNION ALL
SELECT 
    'Excipientes en Grafo',
    COUNT(*)
FROM graph_edge
WHERE src_type = 'Medicamento'
  AND src_key = '67939'
  AND rel = 'CONTIENE_EXCIPIENTE';
