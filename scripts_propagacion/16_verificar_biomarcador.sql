-- ============================================
-- VERIFICACIÓN: Biomarcador (FARMACOGENÓMICA)
-- ============================================

\echo '=== ANÁLISIS BIOMARCADOR ==='
\echo ''

-- 1. Conteos
\echo '1. CONTEO DE REGISTROS'
SELECT 'Biomarcador (tabla)' as tabla, COUNT(*) as registros FROM "Biomarcador"
UNION ALL
SELECT 'MedicamentoBiomarcador', COUNT(*) FROM "MedicamentoBiomarcador"
UNION ALL
SELECT 'AliasBiomarcador', COUNT(*) FROM "AliasBiomarcador"
UNION ALL
SELECT 'BiomarcadorExtractStaging', COUNT(*) FROM "BiomarcadorExtractStaging";

\echo ''
\echo '2. ESTRUCTURA Biomarcador'
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'Biomarcador'
ORDER BY ordinal_position;

\echo ''
\echo '3. ESTRUCTURA MedicamentoBiomarcador'
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'MedicamentoBiomarcador'
ORDER BY ordinal_position;

\echo ''
\echo '4. ESTRUCTURA BiomarcadorExtractStaging'
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'BiomarcadorExtractStaging'
ORDER BY ordinal_position;

\echo ''
\echo '5. NODOS Biomarcador EN GRAFO'
SELECT COUNT(*) as nodos_biomarcador_en_grafo
FROM graph_node
WHERE node_type = 'Biomarcador';

\echo ''
\echo '6. ARISTAS Med->Biomarcador EN GRAFO'
SELECT 
  src_type,
  rel,
  COUNT(*) as total
FROM graph_edge
WHERE dst_type = 'Biomarcador'
GROUP BY src_type, rel;

\echo ''
\echo '7. BÚSQUEDA EN prescripcion_sample.xml'
-- Verificar si existe el archivo de muestra
\! if exist prescripcion_sample.xml (echo Archivo existe) else (echo Archivo NO existe)
