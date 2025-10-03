\set ON_ERROR_STOP on
SET search_path TO public;

-- Graph: consultas típicas
CREATE INDEX IF NOT EXISTS ge_src_med_pres
  ON graph_edge (src_type, rel, src_key)
  WHERE src_type='Medicamento' AND rel='TIENE_PRESENTACION' AND dst_type='Presentacion';

CREATE INDEX IF NOT EXISTS ge_dst_pres_med
  ON graph_edge (dst_type, rel, dst_key)
  WHERE dst_type='Presentacion' AND rel='TIENE_PRESENTACION' AND src_type='Medicamento';

CREATE INDEX IF NOT EXISTS ge_src_dcpf_dcp
  ON graph_edge (src_type, rel, src_key)
  WHERE src_type='DCPF' AND rel='PERTENECE_A_DCP';

CREATE INDEX IF NOT EXISTS ge_src_dcp_dcsa
  ON graph_edge (src_type, rel, src_key)
  WHERE src_type='DCP' AND rel='PERTENECE_A_DCSA';

-- Diccionarios
CREATE INDEX IF NOT EXISTS idx_dcpdic_dcp   ON "DcpDicStaging"("CodigoDcp");
CREATE INDEX IF NOT EXISTS idx_dcpdic_dcsa  ON "DcpDicStaging"("CodigoDcsa");
CREATE INDEX IF NOT EXISTS idx_dcpfdic_dcpf ON "DcpfDicStaging"("CodigoDcpf");
CREATE INDEX IF NOT EXISTS idx_dcpfdic_dcp  ON "DcpfDicStaging"("CodigoDcp");
CREATE INDEX IF NOT EXISTS idx_dcsadic_dcsa ON "DcsaDicStaging"("CodigoDcsa");

-- Prescripción (joins rápidos)
CREATE INDEX IF NOT EXISTS idx_presc_codnacion ON "PrescripcionStaging_NUEVA"("CodNacion");
CREATE INDEX IF NOT EXISTS idx_presc_nreg      ON "PrescripcionStaging_NUEVA"("NRegistro");
CREATE INDEX IF NOT EXISTS idx_presc_codes     ON "PrescripcionStaging_NUEVA"("CodDcp","CodDcpf","CodDcsa");
