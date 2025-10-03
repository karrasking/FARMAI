-- ============================================================
-- EXTRACCION COMPLETA Y EXHAUSTIVA - IBUPROFENO CINFA 600 mg
-- Muestra TODO el contenido, no solo conteos
-- ============================================================

\echo '========================================='
\echo '1. INFORMACION BASICA'
\echo '========================================='
SELECT 
    "NRegistro",
    "Nombre",
    "Dosis",
    "Generico",
    "Receta",
    "Comercializado",
    "FechaAutorizacion"::date,
    "AfectaConduccion",
    "TrianguloNegro",
    "Huerfano",
    "Biosimilar"
FROM "Medicamentos"
WHERE "Nombre" ILIKE '%IBUPROFENO%CINFA%600%'
LIMIT 1;

\echo ''
\echo '========================================='
\echo '2. PRESENTACIONES COMPLETAS CON ENVASES'
\echo '========================================='
SELECT 
    p."CN" as codigo_nacional,
    p."Nombre" as presentacion_completa,
    pc."Contenido" as cantidad,
    pc."NroConte" as numero_unidades,
    u."Nombre" as tipo_unidad,
    e."Nombre" as tipo_envase,
    sr."Descripcion" as situacion_registro
FROM "Medicamentos" m
JOIN "MedicamentoPresentacion" mp ON m."NRegistro" = mp."NRegistro"
JOIN "Presentacion" p ON mp."CN" = p."CN"
LEFT JOIN "PresentacionContenido" pc ON p."CN" = pc."CN"
LEFT JOIN "UnidadContenidoDicStaging" u ON pc."UnidadId" = u."Id"
LEFT JOIN "EnvaseDicStaging" e ON pc."EnvaseId" = e."Id"
LEFT JOIN "SituacionRegistroDicStaging" sr ON p."SituacionRegistroId" = sr."Id"
WHERE m."Nombre" ILIKE '%IBUPROFENO%CINFA%600%';

\echo ''
\echo '========================================='
\echo '3. PRINCIPIOS ACTIVOS DETALLADOS'
\echo '========================================='
SELECT 
    sa."Nombre" as principio_activo,
    ms."Cantidad",
    ms."Unidad",
    ms."Orden" as orden_composicion
FROM "Medicamentos" m
JOIN "MedicamentoSustancia" ms ON m."NRegistro" = ms."NRegistro"
JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
WHERE m."Nombre" ILIKE '%IBUPROFENO%CINFA%600%'
ORDER BY ms."Orden";

\echo ''
\echo '========================================='
\echo '4. TODOS LOS EXCIPIENTES'
\echo '========================================='
SELECT 
    e."Nombre" as excipiente,
    CASE 
        WHEN e."Id" IN (SELECT "Id" FROM "DictExcipienteOblig") 
        THEN 'DECLARACION OBLIGATORIA'
        ELSE 'Normal'
    END as tipo,
    CASE 
        WHEN e."Nombre" ILIKE '%LACTOSA%' THEN 'ALERTA: No apto intolerantes lactosa'
        WHEN e."Nombre" ILIKE '%ASPARTAMO%' THEN 'ALERTA: Contiene fenilalanina (fenilcetonuricos)'
        WHEN e."Nombre" ILIKE '%SACAROSA%' OR e."Nombre" ILIKE '%AZUCAR%' THEN 'ALERTA: Diabeticos considerar'
        ELSE 'Sin alertas especiales'
    END as alerta_especial
FROM "Medicamentos" m
JOIN "MedicamentoExcipiente" me ON m."NRegistro" = me."NRegistro"
JOIN "Excipiente" e ON me."ExcipienteId" = e."Id"
WHERE m."Nombre" ILIKE '%IBUPROFENO%CINFA%600%'
ORDER BY tipo DESC, e."Nombre";

\echo ''
\echo '========================================='
\echo '5. FORMA FARMACEUTICA COMPLETA'
\echo '========================================='
SELECT 
    ff."Nombre" as forma_farmaceutica,
    ffs."Nombre" as forma_simplificada,
    va."Nombre" as via_administracion
