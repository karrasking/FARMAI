-- Verificar si PrescripcionStaging tiene URLs

SELECT 
    COUNT(*) as total,
    COUNT(CASE WHEN "UrlFictec" IS NOT NULL AND "UrlFictec" != '' THEN 1 END) as con_url_ft,
    COUNT(CASE WHEN "UrlProsp" IS NOT NULL AND "UrlProsp" != '' THEN 1 END) as con_url_p
FROM "PrescripcionStaging";

-- Ver ejemplos
SELECT 
    "NRegistro",
    "DesNomco",
    "UrlFictec",
    "UrlProsp"
FROM "PrescripcionStaging"
WHERE "UrlFictec" IS NOT NULL OR "UrlProsp" IS NOT NULL
LIMIT 5;
