-- ============================================================
-- INVESTIGACIÓN COMPLETA DE EXCIPIENTES
-- ============================================================

-- 1. Estado de MedicamentoExcipiente
SELECT 
    COUNT(*) as total_relaciones,
    COUNT(DISTINCT "NRegistro") as meds_con_excipientes,
    COUNT(DISTINCT "ExcipienteId") as excipientes_distintos
FROM "MedicamentoExcipiente";

-- 2. Distribución de excipientes por medicamento
SELECT 
    num_excipientes,
    COUNT(*) as cantidad_meds
FROM (
    SELECT "NRegistro", COUNT(*) as num_excipientes
    FROM "MedicamentoExcipiente"
    GROUP BY "NRegistro"
) sub
GROUP BY num_excipientes
ORDER BY num_excipientes;

-- 3. Estado de la tabla Excipiente
SELECT COUNT(*) as total_excipientes FROM "Excipiente";

-- 4. Estado de ExcipientesDeclObligDicStaging (fuente)
SELECT COUNT(*) as total_staging FROM "ExcipientesDeclObligDicStaging";

-- 5. Muestra de ExcipientesDeclObligDicStaging
SELECT * FROM "ExcipientesDeclObligDicStaging" LIMIT 10;

-- 6. Ver si hay excipientes ya en la tabla
SELECT * FROM "Excipiente" LIMIT 10;

-- 7. Top 10 excipientes más usados (por ID, aunque no existan)
SELECT 
    "ExcipienteId",
    COUNT(*) as uso_count
FROM "MedicamentoExcipiente"
GROUP BY "ExcipienteId"
ORDER BY uso_count DESC
LIMIT 10;

-- 8. Verificar si los IDs en MedicamentoExcipiente matchean con staging
SELECT 
    'En MedicamentoExcipiente' as tabla,
    COUNT(DISTINCT "ExcipienteId") as count
FROM "MedicamentoExcipiente"
UNION ALL
SELECT 
    'En ExcipientesDeclObligDicStaging',
    COUNT(DISTINCT "CodExcipiente")
FROM "ExcipientesDeclObligDicStaging";

-- 9. Ver medicamentos con más excipientes
SELECT 
    me."NRegistro",
    m."Nombre",
    COUNT(*) as num_excipientes
FROM "MedicamentoExcipiente" me
LEFT JOIN "Medicamentos" m ON me."NRegistro" = m."NRegistro"
GROUP BY me."NRegistro", m."Nombre"
ORDER BY num_excipientes DESC
LIMIT 10;

-- 10. Verificar estructura de MedicamentoExcipiente
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'MedicamentoExcipiente'
ORDER BY ordinal_position;
