-- ========================================
-- VERIFICACIÓN EXHAUSTIVA: FOTOS EN JSON
-- ========================================

-- 1. Ver TODAS las keys del JSON (no solo las primeras 20)
SELECT DISTINCT jsonb_object_keys("Json") as "Key"
FROM "MedicamentoDetalleRaw"
ORDER BY "Key";

-- 2. Buscar CUALQUIER mención de foto/imagen en keys
SELECT DISTINCT jsonb_object_keys("Json") as "Key"
FROM "MedicamentoDetalleRaw"
WHERE jsonb_object_keys("Json") ILIKE '%foto%'
   OR jsonb_object_keys("Json") ILIKE '%image%'
   OR jsonb_object_keys("Json") ILIKE '%picture%'
   OR jsonb_object_keys("Json") ILIKE '%img%'
   OR jsonb_object_keys("Json") ILIKE '%visual%';

-- 3. Contar medicamentos con campo 'fotos' (minúscula)
SELECT 
    'fotos (minúscula)' as "Campo",
    COUNT(*) as "Medicamentos"
FROM "MedicamentoDetalleRaw"
WHERE "Json" ? 'fotos';

-- 4. Buscar variaciones de capitalización
SELECT 
    'Fotos (capital F)' as "Campo",
    COUNT(*) as "Medicamentos"
FROM "MedicamentoDetalleRaw"
WHERE "Json" ? 'Fotos'
UNION ALL
SELECT 
    'FOTOS (mayúsculas)',
    COUNT(*)
FROM "MedicamentoDetalleRaw"
WHERE "Json" ? 'FOTOS'
UNION ALL
SELECT 
    'foto (singular)',
    COUNT(*)
FROM "MedicamentoDetalleRaw"
WHERE "Json" ? 'foto'
UNION ALL
SELECT 
    'imagen',
    COUNT(*)
FROM "MedicamentoDetalleRaw"
WHERE "Json" ? 'imagen'
UNION ALL
SELECT 
    'imagenes',
    COUNT(*)
FROM "MedicamentoDetalleRaw"
WHERE "Json" ? 'imagenes';

-- 5. Ver estructura completa de un medicamento con fotos
SELECT 
    "NRegistro",
    jsonb_pretty("Json") as "JSON_Completo"
FROM "MedicamentoDetalleRaw"
WHERE "Json" ? 'fotos'
LIMIT 1;

-- 6. Ver tipos de datos en campo fotos
SELECT 
    jsonb_typeof("Json"->'fotos') as "TipoDato",
    COUNT(*) as "Cantidad"
FROM "MedicamentoDetalleRaw"
WHERE "Json" ? 'fotos'
GROUP BY jsonb_typeof("Json"->'fotos');

-- 7. Verificar si hay fotos nested en otros campos
SELECT 
    'fotos dentro de presentaciones' as "Ubicacion",
    COUNT(*) as "Cantidad"
FROM "MedicamentoDetalleRaw" mdr,
jsonb_array_elements(mdr."Json"->'presentaciones') as pres
WHERE pres ? 'fotos'
   OR pres ? 'foto'
   OR pres ? 'imagen';
