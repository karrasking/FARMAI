-- ============================================================
-- PROPAGAR 11 FLAGS RESTANTES AL GRAFO
-- Completando TODOS los flags disponibles
-- ============================================================

-- 1. Verificar estado actual
SELECT COUNT(*) as flags_actuales FROM graph_node WHERE node_type = 'Flag';

-- 2. Crear nodos para los 11 flags restantes
INSERT INTO graph_node (node_type, node_key, props)
VALUES 
    ('Flag', 'SUSTITUIBLE', jsonb_build_object('nombre', 'Sustituible', 'descripcion', 'Medicamento sustituible por genérico', 'severidad', 'ninguna')),
    ('Flag', 'ENVASE_CLINICO', jsonb_build_object('nombre', 'Envase Clínico', 'descripcion', 'Envase de uso clínico/hospitalario', 'severidad', 'media')),
    ('Flag', 'USO_HOSPITALARIO', jsonb_build_object('nombre', 'Uso Hospitalario', 'descripcion', 'De uso exclusivo hospitalario', 'severidad', 'alta')),
    ('Flag', 'DIAGNOSTICO_HOSPITALARIO', jsonb_build_object('nombre', 'Diagnóstico Hospitalario', 'descripcion', 'Requiere diagnóstico hospitalario', 'severidad', 'alta')),
    ('Flag', 'TLD', jsonb_build_object('nombre', 'TLD', 'descripcion', 'Terapia de Larga Duración', 'severidad', 'media')),
    ('Flag', 'ESPECIAL_CONTROL_MEDICO', jsonb_build_object('nombre', 'Control Médico Especial', 'descripcion', 'Requiere control médico especial', 'severidad', 'alta')),
    ('Flag', 'BASE_PLANTAS', jsonb_build_object('nombre', 'Base a Plantas', 'descripcion', 'Medicamento de base vegetal', 'severidad', 'ninguna')),
    ('Flag', 'IMPORTACION_PARALELA', jsonb_build_object('nombre', 'Importación Paralela', 'descripcion', 'Medicamento de importación paralela', 'severidad', 'media')),
    ('Flag', 'RADIOFARMACO', jsonb_build_object('nombre', 'Radiofármaco', 'descripcion', 'Medicamento radiofármaco', 'severidad', 'muy_alta')),
    ('Flag', 'SERIALIZACION', jsonb_build_object('nombre', 'Serialización', 'descripcion', 'Medicamento con código de serialización', 'severidad', 'ninguna')),
    ('Flag', 'TIENE_EXCIP_DECL_OBLIG', jsonb_build_object('nombre', 'Excipientes Declaración Obligatoria', 'descripcion', 'Contiene excipientes de declaración obligatoria', 'severidad', 'media'))
ON CONFLICT DO NOTHING;

-- 3. Verificar total después
SELECT COUNT(*) as flags_despues FROM graph_node WHERE node_type = 'Flag';

-- 4-14. Crear aristas para cada flag (desde PrescripcionStaging)

-- SUSTITUIBLE
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT
    'Medicamento',
    ps."NRegistro",
    'TIENE_FLAG',
    'Flag',
    'SUSTITUIBLE',
    jsonb_build_object('activo', true, 'fuente', 'prescripcion')
FROM "PrescripcionStaging" ps
WHERE ps."SwSustituible" = true
  AND EXISTS (SELECT 1 FROM "Medicamentos" m WHERE m."NRegistro" = ps."NRegistro")
ON CONFLICT DO NOTHING;

-- ENVASE_CLINICO  
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT
    'Medicamento', ps."NRegistro", 'TIENE_FLAG', 'Flag', 'ENVASE_CLINICO',
    jsonb_build_object('activo', true, 'fuente', 'prescripcion')
FROM "PrescripcionStaging" ps
WHERE ps."SwEnvaseClinico" = true
  AND EXISTS (SELECT 1 FROM "Medicamentos" m WHERE m."NRegistro" = ps."NRegistro")
ON CONFLICT DO NOTHING;

-- USO_HOSPITALARIO
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT
    'Medicamento', ps."NRegistro", 'TIENE_FLAG', 'Flag', 'USO_HOSPITALARIO',
    jsonb_build_object('activo', true, 'fuente', 'prescripcion')
FROM "PrescripcionStaging" ps
WHERE ps."SwUsoHospitalario" = true
  AND EXISTS (SELECT 1 FROM "Medicamentos" m WHERE m."NRegistro" = ps."NRegistro")
ON CONFLICT DO NOTHING;

-- DIAGNOSTICO_HOSPITALARIO
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT
    'Medicamento', ps."NRegistro", 'TIENE_FLAG', 'Flag', 'DIAGNOSTICO_HOSPITALARIO',
    jsonb_build_object('activo', true, 'fuente', 'prescripcion')
FROM "PrescripcionStaging" ps
WHERE ps."SwDiagnosticoHospitalario" = true
  AND EXISTS (SELECT 1 FROM "Medicamentos" m WHERE m."NRegistro" = ps."NRegistro")
ON CONFLICT DO NOTHING;

-- TLD
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT
    'Medicamento', ps."NRegistro", 'TIENE_FLAG', 'Flag', 'TLD',
    jsonb_build_object('activo', true, 'fuente', 'prescripcion')
FROM "PrescripcionStaging" ps
WHERE ps."SwTld" = true
  AND EXISTS (SELECT 1 FROM "Medicamentos" m WHERE m."NRegistro" = ps."NRegistro")
ON CONFLICT DO NOTHING;

