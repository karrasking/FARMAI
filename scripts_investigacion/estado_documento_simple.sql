SELECT 
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE "Downloaded" = true) as descargados,
    COUNT(*) FILTER (WHERE "Downloaded" = false) as pendientes,
    COUNT(*) FILTER (WHERE "DownloadAttempts" > 0) as con_reintentos,
    MAX("DownloadAttempts") as max_reintentos,
    COUNT(*) FILTER (WHERE "HttpStatus" = 404) as url_404
FROM "Documento";
