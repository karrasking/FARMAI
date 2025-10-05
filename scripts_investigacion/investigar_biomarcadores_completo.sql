-- Investigación completa de biomarcadores

-- 1. Ver estructura de la tabla Biomarcador
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'Biomarcador'
ORDER BY ordinal_position;

-- 2. Contar biomarcadores totales
SELECT COUNT(*) as total_biomarcadores
FROM "Biomarcador";

-- 3. Ver ejemplos de biomarcadores
SELECT 
    "Id",
    "Nombre",
    "Descripcion"
FROM "Biomarcador"
LIMIT 20;

-- 4. Ver relación medicamento-biomarcador
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'MedicamentoBiomarcador'
ORDER BY ordinal_position;

-- 5. Contar medicamentos con biomarcadores
SELECT COUNT(DISTINCT "NRegistro") as meds_con_biomarcadores
FROM "MedicamentoBiomarcador";

-- 6. Ver ejemplos de medicamentos con biomarcadores
SELECT 
    m."NRegistro",
    m."Nombre" as medicamento,
    b."Nombre" as biomarcador,
    b."Descripcion"
FROM "MedicamentoBiomarcador" mb
JOIN "Medicamentos" m ON mb."NRegistro" = m."NRegistro"
JOIN "Biomarcador" b ON mb."BiomarcadorId" = b."Id"
LIMIT 10;

-- 7. Top biomarcadores más usados
SELECT 
    b."Nombre",
    b."Descripcion",
    COUNT(*) as num_medicamentos
FROM "MedicamentoBiomarcador" mb
JOIN "Biomarcador" b ON mb."BiomarcadorId" = b."Id"
GROUP BY b."Id", b."Nombre", b."Descripcion"
ORDER BY num_medicamentos DESC
LIMIT 15;

-- 8. Buscar por principio activo - ver si podemos
SELECT 
    m."NRegistro",
    m."Nombre" as medicamento,
    sa."Nombre" as principio_activo,
    ms."Cantidad",
    ms."Unidad"
FROM "MedicamentoSustancia" ms
JOIN "Medicamentos" m ON ms."NRegistro" = m."NRegistro"
LEFT JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
WHERE sa."Nombre" ILIKE '%ibuprofeno%'
LIMIT 10;

-- 9. Buscar por excipiente - ver si podemos  
SELECT 
    m."NRegistro",
    m."Nombre" as medicamento,
    e."Nombre" as excipiente,
    me."Cantidad",
    me."Unidad"
FROM "MedicamentoExcipiente" me
JOIN "Medicamentos" m ON me."NRegistro" = m."NRegistro"
LEFT JOIN "Excipiente" e ON me."ExcipienteId" = e."Id"
WHERE e."Nombre" ILIKE '%lactosa%'
LIMIT 10;

-- 10. Verificar si biomarcadores están en el grafo
SELECT COUNT(*) as nodos_biomarcador
FROM "Node"
WHERE "Labels" LIKE '%Biomarcador%';
