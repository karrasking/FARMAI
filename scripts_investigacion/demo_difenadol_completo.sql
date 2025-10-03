-- ============================================================
-- EXTRACCION COMPLETA - DIFENADOL RAPID 400 mg
-- ============================================================

\echo '1. INFORMACION BASICA'
SELECT 
    "NRegistro",
    "Nombre",
    "Dosis",
    "Generico",
    "Receta",
    "Comercializado",
    "FechaAutorizacion"::date
FROM "Medicamentos"
WHERE "NRegistro" = '74559';

\echo ''
\echo '2. PRESENTACIONES'
SELECT 
    p."CN",
    p."Nombre"
FROM "Medicamentos" m
JOIN "MedicamentoPresentacion" mp ON m."NRegistro" = mp."NRegistro"
JOIN "Presentacion" p ON mp."CN" = p."CN"
WHERE m."NRegistro" = '74559';

\echo ''
\echo '3. PRINCIPIOS ACTIVOS'
SELECT 
    sa."Nombre",
    ms."Cantidad",
    ms."Unidad"
FROM "Medicamentos" m
JOIN "MedicamentoSustancia" ms ON m."NRegistro" = ms."NRegistro"
JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
WHERE m."NRegistro" = '74559';

\echo ''
\echo '4. EXCIPIENTES'
SELECT 
    e."Nombre" as excipiente,
    CASE 
        WHEN e."Nombre" ILIKE '%LACTOSA%' THEN 'ALERTA LACTOSA'
        WHEN e."Nombre" ILIKE '%ASPARTAMO%' THEN 'ALERTA ASPARTAMO'
        WHEN e."Nombre" ILIKE '%SACAROSA%' THEN 'ALERTA SACAROSA'
        ELSE 'Sin alertas'
    END as alerta
FROM "Medicamentos" m
JOIN "MedicamentoExcipiente" me ON m."NRegistro" = me."NRegistro"
JOIN "Excipiente" e ON me."ExcipienteId" = e."Id"
WHERE m."NRegistro" = '74559';

\echo ''
\echo '5. CLASIFICACION ATC'
SELECT 
    a."Nivel",
    a."Codigo",
    a."Nombre"
FROM "Medicamentos" m
JOIN "MedicamentoAtc" ma ON m."NRegistro" = ma."NRegistro"
JOIN "Atc" a ON ma."Codigo" = a."Codigo"
WHERE m."NRegistro" = '74559'
ORDER BY a."Nivel";

\echo ''
\echo '6. LABORATORIO'
SELECT 
    l."Nombre"
FROM "Medicamentos" m
JOIN "Laboratorio" l ON m."LaboratorioTitularId" = l."Id"
WHERE m."NRegistro" = '74559';

\echo ''
\echo '7. FLAGS'
SELECT 
    dst_key as flag,
    CASE dst_key
        WHEN 'GENERICO' THEN 'Medicamento generico EFG'
        WHEN 'COMERCIALIZADO' THEN 'Disponible en farmacias'
        WHEN 'REQUIERE_RECETA' THEN 'Necesita receta'
        WHEN 'SIN_RECETA' THEN 'Venta libre'
        ELSE dst_key
    END as descripcion
FROM graph_edge
WHERE src_key = '74559'
  AND src_type = 'Medicamento'
  AND rel = 'TIENE_FLAG';

\echo ''
\echo '8. INTERACCIONES'
SELECT DISTINCT
    ge.dst_key,
    a."Nombre"
FROM graph_edge ge
JOIN "Atc" a ON ge.dst_key = a."Codigo"
WHERE ge.src_key = '74559'
  AND ge.src_type = 'Medicamento'
  AND ge.rel = 'INTERACCIONA_CON'
LIMIT 10;

\echo ''
\echo '9. ALERTAS GERIATRICAS'
SELECT 
    dst_key as alerta_id,
    props
FROM graph_edge
WHERE src_key = '74559'
  AND src_type = 'Medicamento'
  AND rel = 'TIENE_ALERTA_GERIATRIA';

\echo ''
\echo '10. BIOMARCADORES'
SELECT 
    b."Nombre",
    b."Tipo",
    mb."TipoRelacion"
FROM "Medicamentos" m
JOIN "MedicamentoBiomarcador" mb ON m."NRegistro" = mb."NRegistro"
JOIN "Biomarcador" b ON mb."BiomarcadorId" = b."Id"
WHERE m."NRegistro" = '74559';

\echo ''
\echo '11. RESUMEN COMPLETO GRAFO'
SELECT 
    rel,
    COUNT(*) as total
FROM graph_edge
WHERE src_key = '74559'
  AND src_type = 'Medicamento'
GROUP BY rel
ORDER BY total DESC;

\echo ''
\echo '12. TODAS LAS RELACIONES DETALLADAS'
SELECT 
    rel,
    dst_type,
    dst_key,
    props
FROM graph_edge
WHERE src_key = '74559'
  AND src_type = 'Medicamento'
ORDER BY rel, dst_key;
