-- Verificar que la corrección masiva funcionó

-- 1. Contar inconsistencias restantes (debería ser 0 o casi 0)
WITH json_pas AS (
    SELECT DISTINCT
        (jsonb_array_elements(m."RawJson"::jsonb -> 'principiosActivos') ->> 'id')::bigint as id_json,
        jsonb_array_elements(m."RawJson"::jsonb -> 'principiosActivos') ->> 'nombre' as nombre_json
    FROM "Medicamentos" m
    WHERE m."RawJson" IS NOT NULL
      AND m."RawJson"::jsonb -> 'principiosActivos' IS NOT NULL
)
SELECT 
    COUNT(*) as inconsistencias_restantes
FROM json_pas jp
JOIN "SustanciaActiva" sa ON jp.id_json = sa."Id"
WHERE jp.nombre_json != sa."Nombre";

-- 2. Verificar que ISOGAINE ya no aparece buscando "cafeina"
SELECT 
    m."NRegistro",
    m."Nombre",
    'ENCONTRADO EN BUSQUEDA CAFEINA' as problema
FROM "Medicamentos" m
WHERE EXISTS (
    SELECT 1
    FROM "MedicamentoSustancia" ms
    JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
    WHERE ms."NRegistro" = m."NRegistro"
      AND sa."Nombre" ILIKE '%cafeina%'
)
AND m."NRegistro" = '60605';
-- Debería devolver 0 rows

-- 3. Verificar que 60605 tiene MEPIVACAINA correcto
SELECT 
    ms."NRegistro",
    sa."Nombre" as principio_activo,
    'CORRECTO' as estado
FROM "MedicamentoSustancia" ms
JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
WHERE ms."NRegistro" = '60605';

-- 4. Mostrar muestra de correcciones aplicadas
SELECT 
    'Backup contiene' as info,
    COUNT(*) as registros
FROM "SustanciaActiva_BACKUP_20251005";
