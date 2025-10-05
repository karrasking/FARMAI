-- INVESTIGACIÓN: USO COMERCIAL vs HOSPITALARIO
-- ===============================================
-- Objetivo: Analizar el campo "comerc" del JSON que indica si es de uso comercial o hospitalario

-- 1. Distribución general uso comercial vs hospitalario
SELECT 
    CASE 
        WHEN ("RawJson"::jsonb ->> 'comerc')::boolean = true THEN 'Comercializado'
        WHEN ("RawJson"::jsonb ->> 'comerc')::boolean = false THEN 'Uso Hospitalario'
        ELSE 'Sin Información'
    END as tipo_uso,
    COUNT(*) as cantidad,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as porcentaje
FROM "Medicamentos"
GROUP BY tipo_uso
ORDER BY cantidad DESC;

-- 2. Ver sample de medicamentos de uso hospitalario
SELECT 
    "NRegistro",
    "Nombre",
    "LabTitular",
    "RawJson"::jsonb ->> 'comerc' as comercializado,
    "RawJson"::jsonb ->> 'receta' as requiere_receta,
    "RawJson"::jsonb ->> 'cpresc' as condicion_prescripcion
FROM "Medicamentos"
WHERE ("RawJson"::jsonb ->> 'comerc')::boolean = false
LIMIT 10;

-- 3. Ver sample de medicamentos comercializados
SELECT 
    "NRegistro",
    "Nombre",
    "LabTitular",
    "RawJson"::jsonb ->> 'comerc' as comercializado,
    "RawJson"::jsonb ->> 'receta' as requiere_receta
FROM "Medicamentos"
WHERE ("RawJson"::jsonb ->> 'comerc')::boolean = true
LIMIT 10;

-- 4. Cruce: Uso hospitalario + campos relacionados
SELECT 
    "RawJson"::jsonb ->> 'cpresc' as condicion_prescripcion,
    COUNT(*) as cantidad
FROM "Medicamentos"
WHERE ("RawJson"::jsonb ->> 'comerc')::boolean = false
GROUP BY condicion_prescripcion
ORDER BY cantidad DESC;

-- 5. Top 10 laboratorios con más medicamentos hospitalarios
SELECT 
    "LabTitular",
    COUNT(*) as medicamentos_hospitalarios
FROM "Medicamentos"
WHERE ("RawJson"::jsonb ->> 'comerc')::boolean = false
  AND "LabTitular" IS NOT NULL
GROUP BY "LabTitular"
ORDER BY medicamentos_hospitalarios DESC
LIMIT 10;

-- 6. Verificar si tenemos este campo en tabla Medicamentos
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'Medicamentos' 
  AND column_name IN ('Comercializado', 'UsoHospitalario', 'Comerc');
