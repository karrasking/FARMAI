-- Obtener las URLs con HttpStatus NULL (timeout)
SELECT 
    "NRegistro",
    "Tipo",
    "UrlPdf",
    "HttpStatus",
    "DownloadAttempts",
    "ErrorMessage"
FROM "Documento"
WHERE "Downloaded" = false 
  AND "HttpStatus" IS NULL;
