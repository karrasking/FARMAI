-- FASE 7: PROPAGAR CAMPO COMERCIALIZADO A 20K MEDICAMENTOS
-- ===========================================================
-- Script: 46_propagar_comercializado_masivo.sql
-- Objetivo: Actualizar campo Comercializado desde RawJson para 20,126 medicamentos

-- PASO 1: Verificar estado ANTES
SELECT 
    'ANTES DE PROPAGACIÓN' as momento,
    COUNT(*) as total,
    COUNT("Comercializado") as con_valor,
    COUNT(*) - COUNT("Comercializado") as nulls,
    ROUND(100.0 * COUNT("Comercializado") / COUNT(*), 2) as porcentaje_poblado
FROM "Medicamentos";

-- PASO 2: SIMULACIÓN - Ver cuántos se actualizarían
SELECT 
    'SIMULACIÓN' as tipo,
    COUNT(*) as total_a_actualizar,
    COUNT(CASE WHEN ("RawJson"::jsonb ->> 'comerc')::boolean = true THEN 1 END) as seran_comercializados,
    COUNT(CASE WHEN ("RawJson"::jsonb ->> 'comerc')::boolean = false THEN 1 END) as seran_hospitalarios,
    COUNT(CASE WHEN "RawJson"::jsonb ->> 'comerc' IS NULL THEN 1 END) as sin_dato_json
FROM "Medicamentos"
WHERE "Comercializado" IS NULL
  AND "RawJson" IS NOT NULL;

-- PASO 3: PROPAGACIÓN REAL
-- Actualizar campo Comercializado desde RawJson
UPDATE "Medicamentos"
SET "Comercializado" = ("RawJson"::jsonb ->> 'comerc')::boolean
WHERE "Comercializado" IS NULL
  AND "RawJson" IS NOT NULL
  AND "RawJson"::jsonb ? 'comerc';

-- PASO 4: Verificar resultado DESPUÉS
SELECT 
    'DESPUÉS DE PROPAGACIÓN' as momento,
    COUNT(*) as total,
    COUNT("Comercializado") as con_valor,
    COUNT(*) - COUNT("Comercializado") as nulls,
    ROUND(100.0 * COUNT("Comercializado") / COUNT(*), 2) as porcentaje_poblado
FROM "Medicamentos";

-- PASO 5: Distribución final
SELECT 
    'DISTRIBUCIÓN FINAL' as tipo,
    CASE 
        WHEN "Comercializado" = true THEN 'Comercializado'
        WHEN "Comercializado" = false THEN 'Uso Hospitalario'
        ELSE 'Sin Dato'
    END as estado_comercializacion,
    COUNT(*) as cantidad,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as porcentaje
FROM "Medicamentos"
GROUP BY "Comercializado"
ORDER BY cantidad DESC;

-- PASO 6: Verificar calidad - Sample de cada tipo
SELECT 
    'COMERCIALIZADOS' as tipo,
    "NRegistro",
    "Nombre",
    "Comercializado"
FROM "Medicamentos"
WHERE "Comercializado" = true
LIMIT 5;

SELECT 
    'USO HOSPITALARIO' as tipo,
    "NRegistro",
    "Nombre",
    "Comercializado"
FROM "Medicamentos"
WHERE "Comercializado" = false
LIMIT 5;

-- PASO 7: Medicamentos aún sin dato (si los hay)
SELECT 
    COUNT(*) as total_aun_sin_dato,
    STRING_AGG(DISTINCT "NRegistro", ', ') as nregistros_sample
FROM "Medicamentos"
WHERE "Comercializado" IS NULL;
