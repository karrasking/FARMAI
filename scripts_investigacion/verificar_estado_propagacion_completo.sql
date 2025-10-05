-- VERIFICAR ESTADO DE PROPAGACIÓN COMPLETO
-- ==========================================
-- Ahora que tenemos 20,119 JSON completos, verificamos qué está propagado

-- 1. CAMPOS BOOLEANOS ESPECIALES
SELECT 
    'AfectaConduccion' as campo,
    COUNT(*) as total,
    COUNT("AfectaConduccion") as con_valor,
    COUNT(*) - COUNT("AfectaConduccion") as nulls
FROM "Medicamentos"
UNION ALL
SELECT 
    'TrianguloNegro',
    COUNT(*),
    COUNT("TrianguloNegro"),
    COUNT(*) - COUNT("TrianguloNegro")
FROM "Medicamentos"
UNION ALL
SELECT 
    'Huerfano',
    COUNT(*),
    COUNT("Huerfano"),
    COUNT(*) - COUNT("Huerfano")
FROM "Medicamentos"
UNION ALL
SELECT 
    'Biosimilar',
    COUNT(*),
    COUNT("Biosimilar"),
    COUNT(*) - COUNT("Biosimilar")
FROM "Medicamentos"
UNION ALL
SELECT 
    'MaterialesInformativos',
    COUNT(*),
    COUNT("MaterialesInformativos"),
    COUNT(*) - COUNT("MaterialesInformativos")
FROM "Medicamentos"
UNION ALL
SELECT 
    'Fotos',
    COUNT(*),
    COUNT("Fotos"),
    COUNT(*) - COUNT("Fotos")
FROM "Medicamentos"
UNION ALL
SELECT 
    'Psum',
    COUNT(*),
    COUNT("Psum"),
    COUNT(*) - COUNT("Psum")
FROM "Medicamentos";

-- 2. CONTAR CUÁNTOS TIENEN ESTOS DATOS EN EL JSON
SELECT 
    COUNT(*) as total_con_json,
    COUNT(CASE WHEN "RawJson"::jsonb ->> 'conduc' IS NOT NULL THEN 1 END) as json_tiene_conduc,
    COUNT(CASE WHEN "RawJson"::jsonb ->> 'triangulo' IS NOT NULL THEN 1 END) as json_tiene_triangulo,
    COUNT(CASE WHEN "RawJson"::jsonb ->> 'huerfano' IS NOT NULL THEN 1 END) as json_tiene_huerfano,
    COUNT(CASE WHEN "RawJson"::jsonb ->> 'biosimilar' IS NOT NULL THEN 1 END) as json_tiene_biosimilar,
    COUNT(CASE WHEN "RawJson"::jsonb ->> 'materialesInf' IS NOT NULL THEN 1 END) as json_tiene_materiales,
    COUNT(CASE WHEN "RawJson"::jsonb ->> 'psum' IS NOT NULL THEN 1 END) as json_tiene_psum
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL AND "RawJson"::text != '{}';

-- 3. SAMPLE: Ver uno con JSON para ver qué campos tiene
SELECT 
    "NRegistro",
    "Nombre",
    "AfectaConduccion" as col_conduc,
    ("RawJson"::jsonb ->> 'conduc')::boolean as json_conduc,
    "TrianguloNegro" as col_triangulo,
    ("RawJson"::jsonb ->> 'triangulo')::boolean as json_triangulo,
    "Huerfano" as col_huerfano,
    ("RawJson"::jsonb ->> 'huerfano')::boolean as json_huerfano
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL AND "RawJson"::text != '{}'
LIMIT 5;
