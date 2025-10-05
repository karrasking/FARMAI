-- ========================================
-- POBLAR LABORATORIOS FALTANTES (27 meds)
-- ========================================

-- PASO 1: Verificar antes de actualizar
SELECT 
    'Antes de actualizar' as "Estado",
    COUNT(*) as "MedicamentosSinLabTitularId"
FROM "Medicamentos"
WHERE "LaboratorioTitularId" IS NULL;

-- PASO 2: Actualizar LaboratorioTitularId desde JSON
UPDATE "Medicamentos" m
SET 
    "LaboratorioTitularId" = l."Id",
    "UpdatedAt" = NOW()
FROM "MedicamentoDetalleRaw" mdr
JOIN "Laboratorio" l ON l."Nombre" = mdr."Json"->>'labtitular'
WHERE m."NRegistro" = mdr."NRegistro"
AND m."LaboratorioTitularId" IS NULL;

-- PASO 3: Actualizar LaboratorioComercializadorId desde JSON
UPDATE "Medicamentos" m
SET 
    "LaboratorioComercializadorId" = l."Id",
    "UpdatedAt" = NOW()
FROM "MedicamentoDetalleRaw" mdr
JOIN "Laboratorio" l ON l."Nombre" = mdr."Json"->>'labcomercializador'
WHERE m."NRegistro" = mdr."NRegistro"
AND m."LaboratorioComercializadorId" IS NULL
AND mdr."Json" ? 'labcomercializador';

-- PASO 4: Verificar después de actualizar
SELECT 
    'Después de actualizar' as "Estado",
    COUNT(*) as "MedicamentosSinLabTitularId"
FROM "Medicamentos"
WHERE "LaboratorioTitularId" IS NULL;

-- PASO 5: Ver medicamentos actualizados
SELECT 
    m."NRegistro",
    m."Nombre",
    lt."Nombre" as "LaboratorioTitular",
    lc."Nombre" as "LaboratorioComercializador"
FROM "Medicamentos" m
LEFT JOIN "Laboratorio" lt ON lt."Id" = m."LaboratorioTitularId"
LEFT JOIN "Laboratorio" lc ON lc."Id" = m."LaboratorioComercializadorId"
WHERE m."NRegistro" IN (
    '01185072', '02203003', '02212009', '06332001', '06337001',
    '06341001', '06343005', '06357001', '06363007', '06380001'
);

-- PASO 6: Estadísticas finales
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
    'Sin LaboratorioTitularId',
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
    'Sin LaboratorioComercializadorId',
    COUNT(*)
FROM "Medicamentos"
WHERE "LaboratorioComercializadorId" IS NULL;
