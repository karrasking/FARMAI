-- ============================================================
-- NORMALIZAR RELACIONES DUPLICADAS EN EL GRAFO
-- Unificar nombres de relaciones semánticamente equivalentes
-- ============================================================

-- 1. Ver estado actual de relaciones
SELECT rel, COUNT(*) as total
FROM graph_edge
WHERE rel IN ('CONTINE', 'CONTIENE_PA', 'PERTENECE_A_PRINCIPIO_ACTIVO')
GROUP BY rel
ORDER BY total DESC;

-- 2. Migrar CONTINE → CONTIENE_PA
UPDATE graph_edge
SET rel = 'CONTIENE_PA'
WHERE rel = 'CONTINE';

-- 3. Migrar PERTENECE_A_PRINCIPIO_ACTIVO → CONTIENE_PA
UPDATE graph_edge
SET rel = 'CONTIENE_PA'
WHERE rel = 'PERTENECE_A_PRINCIPIO_ACTIVO';

-- 4. Verificar resultado
SELECT rel, COUNT(*) as total
FROM graph_edge
WHERE rel IN ('CONTINE', 'CONTIENE_PA', 'PERTENECE_A_PRINCIPIO_ACTIVO')
GROUP BY rel
ORDER BY total DESC;

-- 5. Listar todas las relaciones actuales
SELECT rel, COUNT(*) as total, COUNT(DISTINCT src_type) as src_types, COUNT(DISTINCT dst_type) as dst_types
FROM graph_edge
GROUP BY rel
ORDER BY total DESC;

SELECT '✅ RELACIONES NORMALIZADAS' as resultado;
