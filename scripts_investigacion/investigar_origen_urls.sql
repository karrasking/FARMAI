-- Investigar de dónde vienen las URLs de la tabla Documento

-- 1. Ver un ejemplo de RawJson de un medicamento que SÍ tiene documentos
SELECT 
    "NRegistro",
    "Nombre",
    "RawJson"
FROM "Medicamentos"
WHERE "NRegistro" = '81807'
LIMIT 1;

-- 2. Buscar en TODOS los medicamentos si tienen URLs en el JSON
SELECT 
    COUNT(*) as total_meds,
    COUNT(CASE WHEN "RawJson"::text LIKE '%urlHtmlFichaTecnica%' THEN 1 END) as con_url_ft_en_json,
    COUNT(CASE WHEN "RawJson"::text LIKE '%urlHtmlProspecto%' THEN 1 END) as con_url_p_en_json,
    COUNT(CASE WHEN "RawJson"::text LIKE '%docs%' THEN 1 END) as con_docs_en_json
FROM "Medicamentos";

-- 3. Ver medicamentos que tienen docs en tabla Documento
SELECT 
    m."NRegistro",
    m."Nombre",
    COUNT(d."Id") as num_docs
FROM "Medicamentos" m
JOIN "Documento" d ON m."NRegistro" = d."NRegistro"
GROUP BY m."NRegistro", m."Nombre"
ORDER BY num_docs DESC
LIMIT 5;

-- 4. Comparar: medicamentos con docs vs medicamentos totales
SELECT 
    'Total medicamentos' as categoria,
    COUNT(*) as cantidad
FROM "Medicamentos"
UNION ALL
SELECT 
    'Con documentos en tabla Documento',
    COUNT(DISTINCT "NRegistro")
FROM "Documento";
