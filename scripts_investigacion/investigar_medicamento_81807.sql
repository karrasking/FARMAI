-- Investigar medicamento 81807 (COULDINA CON IBUPROFENO)
-- que está dando error

SELECT 
    nregistro,
    nombre,
    CASE 
        WHEN RawJson IS NULL THEN 'NULL'
        WHEN RawJson = '' THEN 'EMPTY'
        WHEN RawJsonDetalle IS NULL THEN 'Solo RawJson'
        ELSE 'Ambos'
    END AS estado_json,
    LEN(RawJson) as len_rawjson,
    LEN(RawJsonDetalle) as len_rawjsondetalle,
    labTitular,
    comercializado
FROM dbo.Medicamento
WHERE nregistro = '81807';

-- Ver si tiene el JSON
SELECT TOP 1
    nregistro,
    LEFT(RawJson, 500) as inicio_json,
    LEFT(RawJsonDetalle, 500) as inicio_json_detalle
FROM dbo.Medicamento
WHERE nregistro = '81807';
