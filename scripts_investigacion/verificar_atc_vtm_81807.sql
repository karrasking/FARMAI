-- Verificar ATCs y VTM para el medicamento 81807

-- 1. ATCs del medicamento 81807
SELECT 'ATCs del 81807' as info;
SELECT ma.*, a.*
FROM "MedicamentoAtc" ma
LEFT JOIN "Atc" a ON ma."Codigo" = a."Codigo"
WHERE ma."NRegistro" = '81807';

-- 2. Cobertura general de ATCs
SELECT 'Cobertura ATCs' as info;
SELECT COUNT(DISTINCT "NRegistro") as meds_con_atc FROM "MedicamentoAtc";

-- 3. Total de VTMs en tabla
SELECT 'Total VTMs' as info;
SELECT COUNT(*) as total_vtms FROM "Vtm";

-- 4. VTM específico para 81807
SELECT 'VTM para 81807 (ID 185651000140100)' as info;
SELECT * FROM "Vtm" WHERE "Id" = 185651000140100;

-- 5. Buscar cualquier medicamento con ATCs
SELECT 'Ejemplo medicamento CON ATCs' as info;
SELECT ma."NRegistro", COUNT(*) as num_atcs
FROM "MedicamentoAtc" ma
GROUP BY ma."NRegistro"
HAVING COUNT(*) > 0
LIMIT 1;
