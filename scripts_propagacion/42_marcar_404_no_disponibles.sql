-- Marcar documentos con HTTP 404 como "no disponibles" para no reintentarlos

-- Ver cuántos hay
SELECT COUNT(*) as "Docs404PreMarcado"
FROM "Documento" d
WHERE EXISTS (
    SELECT 1 FROM "DocumentDownloadLog" dl
    WHERE dl."DocumentId" = d."Id"
    AND dl."HttpStatus" = 404
    AND dl."Success" = false
);

-- Marcarlos como descargados con error especial
UPDATE "Documento" d
SET 
    "Downloaded" = true,  -- Marcamos como "descargado" para que no se reintente
    "DownloadedAt" = NOW(),
    "ErrorMessage" = 'HTTP 404 - Documento no disponible en CIMA',
    "HttpStatus" = 404
WHERE EXISTS (
    SELECT 1 FROM "DocumentDownloadLog" dl
    WHERE dl."DocumentId" = d."Id"
    AND dl."HttpStatus" = 404
    AND dl."Success" = false
)
AND d."Downloaded" = false;

-- Ver resultado
SELECT 
    COUNT(*) as "DocsMarcados",
    '404 - No disponible' as "Razon"
FROM "Documento"
WHERE "HttpStatus" = 404
AND "ErrorMessage" LIKE '%404%';

-- Actualizar estadísticas
SELECT 
    COUNT(*) FILTER (WHERE "Downloaded" = true) as "Descargados",
    COUNT(*) FILTER (WHERE "Downloaded" = false) as "Pendientes",
    COUNT(*) FILTER (WHERE "HttpStatus" = 404) as "NoDisponibles404"
FROM "Documento";
