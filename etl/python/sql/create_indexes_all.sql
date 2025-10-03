\set ON_ERROR_STOP on
SET search_path TO public;

-- Diccionarios (DCP/DCPF/DCSA)
CREATE INDEX IF NOT EXISTS idx_dcpdic_dcp   ON "DcpDicStaging"("CodigoDcp");
CREATE INDEX IF NOT EXISTS idx_dcpdic_dcsa  ON "DcpDicStaging"("CodigoDcsa");
CREATE INDEX IF NOT EXISTS idx_dcpfdic_dcpf ON "DcpfDicStaging"("CodigoDcpf");
CREATE INDEX IF NOT EXISTS idx_dcpfdic_dcp  ON "DcpfDicStaging"("CodigoDcp");
CREATE INDEX IF NOT EXISTS idx_dcsadic_dcsa ON "DcsaDicStaging"("CodigoDcsa");

-- Prescripción (joins y filtros típicos)
CREATE INDEX IF NOT EXISTS idx_presc_codnacion ON "PrescripcionStaging_NUEVA"("CodNacion");
CREATE INDEX IF NOT EXISTS idx_presc_nreg      ON "PrescripcionStaging_NUEVA"("NRegistro");
CREATE INDEX IF NOT EXISTS idx_presc_codes     ON "PrescripcionStaging_NUEVA"("CodDcp","CodDcpf","CodDcsa");

-- Presentaciones
CREATE UNIQUE INDEX IF NOT EXISTS ux_presentacion_cn        ON "Presentacion"("CN");
CREATE UNIQUE INDEX IF NOT EXISTS ux_pc_final               ON "PresentacionContenido"("CN","Secuencia");
CREATE INDEX IF NOT EXISTS     idx_pc_envaseid              ON "PresentacionContenido"("EnvaseId");
CREATE INDEX IF NOT EXISTS     idx_pc_unidadid              ON "PresentacionContenido"("UnidadId");

-- Grafo (parciales orientadas a consultas)
CREATE INDEX IF NOT EXISTS ge_med_pres_src
  ON graph_edge (src_type, rel, src_key)
  WHERE src_type='Medicamento' AND rel='TIENE_PRESENTACION' AND dst_type='Presentacion';

CREATE INDEX IF NOT EXISTS ge_pres_med_dst
  ON graph_edge (dst_type, rel, dst_key)
  WHERE dst_type='Presentacion' AND rel='TIENE_PRESENTACION' AND src_type='Medicamento';

CREATE INDEX IF NOT EXISTS ge_med_exc_src
  ON graph_edge (src_type, rel, src_key)
  WHERE src_type='Medicamento' AND dst_type='Excipiente' AND rel='CONTINE_EXCIPIENTE';

CREATE INDEX IF NOT EXISTS ge_pres_env_src
  ON graph_edge (src_type, rel, src_key)
  WHERE src_type='Presentacion' AND rel='USA_ENVASE' AND dst_type='Envase';

CREATE INDEX IF NOT EXISTS ge_pres_uni_src
  ON graph_edge (src_type, rel, src_key)
  WHERE src_type='Presentacion' AND rel='TIENE_UNIDAD' AND dst_type='UnidadContenido';

CREATE INDEX IF NOT EXISTS ge_dcpf_dcp_src
  ON graph_edge (src_type, rel, src_key)
  WHERE src_type='DCPF' AND rel='PERTENECE_A_DCP' AND dst_type='DCP';

CREATE INDEX IF NOT EXISTS ge_dcp_dcsa_src
  ON graph_edge (src_type, rel, src_key)
  WHERE src_type='DCP' AND rel='PERTENECE_A_DCSA' AND dst_type='DCSA';
