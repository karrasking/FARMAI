-- Investigar los 179 documentos marcados como descargados pero sin archivo físico
-- 
-- Teoría: 42,647 en BD - 42,468 en disco = 179 faltantes
-- Desglose: 8 Fichas + 8 Prospectos + 163 IPEs

-- 1. Primero, ver cuántos tenemos de cada tipo en BD
SELECT 
    'Estado BD' as fuente,
    "Tipo",
    CASE 
        WHEN "Tipo" = 1 THEN 'Ficha Técnica'
        WHEN "Tipo" = 2 THEN 'Prospecto'
        WHEN "Tipo" = 3 THEN 'IPE'
    END as descripcion,
    COUNT(*) FILTER (WHERE "Downloaded" = true) as descargados_bd
FROM "Documento"
GROUP BY "Tipo"
ORDER BY "Tipo";

-- 2. Estrategia: Encontrar los más recientes descargados de cada tipo
-- Probablemente los 179 están entre los últimos descargados

-- Ver los últimos 10 de cada tipo
SELECT 
    "Tipo",
    CASE 
        WHEN "Tipo" = 1 THEN 'Ficha Técnica'
        WHEN "Tipo" = 2 THEN 'Prospecto'
        WHEN "Tipo" = 3 THEN 'IPE'
    END as descripcion,
    "NRegistro",
    "FileName",
    "LocalPath",
    "UrlPdf",
    "DownloadedAt",
    "HttpStatus"
FROM "Documento"
WHERE "Downloaded" = true
  AND "Tipo" = 1
ORDER BY "DownloadedAt" DESC NULLS LAST
LIMIT 10;

-- Fichas DownloadedAt = NULL (probablemente los problemáticos)
SELECT 
    'Fichas con DownloadedAt NULL' as categoria,
    "NRegistro",
    "FileName",
    "LocalPath",
    "UrlPdf",
    "HttpStatus"
FROM "Documento"
WHERE "Downloaded" = true
  AND "Tipo" = 1
  AND "DownloadedAt" IS NULL
LIMIT 20;

-- Lo mismo para Prospectos
SELECT 
    'Prospectos con DownloadedAt NULL' as categoria,
    "NRegistro",
    "FileName",
    "LocalPath",
    "UrlPdf",
    "HttpStatus"
FROM "Documento"
WHERE "Downloaded" = true
  AND "Tipo" = 2
  AND "DownloadedAt" IS NULL
LIMIT 20;

-- Y para IPEs (163 sospechosos)
SELECT 
    'IPE con DownloadedAt NULL' as categoria,
    COUNT(*) as total
FROM "Documento"
WHERE "Downloaded" = true
  AND "Tipo" = 3
  AND "DownloadedAt" IS NULL;

-- Listar algunos IPEs sospechosos
SELECT 
    "NRegistro",
    "FileName",
    "LocalPath",
    "UrlPdf",
    "HttpStatus"
FROM "Documento"
WHERE "Downloaded" = true
  AND "Tipo" = 3
  AND "DownloadedAt" IS NULL
LIMIT 20;
