-- Ver muestra de documentos
SELECT * FROM "Documento" LIMIT 10;

-- Ver estructura de la tabla
\d "Documento"

-- Conteo simple
SELECT COUNT(*) as total_documentos FROM "Documento";

-- Documentos únicos por medicamento
SELECT 
    COUNT(DISTINCT "NRegistro") as medicamentos_con_docs,
    COUNT(*) as total_documentos,
    ROUND(COUNT(*)::numeric / COUNT(DISTINCT "NRegistro"), 2) as docs_por_med
FROM "Documento";
