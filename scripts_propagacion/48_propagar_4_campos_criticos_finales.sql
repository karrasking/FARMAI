-- PROPAGAR 4 CAMPOS CRÍTICOS FINALES
-- ====================================
-- ema, notas, receta, generico

-- 1. AÑADIR las 4 columnas nuevas
ALTER TABLE "Medicamentos" 
  ADD COLUMN IF NOT EXISTS "AutorizadoPorEma" boolean,
  ADD COLUMN IF NOT EXISTS "TieneNotas" boolean,
  ADD COLUMN IF NOT EXISTS "RequiereReceta" boolean,
  ADD COLUMN IF NOT EXISTS "EsGenerico" boolean;

-- 2. Ver estado ANTES
SELECT 'ANTES DE PROPAGACIÓN' as momento,
    COUNT(*) as total,
    COUNT("AutorizadoPorEma") as ema_ok,
    COUNT("TieneNotas") as notas_ok,
    COUNT("RequiereReceta") as receta_ok,
    COUNT("EsGenerico") as generico_ok
FROM "Medicamentos";

-- 3. PROPAGAR AutorizadoPorEma
UPDATE "Medicamentos"
SET "AutorizadoPorEma" = ("RawJson"::jsonb ->> 'ema')::boolean
WHERE "RawJson" IS NOT NULL 
  AND "RawJson"::text != '{}'
  AND "RawJson"::jsonb ->> 'ema' IS NOT NULL;

-- 4. PROPAGAR TieneNotas
UPDATE "Medicamentos"
SET "TieneNotas" = ("RawJson"::jsonb ->> 'notas')::boolean
WHERE "RawJson" IS NOT NULL 
  AND "RawJson"::text != '{}'
  AND "RawJson"::jsonb ->> 'notas' IS NOT NULL;

-- 5. PROPAGAR RequiereReceta
UPDATE "Medicamentos"
SET "RequiereReceta" = ("RawJson"::jsonb ->> 'receta')::boolean
WHERE "RawJson" IS NOT NULL 
  AND "RawJson"::text != '{}'
  AND "RawJson"::jsonb ->> 'receta' IS NOT NULL;

-- 6. PROPAGAR EsGenerico
UPDATE "Medicamentos"
SET "EsGenerico" = ("RawJson"::jsonb ->> 'generico')::boolean
WHERE "RawJson" IS NOT NULL 
  AND "RawJson"::text != '{}'
  AND "RawJson"::jsonb ->> 'generico' IS NOT NULL;

-- 7. Ver estado DESPUÉS
SELECT 'DESPUÉS DE PROPAGACIÓN' as momento,
    COUNT(*) as total,
    COUNT("AutorizadoPorEma") as ema_ok,
    COUNT("TieneNotas") as notas_ok,
    COUNT("RequiereReceta") as receta_ok,
    COUNT("EsGenerico") as generico_ok,
    ROUND(COUNT("AutorizadoPorEma")::numeric / COUNT(*) * 100, 2) as pct_ema,
    ROUND(COUNT("TieneNotas")::numeric / COUNT(*) * 100, 2) as pct_notas,
    ROUND(COUNT("RequiereReceta")::numeric / COUNT(*) * 100, 2) as pct_receta,
    ROUND(COUNT("EsGenerico")::numeric / COUNT(*) * 100, 2) as pct_generico
FROM "Medicamentos";

-- 8. DISTRIBUCIÓN de valores
SELECT 'AutorizadoPorEma' as campo,
    "AutorizadoPorEma" as valor,
    COUNT(*) as cantidad,
    ROUND(COUNT(*)::numeric / (SELECT COUNT(*) FROM "Medicamentos") * 100, 2) as porcentaje
FROM "Medicamentos"
GROUP BY "AutorizadoPorEma"
UNION ALL
SELECT 'TieneNotas',
    "TieneNotas",
    COUNT(*),
    ROUND(COUNT(*)::numeric / (SELECT COUNT(*) FROM "Medicamentos") * 100, 2)
FROM "Medicamentos"
GROUP BY "TieneNotas"
UNION ALL
SELECT 'RequiereReceta',
    "RequiereReceta",
    COUNT(*),
    ROUND(COUNT(*)::numeric / (SELECT COUNT(*) FROM "Medicamentos") * 100, 2)
FROM "Medicamentos"
GROUP BY "RequiereReceta"
UNION ALL
SELECT 'EsGenerico',
    "EsGenerico",
    COUNT(*),
    ROUND(COUNT(*)::numeric / (SELECT COUNT(*) FROM "Medicamentos") * 100, 2)
FROM "Medicamentos"
GROUP BY "EsGenerico"
ORDER BY campo, valor DESC NULLS LAST;

-- 9. Ejemplos de cada tipo
SELECT 'Genéricos SIN receta' as tipo, "NRegistro", "Nombre"
FROM "Medicamentos"
WHERE "EsGenerico" = true 
  AND "RequiereReceta" = false
LIMIT 5;

SELECT 'Autorizados EMA con notas' as tipo, "NRegistro", "Nombre"
FROM "Medicamentos"
WHERE "AutorizadoPorEma" = true 
  AND "TieneNotas" = true
LIMIT 5;

SELECT 'Genéricos comercializados' as tipo, "NRegistro", "Nombre"
FROM "Medicamentos"
WHERE "EsGenerico" = true 
  AND "Comercializado" = true
LIMIT 5;

-- 10. RESUMEN FINAL DE TODOS LOS CAMPOS PROPAGADOS
SELECT 
    '🎯 PROPAGACIÓN COMPLETA - TODOS LOS CAMPOS' as titulo,
    COUNT(*) as total_medicamentos,
    ROUND(COUNT("RawJson")::numeric / COUNT(*) * 100, 2) as pct_json_completo,
    ROUND(COUNT("Comercializado")::numeric / COUNT(*) * 100, 2) as pct_comercializado,
    ROUND(COUNT("AfectaConduccion")::numeric / COUNT(*) * 100, 2) as pct_conduccion,
    ROUND(COUNT("TrianguloNegro")::numeric / COUNT(*) * 100, 2) as pct_triangulo,
    ROUND(COUNT("Huerfano")::numeric / COUNT(*) * 100, 2) as pct_huerfano,
    ROUND(COUNT("Biosimilar")::numeric / COUNT(*) * 100, 2) as pct_biosimilar,
    ROUND(COUNT("Psum")::numeric / COUNT(*) * 100, 2) as pct_psum,
    ROUND(COUNT("MaterialesInformativos")::numeric / COUNT(*) * 100, 2) as pct_materiales,
    ROUND(COUNT("AutorizadoPorEma")::numeric / COUNT(*) * 100, 2) as pct_ema,
    ROUND(COUNT("TieneNotas")::numeric / COUNT(*) * 100, 2) as pct_notas,
    ROUND(COUNT("RequiereReceta")::numeric / COUNT(*) * 100, 2) as pct_receta,
    ROUND(COUNT("EsGenerico")::numeric / COUNT(*) * 100, 2) as pct_generico
FROM "Medicamentos";
