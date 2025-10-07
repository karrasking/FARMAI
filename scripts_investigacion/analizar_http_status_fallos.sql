-- Analizar códigos HTTP de documentos fallidos
SELECT 
    "HttpStatus",
    COUNT(*) as cantidad,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM "Documento" WHERE "Downloaded" = false), 1) as porcentaje
FROM "Documento"
WHERE "Downloaded" = false
GROUP BY "HttpStatus"
ORDER BY cantidad DESC;

-- Ver sample de URLs por tipo de error
SELECT 
    'HTTP 429 (Rate Limit)' as tipo,
    COUNT(*) as cantidad
FROM "Documento"
WHERE "Downloaded" = false AND "HttpStatus" = 429

UNION ALL

SELECT 
    'HTTP 404 (No encontrado)' as tipo,
    COUNT(*) as cantidad
FROM "Documento"
WHERE "Downloaded" = false AND "HttpStatus" = 404

UNION ALL

SELECT 
    'HTTP 500+ (Error servidor)' as tipo,
    COUNT(*) as cantidad
FROM "Documento"
WHERE "Downloaded" = false AND "HttpStatus" >= 500

UNION ALL

SELECT 
    'NULL (Sin intentar o timeout)' as tipo,
    COUNT(*) as cantidad
FROM "Documento"
WHERE "Downloaded" = false AND "HttpStatus" IS NULL

UNION ALL

SELECT 
    'Otros errores' as tipo,
    COUNT(*) as cantidad
FROM "Documento"
WHERE "Downloaded" = false 
  AND "HttpStatus" IS NOT NULL 
  AND "HttpStatus" NOT IN (404, 429)
  AND "HttpStatus" < 500;
