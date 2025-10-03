-- ============================================
-- PASO 2: Crear Aristas (VERSION SIMPLE)
-- ============================================
-- Solo INSERT, sin consultas complejas
-- ============================================

BEGIN;

-- 1. Medicamento -> SituacionRegistro
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT ON (ps."NRegistro", ps."CodSitReg")
  'Medicamento',
  ps."NRegistro",
  'TIENE_SITUACION_REGISTRO',
  'SituacionRegistro',
  ps."CodSitReg"::text,
  jsonb_build_object('fecha', ps."FechaSitReg", 'tipo', 'medicamento')
FROM "PrescripcionStaging" ps
WHERE ps."CodSitReg" IS NOT NULL
  AND ps."NRegistro" IS NOT NULL
  AND EXISTS (SELECT 1 FROM graph_node gn WHERE gn.node_type = 'Medicamento' AND gn.node_key = ps."NRegistro")
ORDER BY ps."NRegistro", ps."CodSitReg", ps."FechaSitReg" DESC NULLS LAST
ON CONFLICT DO NOTHING;

-- 2. Presentacion -> SituacionRegistro
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT ON (ps."CodNacion", ps."CodSitRegPresen")
  'Presentacion',
  ps."CodNacion",
  'TIENE_SITUACION_REGISTRO',
  'SituacionRegistro',
  ps."CodSitRegPresen"::text,
  jsonb_build_object('fecha', ps."FechaSitRegPresen", 'tipo', 'presentacion')
FROM "PrescripcionStaging" ps
WHERE ps."CodSitRegPresen" IS NOT NULL
  AND ps."CodNacion" IS NOT NULL
  AND EXISTS (SELECT 1 FROM graph_node gn WHERE gn.node_type = 'Presentacion' AND gn.node_key = ps."CodNacion")
ORDER BY ps."CodNacion", ps."CodSitRegPresen", ps."FechaSitRegPresen" DESC NULLS LAST
ON CONFLICT DO NOTHING;

COMMIT;

-- Mostrar conteo simple
SELECT COUNT(*) as total_aristas_situacion
FROM graph_edge
WHERE dst_type = 'SituacionRegistro' 
  AND rel = 'TIENE_SITUACION_REGISTRO';
