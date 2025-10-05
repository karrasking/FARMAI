-- Ver estado de reintentos y documentos pendientes

-- 1. Estado de la cola de reintentos
SELECT 
    "Status",
    COUNT(*) as "Cantidad"
FROM "DocumentDownloadRetry"
GROUP BY "Status"
ORDER BY "Cantidad" DESC;

-- 2. Documentos no descargados
SELECT 
    "Downloaded",
    COUNT(*) as "Cantidad"
FROM "Documento"
GROUP BY "Downloaded";

-- 3. Documentos con intentos pero no descargados
SELECT 
    COUNT(*) as "DocsConIntentosNoDescargados",
    AVG("DownloadAttempts") as "PromedioIntentos",
    MAX("DownloadAttempts") as "MaxIntentos"
FROM "Documento"
WHERE "Downloaded" = false AND "DownloadAttempts" > 0;

-- 4. ¿Hay docs en retry que aún no es su momento?
SELECT 
    COUNT(*) as "EnRetryPeroNoEsHora"
FROM "DocumentDownloadRetry"
WHERE "Status" = 'pending' AND "NextRetryAt" > NOW();

-- 5. Documentos listos para reintentar
SELECT 
    COUNT(*) as "ListosParaReintentar"
FROM "DocumentDownloadRetry"
WHERE "Status" = 'pending' AND "NextRetryAt" <= NOW();
