-- Verificar que documentos FT y P corresponden a su medicamento

-- 1. Seleccionar 50 medicamentos aleatorios con documentos
WITH meds_sample AS (
    SELECT DISTINCT "NRegistro"
    FROM "Documento"
    ORDER BY RANDOM()
    LIMIT 50
)
SELECT 
    m."NRegistro",
    m."Nombre",
    d."Tipo",
    CASE 
        WHEN d."Tipo" = 1 THEN 'Ficha Técnica'
        WHEN d."Tipo" = 2 THEN 'Prospecto'
        ELSE 'Otro'
    END as tipo_nombre,
    d."UrlPdf",
    -- Verificar que la URL contenga el NRegistro correcto
    CASE 
        WHEN d."UrlPdf" LIKE '%' || m."NRegistro" || '%' THEN '✓ OK'
        ELSE '✗ ERROR'
    END as verificacion
FROM meds_sample ms
JOIN "Medicamentos" m ON m."NRegistro" = ms."NRegistro"
JOIN "Documento" d ON d."NRegistro" = m."NRegistro"
ORDER BY m."NRegistro", d."Tipo";

-- 2. Contar si hay algún error
SELECT 
    COUNT(*) as total_docs_verificados,
    COUNT(CASE WHEN d."UrlPdf" LIKE '%' || m."NRegistro" || '%' THEN 1 END) as correctos,
    COUNT(CASE WHEN d."UrlPdf" NOT LIKE '%' || m."NRegistro" || '%' THEN 1 END) as incorrectos
FROM "Documento" d
JOIN "Medicamentos" m ON m."NRegistro" = d."NRegistro";

-- 3. Ejemplos específicos para validar manualmente
SELECT 
    m."NRegistro",
    m."Nombre",
    d."Tipo",
    d."UrlPdf"
FROM "Medicamentos" m
JOIN "Documento" d ON d."NRegistro" = m."NRegistro"
WHERE m."NRegistro" IN ('1171251003IP', '62974', '81807')  -- OZEMPIC e ibuprofenos
ORDER BY m."NRegistro", d."Tipo";
