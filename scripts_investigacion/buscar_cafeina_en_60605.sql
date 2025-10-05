-- Buscar "cafe" en TODOS los campos de 60605

-- 1. Biomarcadores
SELECT 'Biomarcador' as tipo, b."Nombre"
FROM "MedicamentoBiomarcador" mb
JOIN "Biomarcador" b ON mb."BiomarcadorId" = b."Id"
WHERE mb."NRegistro" = '60605'
  AND b."Nombre" ILIKE '%cafe%';

-- 2. Presentaciones (CN)
SELECT 'Presentacion_CN' as tipo, p."CN"
FROM "MedicamentoPresentacion" mp
JOIN "Presentacion" p ON mp."CN" = p."CN"
WHERE mp."NRegistro" = '60605'
  AND p."CN" ILIKE '%cafe%';

-- 3. VTM
SELECT 'VTM' as tipo, v."Nombre"  
FROM "MedicamentoVtm" mv
JOIN "Vtm" v ON mv."VtmId" = v."Id"
WHERE mv."NRegistro" = '60605'
  AND v."Nombre" ILIKE '%cafe%';

-- 4. ATC
SELECT 'ATC' as tipo, a."Nombre"
FROM "MedicamentoAtc" ma
JOIN "Atc" a ON ma."AtcId" = a."Id"
WHERE ma."NRegistro" = '60605'
  AND a."Nombre" ILIKE '%cafe%';

-- 5. Campos del medicamento directo
SELECT 
    'Medicamento' as tipo,
    CASE 
        WHEN "Nombre" ILIKE '%cafe%' THEN 'Nombre: ' || "Nombre"
        WHEN "LabTitular" ILIKE '%cafe%' THEN 'Lab: ' || "LabTitular"
        WHEN "Dosis" ILIKE '%cafe%' THEN 'Dosis: ' || "Dosis"
    END as campo
FROM "Medicamentos"
WHERE "NRegistro" = '60605'
  AND ("Nombre" ILIKE '%cafe%' OR "LabTitular" ILIKE '%cafe%' OR "Dosis" ILIKE '%cafe%');
