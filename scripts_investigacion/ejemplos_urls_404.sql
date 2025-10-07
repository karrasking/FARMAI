-- Obtener ejemplos de URLs que devolvieron 404
SELECT 
    "NRegistro",
    "Tipo",
    "UrlPdf" as url_completa,
    "HttpStatus",
    "DownloadAttempts" as reintentos,
    "ErrorMessage"
FROM "Documento"
WHERE "HttpStatus" = 404
  AND "UrlPdf" IS NOT NULL
LIMIT 5;

-- Estado actual completo
SELECT 
    'ESTADO ACTUAL' as info,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE "Downloaded" = true) as descargados,
    COUNT(*) FILTER (WHERE "Downloaded" = false) as pendientes,
    ROUND(COUNT(*) FILTER (WHERE "Downloaded" = true) * 100.0 / COUNT(*), 2) as porcentaje
FROM "Documento";
