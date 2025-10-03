-- Investigación de tablas NO propagadas al grafo
-- Generado: 10/01/2025

-- ============================================
-- 1. LABORATORIO INFO
-- ============================================
\echo '=== 1. LABORATORIO INFO ==='
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'LaboratorioInfo'
ORDER BY ordinal_position;

SELECT * FROM "LaboratorioInfo" LIMIT 3;

-- ============================================
-- 2. PRINCIPIO ACTIVO STAGING
-- ============================================
\echo '=== 2. PRINCIPIO ACTIVO STAGING ==='
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'PrincipioActivoStaging'
ORDER BY ordinal_position;

SELECT * FROM "PrincipioActivoStaging" LIMIT 5;

-- ============================================
-- 3. SITUACION REGISTRO DIC STAGING
-- ============================================
\echo '=== 3. SITUACION REGISTRO ==='
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'SituacionRegistroDicStaging'
ORDER BY ordinal_position;

SELECT * FROM "SituacionRegistroDicStaging" ORDER BY "Codigo";

-- ============================================
-- 4. ALIAS EXCIPIENTE (Discrepancia)
-- ============================================
\echo '=== 4. ALIAS EXCIPIENTE ==='
SELECT COUNT(*) as total_tabla FROM "AliasExcipiente";
SELECT COUNT(*) as total_grafo FROM graph_node WHERE node_type = 'AliasExcipiente';

SELECT * FROM "AliasExcipiente";

-- ============================================
-- 5. PA_UNMATCHED (2,691 sin mapear)
-- ============================================
\echo '=== 5. PA UNMATCHED ==='
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'pa_unmatched'
ORDER BY ordinal_position;

SELECT * FROM pa_unmatched LIMIT 10;

-- ============================================
-- 6. ATC DISCREPANCIA
-- ============================================
\echo '=== 6. ATC DISCREPANCIA ==='
SELECT 
  'AtcDicStaging' as tabla,
  COUNT(*) as registros
FROM "AtcDicStaging"
UNION ALL
SELECT 
  'AtcXmlTemp',
  COUNT(*)
FROM "AtcXmlTemp"
UNION ALL
SELECT 
  'Atc',
  COUNT(*)
FROM "Atc"
UNION ALL
SELECT 
  'Grafo ATC',
  COUNT(*)
FROM graph_node WHERE node_type = 'ATC';

-- ============================================
-- 7. EXCIPIENTE DIC MAP
-- ============================================
\echo '=== 7. EXCIPIENTE DIC MAP ==='
SELECT * FROM excip_dic_map LIMIT 10;

-- ============================================
-- 8. MEDICAMENTO DETALLE RAW (Metadatos API)
-- ============================================
\echo '=== 8. MEDICAMENTO DETALLE RAW ==='
SELECT 
  COUNT(*) as total,
  COUNT("ETag") as con_etag,
  COUNT("LastModified") as con_last_modified,
  COUNT("ErrorText") as con_error
FROM "MedicamentoDetalleRaw";

-- ============================================
-- 9. MED QUARANTINE
-- ============================================
\echo '=== 9. MED QUARANTINE ==='
SELECT * FROM med_quarantine;

-- ============================================
-- 10. MEDICAMENTO DETALLE NOT FOUND
-- ============================================
\echo '=== 10. NOT FOUND ==='
SELECT 
  "HttpStatus",
  COUNT(*) as cantidad,
  ARRAY_AGG("Reason" ORDER BY "NRegistro" LIMIT 3) as ejemplos_razon
FROM "MedicamentoDetalleNotFound"
GROUP BY "HttpStatus"
ORDER BY cantidad DESC;

-- ============================================
-- 11. LABORATORIOS STAGING vs FINAL
-- ============================================
\echo '=== 11. LABORATORIOS DISCREPANCIA ==='
SELECT 
  'Staging' as origen,
  COUNT(*) as total
FROM "LaboratoriosDicStaging"
UNION ALL
SELECT 
  'Final',
  COUNT(*)
FROM "Laboratorio"
UNION ALL
SELECT 
  'Grafo',
  COUNT(*)
FROM graph_node WHERE node_type = 'Laboratorio';

-- Labs en staging que no están en final
SELECT lds."Nombre"
FROM "LaboratoriosDicStaging" lds
LEFT JOIN "Laboratorio" l ON l."NombreCanon" = lds."NombreCanon"
WHERE l."Id" IS NULL
LIMIT 10;
