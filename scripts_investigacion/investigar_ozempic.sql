-- Investigar OZEMPIC y su estructura JSON completa

-- 1. Buscar OZEMPIC
SELECT 
    "NRegistro",
    "Nombre",
    "RawJson"
FROM "Medicamentos"
WHERE "Nombre" LIKE '%OZEMPIC%'
LIMIT 1;

-- 2. Ver si tiene URLs en otras columnas (no solo RawJson)
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'Medicamentos'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. Ver todos los campos de OZEMPIC
SELECT *
FROM "Medicamentos"
WHERE "Nombre" LIKE '%OZEMPIC%'
LIMIT 1;