FROM "Medicamentos" m
LEFT JOIN "FormaFarmaceutica" ff ON m."FormaFarmaceuticaId" = ff."Id"
LEFT JOIN "FormaFarmaceuticaSimplificada" ffs ON m."FormaFarmaceuticaSimplificadaId" = ffs."Id"
LEFT JOIN "MedicamentoVia" mv ON m."NRegistro" = mv."NRegistro"
LEFT JOIN "ViaAdministracion" va ON mv."ViaId" = va."Id"
WHERE m."Nombre" ILIKE '%IBUPROFENO%CINFA%600%';

\echo ''
\echo '========================================='
\echo '6. CLASIFICACION ATC JERARQUICA'
\echo '========================================='
SELECT 
    a."Nivel",
    a."Codigo",
    a."Nombre" as descripcion,
    a."CodigoPadre" as codigo_padre
FROM "Medicamentos" m
JOIN "MedicamentoAtc" ma ON m."NRegistro" = ma."NRegistro"
JOIN "Atc" a ON ma."Codigo" = a."Codigo"
WHERE m."Nombre" ILIKE '%IBUPROFENO%CINFA%600%'
ORDER BY a."Nivel", a."Codigo";

\echo ''
\echo '========================================='
\echo '7. LABORATORIO COMPLETO'
\echo '========================================='
SELECT 
    'TITULAR' as tipo,
    l."Nombre" as laboratorio,
    l."Codigo" as codigo_lab
FROM "Medicamentos" m
JOIN "Laboratorio" l ON m."LaboratorioTitularId" = l."Id"
WHERE m."Nombre" ILIKE '%IBUPROFENO%CINFA%600%'
UNION ALL
SELECT 
    'COMERCIALIZADOR' as tipo,
    l."Nombre" as laboratorio,
    l."Codigo" as codigo_lab
FROM "Medicamentos" m
JOIN "Laboratorio" l ON m."LaboratorioComercializadorId" = l."Id"
WHERE m."Nombre" ILIKE '%IBUPROFENO%CINFA%600%';

\echo ''
\echo '========================================='
\echo '8. TODOS LOS FLAGS Y ESTADOS'
\echo '========================================='
SELECT 
    dst_key as flag_codigo,
    CASE dst_key
        WHEN 'GENERICO' THEN 'Medicamento generico (EFG)'
        WHEN 'COMERCIALIZADO' THEN 'Disponible en farmacias'
        WHEN 'REQUIERE_RECETA' THEN 'Necesita receta medica'
        WHEN 'SUSTITUIBLE' THEN 'Puede sustituirse por otros genericos'
        WHEN 'SERIALIZACION' THEN 'Codigo unico trazabilidad'
        WHEN 'ENVASE_CLINICO' THEN 'Disponible uso hospitalario'
        WHEN 'TIENE_EXCIP_DECL_OBLIG' THEN 'Contiene excipientes a declarar'
        WHEN 'TIENE_FOTOS' THEN 'Fotos disponibles del envase'
        ELSE dst_key
    END as descripcion_flag
FROM graph_edge
WHERE src_key = (SELECT "NRegistro" FROM "Medicamentos" WHERE "Nombre" ILIKE '%IBUPROFENO%CINFA%600%' LIMIT 1)
  AND src_type = 'Medicamento'
  AND rel = 'TIENE_FLAG'
ORDER BY dst_key;

\echo ''
\echo '========================================='
\echo '9. TODAS LAS ALERTAS GERIATRICAS'
\echo '========================================='
SELECT 
    dst_key as alerta_id,
    props->>'criterio' as criterio,
    props->>'severidad' as nivel_severidad,
    props->>'descripcion' as descripcion_completa,
    props->>'recomendacion' as recomendacion
FROM graph_edge
WHERE src_key = (SELECT "NRegistro" FROM "Medicamentos" WHERE "Nombre" ILIKE '%IBUPROFENO%CINFA%600%' LIMIT 1)
  AND src_type = 'Medicamento'
  AND rel = 'TIENE_ALERTA_GERIATRIA';

