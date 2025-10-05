-- Verificar medicamentos con laboratorios NULL
SELECT 
    'Total Medicamentos' as "Metrica",
    COUNT(*) as "Cantidad"
FROM "Medicamentos"
UNION ALL
SELECT 
    'Con LaboratorioTitularId',
    COUNT(*)
FROM "Medicamentos"
WHERE "LaboratorioTitularId" IS NOT NULL
UNION ALL
SELECT 
    'Sin LaboratorioTitularId (NULL)',
    COUNT(*)
FROM "Medicamentos"
WHERE "LaboratorioTitularId" IS NULL
UNION ALL
SELECT 
    'Con LaboratorioComercializadorId',
    COUNT(*)
FROM "Medicamentos"
WHERE "LaboratorioComercializadorId" IS NOT NULL
UNION ALL
SELECT 
    'Sin LaboratorioComercializadorId (NULL)',
    COUNT(*)
FROM "Medicamentos"
WHERE "LaboratorioComercializadorId" IS NULL;

-- Sample de medicamentos con NULL
SELECT 
    "NRegistro",
    "Nombre",
    "LabTitular",
    "LaboratorioTitularId",
    "LaboratorioComercializadorId"
FROM "Medicamentos"
WHERE "LaboratorioTitularId" IS NULL
LIMIT 20;
