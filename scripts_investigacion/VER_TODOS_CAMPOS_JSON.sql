-- VER TODOS LOS CAMPOS JSON EN MEDICAMENTOS
-- ============================================

-- 1. Ver TODOS los campos de la tabla
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'Medicamentos'
ORDER BY ordinal_position;

-- 2. Contar específicamente los campos JSON/JSONB
SELECT column_name, data_type
FROM information_schema.columns 
WHERE table_name = 'Medicamentos'
  AND (data_type LIKE '%json%' OR column_name LIKE '%Json%')
ORDER BY column_name;

-- 3. Ver sample de TODOS los campos JSON que encuentre
-- Ver un medicamento completo con TODOS sus campos
SELECT *
FROM "Medicamentos"
WHERE "NRegistro" = '85358'
LIMIT 1;
