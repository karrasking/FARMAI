-- Verificar si hay duplicados por NRegistro + Tipo

-- 1. Buscar duplicados (más de 1 documento para mismo NRegistro y Tipo)
SELECT 
    "NRegistro",
    "Tipo",
    CASE 
        WHEN "Tipo" = 1 THEN 'Ficha Técnica'
        WHEN "Tipo" = 2 THEN 'Prospecto'
        WHEN "Tipo" = 3 THEN 'IPE'
        ELSE 'Otro'
    END as "TipoNombre",
    COUNT(*) as "CantidadDuplicados"
FROM "Documento"
GROUP BY "NRegistro", "Tipo"
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- 2. Contar total de combinaciones NRegistro+Tipo
SELECT 
    COUNT(*) as "TotalCombinacionesUnicas"
FROM (
    SELECT DISTINCT "NRegistro", "Tipo"
    FROM "Documento"
) subq;

-- 3. Contar total de documentos
SELECT 
    COUNT(*) as "TotalDocumentos"
FROM "Documento";

-- 4. Ver constraint que previene duplicados
SELECT 
    con.conname as "ConstraintName",
    pg_get_constraintdef(con.oid) as "Definition"
FROM pg_constraint con
INNER JOIN pg_class rel ON rel.oid = con.conrelid
WHERE rel.relname = 'Documento'
  AND con.contype = 'u';  -- unique constraints
