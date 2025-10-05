-- ESTADO REAL DE LAS TABLAS DE GRAFO
-- =====================================
-- Ver qué nodos y aristas tenemos en las tablas _Vertex y _Edge

-- 1. Ver TODAS las tablas que tienen "graph" en el nombre o son de grafo
SELECT 
    'TABLAS DE GRAFO' as tipo,
    table_schema,
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = t.table_schema AND table_name = t.table_name) as num_columnas
FROM information_schema.tables t
WHERE table_name LIKE '%_Vertex' 
   OR table_name LIKE '%_Edge'
   OR table_name LIKE '%graph%'
ORDER BY table_schema, table_name;

-- 2. Si existe FarmaiGraph_Vertex, ver su estructura
SELECT 
    'COLUMNAS FarmaiGraph_Vertex' as tipo,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name LIKE '%Vertex'
ORDER BY ordinal_position;

-- 3. Contar registros en las tablas de grafo
SELECT 
    'CONTEO NODOS' as tipo,
    COUNT(*) as total_nodos,
    COUNT(DISTINCT "Type") as tipos_nodos_distintos
FROM "FarmaiGraph_Vertex"
WHERE 1=1;

SELECT 
    'CONTEO POR TIPO NODO' as categoria,
    "Type" as tipo_nodo,
    COUNT(*) as cantidad
FROM "FarmaiGraph_Vertex"
GROUP BY "Type"
ORDER BY cantidad DESC;

-- 4. Ver propiedades de UN nodo Medicamento de ejemplo
SELECT 
    'EJEMPLO NODO MEDICAMENTO' as tipo,
    "Id",
    "Type",
    jsonb_pretty("Properties"::jsonb) as propiedades
FROM "FarmaiGraph_Vertex"
WHERE "Type" = 'Medicamento'
LIMIT 1;

-- 5. Ver QUÉ PROPIEDADES tienen los nodos Medicamento
SELECT 
    'PROPIEDADES EN MEDICAMENTO GRAFO' as tipo,
    jsonb_object_keys("Properties"::jsonb) as propiedad,
    COUNT(*) as apariciones
FROM "FarmaiGraph_Vertex"
WHERE "Type" = 'Medicamento'
  AND "Properties" IS NOT NULL
GROUP BY propiedad
ORDER BY apariciones DESC;

-- 6. Contar aristas
SELECT 
    'CONTEO ARISTAS' as tipo,
    COUNT(*) as total_aristas,
    COUNT(DISTINCT "Type") as tipos_aristas_distintas
FROM "FarmaiGraph_Edge";

SELECT 
    'CONTEO POR TIPO ARISTA' as categoria,
    "Type" as tipo_arista,
    COUNT(*) as cantidad
FROM "FarmaiGraph_Edge"
GROUP BY "Type"
ORDER BY cantidad DESC;

-- 7. Ver si existen los 4 NUEVOS campos en el grafo
SELECT 
    'NUEVOS CAMPOS EN GRAFO?' as pregunta,
    COUNT(CASE WHEN "Properties"::jsonb ? 'AutorizadoPorEma' THEN 1 END) as tiene_ema,
    COUNT(CASE WHEN "Properties"::jsonb ? 'TieneNotas' THEN 1 END) as tiene_notas,
    COUNT(CASE WHEN "Properties"::jsonb ? 'RequiereReceta' THEN 1 END) as tiene_receta,
    COUNT(CASE WHEN "Properties"::jsonb ? 'EsGenerico' THEN 1 END) as tiene_generico,
    COUNT(*) as total_medicamentos_grafo
FROM "FarmaiGraph_Vertex"
WHERE "Type" = 'Medicamento';
