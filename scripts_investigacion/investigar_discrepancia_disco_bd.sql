-- INVESTIGAR DISCREPANCIA ENTRE BD Y DISCO

-- Archivos REALES en disco:
-- Fichas: 0 (carpeta no existe)
-- Prospectos: 19,892
-- IPE: 3,150
-- TOTAL REAL: 23,042 PDFs

-- BD dice que descargó 42,647
-- Faltan: 19,605 archivos!

-- 1. Ver estado de Fichas Técnicas (Tipo 1) en BD
SELECT 
    'Tipo 1 - Fichas Técnicas' as categoria,
    COUNT(*) as total_en_bd,
    COUNT(*) FILTER (WHERE "Downloaded" = true) as marcados_descargados,
    COUNT(*) FILTER (WHERE "Downloaded" = false) as marcados_pendientes
FROM "Documento"
WHERE "Tipo" = 1;

-- 2. Ver algunas rutas de Fichas Técnicas
SELECT 
    "NRegistro",
    "Tipo",
    "Downloaded",
    "LocalPath",
    "DownloadedAt"
FROM "Documento"
WHERE "Tipo" = 1
  AND "Downloaded" = true
ORDER BY "DownloadedAt" DESC NULLS LAST
LIMIT 5;

-- 3. Verificar si las Fichas se guardaron con otro Tipo
SELECT 
    "Tipo",
    CASE 
        WHEN "Tipo" = 1 THEN 'Ficha Técnica'
        WHEN "Tipo" = 2 THEN 'Prospecto'
        WHEN "Tipo" = 3 THEN 'IPE'
        ELSE 'Desconocido'
    END as descripcion,
    COUNT(*) FILTER (WHERE "Downloaded" = true) as descargados_bd
FROM "Documento"
GROUP BY "Tipo"
ORDER BY "Tipo";

-- 4. Verificar LocalPath de Fichas (¿tienen path correcto?)
SELECT 
    'Prospectos en prospectos/' as tipo,
    COUNT(*) as cantidad
FROM "Documento"
WHERE "Downloaded" = true
  AND "LocalPath" LIKE '%prospectos%'
UNION ALL
SELECT 
    'Fichas en fichas/' as tipo,
    COUNT(*) as cantidad
FROM "Documento"
WHERE "Downloaded" = true
  AND "LocalPath" LIKE '%fichas%'
UNION ALL
SELECT 
    'IPE en otros/' as tipo,
    COUNT(*) as cantidad
FROM "Documento"
WHERE "Downloaded" = true
  AND "LocalPath" LIKE '%otros%';
