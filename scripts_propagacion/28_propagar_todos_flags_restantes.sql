-- ============================================================
-- PROPAGAR TODOS LOS FLAGS RESTANTES AL GRAFO
-- Psicotropo, Estupefaciente, Generico, RequiereReceta, Comercializado, TieneFotos, PSUM
-- ============================================================

-- 1. Crear nodos para TODOS los flags nuevos
INSERT INTO graph_node (node_type, node_key, props)
VALUES 
    ('Flag', 'PSICOTROPO', jsonb_build_object('nombre', 'Psicotropo', 'descripcion', 'Sustancia psicotrópica controlada', 'severidad', 'alta')),
    ('Flag', 'ESTUPEFACIENTE', jsonb_build_object('nombre', 'Estupefaciente', 'descripcion', 'Sustancia estupefaciente controlada', 'severidad', 'muy_alta')),
    ('Flag', 'GENERICO', jsonb_build_object('nombre', 'Genérico', 'descripcion', 'Medicamento genérico (EFG)', 'severidad', 'ninguna')),
    ('Flag', 'REQUIERE_RECETA', jsonb_build_object('nombre', 'Requiere Receta', 'descripcion', 'Medicamento sujeto a prescripción médica', 'severidad', 'media')),
    ('Flag', 'COMERCIALIZADO', jsonb_build_object('nombre', 'Comercializado', 'descripcion', 'Actualmente comercializado', 'severidad', 'ninguna')),
    ('Flag', 'TIENE_FOTOS', jsonb_build_object('nombre', 'Tiene Fotos', 'descripcion', 'Dispone de imágenes del medicamento', 'severidad', 'ninguna')),
    ('Flag', 'PSUM', jsonb_build_object('nombre', 'PSUM', 'descripcion', 'Plan de Seguimiento, Uso y Minimización de riesgos', 'severidad', 'alta'))
ON CONFLICT DO NOTHING;

-- 2. Verificar cuántos flags hay ahora
SELECT COUNT(*) as total_flags FROM graph_node WHERE node_type = 'Flag';

-- 3. PSICOTROPO - desde PrescripcionStaging
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT
    'Medicamento',
    ps."NRegistro",
    'TIENE_FLAG',
    'Flag',
    'PSICOTROPO',
    jsonb_build_object('activo', true, 'fuente', 'prescripcion')
FROM "PrescripcionStaging" ps
WHERE ps."SwPsicotropo" = true
  AND EXISTS (
      SELECT 1 FROM "Medicamentos" m WHERE m."NRegistro" = ps."NRegistro"
  )
ON CONFLICT DO NOTHING;

-- 4. ESTUPEFACIENTE - desde PrescripcionStaging
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT
    'Medicamento',
    ps."NRegistro",
    'TIENE_FLAG',
    'Flag',
    'ESTUPEFACIENTE',
    jsonb_build_object('activo', true, 'fuente', 'prescripcion')
FROM "PrescripcionStaging" ps
WHERE ps."SwEstupefaciente" = true
  AND EXISTS (
      SELECT 1 FROM "Medicamentos" m WHERE m."NRegistro" = ps."NRegistro"
  )
ON CONFLICT DO NOTHING;

-- 5. GENERICO - desde Medicamentos
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Medicamento',
    "NRegistro",
    'TIENE_FLAG',
    'Flag',
    'GENERICO',
    jsonb_build_object('activo', true)
FROM "Medicamentos"
WHERE "Generico" = true
ON CONFLICT DO NOTHING;

-- 6. REQUIERE_RECETA - desde Medicamentos
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Medicamento',
    "NRegistro",
    'TIENE_FLAG',
    'Flag',
    'REQUIERE_RECETA',
    jsonb_build_object('activo', true)
FROM "Medicamentos"
WHERE "Receta" = true
ON CONFLICT DO NOTHING;

-- 7. COMERCIALIZADO - desde Medicamentos
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Medicamento',
    "NRegistro",
    'TIENE_FLAG',
    'Flag',
    'COMERCIALIZADO',
    jsonb_build_object('activo', true)
FROM "Medicamentos"
WHERE "Comercializado" = true
ON CONFLICT DO NOTHING;

-- 8. TIENE_FOTOS - desde Medicamentos
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Medicamento',
    "NRegistro",
    'TIENE_FLAG',
    'Flag',
    'TIENE_FOTOS',
    jsonb_build_object('activo', true)
FROM "Medicamentos"
WHERE "Fotos" = true
ON CONFLICT DO NOTHING;

-- 9. PSUM - desde Medicamentos
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Medicamento',
    "NRegistro",
    'TIENE_FLAG',
    'Flag',
    'PSUM',
    jsonb_build_object('activo', true)
FROM "Medicamentos"
WHERE "Psum" = true
ON CONFLICT DO NOTHING;

-- 10. Verificar conteos finales de cada flag nuevo
SELECT 
    'PSICOTROPO' as flag,
    COUNT(*) as aristas
FROM graph_edge
WHERE dst_type = 'Flag' AND dst_key = 'PSICOTROPO'
UNION ALL
SELECT 
    'ESTUPEFACIENTE',
    COUNT(*)
FROM graph_edge
WHERE dst_type = 'Flag' AND dst_key = 'ESTUPEFACIENTE'
UNION ALL
SELECT 
    'GENERICO',
    COUNT(*)
FROM graph_edge
WHERE dst_type = 'Flag' AND dst_key = 'GENERICO'
UNION ALL
SELECT 
    'REQUIERE_RECETA',
    COUNT(*)
FROM graph_edge
WHERE dst_type = 'Flag' AND dst_key = 'REQUIERE_RECETA'
UNION ALL
SELECT 
    'COMERCIALIZADO',
    COUNT(*)
FROM graph_edge
WHERE dst_type = 'Flag' AND dst_key = 'COMERCIALIZADO'
UNION ALL
SELECT 
    'TIENE_FOTOS',
    COUNT(*)
FROM graph_edge
WHERE dst_type = 'Flag' AND dst_key = 'TIENE_FOTOS'
UNION ALL
SELECT 
    'PSUM',
    COUNT(*)
FROM graph_edge
WHERE dst_type = 'Flag' AND dst_key = 'PSUM';

-- 11. Total aristas TIENE_FLAG después de todo
SELECT COUNT(*) as total_tiene_flag 
FROM graph_edge 
WHERE rel = 'TIENE_FLAG';

-- 12. Total de flags en el sistema
SELECT COUNT(*) as total_flags_nodos
FROM graph_node 
WHERE node_type = 'Flag';

-- 13. Medicamentos con múltiples flags (top 20)
SELECT 
    gn.props->>'nombre' as medicamento,
    array_agg(DISTINCT ge.dst_key ORDER BY ge.dst_key) as flags,
    COUNT(DISTINCT ge.dst_key) as num_flags
FROM graph_edge ge
JOIN graph_node gn ON ge.src_key = gn.node_key AND gn.node_type = 'Medicamento'
WHERE ge.rel = 'TIENE_FLAG' 
  AND ge.dst_type = 'Flag'
  AND gn.props ? 'nombre'
GROUP BY gn.props->>'nombre'
ORDER BY num_flags DESC, medicamento
LIMIT 20;

-- 14. Distribución de flags por tipo
SELECT 
    ge.dst_key as flag,
    COUNT(*) as medicamentos
FROM graph_edge ge
WHERE ge.rel = 'TIENE_FLAG' 
  AND ge.dst_type = 'Flag'
GROUP BY ge.dst_key
ORDER BY medicamentos DESC;

SELECT '✅ TODOS LOS FLAGS PROPAGADOS AL GRAFO' as resultado;
