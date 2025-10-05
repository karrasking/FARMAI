-- Ver los 20 documentos que no coinciden

SELECT 
    m."NRegistro",
    m."Nombre",
    d."Tipo",
    d."UrlPdf",
    CASE 
        WHEN d."UrlPdf" LIKE '%' || m."NRegistro" || '%' THEN 'OK'
        ELSE 'ERROR: No contiene NRegistro'
    END as problema
FROM "Documento" d
JOIN "Medicamentos" m ON m."NRegistro" = d."NRegistro"
WHERE d."UrlPdf" NOT LIKE '%' || m."NRegistro" || '%'
ORDER BY m."NRegistro", d."Tipo";