\echo ''
\echo '========================================='
\echo '10. TODOS LOS MEDICAMENTOS DUPLICADOS/EQUIVALENTES'
\echo '========================================='
SELECT 
    m2."NRegistro",
    m2."Nombre" as medicamento_equivalente,
    m2."Generico" as es_generico,
    l."Nombre" as laboratorio
FROM "Medicamentos" m1
JOIN graph_edge ge ON m1."NRegistro" = ge.src_key
JOIN "Medicamentos" m2 ON ge.dst_key = m2."NRegistro"
LEFT JOIN "Laboratorio" l ON m2."LaboratorioTitularId" = l."Id"
WHERE m1."Nombre" ILIKE '%IBUPROFENO%CINFA%600%'
  AND ge.rel = 'DUPLICIDAD_CON'
ORDER BY m2."Nombre";

\echo ''
\echo '========================================='
\echo '11. TODAS LAS INTERACCIONES (desde grafo)'
\echo '========================================='
SELECT DISTINCT
    ge.dst_key as codigo_atc_interaccion,
    a."Nombre" as medicamento_interaccion,
    a."Nivel" as nivel_atc
FROM graph_edge ge
JOIN "Atc" a ON ge.dst_key = a."Codigo"
WHERE ge.src_key = (SELECT "NRegistro" FROM "Medicamentos" WHERE "Nombre" ILIKE '%IBUPROFENO%CINFA%600%' LIMIT 1)
  AND ge.src_type = 'Medicamento'
  AND ge.rel = 'INTERACCIONA_CON'
ORDER BY a."Nivel", a."Codigo";

\echo ''
\echo '========================================='
\echo '12. DOCUMENTOS OFICIALES'
\echo '========================================='
SELECT 
    d."Tipo" as tipo_documento,
    d."Url" as url_documento,
    d."FechaActualizacion"::date as fecha_actualizacion
FROM "Medicamentos" m
JOIN "Documento" d ON m."NRegistro" = d."NRegistro"
WHERE m."Nombre" ILIKE '%IBUPROFENO%CINFA%600%'
ORDER BY d."Tipo";

\echo ''
\echo '========================================='
\echo '13. BIOMARCADORES FARMACOGENOMICOS'
\echo '========================================='
SELECT 
    b."Nombre" as gen_biomarcador,
    b."Tipo" as tipo_biomarcador,
    mb."TipoRelacion" as tipo_interaccion,
    mb."NivelEvidencia" as nivel_evidencia,
    b."Descripcion" as descripcion_gen
FROM "Medicamentos" m
JOIN "MedicamentoBiomarcador" mb ON m."NRegistro" = mb."NRegistro"
JOIN "Biomarcador" b ON mb."BiomarcadorId" = b."Id"
WHERE m."Nombre" ILIKE '%IBUPROFENO%CINFA%600%';

\echo ''
\echo '========================================='
\echo '14. NOTAS DE SEGURIDAD AEMPS'
\echo '========================================='
SELECT 
    props->>'titulo' as titulo_nota,
    props->>'tipo' as tipo_nota,
    props->>'fecha' as fecha_publicacion,
    props->>'descripcion' as descripcion,
    props->>'url' as url_nota
FROM graph_edge
WHERE src_key = (SELECT "NRegistro" FROM "Medicamentos" WHERE "Nombre" ILIKE '%IBUPROFENO%CINFA%600%' LIMIT 1)
  AND src_type = 'Medicamento'
  AND rel = 'TIENE_NOTA_SEGURIDAD';

\echo ''
\echo '========================================='
\echo '15. RESUMEN COMPLETO TODAS LAS RELACIONES'
\echo '========================================='
SELECT 
    rel as tipo_relacion,
    dst_type as tipo_destino,
    dst_key as clave_destino,
    props as propiedades_adicionales
FROM graph_edge
WHERE src_key = (SELECT "NRegistro" FROM "Medicamentos" WHERE "Nombre" ILIKE '%IBUPROFENO%CINFA%600%' LIMIT 1)
  AND src_type = 'Medicamento'
ORDER BY rel, dst_key;

\echo ''
\echo '========================================='
\echo 'EXTRACCION COMPLETA FINALIZADA'
\echo '========================================='
