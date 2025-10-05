-- ========================================
-- POBLAR LABORATORIOS FALTANTES V2
-- Con normalización de nombres
-- ========================================

-- PASO 1: Ver el problema del match
SELECT 
    mdr."NRegistro",
    mdr."Json"->>'labtitular' as "JSON_Lab",
    l."Nombre" as "BD_Lab",
    CASE 
        WHEN l."Nombre" = mdr."Json"->>'labtitular' THEN 'MATCH EXACTO'
        WHEN UPPER(l."Nombre") = UPPER(mdr."Json"->>'labtitular') THEN 'MATCH CASE INSENSITIVE'
        ELSE 'NO MATCH'
    END as "TipoMatch"
FROM "MedicamentoDetalleRaw" mdr
LEFT JOIN "Laboratorio" l ON UPPER(TRIM(l."Nombre")) = UPPER(TRIM(mdr."Json"->>'labtitular'))
WHERE mdr."NRegistro" IN (
    SELECT "NRegistro" 
    FROM "Medicamentos" 
    WHERE "LaboratorioTitularId" IS NULL
)
LIMIT 10;

-- PASO 2: Actualizar con UPPER + TRIM
UPDATE "Medicamentos" m
SET 
    "LaboratorioTitularId" = l."Id",
    "UpdatedAt" = NOW()
FROM "MedicamentoDetalleRaw" mdr
JOIN "Laboratorio" l ON UPPER(TRIM(l."Nombre")) = UPPER(TRIM(mdr."Json"->>'labtitular'))
WHERE m."NRegistro" = mdr."NRegistro"
AND m."LaboratorioTitularId" IS NULL;

-- PASO 3: Actualizar comercializador
UPDATE "Medicamentos" m
SET 
    "LaboratorioComercializadorId" = l."Id",
    "UpdatedAt" = NOW()
FROM "MedicamentoDetalleRaw" mdr
JOIN "Laboratorio" l ON UPPER(TRIM(l."Nombre")) = UPPER(TRIM(mdr."Json"->>'labcomercializador'))
WHERE m."NRegistro" = mdr."NRegistro"
AND m."LaboratorioComercializadorId" IS NULL
AND mdr."Json" ? 'labcomercializador';

-- PASO 4: Verificar resultado
SELECT 
    'Después de actualizar' as "Estado",
    COUNT(*) as "MedicamentosSinLabTitularId"
FROM "Medicamentos"
WHERE "LaboratorioTitularId" IS NULL;

-- PASO 5: Ver sample actualizado
SELECT 
    m."NRegistro",
    LEFT(m."Nombre", 50) as "Medicamento",
    lt."Nombre" as "LabTitular",
    lc."Nombre" as "LabComercializador"
FROM "Medicamentos" m
LEFT JOIN "Laboratorio" lt ON lt."Id" = m."LaboratorioTitularId"
LEFT JOIN "Laboratorio" lc ON lc."Id" = m."LaboratorioComercializadorId"
WHERE m."NRegistro" IN (
    '01185072', '02203003', '02212009', '06332001', '06337001'
);
