-- ============================================
-- PASO 4: Crear Aristas FlagEstado
-- ============================================
-- Propósito: Conectar medicamentos con flags
-- Total esperado: ~1,446 aristas
-- ============================================

BEGIN;

-- 1. Med → EN_CUARENTENA (31 aristas)
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
  'Medicamento',
  nregistro,
  'TIENE_FLAG',
  'FlagEstado',
  'EN_CUARENTENA',
  jsonb_build_object(
    'motivo', motivo,
    'fecha_cuarentena', created_at
  )
FROM med_quarantine
WHERE EXISTS (
  SELECT 1 FROM graph_node gn 
  WHERE gn.node_type = 'Medicamento' 
  AND gn.node_key = nregistro
)
ON CONFLICT DO NOTHING;

-- 2. Med → NO_ENCONTRADO (1,415 aristas)
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
  'Medicamento',
  "NRegistro",
  'TIENE_FLAG',
  'FlagEstado',
  'NO_ENCONTRADO',
  jsonb_build_object(
    'http_status', "HttpStatus",
    'razon', "Reason",
    'intentos', "Attempts",
    'ultimo_intento', "LastTried"
  )
FROM "MedicamentoDetalleNotFound"
WHERE EXISTS (
  SELECT 1 FROM graph_node gn 
  WHERE gn.node_type = 'Medicamento' 
  AND gn.node_key = "NRegistro"
)
ON CONFLICT DO NOTHING;

COMMIT;

-- Verificar
SELECT 
  gn.props->>'nombre' as flag,
  COUNT(*) as total_medicamentos
FROM graph_edge ge
JOIN graph_node gn ON gn.node_type = 'FlagEstado' AND gn.node_key = ge.dst_key
WHERE ge.dst_type = 'FlagEstado' 
  AND ge.rel = 'TIENE_FLAG'
GROUP BY gn.props->>'nombre'
ORDER BY COUNT(*) DESC;
