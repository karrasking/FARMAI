-- Investigar DEXIBUPROFENO STRIDES 200 MG
-- Verificar qué datos tenemos disponibles

-- 1. Buscar el medicamento
SELECT 
    nregistro,
    nombre,
    dosis,
    labTitular,
    generico,
    receta,
    comercializado,
    CASE 
        WHEN RawJson IS NULL THEN '❌ NULL'
        WHEN RawJson = '' THEN '❌ VACIO'
        WHEN LEN(RawJson) < 100 THEN '⚠️ MUY CORTO (' + CAST(LEN(RawJson) AS VARCHAR) + ')'
        ELSE '✅ OK (' + CAST(LEN(RawJson) AS VARCHAR) + ' chars)'
    END AS estado_rawjson,
    CASE 
        WHEN RawJsonDetalle IS NULL THEN '❌ NULL'
        WHEN RawJsonDetalle = '' THEN '❌ VACIO'  
        WHEN LEN(RawJsonDetalle) < 100 THEN '⚠️ MUY CORTO (' + CAST(LEN(RawJsonDetalle) AS VARCHAR) + ')'
        ELSE '✅ OK (' + CAST(LEN(RawJsonDetalle) AS VARCHAR) + ' chars)'
    END AS estado_rawjsondetalle
FROM dbo.Medicamento
WHERE nombre LIKE '%DEXIBUPROFENO STRIDES%'
   OR nombre LIKE '%DEXIBUPROFENO%200%';

-- 2. Si existe, ver un sample del JSON
DECLARE @nregistro VARCHAR(20);
SELECT TOP 1 @nregistro = nregistro 
FROM dbo.Medicamento
WHERE nombre LIKE '%DEXIBUPROFENO STRIDES%';

IF @nregistro IS NOT NULL
BEGIN
    PRINT 'N° Registro encontrado: ' + @nregistro;
    PRINT '';
    
    -- Ver inicio del RawJson
    SELECT 
        'RawJson (primeros 2000 chars):' as tipo,
        LEFT(RawJson, 2000) as contenido
    FROM dbo.Medicamento
    WHERE nregistro = @nregistro;
    
    -- Contar campos disponibles en el JSON
    SELECT 
        'Análisis de campos en JSON:' as titulo,
        CASE WHEN RawJson LIKE '%"principiosActivos"%' THEN '✅' ELSE '❌' END as principios_activos,
        CASE WHEN RawJson LIKE '%"excipientes"%' THEN '✅' ELSE '❌' END as excipientes,
        CASE WHEN RawJson LIKE '%"presentaciones"%' THEN '✅' ELSE '❌' END as presentaciones,
        CASE WHEN RawJson LIKE '%"docs"%' THEN '✅' ELSE '❌' END as documentos,
        CASE WHEN RawJson LIKE '%"fotos"%' THEN '✅' ELSE '❌' END as fotos,
        CASE WHEN RawJson LIKE '%"atcs"%' THEN '✅' ELSE '❌' END as atcs,
        CASE WHEN RawJson LIKE '%"vtm"%' THEN '✅' ELSE '❌' END as vtm,
        CASE WHEN RawJson LIKE '%"viasAdministracion"%' THEN '✅' ELSE '❌' END as vias_admin
    FROM dbo.Medicamento
    WHERE nregistro = @nregistro;
END
ELSE
BEGIN
    PRINT '❌ Medicamento NO encontrado en la base de datos';
END
