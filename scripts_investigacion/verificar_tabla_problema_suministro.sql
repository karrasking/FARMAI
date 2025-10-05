-- Verificar si existe tabla ProblemaSuministro o similar
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns 
     WHERE table_name = t.table_name) as "NumColumnas"
FROM information_schema.tables t
WHERE table_schema = 'public'
AND table_name ILIKE '%problema%'
   OR table_name ILIKE '%suministro%'
   OR table_name ILIKE '%desabast%'
ORDER BY table_name;

-- Ver estructura si existe
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name IN (
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'public'
    AND (table_name ILIKE '%problema%'
         OR table_name ILIKE '%suministro%'
         OR table_name ILIKE '%desabast%')
)
ORDER BY table_name, ordinal_position;
