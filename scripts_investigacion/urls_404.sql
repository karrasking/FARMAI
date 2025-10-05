-- URLs que devuelven HTTP 404 (no existen)

SELECT 
    d."NRegistro",
    d."Tipo",
    CASE 
        WHEN d."Tipo" = 1 THEN 'FT (Ficha Técnica)'
        WHEN d."Tipo" = 2 THEN 'P (Prospecto)'
        WHEN d."Tipo" = 3 THEN 'IPE (Informe)'
        ELSE 'Otro'
    END as "TipoDoc",
    d."UrlPdf",
    m."Nombre" as "Medicamento",
    dl."ErrorMessage"
FROM "DocumentDownloadLog" dl
JOIN "Documento" d ON d."Id" = dl."DocumentId"
LEFT JOIN "Medicamentos" m ON m."NRegistro" = d."NRegistro"
WHERE dl."HttpStatus" = 404
AND dl."Success" = false
ORDER BY d."Tipo", d."NRegistro"
LIMIT 10;
