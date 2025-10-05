-- Análisis completo de URLs que fallan

-- 1. Tipos de errores HTTP
SELECT 
    dl."HttpStatus",
    COUNT(*) as "Cantidad",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as "Porcentaje"
FROM "DocumentDownloadLog" dl
WHERE dl."Success" = false
GROUP BY dl."HttpStatus"
ORDER BY "Cantidad" DESC;

-- 2. Tipos de documento que más fallan
SELECT 
    d."Tipo",
    CASE 
        WHEN d."Tipo" = 1 THEN 'Ficha Técnica'
        WHEN d."Tipo" = 2 THEN 'Prospecto'
        WHEN d."Tipo" = 3 THEN 'IPE'
        ELSE 'Otro'
    END as "TipoNombre",
    COUNT(DISTINCT d."Id") as "DocumentosQueFallan",
    COUNT(*) as "IntentosTotal"
FROM "DocumentDownloadLog" dl
JOIN "Documento" d ON d."Id" = dl."DocumentId"
WHERE dl."Success" = false
GROUP BY d."Tipo"
ORDER BY "DocumentosQueFallan" DESC;

-- 3. Sample de 5 URLs que fallan (con diferentes errores)
SELECT 
    d."NRegistro",
    d."Tipo",
    d."UrlPdf",
    d."DownloadAttempts" as "Intentos",
    dl."HttpStatus",
    LEFT(dl."ErrorMessage", 100) as "Error",
    m."Nombre" as "Medicamento"
FROM "DocumentDownloadLog" dl
JOIN "Documento" d ON d."Id" = dl."DocumentId"
LEFT JOIN "Medicamentos" m ON m."NRegistro" = d."NRegistro"
WHERE dl."Success" = false
AND dl."Id" IN (
    SELECT DISTINCT ON (dl2."HttpStatus") dl2."Id"
    FROM "DocumentDownloadLog" dl2
    WHERE dl2."Success" = false
    ORDER BY dl2."HttpStatus", dl2."Id"
    LIMIT 5
)
ORDER BY dl."HttpStatus", d."Tipo";

-- 4. URLs más problemáticas (más intentos fallidos)
SELECT 
    d."NRegistro",
    d."Tipo",
    d."UrlPdf",
    COUNT(*) as "IntentosFallidos",
    STRING_AGG(DISTINCT CAST(dl."HttpStatus" AS TEXT), ', ') as "StatusCodes",
    m."Nombre" as "Medicamento"
FROM "DocumentDownloadLog" dl
JOIN "Documento" d ON d."Id" = dl."DocumentId"
LEFT JOIN "Medicamentos" m ON m."NRegistro" = d."NRegistro"
WHERE dl."Success" = false
GROUP BY d."NRegistro", d."Tipo", d."UrlPdf", m."Nombre"
ORDER BY "IntentosFallidos" DESC
LIMIT 10;

-- 5. Patrones en NRegistro (espacios, caracteres especiales)
SELECT 
    CASE 
        WHEN d."NRegistro" LIKE '% %' THEN 'Con espacios'
        WHEN d."NRegistro" LIKE '%+%' THEN 'Con +'
        WHEN d."NRegistro" ~ '[^0-9A-Z]' THEN 'Con caracteres especiales'
        ELSE 'Normal'
    END as "PatronNRegistro",
    COUNT(DISTINCT d."Id") as "DocumentosQueFallan"
FROM "Documento" d
WHERE d."Downloaded" = false
GROUP BY "PatronNRegistro"
ORDER BY "DocumentosQueFallan" DESC;
