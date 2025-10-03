-- ============================================================
-- BÚSQUEDA COMPLETA DE MEDICAMENTO (Estilo RAG/Agentic)
-- Extrae TODA la información relacionada del grafo y tablas
-- ============================================================

-- Parámetro: Buscar "IBUPROFENO CINFA 600"
\set nombre_busqueda 'IBUPROFENO CINFA 600'

-- 1. INFORMACIÓN BÁSICA DEL MEDICAMENTO
SELECT 
    '1️⃣ INFORMACIÓN BÁSICA' as seccion,
    "NRegistro",
    "Nombre",
    "Dosis",
    "Generico" as es_generico,
    "Receta" as necesita_receta,
    "Comercializado",
    "FechaAutorizacion",
    "AfectaConduccion",
    "TrianguloNegro",
    "Huerfano",
    "Biosimilar"
FROM "Medicamentos"
WHERE "Nombre" ILIKE '%' || :'nombre_busqueda' || '%'
LIMIT 1;

-- Guardar NRegistro para consultas posteriores
\gset med_

-- 2. PRESENTACIONES DISPONIBLES
SELECT 
    '2️⃣ PRESENTACIONES' as seccion,
    p."CN" as codigo_nacional,
    p."Nombre" as presentacion,
    p."PrecioVentaPublico" as pvp,
    pc."Contenido",
    pc."NroConte" as unidades,
    u."Nombre" as unidad,
    e."Nombre" as tipo_envase
FROM "Medicamentos" m
JOIN "MedicamentoPresentacion" mp ON m."NRegistro" = mp."NRegistro"
JOIN "Presentacion" p ON mp."CN" = p."CN"
LEFT JOIN "PresentacionContenido" pc ON p."CN" = pc."CN"
LEFT JOIN "UnidadContenidoDicStaging" u ON pc."UnidadId" = u."Id"
LEFT JOIN "EnvaseDicStaging" e ON pc."EnvaseId" = e."Id"
WHERE m."Nombre" ILIKE '%' || :'nombre_busqueda' || '%';

-- 3. PRINCIPIOS ACTIVOS (Composición)
SELECT 
    '3️⃣ PRINCIPIOS ACTIVOS' as seccion,
    sa."Nombre" as principio_activo,
    ms."Cantidad",
    ms."Unidad",
    ms."Orden"
FROM "Medicamentos" m
JOIN "MedicamentoSustancia" ms ON m."NRegistro" = ms."NRegistro"
JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
WHERE m."Nombre" ILIKE '%' || :'nombre_busqueda' || '%'
ORDER BY ms."Orden";

-- 4. EXCIPIENTES
SELECT 
    '4️⃣ EXCIPIENTES' as seccion,
    e."Nombre" as excipiente,
    CASE 
        WHEN e."Id" IN (SELECT "Id" FROM "DictExcipienteOblig") 
        THEN 'Declaración Obligatoria'
        ELSE 'Normal'
    END as tipo
FROM "Medicamentos" m
JOIN "MedicamentoExcipiente" me ON m."NRegistro" = me."NRegistro"
JOIN "Excipiente" e ON me."ExcipienteId" = e."Id"
WHERE m."Nombre" ILIKE '%' || :'nombre_busqueda' || '%'
ORDER BY tipo DESC, e."Nombre";

-- 5. CLASIFICACIÓN ATC
SELECT 
    '5️⃣ CLASIFICACIÓN ATC' as seccion,
    a."Codigo",
    a."Nombre",
    a."Nivel"
FROM "Medicamentos" m
JOIN "MedicamentoAtc" ma ON m."NRegistro" = ma."NRegistro"
JOIN "Atc" a ON ma."Codigo" = a."Codigo"
WHERE m."Nombre" ILIKE '%' || :'nombre_busqueda' || '%'
ORDER BY a."Nivel";

-- 6. LABORATORIOS
SELECT 
    '6️⃣ LABORATORIOS' as seccion,
    lt."Nombre" as laboratorio_titular,
    li_t."Direccion" as direccion_titular,
    li_t."Localidad" as localidad_titular,
    lc."Nombre" as laboratorio_comercializador,
    li_c."Direccion" as direccion_comercializador
FROM "Medicamentos" m
LEFT JOIN "Laboratorio" lt ON m."LaboratorioTitularId" = lt."Id"
LEFT JOIN "LaboratorioInfo" li_t ON lt."Id" = li_t."LabId"
LEFT JOIN "Laboratorio" lc ON m."LaboratorioComercializadorId" = lc."Id"
LEFT JOIN "LaboratorioInfo" li_c ON lc."Id" = li_c."LabId"
WHERE m."Nombre" ILIKE '%' || :'nombre_busqueda' || '%';

-- 7. FLAGS Y ESTADOS (desde grafo)
SELECT 
    '7️⃣ FLAGS Y ESTADOS' as seccion,
    dst_key as flag_nombre,
    (props->>'count')::int as veces_aplicado
FROM graph_edge
WHERE src_key = (SELECT "NRegistro" FROM "Medicamentos" WHERE "Nombre" ILIKE '%' || :'nombre_busqueda' || '%' LIMIT 1)
  AND src_type = 'Medicamento'
  AND rel = 'TIENE_FLAG'
ORDER BY dst_key;

-- 8. INTERACCIONES (vía ATC)
SELECT 
    '8️⃣ INTERACCIONES' as seccion,
    ge.dst_key as interacciona_con_atc,
    a2."Nombre" as nombre_atc_interaccion,
    COUNT(*) as num_medicamentos_afectados
