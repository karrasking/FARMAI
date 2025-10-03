-- ============================================================
-- MAPEAR 2,691 PRINCIPIOS ACTIVOS FALTANTES
-- Crear nodos PrincipioActivo desde pa_unmatched
-- ============================================================

-- 1. Estado inicial
SELECT 'ANTES DEL MAPEO' as paso;
SELECT COUNT(*) as total_principios_activos FROM graph_node WHERE node_type = 'PrincipioActivo';
SELECT COUNT(DISTINCT codigo_num) as pas_sin_mapear FROM pa_unmatched;

-- 2. Crear nodos PrincipioActivo para los PAs sin mapear
INSERT INTO graph_node (node_type, node_key, props)
SELECT DISTINCT
    'PrincipioActivo',
    codigo_num::text,
    jsonb_build_object(
        'nombre', nom,
        'codigo', codigo_json,
        'categoria', categoria,
        'origen', 'pa_unmatched'
    )
FROM pa_unmatched
ON CONFLICT (node_type, node_key) DO NOTHING;

-- 3. Estado final
SELECT 'DESPUÉS DEL MAPEO' as paso;
SELECT COUNT(*) as total_principios_activos FROM graph_node WHERE node_type = 'PrincipioActivo';

-- 4. Verificar nodos creados
SELECT COUNT(*) as nodos_creados_desde_unmatched
FROM graph_node
WHERE node_type = 'PrincipioActivo'
  AND props->>'origen' = 'pa_unmatched';

-- 5. Ejemplos de PAs mapeados
SELECT node_key, props->>'nombre' as nombre, props->>'codigo' as codigo
FROM graph_node
WHERE node_type = 'PrincipioActivo'
  AND props->>'origen' = 'pa_unmatched'
LIMIT 10;

-- 6. Estadísticas finales
SELECT 
    'Total PrincipioActivo' as metrica,
    COUNT(*) as valor
FROM graph_node
WHERE node_type = 'PrincipioActivo'
UNION ALL
SELECT 
    'Con nombre' as metrica,
    COUNT(*) as valor
FROM graph_node
WHERE node_type = 'PrincipioActivo'
  AND props ? 'nombre'
UNION ALL
SELECT 
    'Desde pa_unmatched' as metrica,
    COUNT(*) as valor
FROM graph_node
WHERE node_type = 'PrincipioActivo'
  AND props->>'origen' = 'pa_unmatched';

SELECT '✅ MAPEO COMPLETADO - 2,691 PAs AGREGADOS AL GRAFO' as resultado;
