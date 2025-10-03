-- ============================================================
-- ENRIQUECER NODOS LABORATORIO CON INFO DETALLADA
-- Añadir dirección, CIF, código postal, localidad
-- ============================================================

-- 1. Estado inicial
SELECT 'ANTES' as momento;
SELECT COUNT(*) as labs_con_direccion
FROM graph_node
WHERE node_type = 'Laboratorio'
  AND props ? 'direccion';

-- 2. Enriquecer nodos Laboratorio con LaboratorioInfo
UPDATE graph_node gn
SET props = gn.props || jsonb_build_object(
    'direccion', li."Direccion",
    'codigo_postal', li."CodigoPostalCanon",
    'localidad', li."Localidad",
    'cif', li."CifCanon",
    'updated_at', li."UpdatedAt"::text
)
FROM "LaboratorioInfo" li
WHERE gn.node_type = 'Laboratorio'
  AND gn.node_key = li."LabId"::text;

-- 3. Estado final
SELECT 'DESPUÉS' as momento;
SELECT COUNT(*) as labs_con_direccion
FROM graph_node
WHERE node_type = 'Laboratorio'
  AND props ? 'direccion';

-- 4. Ejemplos
SELECT node_key, 
       props->>'nombre' as nombre,
       props->>'direccion' as direccion,
       props->>'localidad' as localidad
FROM graph_node
WHERE node_type = 'Laboratorio'
  AND props ? 'direccion'
LIMIT 5;

SELECT '✅ LABORATORIOS ENRIQUECIDOS CON INFO DETALLADA' as resultado;
