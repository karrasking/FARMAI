-- Investigar cómo relacionar Medicamentos con Presentacion

-- 1. Ver estructura de ambas tablas
SELECT 'Medicamentos' as tabla, column_name, data_type
FROM information_schema.columns 
WHERE table_name = 'Medicamentos'
UNION ALL
SELECT 'Presentacion' as tabla, column_name, data_type
FROM information_schema.columns 
WHERE table_name = 'Presentacion'
ORDER BY tabla, column_name;

-- 2. Buscar presentaciones de un medicamento específico
-- Probemos con un ibuprofeno
SELECT 
    m."NRegistro",
    m."Nombre",
    COUNT(*) as num_presentaciones
FROM "Medicamentos" m
WHERE m."Nombre" ILIKE '%IBUPROFENO NORMON 600%'
GROUP BY m."NRegistro", m."Nombre"
LIMIT 1;

-- 3. Ver si hay una tabla intermedia MedicamentoPresentacion
SELECT table_name 
FROM information_schema.tables 
WHERE table_name LIKE '%Presentacion%' 
   OR table_name LIKE '%Medicamento%';

-- 4. Buscar CNs relacionados con un NRegistro específico
-- Primero necesitamos el NRegistro de un medicamento
SELECT 
    "CN",
    "Nombre"
FROM "Presentacion"
WHERE "CN" = '659726'
LIMIT 5;

-- 5. Ver si podemos buscar por CN directamente y obtener medicamento
-- La tabla Presentacion tiene CN, pero necesitamos saber cómo conecta con Medicamentos
SELECT COUNT(*) as total_presentaciones_con_nombre
FROM "Presentacion"
WHERE "Nombre" IS NOT NULL AND "Nombre" != '';
