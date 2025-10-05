-- Script para propagar documentos desde RawJson a tabla Documento
-- Extrae el array "docs" del JSON de cada medicamento y crea registros

-- 1. Ver cuántos medicamentos tienen docs en su JSON
SELECT 
    COUNT(*) as total_meds_con_docs,
    COUNT(*) FILTER (WHERE "RawJson"::text LIKE '%"docs"%') as con_array_docs
FROM "Medicamentos"
WHERE "RawJson"::text LIKE '%"docs"%';

-- 2. Ver ejemplo de estructura de docs
SELECT 
    "NRegistro",
    "Nombre",
    jsonb_array_length("RawJson"->'docs') as num_docs,
    "RawJson"->'docs' as docs_array
FROM "Medicamentos"
WHERE "RawJson"->'docs' IS NOT NULL
LIMIT 3;

-- 3. PROPAGAR DOCUMENTOS a tabla Documento (solo los que existen en Medicamentos)
INSERT INTO "Documento" ("NRegistro", "Tipo", "Secc", "UrlHtml", "FechaRaw", "Fecha", "UrlPdf", "FechaDoc")
SELECT 
    r."NRegistro",
    (doc->>'tipo')::smallint as tipo,
    (doc->>'secc')::boolean as secc,
    doc->>'urlHtml' as url_html,
    (doc->>'fecha')::bigint as fecha_raw,
    to_timestamp((doc->>'fecha')::bigint / 1000.0) as fecha,
    doc->>'url' as url_pdf,
    to_timestamp((doc->>'fecha')::bigint / 1000.0) as fecha_doc
FROM "MedicamentoDetalleRaw" r
INNER JOIN "Medicamentos" m ON m."NRegistro" = r."NRegistro",
     jsonb_array_elements(r."Json"->'docs') as doc
WHERE r."Json"->'docs' IS NOT NULL
ON CONFLICT ("NRegistro", "Tipo", COALESCE("UrlPdf", ''))
DO UPDATE SET
    "Secc" = EXCLUDED."Secc",
    "UrlHtml" = EXCLUDED."UrlHtml",
    "FechaRaw" = EXCLUDED."FechaRaw",
    "Fecha" = EXCLUDED."Fecha",
    "FechaDoc" = EXCLUDED."FechaDoc";

-- 4. Verificar resultado
SELECT 
    'Total documentos insertados' as metrica,
    COUNT(*) as cantidad
FROM "Documento";

-- 5. Por tipo
SELECT 
    "Tipo",
    COUNT(*) as cantidad,
    CASE 
        WHEN "Tipo" = 1 THEN 'Ficha Técnica'
        WHEN "Tipo" = 2 THEN 'Prospecto'
        ELSE 'Otro'
    END as tipo_nombre
FROM "Documento"
GROUP BY "Tipo"
ORDER BY "Tipo";

-- 6. Medicamentos únicos con documentos
SELECT 
    'Medicamentos con al menos 1 documento' as metrica,
    COUNT(DISTINCT "NRegistro") as cantidad
FROM "Documento";
