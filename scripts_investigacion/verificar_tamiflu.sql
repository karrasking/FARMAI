-- Verificar TAMIFLU y sus laboratorios
SELECT 
    m."NRegistro",
    m."Nombre",
    m."LabTitular",
    m."LaboratorioTitularId",
    lt."Nombre" as "LaboratorioTitular_Nombre",
    m."LaboratorioComercializadorId",
    lc."Nombre" as "LaboratorioComercializador_Nombre"
FROM "Medicamentos" m
LEFT JOIN "Laboratorio" lt ON lt."Id" = m."LaboratorioTitularId"
LEFT JOIN "Laboratorio" lc ON lc."Id" = m."LaboratorioComercializadorId"
WHERE UPPER(m."Nombre") LIKE '%TAMIFLU%'
ORDER BY m."Nombre";
