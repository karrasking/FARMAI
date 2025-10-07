-- DIAGNÓSTICO URGENTE: Por qué fallan las descargas

-- 1. Estado general documentos
SELECT 
    'ESTADO GENERAL' as seccion,
    COUNT(*) as total_documentos,
    COUNT(*) FILTER (WHERE "EstaDescargado" = true) as descargados,
    COUNT(*) FILTER (WHERE "EstaDescargado" = false) as pendientes,
    COUNT(*) FILTER (WHERE "Reintentos" > 0) as con_reintentos,
    COUNT(*) FILTER (WHERE "Reintentos" >= 3) as reintentos_maximos
FROM "Documento";

-- 2. Por tipo de documento
SELECT 
    'POR TIPO' as seccion,
    "TipoDocumento",
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE "EstaDescargado" = true) as ok,
    COUNT(*) FILTER (WHERE "EstaDescargado" = false) as pendientes,
    ROUND(COUNT(*) FILTER (WHERE "EstaDescargado" = true)::numeric / COUNT(*) * 100, 1) as porcentaje_ok
FROM "Documento"
GROUP BY "TipoDocumento"
ORDER BY pendientes DESC;

-- 3. URLs problemáticas (sample)
SELECT 
    'URLS PROBLEMATICAS' as seccion,
    "NRegistro",
    "TipoDocumento",
    LEFT("Url", 80) as url_truncada,
    "Reintentos",
    "EstaDescargado"
FROM "Documento"
WHERE "EstaDescargado" = false
  AND "Reintentos" > 0
ORDER BY "Reintentos" DESC
LIMIT 10;

-- 4. Verificar si existen URLs NULL o vacías
SELECT 
    'URLS INVALIDAS' as seccion,
    COUNT(*) FILTER (WHERE "Url" IS NULL) as url_null,
    COUNT(*) FILTER (WHERE "Url" = '') as url_vacia,
    COUNT(*) FILTER (WHERE "Url" NOT LIKE 'http%') as url_no_http
FROM "Documento";

-- 5. ¿Existen documentos disponibles NO procesados?
SELECT 
    'NO PROCESADOS' as seccion,
    COUNT(*) as total_sin_procesar
FROM "Documento"
WHERE "EstaDescargado" = false
  AND "Reintentos" = 0;
