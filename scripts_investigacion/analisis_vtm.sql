-- Análisis tabla Vtm
SELECT COUNT(*) as total FROM "Vtm";
SELECT * FROM "Vtm" LIMIT 5;
SELECT column_name FROM information_schema.columns WHERE table_name = 'Vtm';
