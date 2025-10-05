-- Investigar por qué ISOGAINE aparece al buscar "cafeína" pero no se ve en el detalle
-- N° Registro: 60605

-- 1. Ver info básica del medicamento
SELECT nregistro, nombre, labtitular
FROM medicamento 
WHERE nregistro = '60605';

-- 2. Buscar "cafeina" en TODAS las columnas del medicamento
SELECT 
    nregistro,
    nombre,
    labtitular,
    -- Buscar en texto plano
    CASE WHEN nombre ILIKE '%cafeina%' THEN 'nombre' END as campo_nombre,
    CASE WHEN labtitular ILIKE '%cafeina%' THEN 'labtitular' END as campo_lab,
    -- Ver JSON completo para buscar
    rawjsondetalle::text ILIKE '%cafeina%' as en_json
FROM medicamento 
WHERE nregistro = '60605';

-- 3. Ver PRINCIPIOS ACTIVOS
SELECT 
    ms.nregistro,
    s.nombre as principio_activo,
    ms.cantidad,
    ms.unidad
FROM medicamento_sustancia ms
JOIN sustancia s ON ms.sustancia_id = s.id
WHERE ms.nregistro = '60605';

-- 4. Ver EXCIPIENTES
SELECT 
    me.nregistro,
    e.nombre as excipiente,
    me.cantidad,
    me.unidad,
    me.orden
FROM medicamento_excipiente me
JOIN excipiente e ON me.excipiente_id = e.id
WHERE me.nregistro = '60605'
ORDER BY me.orden;

-- 5. Buscar en JSON directamente
SELECT 
    nregistro,
    nombre,
    rawjsondetalle->'excipientes' as excipientes_json,
    rawjsondetalle->'principiosActivos' as pas_json
FROM medicamento
WHERE nregistro = '60605';

-- 6. Ver si "cafeina" está en el JSON como texto
SELECT 
    nregistro,
    nombre,
    rawjsondetalle::text
FROM medicamento
WHERE nregistro = '60605'
  AND rawjsondetalle::text ILIKE '%cafe%';
