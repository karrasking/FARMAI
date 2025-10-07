-- Ver estructura de la tabla Documento
\d "Documento"

-- Conteo de documentos descargados por tipo
SELECT 
    "Tipo",
    CASE 
        WHEN "Tipo" = 1 THEN 'Ficha Técnica'
        WHEN "Tipo" = 2 THEN 'Prospecto'
        WHEN "Tipo" = 3 THEN 'Informe Público Evaluación (IPE)'
        WHEN "Tipo" = 4 THEN 'Plan Gestión Riesgos'
        WHEN "Tipo" = 5 THEN 'Informe Posicionamiento'
        ELSE 'Otro'
    END as descripcion,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE "Downloaded" = true) as descargados,
    COUNT(*) FILTER (WHERE "Downloaded" = false) as pendientes,
    ROUND(COUNT(*) FILTER (WHERE "Downloaded" = true) * 100.0 / COUNT(*), 2) as porcentaje_descargado
FROM "Documento"
GROUP BY "Tipo"
ORDER BY "Tipo";

-- Resumen total
SELECT 
    'TOTAL' as tipo,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE "Downloaded" = true) as descargados,
    COUNT(*) FILTER (WHERE "Downloaded" = false) as pendientes,
    ROUND(COUNT(*) FILTER (WHERE "Downloaded" = true) * 100.0 / COUNT(*), 2) as porcentaje
FROM "Documento";
