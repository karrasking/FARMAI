-- INVESTIGAR RESTRICCIONES DE USO EN LA BD
-- ==========================================
-- Ver qué campos tenemos sobre conducción, embarazo, celíacos, etc.

-- 1. Ver TODOS los campos en tabla Medicamentos
SELECT 
    'CAMPOS EN MEDICAMENTOS' as tabla,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'Medicamentos'
  AND column_name LIKE '%Conduc%'
     OR column_name LIKE '%Embara%'
     OR column_name LIKE '%Terato%'
     OR column_name LIKE '%Celia%'
     OR column_name LIKE '%Gluten%'
     OR column_name LIKE '%Lacto%'
ORDER BY ordinal_position;

-- 2. Ver si tenemos AfectaConduccion
SELECT 
    '✅ AFECTA CONDUCCION' as campo,
    COUNT(*) as total_medicamentos,
    COUNT(CASE WHEN "AfectaConduccion" = true THEN 1 END) as afecta_si,
    COUNT(CASE WHEN "AfectaConduccion" = false THEN 1 END) as afecta_no
FROM "Medicamentos";

-- 3. Ver ejemplos de medicamentos que afectan conducción
SELECT 
    'EJEMPLOS AFECTA CONDUCCION' as tipo,
    "NRegistro",
    "Nombre",
    "AfectaConduccion"
FROM "Medicamentos"
WHERE "AfectaConduccion" = true
LIMIT 5;

-- 4. Buscar en JSON si hay info de embarazo/lactancia/gluten
SELECT 
    'INFO EN JSON (embarazo, lactancia, gluten)' as tipo,
    "NRegistro",
    "Nombre",
    "RawJson"::jsonb -> 'viasAdministracion' as vias,
    "RawJson"::jsonb -> 'excipientes' as excipientes,
    "RawJson"::jsonb ? 'embarazo' as tiene_embarazo,
    "RawJson"::jsonb ? 'lactancia' as tiene_lactancia,
    "RawJson"::jsonb ? 'gluten' as tiene_gluten
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL
LIMIT 3;

-- 5. Ver QUÉ PROPIEDADES tiene el JSON completo de UN medicamento
SELECT 
    'PROPIEDADES JSON' as tipo,
    jsonb_object_keys("RawJson"::jsonb) as propiedad
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL
LIMIT 1;

-- 6. Ver si hay algo en Excipientes (gluten, lactosa)
SELECT 
    'EXCIPIENTES ESPECIALES' as tipo,
    e."Nombre" as excipiente,
    COUNT(DISTINCT me."MedicamentoId") as medicamentos_que_lo_tienen
FROM "MedicamentoExcipientes" me
JOIN "Excipientes" e ON me."ExcipienteId" = e."Id"
WHERE LOWER(e."Nombre") LIKE '%gluten%'
   OR LOWER(e."Nombre") LIKE '%lactos%'
   OR LOWER(e."Nombre") LIKE '%soja%'
   OR LOWER(e."Nombre") LIKE '%cacahu%'
GROUP BY e."Nombre"
ORDER BY medicamentos_que_lo_tienen DESC;

-- 7. Ver FLAGS especiales que puedan indicar restricciones
SELECT 
    'FLAGS RESTRICCIONES' as tipo,
    f."Nombre" as flag_nombre,
    f."Descripcion",
    COUNT(*) as medicamentos_con_flag
FROM "MedicamentoFlags" mf
JOIN "Flags" f ON mf."FlagId" = f."Id"
WHERE f."Nombre" IN ('DH', 'ECM', 'TLD', 'H', 'EXC', 'ESP')
GROUP BY f."Nombre", f."Descripcion"
ORDER BY medicamentos_con_flag DESC;

-- 8. Ver si hay campos en XML staging relacionados
SELECT 
    'CAMPOS EN STAGING' as tipo,
    column_name
FROM information_schema.columns
WHERE table_name = 'PrescripcionStaging'
  AND (column_name LIKE '%conduc%'
   OR column_name LIKE '%embara%'
   OR column_name LIKE '%terato%'
   OR column_name LIKE '%gluten%'
   OR column_name LIKE '%lacto%'
   OR column_name LIKE '%celia%')
ORDER BY column_name;

-- 9. Ver TODAS las propiedades que tiene el JSON completo
SELECT DISTINCT
    'TODAS PROPIEDADES JSON DISPONIBLES' as tipo,
    jsonb_object_keys("RawJson"::jsonb) as propiedad
FROM "Medicamentos"
WHERE "RawJson" IS NOT NULL
ORDER BY propiedad;

-- 10. Ver si hay notas relacionadas con embarazo/conducción
SELECT 
    'NOTAS RELACIONADAS' as tipo,
    n."Tipo",
    n."Titulo",
    COUNT(*) as cantidad_notas
FROM "NotaSeguridadReferencias" nr
JOIN "NotaSeguridad" n ON nr."NotaSeguridadId" = n."Id"
WHERE LOWER(n."Titulo") LIKE '%embara%'
   OR LOWER(n."Titulo") LIKE '%condu%'
   OR LOWER(n."Titulo") LIKE '%lactan%'
GROUP BY n."Tipo", n."Titulo"
ORDER BY cantidad_notas DESC;
