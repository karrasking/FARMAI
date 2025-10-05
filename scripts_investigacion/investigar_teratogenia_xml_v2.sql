-- INVESTIGACIÓN TERATOGENIA - Versión corregida
-- Primero verificar qué tablas y columnas existen

-- 1. Ver qué columnas tiene MedicamentoDetalleRaw
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'MedicamentoDetalleRaw'
ORDER BY ordinal_position;

-- 2. Ver qué columnas tiene PrescripcionStaging
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'PrescripcionStaging'
ORDER BY ordinal_position
LIMIT 20;

-- 3. Verificar si hay información sobre embarazo/lactancia en alguna columna
SELECT 
    table_name,
    column_name
FROM information_schema.columns
WHERE table_schema = 'public'
AND (
    column_name ILIKE '%embarazo%'
    OR column_name ILIKE '%lactancia%'
    OR column_name ILIKE '%terato%'
    OR column_name ILIKE '%riesgo%'
)
ORDER BY table_name, column_name;
