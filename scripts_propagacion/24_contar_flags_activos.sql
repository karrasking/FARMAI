-- ============================================================
-- CONTAR MEDICAMENTOS CON FLAGS ESPECIALES ACTIVOS
-- ============================================================

-- 1. Conteo de flags en Medicamentos
SELECT 
    COUNT(*) FILTER (WHERE "AfectaConduccion" = true) as afecta_conduccion,
    COUNT(*) FILTER (WHERE "TrianguloNegro" = true) as triangulo_negro,
    COUNT(*) FILTER (WHERE "Huerfano" = true) as huerfano,
    COUNT(*) FILTER (WHERE "Biosimilar" = true) as biosimilar,
    COUNT(*) FILTER (WHERE "MaterialesInformativos" = true) as materiales_informativos,
    COUNT(*) as total_medicamentos
FROM "Medicamentos";

-- 2. Conteo de flags en PrescripcionStaging
SELECT 
    COUNT(*) FILTER (WHERE "SwPsicotropo" = true) as psicotropo,
    COUNT(*) FILTER (WHERE "SwEstupefaciente" = true) as estupefaciente,
    COUNT(*) FILTER (WHERE "SwAfectaConduccion" = true) as afecta_conduccion,
    COUNT(*) FILTER (WHERE "SwTrianguloNegro" = true) as triangulo_negro,
    COUNT(*) as total_prescripciones
FROM "PrescripcionStaging";

-- 3. Medicamentos que afectan conducción (muestra)
SELECT "NRegistro", "Nombre", "AfectaConduccion"
FROM "Medicamentos"
WHERE "AfectaConduccion" = true
LIMIT 20;

-- 4. Medicamentos con triángulo negro (muestra)
SELECT "NRegistro", "Nombre", "TrianguloNegro"
FROM "Medicamentos"
WHERE "TrianguloNegro" = true
LIMIT 20;

-- 5. Medicamentos huérfanos
SELECT "NRegistro", "Nombre", "Huerfano"
FROM "Medicamentos"
WHERE "Huerfano" = true
LIMIT 20;

-- 6. Biosimilares
SELECT "NRegistro", "Nombre", "Biosimilar"
FROM "Medicamentos"
WHERE "Biosimilar" = true
LIMIT 20;

-- 7. Medicamentos con lactosa (a través de excipientes)
SELECT DISTINCT 
    m."NRegistro",
    m."Nombre",
    e."Nombre" as excipiente_lactosa
FROM "Medicamentos" m
JOIN "MedicamentoExcipiente" me ON m."NRegistro" = me."NRegistro"
JOIN "Excipiente" e ON me."ExcipienteId" = e."Id"
WHERE e."Nombre" ILIKE '%lactosa%'
LIMIT 20;

-- 8. Contar medicamentos con lactosa
SELECT COUNT(DISTINCT m."NRegistro") as meds_con_lactosa
FROM "Medicamentos" m
JOIN "MedicamentoExcipiente" me ON m."NRegistro" = me."NRegistro"
JOIN "Excipiente" e ON me."ExcipienteId" = e."Id"
WHERE e."Nombre" ILIKE '%lactosa%';

-- 9. Medicamentos con aceite de cacahuete
SELECT COUNT(DISTINCT m."NRegistro") as meds_con_cacahuete
FROM "Medicamentos" m
JOIN "MedicamentoExcipiente" me ON m."NRegistro" = me."NRegistro"
JOIN "Excipiente" e ON me."ExcipienteId" = e."Id"
WHERE e."Nombre" ILIKE '%cacahuete%';

-- 10. Medicamentos con soja
SELECT COUNT(DISTINCT m."NRegistro") as meds_con_soja
FROM "Medicamentos" m
JOIN "MedicamentoExcipiente" me ON m."NRegistro" = me."NRegistro"
JOIN "Excipiente" e ON me."ExcipienteId" = e."Id"
WHERE e."Nombre" ILIKE '%soja%';
