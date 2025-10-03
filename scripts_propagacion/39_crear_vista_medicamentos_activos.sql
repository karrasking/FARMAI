-- ============================================================
-- CREAR VISTA MEDICAMENTOS ACTIVOS
-- Filtrar medicamentos disponibles para prescripción
-- ============================================================

-- 1. Crear vista de medicamentos activos
CREATE OR REPLACE VIEW v_medicamentos_activos AS
SELECT 
    m.*
FROM "Medicamentos" m
WHERE m."NRegistro" NOT IN (
    -- Excluir medicamentos con estados inactivos
    SELECT DISTINCT ge.src_key
    FROM graph_edge ge
    WHERE ge.src_type = 'Medicamento'
      AND ge.rel = 'TIENE_FLAG_ESTADO'
      AND ge.dst_key IN ('2', '3', '4')  -- 2=Cuarentena, 3=Suspendido, 4=Revocado
);

-- 2. Estadísticas
SELECT 'MEDICAMENTOS ACTIVOS' as tipo, COUNT(*) as total FROM v_medicamentos_activos;
SELECT 'MEDICAMENTOS TOTALES' as tipo, COUNT(*) as total FROM "Medicamentos";
SELECT 'MEDICAMENTOS INACTIVOS' as tipo, COUNT(*) as total 
FROM "Medicamentos" m
WHERE m."NRegistro" IN (
    SELECT ge.src_key FROM graph_edge ge
    WHERE ge.src_type = 'Medicamento'
      AND ge.rel = 'TIENE_FLAG_ESTADO'
      AND ge.dst_key IN ('2', '3', '4')
);

-- 3. Ejemplos de uso
SELECT "NRegistro", "Nombre", "Atc"
FROM v_medicamentos_activos
WHERE "Nombre" ILIKE '%ibuprofeno%'
LIMIT 5;

-- 4. Medicamentos activos por ATC (top 10)
SELECT LEFT("Atc", 3) as atc_grupo, COUNT(*) as total_activos
FROM v_medicamentos_activos
WHERE "Atc" IS NOT NULL
GROUP BY LEFT("Atc", 3)
ORDER BY total_activos DESC
LIMIT 10;

SELECT '✅ VISTA MEDICAMENTOS ACTIVOS CREADA' as resultado;
