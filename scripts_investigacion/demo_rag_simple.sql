-- Demo RAG: Busqueda completa IBUPROFENO CINFA

-- 1. Buscar medicamento
SELECT 
    'INFORMACION BASICA' as seccion,
    "NRegistro",
    "Nombre",
    "Generico",
    "Receta",
    "Comercializado"
FROM "Medicamentos"
WHERE "Nombre" ILIKE '%IBUPROFENO%CINFA%600%'
LIMIT 1;

-- 2. Presentaciones
SELECT 
    'PRESENTACIONES' as seccion,
    p."CN",
    p."Nombre",
    p."PrecioVentaPublico"
FROM "Medicamentos" m
JOIN "MedicamentoPresentacion" mp ON m."NRegistro" = mp."NRegistro"
JOIN "Presentacion" p ON mp."CN" = p."CN"
WHERE m."Nombre" ILIKE '%IBUPROFENO%CINFA%600%';

-- 3. Principios Activos
SELECT 
    'PRINCIPIOS ACTIVOS' as seccion,
    sa."Nombre",
    ms."Cantidad",
    ms."Unidad"
FROM "Medicamentos" m
JOIN "MedicamentoSustancia" ms ON m."NRegistro" = ms."NRegistro"
JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
WHERE m."Nombre" ILIKE '%IBUPROFENO%CINFA%600%';

-- 4. Excipientes (DETALLE COMPLETO)
SELECT 
    'EXCIPIENTES' as seccion,
    e."Nombre" as excipiente,
    CASE 
        WHEN e."Id" IN (SELECT "Id" FROM "DictExcipienteOblig") 
        THEN 'Declaracion Obligatoria'
        ELSE 'Normal'
    END as tipo
FROM "Medicamentos" m
JOIN "MedicamentoExcipiente" me ON m."NRegistro" = me."NRegistro"
JOIN "Excipiente" e ON me."ExcipienteId" = e."Id"
WHERE m."Nombre" ILIKE '%IBUPROFENO%CINFA%600%'
ORDER BY tipo DESC, e."Nombre";

-- 5. Clasificacion ATC
SELECT 
    'CLASIFICACION ATC' as seccion,
    a."Codigo",
    a."Nombre"
FROM "Medicamentos" m
JOIN "MedicamentoAtc" ma ON m."NRegistro" = ma."NRegistro"
JOIN "Atc" a ON ma."Codigo" = a."Codigo"
WHERE m."Nombre" ILIKE '%IBUPROFENO%CINFA%600%';

-- 6. Laboratorio
SELECT 
    'LABORATORIO' as seccion,
    l."Nombre",
    li."Direccion",
    li."Localidad"
FROM "Medicamentos" m
JOIN "Laboratorio" l ON m."LaboratorioTitularId" = l."Id"
LEFT JOIN "LaboratorioInfo" li ON l."Id" = li."LabId"
WHERE m."Nombre" ILIKE '%IBUPROFENO%CINFA%600%';

-- 7. Flags desde grafo
SELECT 
    'FLAGS Y ESTADOS' as seccion,
    dst_key as flag,
    COUNT(*) as veces
FROM graph_edge
WHERE src_key = (SELECT "NRegistro" FROM "Medicamentos" WHERE "Nombre" ILIKE '%IBUPROFENO%CINFA%600%' LIMIT 1)
  AND src_type = 'Medicamento'
  AND rel = 'TIENE_FLAG'
GROUP BY dst_key;

-- 8. Interacciones (DETALLE COMPLETO)
SELECT 
    'INTERACCIONES' as seccion,
    a2."Codigo" as atc_interaccion,
    a2."Nombre" as descripcion_interaccion
FROM "Medicamentos" m
JOIN "MedicamentoAtc" ma ON m."NRegistro" = ma."NRegistro"
JOIN graph_edge ge ON ma."Codigo" = ge.src_key
JOIN "Atc" a2 ON ge.dst_key = a2."Codigo"
WHERE m."Nombre" ILIKE '%IBUPROFENO%CINFA%600%'
  AND ge.rel = 'INTERACCIONA_CON'
LIMIT 15;

-- 9. Resumen relaciones en grafo
SELECT 
    'RESUMEN GRAFO' as seccion,
    rel,
    COUNT(*) as total
FROM graph_edge
WHERE src_key = (SELECT "NRegistro" FROM "Medicamentos" WHERE "Nombre" ILIKE '%IBUPROFENO%CINFA%600%' LIMIT 1)
  AND src_type = 'Medicamento'
GROUP BY rel
ORDER BY total DESC;
