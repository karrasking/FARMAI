-- Verificar si los 27 medicamentos NULL tienen laboratorio en JSON
SELECT 
    m."NRegistro",
    m."Nombre",
    m."LabTitular" as "LabTitular_Columna",
    mdr."Json"->>'labtitular' as "LabTitular_JSON",
    mdr."Json"->>'labcomercializador' as "LabComercializador_JSON"
FROM "Medicamentos" m
LEFT JOIN "MedicamentoDetalleRaw" mdr ON mdr."NRegistro" = m."NRegistro"
WHERE m."LaboratorioTitularId" IS NULL
ORDER BY m."NRegistro";

-- ¿Podemos encontrarlos en tabla Laboratorio?
SELECT 
    m."NRegistro",
    mdr."Json"->>'labtitular' as "LabJSON",
    l."Id" as "LabId",
    l."Nombre" as "LabNombre",
    l."NombreCanon" as "LabCanon"
FROM "Medicamentos" m
JOIN "MedicamentoDetalleRaw" mdr ON mdr."NRegistro" = m."NRegistro"
LEFT JOIN "Laboratorio" l ON (
    l."Nombre" = mdr."Json"->>'labtitular'
    OR l."NombreCanon" = LOWER(TRIM(mdr."Json"->>'labtitular'))
)
WHERE m."LaboratorioTitularId" IS NULL
ORDER BY m."NRegistro";
