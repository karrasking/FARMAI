-- ============================================
-- VERIFICACIÓN: Documento (URLs FT/Prospecto)
-- ============================================

\echo '=== ANÁLISIS DOCUMENTO ==='
\echo ''

-- 1. Conteos
\echo '1. CONTEO DE REGISTROS'
SELECT 'Documento (tabla)' as tabla, COUNT(*) as registros FROM "Documento"
UNION ALL
SELECT 'PrescripcionStaging (URLs FT)', COUNT(*) 
FROM "PrescripcionStaging" 
WHERE "UrlFictec" IS NOT NULL
UNION ALL
SELECT 'PrescripcionStaging (URLs Prospecto)', COUNT(*) 
FROM "PrescripcionStaging" 
WHERE "UrlProsp" IS NOT NULL;

\echo ''
\echo '2. ESTRUCTURA Documento'
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'Documento'
ORDER BY ordinal_position;

\echo ''
\echo '3. EJEMPLOS URLs en PrescripcionStaging'
SELECT 
  "NRegistro",
  LEFT("UrlFictec", 60) as url_ft,
  LEFT("UrlProsp", 60) as url_prospecto
FROM "PrescripcionStaging"
WHERE "UrlFictec" IS NOT NULL 
   OR "UrlProsp" IS NOT NULL
LIMIT 5;

\echo ''
\echo '4. NODOS Documento EN GRAFO'
SELECT COUNT(*) as nodos_documento_en_grafo
FROM graph_node
WHERE node_type = 'Documento';

\echo ''
\echo '5. ARISTAS Med->Documento EN GRAFO'
SELECT 
  src_type,
  rel,
  COUNT(*) as total
FROM graph_edge
WHERE dst_type = 'Documento'
GROUP BY src_type, rel;
