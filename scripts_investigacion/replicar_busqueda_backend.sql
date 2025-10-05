-- Replicar EXACTAMENTE la búsqueda del backend para "cafeina"
-- Esta es la query que Entity Framework debería generar

-- Buscamos si 60605 aparece con esta lógica
SELECT 
    m."NRegistro",
    m."Nombre",
    m."LabTitular",
    
    -- ¿Match por nombre?
    CASE WHEN m."Nombre" ILIKE '%cafeina%' THEN 'SI-NOMBRE' ELSE 'NO' END as match_nombre,
    
    -- ¿Match por laboratorio?
    CASE WHEN m."LabTitular" ILIKE '%cafeina%' THEN 'SI-LAB' ELSE 'NO' END as match_lab,
    
    -- ¿Match por N°Registro?
    CASE WHEN m."NRegistro" LIKE '%cafeina%' THEN 'SI-NREG' ELSE 'NO' END as match_nregistro,
    
    -- ¿Match por CN (Presentaciones)?
    CASE WHEN EXISTS (
        SELECT 1 
        FROM "MedicamentoPresentacion" mp
        JOIN "Presentacion" p ON mp."CN" = p."CN"
        WHERE mp."NRegistro" = m."NRegistro"
          AND p."CN" LIKE '%cafeina%'
    ) THEN 'SI-CN' ELSE 'NO' END as match_cn,
    
    -- ¿Match por Principio Activo?
    CASE WHEN EXISTS (
        SELECT 1
        FROM "MedicamentoSustancia" ms
        JOIN "SustanciaActiva" sa ON ms."SustanciaId" = sa."Id"
        WHERE ms."NRegistro" = m."NRegistro"
          AND sa."Nombre" ILIKE '%cafeina%'
    ) THEN 'SI-PA' ELSE 'NO' END as match_pa,
    
    -- ¿Match por Excipiente?
    CASE WHEN EXISTS (
        SELECT 1
        FROM "MedicamentoExcipiente" me
        JOIN "Excipiente" e ON me."ExcipienteId" = e."Id"
        WHERE me."NRegistro" = m."NRegistro"
          AND e."Nombre" ILIKE '%cafeina%'
    ) THEN 'SI-EXC' ELSE 'NO' END as match_exc,
    
    -- ¿Match por Biomarcador?
    CASE WHEN EXISTS (
        SELECT 1
        FROM "MedicamentoBiomarcador" mb
        JOIN "Biomarcador" b ON mb."BiomarcadorId" = b."Id"
        WHERE mb."NRegistro" = m."NRegistro"
          AND b."Nombre" ILIKE '%cafeina%'
    ) THEN 'SI-BIO' ELSE 'NO' END as match_biomarcador

FROM "Medicamentos" m
WHERE m."NRegistro" = '60605';

-- Si alguno de estos campos es "SI-*", eso explicaría por qué aparece en búsqueda
