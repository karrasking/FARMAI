-- ============================================================
-- CONTEO DE REGISTROS DE TODAS LAS TABLAS
-- Para mapear completamente el flujo de datos
-- ============================================================

-- Tablas principales
SELECT 'Medicamentos' as tabla, COUNT(*) as registros FROM "Medicamentos";
SELECT 'Presentacion' as tabla, COUNT(*) as registros FROM "Presentacion";
SELECT 'graph_node' as tabla, COUNT(*) as registros FROM graph_node;
SELECT 'graph_edge' as tabla, COUNT(*) as registros FROM graph_edge;

-- Tablas de relaciones
SELECT 'MedicamentoAtc' as tabla, COUNT(*) as registros FROM "MedicamentoAtc";
SELECT 'MedicamentoSustancia' as tabla, COUNT(*) as registros FROM "MedicamentoSustancia";
SELECT 'MedicamentoExcipiente' as tabla, COUNT(*) as registros FROM "MedicamentoExcipiente";
SELECT 'MedicamentoBiomarcador' as tabla, COUNT(*) as registros FROM "MedicamentoBiomarcador";
SELECT 'MedicamentoVia' as tabla, COUNT(*) as registros FROM "MedicamentoVia";
SELECT 'MedicamentoPresentacion' as tabla, COUNT(*) as registros FROM "MedicamentoPresentacion";

-- Staging
SELECT 'PrescripcionStaging' as tabla, COUNT(*) as registros FROM "PrescripcionStaging";
SELECT 'PrescripcionStaging_NUEVA' as tabla, COUNT(*) as registros FROM "PrescripcionStaging_NUEVA";
SELECT 'PrescripcionStaging_NUEVO' as tabla, COUNT(*) as registros FROM "PrescripcionStaging_NUEVO";
SELECT 'PrincipioActivoStaging' as tabla, COUNT(*) as registros FROM "PrincipioActivoStaging";
SELECT 'PresentacionContenidoStaging' as tabla, COUNT(*) as registros FROM "PresentacionContenidoStaging";

-- Diccionarios
SELECT 'AtcDicStaging' as tabla, COUNT(*) as registros FROM "AtcDicStaging";
SELECT 'DcpDicStaging' as tabla, COUNT(*) as registros FROM "DcpDicStaging";
SELECT 'DcpfDicStaging' as tabla, COUNT(*) as registros FROM "DcpfDicStaging";
SELECT 'DcsaDicStaging' as tabla, COUNT(*) as registros FROM "DcsaDicStaging";
SELECT 'LaboratoriosDicStaging' as tabla, COUNT(*) as registros FROM "LaboratoriosDicStaging";

-- Entidades
SELECT 'Atc' as tabla, COUNT(*) as registros FROM "Atc";
SELECT 'SustanciaActiva' as tabla, COUNT(*) as registros FROM "SustanciaActiva";
SELECT 'Excipiente' as tabla, COUNT(*) as registros FROM "Excipiente";
SELECT 'Laboratorio' as tabla, COUNT(*) as registros FROM "Laboratorio";
SELECT 'Biomarcador' as tabla, COUNT(*) as registros FROM "Biomarcador";
SELECT 'Documento' as tabla, COUNT(*) as registros FROM "Documento";
SELECT 'Vtm' as tabla, COUNT(*) as registros FROM "Vtm";

-- Aliases
SELECT 'AliasBiomarcador' as tabla, COUNT(*) as registros FROM "AliasBiomarcador";
SELECT 'AliasExcipiente' as tabla, COUNT(*) as registros FROM "AliasExcipiente";
SELECT 'AliasSustancia' as tabla, COUNT(*) as registros FROM "AliasSustancia";

-- Temporales y mapeo
SELECT 'AtcXmlTemp' as tabla, COUNT(*) as registros FROM "AtcXmlTemp";
SELECT 'PrincipiosActivosXmlTemp' as tabla, COUNT(*) as registros FROM "PrincipiosActivosXmlTemp";
SELECT 'pa_unmatched' as tabla, COUNT(*) as registros FROM pa_unmatched;
SELECT 'pa_map' as tabla, COUNT(*) as registros FROM pa_map;

-- Info adicional
SELECT 'LaboratorioInfo' as tabla, COUNT(*) as registros FROM "LaboratorioInfo";
SELECT 'Foto' as tabla, COUNT(*) as registros FROM "Foto";
SELECT 'Outbox' as tabla, COUNT(*) as registros FROM "Outbox";