-- ESPECIAL_CONTROL_MEDICO
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT
    'Medicamento', ps."NRegistro", 'TIENE_FLAG', 'Flag', 'ESPECIAL_CONTROL_MEDICO',
    jsonb_build_object('activo', true, 'fuente', 'prescripcion')
FROM "PrescripcionStaging" ps
WHERE ps."SwEspecialControlMedico" = true
  AND EXISTS (SELECT 1 FROM "Medicamentos" m WHERE m."NRegistro" = ps."NRegistro")
ON CONFLICT DO NOTHING;

-- BASE_PLANTAS
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT
    'Medicamento', ps."NRegistro", 'TIENE_FLAG', 'Flag', 'BASE_PLANTAS',
    jsonb_build_object('activo', true, 'fuente', 'prescripcion')
FROM "PrescripcionStaging" ps
WHERE ps."SwBaseAPlantas" = true
  AND EXISTS (SELECT 1 FROM "Medicamentos" m WHERE m."NRegistro" = ps."NRegistro")
ON CONFLICT DO NOTHING;

-- IMPORTACION_PARALELA
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT
    'Medicamento', ps."NRegistro", 'TIENE_FLAG', 'Flag', 'IMPORTACION_PARALELA',
    jsonb_build_object('activo', true, 'fuente', 'prescripcion')
FROM "PrescripcionStaging" ps
WHERE ps."ImportacionParalela" = true
  AND EXISTS (SELECT 1 FROM "Medicamentos" m WHERE m."NRegistro" = ps."NRegistro")
ON CONFLICT DO NOTHING;

-- RADIOFARMACO
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT
    'Medicamento', ps."NRegistro", 'TIENE_FLAG', 'Flag', 'RADIOFARMACO',
    jsonb_build_object('activo', true, 'fuente', 'prescripcion')
FROM "PrescripcionStaging" ps
WHERE ps."Radiofarmaco" = true
  AND EXISTS (SELECT 1 FROM "Medicamentos" m WHERE m."NRegistro" = ps."NRegistro")
ON CONFLICT DO NOTHING;

-- SERIALIZACION
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT
    'Medicamento', ps."NRegistro", 'TIENE_FLAG', 'Flag', 'SERIALIZACION',
    jsonb_build_object('activo', true, 'fuente', 'prescripcion')
FROM "PrescripcionStaging" ps
WHERE ps."Serializacion" = true
  AND EXISTS (SELECT 1 FROM "Medicamentos" m WHERE m."NRegistro" = ps."NRegistro")
ON CONFLICT DO NOTHING;

-- TIENE_EXCIP_DECL_OBLIG
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT
    'Medicamento', ps."NRegistro", 'TIENE_FLAG', 'Flag', 'TIENE_EXCIP_DECL_OBLIG',
    jsonb_build_object('activo', true, 'fuente', 'prescripcion')
FROM "PrescripcionStaging" ps
WHERE ps."SwTieneExcipDeclOblig" = true
  AND EXISTS (SELECT 1 FROM "Medicamentos" m WHERE m."NRegistro" = ps."NRegistro")
ON CONFLICT DO NOTHING;

-- 15. Conteo final por flag
SELECT 
    'SUSTITUIBLE' as flag, COUNT(*) as aristas
FROM graph_edge WHERE dst_type = 'Flag' AND dst_key = 'SUSTITUIBLE'
UNION ALL SELECT 'ENVASE_CLINICO', COUNT(*) FROM graph_edge WHERE dst_type = 'Flag' AND dst_key = 'ENVASE_CLINICO'
UNION ALL SELECT 'USO_HOSPITALARIO', COUNT(*) FROM graph_edge WHERE dst_type = 'Flag' AND dst_key = 'USO_HOSPITALARIO'
UNION ALL SELECT 'DIAGNOSTICO_HOSPITALARIO', COUNT(*) FROM graph_edge WHERE dst_type = 'Flag' AND dst_key = 'DIAGNOSTICO_HOSPITALARIO'
UNION ALL SELECT 'TLD', COUNT(*) FROM graph_edge WHERE dst_type = 'Flag' AND dst_key = 'TLD'
UNION ALL SELECT 'ESPECIAL_CONTROL_MEDICO', COUNT(*) FROM graph_edge WHERE dst_type = 'Flag' AND dst_key = 'ESPECIAL_CONTROL_MEDICO'
UNION ALL SELECT 'BASE_PLANTAS', COUNT(*) FROM graph_edge WHERE dst_type = 'Flag' AND dst_key = 'BASE_PLANTAS'
UNION ALL SELECT 'IMPORTACION_PARALELA', COUNT(*) FROM graph_edge WHERE dst_type = 'Flag' AND dst_key = 'IMPORTACION_PARALELA'
UNION ALL SELECT 'RADIOFARMACO', COUNT(*) FROM graph_edge WHERE dst_type = 'Flag' AND dst_key = 'RADIOFARMACO'
UNION ALL SELECT 'SERIALIZACION', COUNT(*) FROM graph_edge WHERE dst_type = 'Flag' AND dst_key = 'SERIALIZACION'
UNION ALL SELECT 'TIENE_EXCIP_DECL_OBLIG', COUNT(*) FROM graph_edge WHERE dst_type = 'Flag' AND dst_key = 'TIENE_EXCIP_DECL_OBLIG';

-- 16. Total flags y aristas
SELECT 
    COUNT(DISTINCT node_key) as total_flags_unicos
FROM graph_node WHERE node_type = 'Flag';

SELECT COUNT(*) as total_tiene_flag FROM graph_edge WHERE rel = 'TIENE_FLAG';

SELECT '✅ 11 FLAGS FINALES PROPAGADOS' as resultado;
