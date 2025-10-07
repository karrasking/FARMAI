-- Verificar campos de rutas locales
SELECT 
    "NRegistro",
    "Tipo",
    "Downloaded",
    "LocalPath",
    "UrlLocal",
    "FileName"
FROM "Documento"
WHERE "Downloaded" = true
LIMIT 5;

-- Conteo de campos NULL
SELECT 
    COUNT(*) as total_descargados,
    COUNT("LocalPath") as con_localpath,
    COUNT("UrlLocal") as con_urllocal,
    COUNT("FileName") as con_filename,
    COUNT(*) FILTER (WHERE "LocalPath" IS NULL) as sin_localpath,
    COUNT(*) FILTER (WHERE "UrlLocal" IS NULL) as sin_urllocal
FROM "Documento"
WHERE "Downloaded" = true;
