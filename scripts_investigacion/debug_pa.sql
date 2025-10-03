-- Investigar PrincipioActivoStaging
SELECT COUNT(*) as total, 
       COUNT(CASE WHEN "CodigoRaw" IS NOT NULL THEN 1 END) as con_codigo,
       COUNT(CASE WHEN "SustanciaId" IS NOT NULL THEN 1 END) as con_sustancia
FROM "PrincipioActivoStaging";

-- Ver muestra de datos
SELECT "NRegistro", "SustanciaId", "CodigoRaw", "NombreRaw", "CantidadRaw", "UnidadRaw"
FROM "PrincipioActivoStaging"
LIMIT 5;

-- Ver si hay match con graph_edge
SELECT COUNT(*) as matches
FROM graph_edge ge
JOIN "PrincipioActivoStaging" pas 
  ON ge.src_key = pas."NRegistro"
  AND ge.dst_key = pas."SustanciaId"::text
WHERE ge.rel = 'PERTENECE_A_PRINCIPIO_ACTIVO'
  AND pas."CodigoRaw" IS NOT NULL;
