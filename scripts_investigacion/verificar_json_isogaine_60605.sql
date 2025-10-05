-- Ver el JSON completo de 60605 para verificar el PA real

SELECT 
    "NRegistro",
    "Nombre",
    "RawJson"::jsonb -> 'principiosActivos' as principios_activos_json
FROM "Medicamentos"
WHERE "NRegistro" = '60605';

-- Ver si el JSON tiene info de principios activos
SELECT 
    "NRegistro",
    "Nombre",
    jsonb_pretty("RawJson"::jsonb -> 'principiosActivos') as pas_formateado
FROM "Medicamentos"
WHERE "NRegistro" = '60605';
