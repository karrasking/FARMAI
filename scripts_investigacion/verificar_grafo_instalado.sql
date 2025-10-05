-- VERIFICAR SI HAY GRAFO INSTALADO
-- ==================================

-- 1. Ver extensiones instaladas
SELECT 
    'EXTENSIONES INSTALADAS' as tipo,
    extname as extension,
    extversion as version
FROM pg_extension
ORDER BY extname;

-- 2. Ver todos los schemas
SELECT 
    'SCHEMAS DISPONIBLES' as tipo,
    schema_name
FROM information_schema.schemata
ORDER BY schema_name;

-- 3. Ver si existe el schema 'ag_catalog' (Apache AGE)
SELECT 
    'TIENE APACHE AGE?' as pregunta,
    EXISTS(SELECT 1 FROM information_schema.schemata WHERE schema_name = 'ag_catalog') as tiene_age;

-- 4. Ver si existe alguna tabla relacionada con grafos
SELECT 
    'TABLAS CON GRAFO' as tipo,
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_name ILIKE '%graph%'
   OR table_name ILIKE '%vertex%'
   OR table_name ILIKE '%edge%'
   OR table_schema ILIKE '%ag%'
ORDER BY table_schema, table_name;

-- 5. Ver TODAS las tablas del schema public
SELECT 
    'TODAS LAS TABLAS PUBLIC' as tipo,
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'public' AND table_name = t.table_name) as num_columnas
FROM information_schema.tables t
WHERE table_schema = 'public'
ORDER BY table_name;
