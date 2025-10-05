-- Ver ejemplo completo de biomarcador con TODOS los campos

-- Seleccionar un medicamento con CYP2C19 (el más común)
SELECT 
    m."NRegistro",
    m."Nombre" as medicamento,
    b."Id" as biomarcador_id,
    b."Nombre" as biomarcador,
    b."NombreCanon",
    b."Tipo",
    b."Descripcion",
    b."CodigoExt",
    -- Campos de la relación (¡los más importantes!)
    mb."TipoRelacion",
    mb."Evidencia",
    mb."NivelEvidencia",
    mb."Fuente",
    mb."FuenteUrl",
    mb."Notas"
FROM "Medicamentos" m
JOIN "MedicamentoBiomarcador" mb ON m."NRegistro" = mb."NRegistro"
JOIN "Biomarcador" b ON mb."BiomarcadorId" = b."Id"
WHERE b."Nombre" = 'CYP2C19'
LIMIT 1;

-- Ver TODOS los valores posibles de TipoRelacion
SELECT DISTINCT "TipoRelacion"
FROM "MedicamentoBiomarcador"
ORDER BY "TipoRelacion";

-- Ver distribución de NivelEvidencia
SELECT 
    "NivelEvidencia",
    COUNT(*) as num_casos
FROM "MedicamentoBiomarcador"
WHERE "NivelEvidencia" IS NOT NULL
GROUP BY "NivelEvidencia"
ORDER BY "NivelEvidencia";

-- Ver si hay URLs de fuentes
SELECT COUNT(*) as con_url
FROM "MedicamentoBiomarcador"
WHERE "FuenteUrl" IS NOT NULL;

-- Ver ejemplos de Notas
SELECT DISTINCT LEFT("Notas", 200) as nota_preview
FROM "MedicamentoBiomarcador"
WHERE "Notas" IS NOT NULL
LIMIT 5;
