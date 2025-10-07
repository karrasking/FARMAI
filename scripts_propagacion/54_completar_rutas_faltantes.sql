-- Completar FileName, LocalPath y UrlLocal para los 179 documentos descargados sin metadata

-- Primero, ver qué vamos a actualizar
SELECT 
    "NRegistro",
    "Tipo",
    "Downloaded",
    "FileName",
    "LocalPath",
    "UrlLocal"
FROM "Documento"
WHERE "Downloaded" = true
  AND "FileName" IS NULL
LIMIT 5;

-- Conteo de lo que vamos a actualizar
SELECT COUNT(*) as docs_a_actualizar
FROM "Documento"
WHERE "Downloaded" = true
  AND "FileName" IS NULL;

-- ACTUALIZAR los 179 registros faltantes
UPDATE "Documento"
SET 
    "FileName" = "NRegistro" || '.pdf',
    "LocalPath" = CONCAT(
        'C:\Users\Victor\Desktop\FARMAI\Farmai.Api\bin\Debug\net8.0\_data\documentos\',
        CASE 
            WHEN "Tipo" = 1 THEN 'fichas\'
            WHEN "Tipo" = 2 THEN 'prospectos\'
            ELSE 'otros\'
        END,
        "NRegistro", '.pdf'
    ),
    "UrlLocal" = CONCAT(
        '/api/documents/',
        CASE 
            WHEN "Tipo" = 1 THEN 'f/'
            WHEN "Tipo" = 2 THEN 'p/'
            ELSE 'ipe/'
        END,
        "NRegistro"
    )
WHERE "Downloaded" = true
  AND "FileName" IS NULL;

-- Verificar resultado
SELECT 
    'Resultado' as info,
    COUNT(*) as total_descargados,
    COUNT("FileName") as con_filename,
    COUNT(*) FILTER (WHERE "FileName" IS NULL) as sin_filename
FROM "Documento"
WHERE "Downloaded" = true;
