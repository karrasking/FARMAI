-- Contar documentos con URLs válidas

-- Total con URL PDF
SELECT 'Docs con URL PDF' as metrica, COUNT(*) as cantidad
FROM "Documento"
WHERE "UrlPdf" IS NOT NULL AND "UrlPdf" != '';

-- Por tipo de documento
SELECT 
    "Tipo",
    COUNT(*) as docs_con_url
FROM "Documento"
WHERE "UrlPdf" IS NOT NULL AND "UrlPdf" != ''
GROUP BY "Tipo"
ORDER BY "Tipo";

-- Medicamentos únicos con FT
SELECT 'Medicamentos con FT (URL)' as metrica, COUNT(DISTINCT "NRegistro") as cantidad
FROM "Documento"
WHERE "Tipo" = 1 AND "UrlPdf" IS NOT NULL AND "UrlPdf" != '';

-- Medicamentos únicos con Prospecto
SELECT 'Medicamentos con Prospecto (URL)' as metrica, COUNT(DISTINCT "NRegistro") as cantidad
FROM "Documento"
WHERE "Tipo" = 2 AND "UrlPdf" IS NOT NULL AND "UrlPdf" != '';
