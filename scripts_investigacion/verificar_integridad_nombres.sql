-- Verificar integridad: FileName debe coincidir con NRegistro
-- Formato esperado: NRegistro.pdf

-- 1. Verificar documentos con FileName correcto
SELECT 
    'Correctos' as categoria,
    COUNT(*) as cantidad
FROM "Documento"
WHERE "Downloaded" = true
  AND "FileName" = "NRegistro" || '.pdf';

-- 2. Verificar documentos con FileName incorrecto
SELECT 
    'Incorrectos' as categoria,
    COUNT(*) as cantidad
FROM "Documento"
WHERE "Downloaded" = true
  AND "FileName" IS NOT NULL
  AND "FileName" != "NRegistro" || '.pdf';

-- 3. Ver ejemplos de incorrectos (si existen)
SELECT 
    "NRegistro",
    "Tipo",
    "FileName",
    "LocalPath"
FROM "Documento"
WHERE "Downloaded" = true
  AND "FileName" IS NOT NULL
  AND "FileName" != "NRegistro" || '.pdf'
LIMIT 10;

-- 4. Total sin FileName
SELECT 
    'Sin FileName' as categoria,
    COUNT(*) as cantidad
FROM "Documento"
WHERE "Downloaded" = true
  AND "FileName" IS NULL;
