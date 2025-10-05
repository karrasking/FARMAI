-- INVESTIGAR JSON MÁS PROFUNDO SOBRE RESTRICCIONES
-- =================================================

-- 1. Ver UN JSON completo para entender estructura
SELECT 
    '📋 JSON COMPLETO DE UN MEDICAMENTO' as tipo,
    "NRegistro",
    "Nombre",
    jsonb_pretty("RawJson"::jsonb) as json_completo
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL
  AND "NRegistro" = '86475'  -- FRIONEX que vimos que tiene lactosa
LIMIT 1;

-- 2. Ver específicamente excipientes con lactosa/gluten
SELECT 
    '🧪 EXCIPIENTES CON LACTOSA/GLUTEN' as tipo,
    "NRegistro",
    "Nombre",
    jsonb_pretty("RawJson"::jsonb -> 'excipientes') as excipientes_json
FROM "Medicamentos"
WHERE "RawJson"::jsonb -> 'excipientes' @> '[{"nombre":"LACTOSA"}]'::jsonb
   OR "RawJson"::text LIKE '%LACTOSA%'
   OR "RawJson"::text LIKE '%lactosa%'
LIMIT 5;

-- 3. Contar medicamentos con lactosa en excipientes
SELECT 
    '📊 CANTIDAD CON LACTOSA' as tipo,
    COUNT(*) as medicamentos_con_lactosa
FROM "Medicamentos"
WHERE "RawJson"::text LIKE '%LACTOSA%'
  AND "RawJson" IS NOT NULL;

-- 4. Contar medicamentos con gluten
SELECT 
    '📊 CANTIDAD CON GLUTEN' as tipo,
    COUNT(*) as medicamentos_con_gluten
FROM "Medicamentos"
WHERE ("RawJson"::text LIKE '%GLUTEN%'
   OR "RawJson"::text LIKE '%gluten%'
   OR "RawJson"::text LIKE '%TRIGO%'
   OR "RawJson"::text LIKE '%trigo%')
  AND "RawJson" IS NOT NULL;

-- 5. Ver tabla de Excipientes en el grafo
SELECT 
    '🌐 EXCIPIENTES EN GRAFO' as tipo,
    COUNT(*) as total_excipientes
FROM graph_node
WHERE node_type = 'Excipiente';

-- 6. Ver excipientes específicos (lactosa, gluten, etc)
SELECT 
    '🎯 EXCIPIENTES ESPECIALES GRAFO' as tipo,
    name as excipiente,
    COUNT(*) as apariciones
FROM graph_node
WHERE node_type = 'Excipiente'
  AND (LOWER(name) LIKE '%lactosa%'
   OR LOWER(name) LIKE '%gluten%'
   OR LOWER(name) LIKE '%soja%'
   OR LOWER(name) LIKE '%cacahu%')
GROUP BY name;

-- 7. Medicamentos conectados a excipiente lactosa en el grafo
SELECT 
    '💊 MEDICAMENTOS CON LACTOSA (GRAFO)' as tipo,
    COUNT(DISTINCT src_key) as cantidad_medicamentos
FROM graph_edge
WHERE rel = 'CONTIENE_EXCIPIENTE'
  AND dst_key IN (
      SELECT node_key 
      FROM graph_node 
      WHERE node_type = 'Excipiente' 
        AND LOWER(name) LIKE '%lactosa%'
  );

-- 8. Ver las NOTAS de seguridad que tenemos
SELECT 
    'NOTAS DISPONIBLES' as tipo,
    COUNT(*) as total_notas
FROM graph_node
WHERE node_type = 'NotaSeguridad';

-- 9. Ver tipos de notas
SELECT 
    'TIPOS DE NOTAS' as tipo,
    props->>'tipo' as tipo_nota,
    COUNT(*) as cantidad
FROM graph_node
WHERE node_type = 'NotaSeguridad'
  AND props IS NOT NULL
GROUP BY props->>'tipo';

-- 10. Ver si hay medicamentos con alertas especiales
SELECT 
    'MEDICAMENTOS CON ALERTAS GERIATRIA' as tipo,
    COUNT(DISTINCT src_key) as cantidad_medicamentos
FROM graph_edge
WHERE rel = 'TIENE_ALERTA_GERIATRIA';
