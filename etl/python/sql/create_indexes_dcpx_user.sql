\set ON_ERROR_STOP on
SET search_path TO public;
-- Diccionarios
CREATE INDEX IF NOT EXISTS idx_dcpdic_dcp   ON "DcpDicStaging"("CodigoDcp");
CREATE INDEX IF NOT EXISTS idx_dcpdic_dcsa  ON "DcpDicStaging"("CodigoDcsa");
CREATE INDEX IF NOT EXISTS idx_dcpfdic_dcpf ON "DcpfDicStaging"("CodigoDcpf");
CREATE INDEX IF NOT EXISTS idx_dcpfdic_dcp  ON "DcpfDicStaging"("CodigoDcp");
CREATE INDEX IF NOT EXISTS idx_dcsadic_dcsa ON "DcsaDicStaging"("CodigoDcsa");
-- Prescripción
CREATE INDEX IF NOT EXISTS idx_presc_codnacion ON "PrescripcionStaging_NUEVA"("CodNacion");
CREATE INDEX IF NOT EXISTS idx_presc_nreg      ON "PrescripcionStaging_NUEVA"("NRegistro");
CREATE INDEX IF NOT EXISTS idx_presc_codes     ON "PrescripcionStaging_NUEVA"("CodDcp","CodDcpf","CodDcsa");
