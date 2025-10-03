-- Buscar DIFENADOL RAPID 400 mg

SELECT 
    'BUSQUEDA' as seccion,
    "NRegistro",
    "Nombre",
    "Generico",
    "Receta",
    "Comercializado"
FROM "Medicamentos"
WHERE "Nombre" ILIKE '%DIFENADOL%RAPID%'
   OR "Nombre" ILIKE '%DIFENADOL%400%'
LIMIT 5;
