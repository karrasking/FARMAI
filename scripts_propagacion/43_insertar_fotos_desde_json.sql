-- ========================================
-- APLICACIÓN FASE 3: INSERTAR FOTOS
-- ========================================
-- ⚠️ ESTE SCRIPT MODIFICA LA BD
-- ⚠️ REQUIERE AUTORIZACIÓN PREVIA

-- PASO 1: Insertar fotos desde JSON
-- Evita duplicados con ON CONFLICT
-- Primero eliminar fotos que ya no están en JSON
DELETE FROM "Foto" 
WHERE "NRegistro" IN (
    SELECT DISTINCT "NRegistro"
    FROM "MedicamentoDetalleRaw"
    WHERE "Json"->'fotos' IS NOT NULL
);

-- Ahora insertar todas las fotos
INSERT INTO "Foto" ("NRegistro", "Tipo", "Url", "FechaRaw", "Fecha", "Orden", "Principal")
SELECT 
    mdr."NRegistro",
    foto->>'tipo' as tipo,
    foto->>'url' as url,
    (foto->>'fecha')::bigint as fecha_raw,
    to_timestamp((foto->>'fecha')::bigint / 1000.0) as fecha,
    ROW_NUMBER() OVER (PARTITION BY mdr."NRegistro" ORDER BY (foto->>'fecha')::bigint) as orden,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY mdr."NRegistro" ORDER BY (foto->>'fecha')::bigint) = 1 
        THEN true 
        ELSE false 
    END as principal
FROM "MedicamentoDetalleRaw" mdr,
jsonb_array_elements(mdr."Json"->'fotos') AS foto
WHERE mdr."Json"->'fotos' IS NOT NULL
AND jsonb_array_length(mdr."Json"->'fotos') > 0;

-- PASO 2: Verificar inserción
SELECT 
    'RESULTADO INSERCIÓN' as "Paso",
    COUNT(*) as "TotalFotos",
    COUNT(DISTINCT "NRegistro") as "MedicamentosConFotos"
FROM "Foto";

-- PASO 3: Ver distribución por tipo
SELECT 
    "Tipo",
    COUNT(*) as "Cantidad",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as "Porcentaje"
FROM "Foto"
GROUP BY "Tipo"
ORDER BY COUNT(*) DESC;

-- PASO 4: Estadísticas finales
SELECT 
    'Antes' as "Estado",
    44 as "Fotos",
    22 as "Medicamentos"
UNION ALL
SELECT 
    'Después',
    COUNT(*) as "Fotos",
    COUNT(DISTINCT "NRegistro") as "Medicamentos"
FROM "Foto";

-- PASO 5: Verificar integridad FK
SELECT 
    'Fotos con NRegistro válido' as "Verificacion",
    COUNT(*) as "Cantidad"
FROM "Foto" f
WHERE EXISTS (
    SELECT 1 FROM "Medicamentos" m
    WHERE m."NRegistro" = f."NRegistro"
);

-- PASO 6: Top 10 medicamentos con más fotos
SELECT 
    f."NRegistro",
    m."Nombre",
    COUNT(*) as "NumFotos"
FROM "Foto" f
JOIN "Medicamentos" m ON m."NRegistro" = f."NRegistro"
GROUP BY f."NRegistro", m."Nombre"
ORDER BY COUNT(*) DESC
LIMIT 10;
