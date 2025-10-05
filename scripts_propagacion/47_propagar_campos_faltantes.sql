-- PROPAGAR CAMPOS FALTANTES DESDE JSON
-- ======================================
-- Ahora que tenemos 20,266 JSON completos, propagamos Psum, Fotos y MaterialesInformativos

-- 1. Ver estado ANTES
SELECT 'ANTES DE PROPAGACIÓN' as momento,
    COUNT(*) as total,
    COUNT("Psum") as psum_ok,
    COUNT("Fotos") as fotos_ok,
    COUNT("MaterialesInformativos") as materiales_ok
FROM "Medicamentos";

-- 2. SIMULAR cuántos se actualizarán
SELECT 'SIMULACIÓN' as tipo,
    COUNT(*) as total_a_actualizar,
    COUNT(CASE WHEN ("RawJson"::jsonb ->> 'psum')::boolean = true THEN 1 END) as tendran_psum,
    COUNT(CASE WHEN ("RawJson"::jsonb ->> 'fotos')::boolean = true THEN 1 END) as tendran_fotos,
    COUNT(CASE WHEN ("RawJson"::jsonb ->> 'materialesInf')::boolean = true THEN 1 END) as tendran_materiales
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL 
  AND "RawJson"::text != '{}'
  AND ("Psum" IS NULL OR "Fotos" IS NULL OR "MaterialesInformativos" IS NULL);

-- 3. PROPAGAR Psum
UPDATE "Medicamentos"
SET "Psum" = ("RawJson"::jsonb ->> 'psum')::boolean
WHERE "RawJson" IS NOT NULL 
  AND "RawJson"::text != '{}'
  AND "RawJson"::jsonb ->> 'psum' IS NOT NULL
  AND "Psum" IS NULL;

-- 4. PROPAGAR Fotos
UPDATE "Medicamentos"
SET "Fotos" = CASE 
    WHEN "RawJson"::jsonb ->> 'fotos' = 'true' THEN true
    WHEN "RawJson"::jsonb ->> 'fotos' = 'false' THEN false
    ELSE false
END
WHERE "RawJson" IS NOT NULL 
  AND "RawJson"::text != '{}'
  AND "RawJson"::jsonb ->> 'fotos' IS NOT NULL
  AND "Fotos" IS NULL;

-- 5. PROPAGAR MaterialesInformativos
UPDATE "Medicamentos"
SET "MaterialesInformativos" = ("RawJson"::jsonb ->> 'materialesInf')::boolean
WHERE "RawJson" IS NOT NULL 
  AND "RawJson"::text != '{}'
  AND "RawJson"::jsonb ->> 'materialesInf' IS NOT NULL
  AND "MaterialesInformativos" IS NULL;

-- 6. Ver estado DESPUÉS
SELECT 'DESPUÉS DE PROPAGACIÓN' as momento,
    COUNT(*) as total,
    COUNT("Psum") as psum_ok,
    COUNT("Fotos") as fotos_ok,
    COUNT("MaterialesInformativos") as materiales_ok,
    ROUND(COUNT("Psum")::numeric / COUNT(*) * 100, 2) as pct_psum,
    ROUND(COUNT("Fotos")::numeric / COUNT(*) * 100, 2) as pct_fotos,
    ROUND(COUNT("MaterialesInformativos")::numeric / COUNT(*) * 100, 2) as pct_materiales
FROM "Medicamentos";

-- 7. DISTRIBUCIÓN FINAL
SELECT 'DISTRIBUCIÓN Psum' as tipo,
    "Psum" as valor,
    COUNT(*) as cantidad,
    ROUND(COUNT(*)::numeric / (SELECT COUNT(*) FROM "Medicamentos") * 100, 2) as porcentaje
FROM "Medicamentos"
GROUP BY "Psum"
UNION ALL
SELECT 'DISTRIBUCIÓN Fotos',
    "Fotos",
    COUNT(*),
    ROUND(COUNT(*)::numeric / (SELECT COUNT(*) FROM "Medicamentos") * 100, 2)
FROM "Medicamentos"
GROUP BY "Fotos"
UNION ALL
SELECT 'DISTRIBUCIÓN MaterialesInf',
    "MaterialesInformativos",
    COUNT(*),
    ROUND(COUNT(*)::numeric / (SELECT COUNT(*) FROM "Medicamentos") * 100, 2)
FROM "Medicamentos"
GROUP BY "MaterialesInformativos"
ORDER BY tipo, valor DESC NULLS LAST;

-- 8. Ejemplos de medicamentos con estos flags activos
SELECT 'CON Psum' as tipo, "NRegistro", "Nombre", "Psum"
FROM "Medicamentos"
WHERE "Psum" = true
LIMIT 5;

SELECT 'CON Fotos' as tipo, "NRegistro", "Nombre", "Fotos"
FROM "Medicamentos"
WHERE "Fotos" = true
LIMIT 5;

SELECT 'CON MaterialesInf' as tipo, "NRegistro", "Nombre", "MaterialesInformativos"
FROM "Medicamentos"
WHERE "MaterialesInformativos" = true
LIMIT 5;
