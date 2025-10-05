-- ========================================
-- INVESTIGACIÓN COMPLETA FASE 3: FOTOS
-- ========================================

-- 1. Ver si existe tabla Foto
SELECT 
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name ILIKE '%foto%'
ORDER BY table_name;

-- 2. Si existe, ver estructura completa
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'Foto'
ORDER BY ordinal_position;

-- 3. Conteo actual de fotos
SELECT COUNT(*) as "TotalFotos"
FROM "Foto";

-- 4. Sample de fotos existentes
SELECT *
FROM "Foto"
LIMIT 10;

-- 5. Ver distribución por tipo
SELECT 
    "Tipo",
    COUNT(*) as "Cantidad"
FROM "Foto"
GROUP BY "Tipo"
ORDER BY COUNT(*) DESC;

-- 6. Ver medicamentos con fotos vs sin fotos
SELECT 
    'Con Fotos' as "Estado",
    COUNT(DISTINCT f."NRegistro") as "Cantidad"
FROM "Foto" f
UNION ALL
SELECT 
    'Sin Fotos' as "Estado",
    COUNT(*) as "Cantidad"
FROM "Medicamentos" m
WHERE NOT EXISTS (SELECT 1 FROM "Foto" f WHERE f."NRegistro" = m."NRegistro");

-- 7. Verificar Foreign Keys existentes
SELECT 
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_name = 'Foto';

-- 8. Ver índices existentes en tabla Foto
SELECT 
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'Foto'
ORDER BY indexname;

-- 9. Buscar fotos en JSON de API CIMA
SELECT 
    COUNT(*) as "TotalMedicamentosConJson",
    COUNT(*) FILTER (WHERE "Json"::text ILIKE '%fotos%') as "JsonConFotos",
    COUNT(*) FILTER (WHERE "Json"::text ILIKE '%foto%') as "JsonConFoto",
    COUNT(*) FILTER (WHERE "Json"::text ILIKE '%imagen%') as "JsonConImagen"
FROM "MedicamentoDetalleRaw";

-- 10. Sample de estructura fotos en JSON
SELECT 
    "NRegistro",
    "Json"->'fotos' as "FotosJson"
FROM "MedicamentoDetalleRaw"
WHERE "Json"::text ILIKE '%fotos%'
LIMIT 3;

-- 11. Verificar si hay fotos en grafo
SELECT 
    COUNT(*) as "NodosFoto"
FROM graph_node
WHERE node_type = 'Foto';

-- 12. Verificar relaciones foto en grafo
SELECT 
    rel,
    COUNT(*) as "Cantidad"
FROM graph_edge
WHERE src_type = 'Medicamento'
AND dst_type = 'Foto'
   OR src_type = 'Foto'
GROUP BY rel;