FROM "Medicamentos" m
JOIN "MedicamentoAtc" ma ON m."NRegistro" = ma."NRegistro"
JOIN graph_edge ge ON ma."Codigo" = ge.src_key
JOIN "Atc" a2 ON ge.dst_key = a2."Codigo"
WHERE m."Nombre" ILIKE '%' || :'nombre_busqueda' || '%'
  AND ge.src_type = 'ATC'
  AND ge.rel = 'INTERACCIONA_CON'
GROUP BY ge.dst_key, a2."Nombre"
LIMIT 10;

-- 9. ALERTAS GERIÁTRICAS
SELECT 
    '9️⃣ ALERTAS GERIÁTRICAS' as seccion,
    props->>'criterio' as criterio,
    props->>'severidad' as severidad,
    props->>'descripcion' as descripcion
FROM graph_edge
WHERE src_key = (SELECT "NRegistro" FROM "Medicamentos" WHERE "Nombre" ILIKE '%' || :'nombre_busqueda' || '%' LIMIT 1)
  AND src_type = 'Medicamento'
  AND rel = 'TIENE_ALERTA_GERIATRIA'
LIMIT 5;

-- 10. BIOMARCADORES (Farmacogenómica)
SELECT 
    '🔟 BIOMARCADORES FARMACOGENÓMICOS' as seccion,
    b."Nombre" as biomarcador,
    b."Tipo" as tipo_biomarcador,
    mb."TipoRelacion" as tipo_relacion,
    mb."RecomendacionDosis" as recomendacion
FROM "Medicamentos" m
JOIN "MedicamentoBiomarcador" mb ON m."NRegistro" = mb."NRegistro"
JOIN "Biomarcador" b ON mb."BiomarcadorId" = b."Id"
WHERE m."Nombre" ILIKE '%' || :'nombre_busqueda' || '%';

-- 11. NOTAS DE SEGURIDAD AEMPS
SELECT 
    '1️⃣1️⃣ NOTAS DE SEGURIDAD' as seccion,
    props->>'titulo' as titulo_nota,
    props->>'fecha' as fecha_publicacion,
    props->>'url' as url_nota
FROM graph_edge
WHERE src_key = (SELECT "NRegistro" FROM "Medicamentos" WHERE "Nombre" ILIKE '%' || :'nombre_busqueda' || '%' LIMIT 1)
  AND src_type = 'Medicamento'
  AND rel = 'TIENE_NOTA_SEGURIDAD'
LIMIT 5;

-- 12. DOCUMENTOS (Ficha Técnica, Prospecto)
SELECT 
    '1️⃣2️⃣ DOCUMENTOS OFICIALES' as seccion,
    d."Tipo" as tipo_documento,
    d."Url" as url_documento,
    d."FechaActualizacion" as ultima_actualizacion
FROM "Medicamentos" m
JOIN "Documento" d ON m."NRegistro" = d."NRegistro"
WHERE m."Nombre" ILIKE '%' || :'nombre_busqueda' || '%';

-- 13. FORMA FARMACÉUTICA
SELECT 
    '1️⃣3️⃣ FORMA FARMACÉUTICA' as seccion,
    ff."Nombre" as forma,
    ffs."Nombre" as forma_simplificada
FROM "Medicamentos" m
LEFT JOIN "FormaFarmaceutica" ff ON m."FormaFarmaceuticaId" = ff."Id"
LEFT JOIN "FormaFarmaceuticaSimplificada" ffs ON m."FormaFarmaceuticaSimplificadaId" = ffs."Id"
WHERE m."Nombre" ILIKE '%' || :'nombre_busqueda' || '%';

-- 14. VÍAS DE ADMINISTRACIÓN
SELECT 
    '1️⃣4️⃣ VÍAS DE ADMINISTRACIÓN' as seccion,
    va."Nombre" as via_administracion
FROM "Medicamentos" m
JOIN "MedicamentoVia" mv ON m."NRegistro" = mv."NRegistro"
JOIN "ViaAdministracion" va ON mv."ViaId" = va."Id"
WHERE m."Nombre" ILIKE '%' || :'nombre_busqueda' || '%';

-- 15. MEDICAMENTOS DUPLICADOS/SIMILARES
SELECT 
    '1️⃣5️⃣ MEDICAMENTOS SIMILARES' as seccion,
    m2."NRegistro" as nregistro_similar,
    m2."Nombre" as nombre_similar,
    m2."Generico" as es_generico
FROM "Medicamentos" m1
JOIN graph_edge ge ON m1."NRegistro" = ge.src_key
JOIN "Medicamentos" m2 ON ge.dst_key = m2."NRegistro"
WHERE m1."Nombre" ILIKE '%' || :'nombre_busqueda' || '%'
  AND ge.rel = 'DUPLICIDAD_CON'
LIMIT 10;

-- 16. RESUMEN NAVEGACIÓN GRAFO
SELECT 
    '1️⃣6️⃣ RESUMEN CONEXIONES EN GRAFO' as seccion,
    rel as tipo_relacion,
    COUNT(*) as num_relaciones
FROM graph_edge
WHERE src_key = (SELECT "NRegistro" FROM "Medicamentos" WHERE "Nombre" ILIKE '%' || :'nombre_busqueda' || '%' LIMIT 1)
  AND src_type = 'Medicamento'
GROUP BY rel
ORDER BY num_relaciones DESC;

SELECT '✅ BÚSQUEDA COMPLETA FINALIZADA' as resultado;
