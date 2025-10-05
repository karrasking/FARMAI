-- ========================================
-- SIMULACIÓN FASE 3: INSERCIÓN FOTOS
-- ========================================
-- ESTE SCRIPT NO MODIFICA LA BD
-- Solo muestra qué se insertaría

-- 1. EXTRACCIÓN: Parsear JSON de fotos a tabla temporal
WITH fotos_json AS (
    SELECT 
        mdr."NRegistro",
        foto->>'url' as url,
        foto->>'tipo' as tipo,
        (foto->>'fecha')::bigint as fecha_raw,
        to_timestamp((foto->>'fecha')::bigint / 1000.0) as fecha,
        ROW_NUMBER() OVER (PARTITION BY mdr."NRegistro" ORDER BY (foto->>'fecha')::bigint) as orden
    FROM "MedicamentoDetalleRaw" mdr,
    jsonb_array_elements(mdr."Json"->'fotos') AS foto
    WHERE mdr."Json"->'fotos' IS NOT NULL
    AND jsonb_array_length(mdr."Json"->'fotos') > 0
)
-- 2. ESTADÍSTICAS: Ver qué tendríamos
SELECT 
    'TOTAL FOTOS A INSERTAR' as "Metrica",
    COUNT(*)::text as "Valor"
FROM fotos_json
UNION ALL
SELECT 
    'MEDICAMENTOS CON FOTOS',
    COUNT(DISTINCT "NRegistro")::text
FROM fotos_json
UNION ALL
SELECT 
    'FOTOS TIPO materialas',
    COUNT(*)::text
FROM fotos_json
WHERE tipo = 'materialas'
UNION ALL
SELECT 
    'FOTOS TIPO formafarmac',
    COUNT(*)::text
FROM fotos_json
WHERE tipo = 'formafarmac'
UNION ALL
SELECT 
    'FOTOS YA EXISTENTES EN BD',
    COUNT(*)::text
FROM "Foto"
UNION ALL
SELECT 
    'FOTOS NUEVAS A INSERTAR',
    (SELECT COUNT(*) FROM fotos_json fj
     WHERE NOT EXISTS (
         SELECT 1 FROM "Foto" f
         WHERE f."NRegistro" = fj."NRegistro"
         AND f."Url" = fj.url
     ))::text;

-- 3. CALIDAD: Ver posibles problemas
WITH fotos_json AS (
    SELECT 
        mdr."NRegistro",
        foto->>'url' as url,
        foto->>'tipo' as tipo,
        (foto->>'fecha')::bigint as fecha_raw,
        to_timestamp((foto->>'fecha')::bigint / 1000.0) as fecha,
        ROW_NUMBER() OVER (PARTITION BY mdr."NRegistro" ORDER BY (foto->>'fecha')::bigint) as orden
    FROM "MedicamentoDetalleRaw" mdr,
    jsonb_array_elements(mdr."Json"->'fotos') AS foto
    WHERE mdr."Json"->'fotos' IS NOT NULL
    AND jsonb_array_length(mdr."Json"->'fotos') > 0
)
SELECT 
    'URLs NULL o vacías' as "Problema",
    COUNT(*) as "Cantidad"
FROM fotos_json
WHERE url IS NULL OR url = ''
UNION ALL
SELECT 
    'Tipo NULL o vacío',
    COUNT(*)
FROM fotos_json
WHERE tipo IS NULL OR tipo = ''
UNION ALL
SELECT 
    'Tipo desconocido (no materialas/formafarmac)',
    COUNT(*)
FROM fotos_json
WHERE tipo NOT IN ('materialas', 'formafarmac')
UNION ALL
SELECT 
    'Fecha NULL',
    COUNT(*)
FROM fotos_json
WHERE fecha IS NULL
UNION ALL
SELECT 
    'NRegistro no existe en Medicamentos',
    COUNT(*)
FROM fotos_json fj
WHERE NOT EXISTS (
    SELECT 1 FROM "Medicamentos" m
    WHERE m."NRegistro" = fj."NRegistro"
);

-- 4. DUPLICADOS: Verificar si hay duplicados en origen
WITH fotos_json AS (
    SELECT 
        mdr."NRegistro",
        foto->>'url' as url,
        foto->>'tipo' as tipo
    FROM "MedicamentoDetalleRaw" mdr,
    jsonb_array_elements(mdr."Json"->'fotos') AS foto
    WHERE mdr."Json"->'fotos' IS NOT NULL
)
SELECT 
    'DUPLICADOS EN JSON' as "Metrica",
    COUNT(*) - COUNT(DISTINCT "NRegistro", url) as "Cantidad"
FROM fotos_json;

-- 5. SAMPLE: Ver primeras 10 fotos que se insertarían
WITH fotos_json AS (
    SELECT 
        mdr."NRegistro",
        foto->>'url' as url,
        foto->>'tipo' as tipo,
        (foto->>'fecha')::bigint as fecha_raw,
        to_timestamp((foto->>'fecha')::bigint / 1000.0) as fecha,
        ROW_NUMBER() OVER (PARTITION BY mdr."NRegistro" ORDER BY (foto->>'fecha')::bigint) as orden
    FROM "MedicamentoDetalleRaw" mdr,
    jsonb_array_elements(mdr."Json"->'fotos') AS foto
    WHERE mdr."Json"->'fotos' IS NOT NULL
    AND jsonb_array_length(mdr."Json"->'fotos') > 0
)
SELECT 
    "NRegistro",
    tipo,
    LEFT(url, 80) as "URL_Preview",
    fecha,
    orden
FROM fotos_json
WHERE NOT EXISTS (
    SELECT 1 FROM "Foto" f
    WHERE f."NRegistro" = fotos_json."NRegistro"
    AND f."Url" = fotos_json.url
)
LIMIT 10;

-- 6. DISTRIBUCIÓN: Top 10 medicamentos con más fotos
WITH fotos_json AS (
    SELECT 
        mdr."NRegistro",
        m."Nombre",
        COUNT(*) as cant_fotos
    FROM "MedicamentoDetalleRaw" mdr
    JOIN "Medicamentos" m ON m."NRegistro" = mdr."NRegistro",
    jsonb_array_elements(mdr."Json"->'fotos') AS foto
    WHERE mdr."Json"->'fotos' IS NOT NULL
    GROUP BY mdr."NRegistro", m."Nombre"
)
SELECT 
    "NRegistro",
    LEFT("Nombre", 60) as "Medicamento",
    cant_fotos as "NumFotos"
FROM fotos_json
ORDER BY cant_fotos DESC
LIMIT 10;

-- 7. ESTIMACIÓN TIEMPO: Calcular cuánto tardaría
WITH fotos_json AS (
    SELECT 
        COUNT(*) as total_fotos
    FROM "MedicamentoDetalleRaw" mdr,
    jsonb_array_elements(mdr."Json"->'fotos') AS foto
    WHERE mdr."Json"->'fotos' IS NOT NULL
)
SELECT 
    total_fotos as "FotasATotales",
    ROUND(total_fotos / 1000.0, 2) as "TiempoEstimado_Segundos",
    ROUND(total_fotos / 1000.0 / 60.0, 2) as "TiempoEstimado_Minutos"
FROM fotos_json;
