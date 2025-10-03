-- ============================================
-- PASO 2: Crear Aristas SituacionRegistro (CORREGIDO)
-- ============================================
-- Propósito: Conectar med/pres con sus estados (sin duplicados)
-- Seguridad: ALTA - Solo inserta aristas, no modifica nodos
-- Tiempo estimado: 5-10 segundos
-- ============================================

BEGIN;

\echo '=== PASO 2: CREANDO ARISTAS SITUACION REGISTRO (V2 - SIN DUPLICADOS) ==='
\echo ''

-- Verificar nodos existen
DO $$
DECLARE
  v_nodos int;
BEGIN
  SELECT COUNT(*) INTO v_nodos 
  FROM graph_node 
  WHERE node_type = 'SituacionRegistro';
  
  IF v_nodos != 3 THEN
    RAISE EXCEPTION 'ERROR: Se esperan 3 nodos SituacionRegistro, hay %', v_nodos;
  END IF;
  
  RAISE NOTICE 'Verificado: 3 nodos SituacionRegistro existen';
END $$;

\echo ''
\echo '1. Creando aristas Medicamento → SituacionRegistro (DISTINCT)...'

-- 1. Medicamento → SituacionRegistro (con DISTINCT para evitar duplicados)
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT ON (ps."NRegistro", ps."CodSitReg")
  'Medicamento',
  ps."NRegistro",
  'TIENE_SITUACION_REGISTRO',
  'SituacionRegistro',
  ps."CodSitReg"::text,
  jsonb_build_object(
    'fecha', ps."FechaSitReg",
    'tipo', 'medicamento'
  )
FROM "PrescripcionStaging" ps
WHERE ps."CodSitReg" IS NOT NULL
  AND ps."NRegistro" IS NOT NULL
  AND EXISTS (
    SELECT 1 FROM graph_node gn 
    WHERE gn.node_type = 'Medicamento' 
    AND gn.node_key = ps."NRegistro"
  )
ORDER BY ps."NRegistro", ps."CodSitReg", ps."FechaSitReg" DESC NULLS LAST
ON CONFLICT (src_type, src_key, rel, dst_type, dst_key) 
DO NOTHING;

-- Contar resultado
DO $$
DECLARE
  v_count int;
BEGIN
  SELECT COUNT(*) INTO v_count 
  FROM graph_edge 
  WHERE src_type = 'Medicamento' 
    AND dst_type = 'SituacionRegistro'
    AND rel = 'TIENE_SITUACION_REGISTRO';
  
  RAISE NOTICE 'Aristas Medicamento → SituacionRegistro creadas: %', v_count;
END $$;

\echo ''
\echo '2. Creando aristas Presentacion → SituacionRegistro (DISTINCT)...'

-- 2. Presentacion → SituacionRegistro (con DISTINCT)
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT DISTINCT ON (ps."CodNacion", ps."CodSitRegPresen")
  'Presentacion',
  ps."CodNacion",
  'TIENE_SITUACION_REGISTRO',
  'SituacionRegistro',
  ps."CodSitRegPresen"::text,
  jsonb_build_object(
    'fecha', ps."FechaSitRegPresen",
    'tipo', 'presentacion'
  )
FROM "PrescripcionStaging" ps
WHERE ps."CodSitRegPresen" IS NOT NULL
  AND ps."CodNacion" IS NOT NULL
  AND EXISTS (
    SELECT 1 FROM graph_node gn 
    WHERE gn.node_type = 'Presentacion' 
    AND gn.node_key = ps."CodNacion"
  )
ORDER BY ps."CodNacion", ps."CodSitRegPresen", ps."FechaSitRegPresen" DESC NULLS LAST
ON CONFLICT (src_type, src_key, rel, dst_type, dst_key) 
DO NOTHING;

-- Contar resultado
DO $$
DECLARE
  v_count int;
BEGIN
  SELECT COUNT(*) INTO v_count 
  FROM graph_edge 
  WHERE src_type = 'Presentacion' 
    AND dst_type = 'SituacionRegistro'
    AND rel = 'TIENE_SITUACION_REGISTRO';
  
  RAISE NOTICE 'Aristas Presentacion → SituacionRegistro creadas: %', v_count;
END $$;

\echo ''
\echo '3. RESUMEN FINAL'

-- Resumen por situación
SELECT 
  'Medicamento → ' || gn.props->>'nombre' as tipo_arista,
  COUNT(*) as total
FROM graph_edge ge
JOIN graph_node gn ON gn.node_type = 'SituacionRegistro' AND gn.node_key = ge.dst_key
WHERE ge.src_type = 'Medicamento' 
  AND ge.dst_type = 'SituacionRegistro'
  AND ge.rel = 'TIENE_SITUACION_REGISTRO'
GROUP BY gn.props->>'nombre'

UNION ALL

SELECT 
  'Presentacion → ' || gn.props->>'nombre',
  COUNT(*)
FROM graph_edge ge
JOIN graph_node gn ON gn.node_type = 'SituacionRegistro' AND gn.node_key = ge.dst_key
WHERE ge.src_type = 'Presentacion' 
  AND ge.dst_type = 'SituacionRegistro'
  AND ge.rel = 'TIENE_SITUACION_REGISTRO'
GROUP BY gn.props->>'nombre'

UNION ALL

SELECT 
  'TOTAL ARISTAS',
  COUNT(*)
FROM graph_edge
WHERE dst_type = 'SituacionRegistro'
  AND rel = 'TIENE_SITUACION_REGISTRO';

\echo ''
\echo '4. EJEMPLOS DE VERIFICACIÓN'

-- Mostrar ejemplos
SELECT 
  ge.src_type as origen_tipo,
  SUBSTRING(ge.src_key, 1, 15) as origen_id,
  gn.props->>'nombre' as situacion,
  ge.props->>'fecha' as fecha
FROM graph_edge ge
JOIN graph_node gn ON gn.node_type = 'SituacionRegistro' AND gn.node_key = ge.dst_key
WHERE ge.dst_type = 'SituacionRegistro'
  AND ge.rel = 'TIENE_SITUACION_REGISTRO'
ORDER BY RANDOM()
LIMIT 10;

COMMIT;

\echo ''
\echo '=== PASO 2 COMPLETADO CON ÉXITO ==='
