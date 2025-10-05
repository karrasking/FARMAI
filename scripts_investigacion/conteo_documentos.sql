-- Consulta: Verificar cuántos medicamentos tienen Ficha Técnica y Prospecto

-- 1. Total de documentos por tipo
SELECT 
    "Tipo",
    COUNT(*) as cantidad
FROM "Documento"
GROUP BY "Tipo"
ORDER BY cantidad DESC;

-- 2. Medicamentos con Ficha Técnica
SELECT COUNT(DISTINCT "NRegistro") as meds_con_ficha_tecnica
FROM "Documento"
WHERE "Tipo" = 'Ficha Técnica' OR "Tipo" LIKE '%ficha%' OR "Tipo" LIKE '%FT%';

-- 3. Medicamentos con Prospecto
SELECT COUNT(DISTINCT "NRegistro") as meds_con_prospecto
FROM "Documento"
WHERE "Tipo" = 'Prospecto' OR "Tipo" LIKE '%prospecto%' OR "Tipo" LIKE '%P_%';

-- 4. Medicamentos con AMBOS documentos
SELECT COUNT(*) as meds_con_ambos
FROM (
    SELECT "NRegistro"
    FROM "Documento"
    GROUP BY "NRegistro"
    HAVING COUNT(DISTINCT "Tipo") >= 2
) sub;

-- 5. Ver tipos exactos de documentos que tenemos
SELECT DISTINCT "Tipo"
FROM "Documento"
ORDER BY "Tipo";

-- 6. Distribución completa
SELECT 
    CASE 
        WHEN COUNT(DISTINCT "Tipo") >= 2 THEN 'Ambos (FT + P)'
        WHEN COUNT(DISTINCT "Tipo") = 1 THEN 'Solo ' || MIN("Tipo")
        ELSE 'Sin documentos'
    END as categoria,
    COUNT(*) as cantidad_medicamentos
FROM "Documento"
GROUP BY "NRegistro"
ORDER BY cantidad_medicamentos DESC;
