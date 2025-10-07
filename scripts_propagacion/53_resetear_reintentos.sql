-- Resetear reintentos de documentos pendientes
UPDATE "Documento"
SET 
    "DownloadAttempts" = 0,
    "LastAttemptAt" = NULL
WHERE "Downloaded" = false
  AND ("HttpStatus" IS NULL OR "HttpStatus" != 404);
