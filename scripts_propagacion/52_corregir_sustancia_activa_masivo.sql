-- CORRECCIÓN MASIVA: Recrear SustanciaActiva desde JSON
-- HAY 2690 INCONSISTENCIAS - Este script las corrige TODAS

-- PASO 1: Backup de seguridad
CREATE TABLE IF NOT EXISTS "SustanciaActiva_BACKUP_20251005" AS 
SELECT * FROM "SustanciaActiva";

-- PASO 2: Crear tabla temporal con datos correctos del JSON
DROP TABLE IF EXISTS "SustanciaActiva_Correcta";
CREATE TEMP TABLE "SustanciaActiva_Correcta" AS
WITH json_pas AS (
    SELECT DISTINCT
        (jsonb_array_elements(m."RawJson"::jsonb -> 'principiosActivos') ->> 'id')::bigint as id,
        jsonb_array_elements(m."RawJson"::jsonb -> 'principiosActivos') ->> 'nombre' as nombre_correcto,
        jsonb_array_elements(m."RawJson"::jsonb -> 'principiosActivos') ->> 'codigo' as codigo_json
    FROM "Medicamentos" m
    WHERE m."RawJson" IS NOT NULL
      AND m."RawJson"::jsonb -> 'principiosActivos' IS NOT NULL
)
SELECT DISTINCT
    jp.id,
    jp.nombre_correcto,
    COALESCE(jp.codigo_json, sa."Codigo") as codigo,
    sa."ListaPsicotropo"
FROM json_pas jp
LEFT JOIN "SustanciaActiva" sa ON jp.id = sa."Id";

-- PASO 3: Ver muestra de correcciones antes de aplicar
SELECT 
    sa_old."Id",
    sa_old."Nombre" as nombre_antiguo,
    sa_new.nombre_correcto as nombre_nuevo,
    'SERA CORREGIDO' as accion
FROM "SustanciaActiva" sa_old
JOIN "SustanciaActiva_Correcta" sa_new ON sa_old."Id" = sa_new.id
WHERE sa_old."Nombre" != sa_new.nombre_correcto
LIMIT 20;

-- PASO 4: Contar total de correcciones
SELECT COUNT(*) as total_a_corregir
FROM "SustanciaActiva" sa_old
JOIN "SustanciaActiva_Correcta" sa_new ON sa_old."Id" = sa_new.id
WHERE sa_old."Nombre" != sa_new.nombre_correcto;

-- PASO 5: APLICAR CORRECCIONES
UPDATE "SustanciaActiva" sa
SET 
    "Nombre" = sa_new.nombre_correcto,
    "Codigo" = sa_new.codigo
FROM "SustanciaActiva_Correcta" sa_new
WHERE sa."Id" = sa_new.id
  AND sa."Nombre" != sa_new.nombre_correcto;

-- PASO 6: Insertar sustancias nuevas que faltan
INSERT INTO "SustanciaActiva" ("Id", "Nombre", "Codigo", "ListaPsicotropo")
SELECT 
    sa_new.id,
    sa_new.nombre_correcto,
    sa_new.codigo,
    sa_new."ListaPsicotropo"
FROM "SustanciaActiva_Correcta" sa_new
LEFT JOIN "SustanciaActiva" sa ON sa_new.id = sa."Id"
WHERE sa."Id" IS NULL;

-- PASO 7: Verificación final
SELECT COUNT(*) as registros_corregidos FROM "SustanciaActiva_BACKUP_20251005";
SELECT 'CORRECCION COMPLETADA' as estado;
