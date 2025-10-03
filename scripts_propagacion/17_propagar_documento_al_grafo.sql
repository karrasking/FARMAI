-- ============================================
-- PROPAGAR DOCUMENTO AL GRAFO
-- ============================================
-- 309 nodos Documento + ~309 aristas Med→Documento
-- ============================================

BEGIN;

\echo '=== PASO 7: PROPAGANDO DOCUMENTO AL GRAFO ==='
\echo ''

-- 1. Crear nodos Documento
\echo '1. Creando nodos Documento...'
INSERT INTO graph_node (node_type, node_key, props)
SELECT 
  'Documento',
  d."Id"::text,
  jsonb_build_object(
    'nregistro', d."NRegistro",
    'tipo', CASE d."Tipo" 
      WHEN 1 THEN 'ficha_tecnica'
      WHEN 2 THEN 'prospecto'
      ELSE 'desconocido'
    END,
    'secc', d."Secc",
    'url_html', d."UrlHtml",
    'url_pdf', d."UrlPdf",
    'fecha', d."Fecha",
    'fecha_documento', d."FechaDoc"
  )
FROM "Documento" d
ON CONFLICT (node_type, node_key) DO UPDATE
  SET props = EXCLUDED.props;

-- Verificar nodos
DO $$
DECLARE
  v_count int;
BEGIN
  SELECT COUNT(*) INTO v_count 
  FROM graph_node 
  WHERE node_type = 'Documento';
  
  RAISE NOTICE 'Nodos Documento creados: %', v_count;
END $$;

\echo ''
\echo '2. Creando aristas Medicamento → Documento...'

-- 2. Aristas Med → Documento
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
  'Medicamento',
  d."NRegistro",
  'TIENE_DOCUMENTO',
  'Documento',
  d."Id"::text,
  jsonb_build_object(
    'tipo', CASE d."Tipo" 
      WHEN 1 THEN 'ficha_tecnica'
      WHEN 2 THEN 'prospecto'
      ELSE 'desconocido'
    END
  )
FROM "Documento" d
WHERE EXISTS (
  SELECT 1 FROM graph_node gn 
  WHERE gn.node_type = 'Medicamento' 
  AND gn.node_key = d."NRegistro"
)
ON CONFLICT DO NOTHING;

-- Verificar aristas
DO $$
DECLARE
  v_count int;
BEGIN
  SELECT COUNT(*) INTO v_count 
  FROM graph_edge 
  WHERE dst_type = 'Documento' 
    AND rel = 'TIENE_DOCUMENTO';
  
  RAISE NOTICE 'Aristas Med → Documento creadas: %', v_count;
END $$;

COMMIT;

\echo ''
\echo '3. RESUMEN FINAL'
SELECT 
  'Nodos Documento' as metrica,
  COUNT(*) as total
FROM graph_node
WHERE node_type = 'Documento'

UNION ALL

SELECT 
  'Aristas Med → Documento',
  COUNT(*)
FROM graph_edge
WHERE dst_type = 'Documento' 
  AND rel = 'TIENE_DOCUMENTO';

\echo ''
\echo '4. EJEMPLOS'
SELECT 
  ge.src_key as nregistro,
  gn.props->>'tipo' as tipo_doc,
  LEFT(gn.props->>'url_pdf', 50) as url_pdf
FROM graph_edge ge
JOIN graph_node gn ON gn.node_type = 'Documento' AND gn.node_key = ge.dst_key
WHERE ge.dst_type = 'Documento'
  AND ge.rel = 'TIENE_DOCUMENTO'
LIMIT 5;

\echo ''
\echo '=== PASO 7 COMPLETADO ==='
