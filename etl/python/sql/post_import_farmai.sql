BEGIN;

-- 0) Extensiones (idempotente)
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 1) Índices útiles (idempotentes)
CREATE INDEX IF NOT EXISTS idx_medicamentos_nombre_trgm
  ON "Medicamentos" USING gin ("Nombre" gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_medicamentos_labtitular_trgm
  ON "Medicamentos" USING gin ("LabTitular" gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_presc_nregistro
  ON "PrescripcionStaging_NUEVA"("NRegistro");
CREATE INDEX IF NOT EXISTS idx_presc_lab_tit
  ON "PrescripcionStaging_NUEVA"("LabTitularCodigo");
CREATE INDEX IF NOT EXISTS idx_presc_lab_com
  ON "PrescripcionStaging_NUEVA"("LabComercializadorCodigo");

-- 2) Vista de mapeo CIMA(JSON) -> Diccionario Prescripción (por nombre normalizado)
CREATE OR REPLACE VIEW "ViaAdminMap" AS
WITH json_map AS (
  SELECT DISTINCT (x->>'id')::int AS "IdJson",
         MIN(x->>'nombre')       AS "NombreCanon"
  FROM "MedicamentoDetalleRaw" d
  CROSS JOIN LATERAL jsonb_array_elements(d."Json"->'viasAdministracion') x
  WHERE d."Json" ? 'viasAdministracion'
  GROUP BY 1
)
SELECT jm."IdJson", v."Id" AS "IdDic", jm."NombreCanon"
FROM json_map jm
LEFT JOIN "ViaAdministracionDicStaging" v
  ON unaccent(upper(v."Nombre")) = unaccent(upper(jm."NombreCanon"));

-- 3) Tabla persistente de mapeo CIMA→IdPresc (upsert, por si cambian nombres)
CREATE TABLE IF NOT EXISTS "ViaAdministracionMap"(
  "IdCima"      int  PRIMARY KEY,
  "IdPresc"     int,
  "NombreCanon" text NOT NULL
);
INSERT INTO "ViaAdministracionMap"("IdCima","IdPresc","NombreCanon")
SELECT "IdJson","IdDic","NombreCanon" FROM "ViaAdminMap"
ON CONFLICT ("IdCima") DO UPDATE
SET "IdPresc" = EXCLUDED."IdPresc",
    "NombreCanon" = EXCLUDED."NombreCanon";

-- 4) Flags (receta, genérico, triángulo, conducción) → Medicamentos
ALTER TABLE "Medicamentos"
  ADD COLUMN IF NOT EXISTS "TrianguloNegro" bool,
  ADD COLUMN IF NOT EXISTS "AfectaConduccion" bool;

UPDATE "Medicamentos" m
SET "Receta"           = ps."SwReceta",
    "Generico"         = ps."SwGenerico",
    "TrianguloNegro"   = ps."SwTrianguloNegro",
    "AfectaConduccion" = ps."SwAfectaConduccion"
FROM "PrescripcionStaging_NUEVA" ps
WHERE ps."NRegistro" = m."NRegistro";

-- 5) Laboratorios (requiere mapping actualizado en "LaboratorioCodigoAemps")
UPDATE "Medicamentos" m
SET "LaboratorioTitularId" = lca_t."LabId"
FROM "PrescripcionStaging_NUEVA" ps
JOIN "LaboratorioCodigoAemps" lca_t ON lca_t."Codigo" = ps."LabTitularCodigo"
WHERE m."NRegistro" = ps."NRegistro"
  AND m."LaboratorioTitularId" IS DISTINCT FROM lca_t."LabId";

UPDATE "Medicamentos" m
SET "LaboratorioComercializadorId" = lca_c."LabId"
FROM "PrescripcionStaging_NUEVA" ps
JOIN "LaboratorioCodigoAemps" lca_c ON lca_c."Codigo" = ps."LabComercializadorCodigo"
WHERE m."NRegistro" = ps."NRegistro"
  AND m."LaboratorioComercializadorId" IS DISTINCT FROM lca_c."LabId";

-- 6) Reconstruir MedicamentoVia desde CIMA (autoridad) con el mapa CIMA→IdPresc
CREATE TEMP TABLE _tmp_mv AS
SELECT d."NRegistro", vm."IdPresc"::int AS "ViaId"
FROM "MedicamentoDetalleRaw" d
JOIN LATERAL jsonb_array_elements(d."Json"->'viasAdministracion') x ON TRUE
JOIN "ViaAdministracionMap" vm ON vm."IdCima" = (x->>'id')::int
WHERE d."Json" ? 'viasAdministracion'
  AND vm."IdPresc" IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux__tmp_mv ON _tmp_mv("NRegistro","ViaId");

-- Reemplazo idempotente
TRUNCATE "MedicamentoVia";
INSERT INTO "MedicamentoVia"("NRegistro","ViaId")
SELECT "NRegistro","ViaId" FROM _tmp_mv;
DROP TABLE _tmp_mv;

-- Garantizar unicidad en destino
CREATE UNIQUE INDEX IF NOT EXISTS ux_medicamentovia_nreg_via
  ON "MedicamentoVia"("NRegistro","ViaId");

-- 7) OVERRIDES (si existen): traducir ViaId CIMA→IdPresc y añadir solo faltantes
UPDATE "MedicamentoViaOverrides" o
SET "ViaId" = vm."IdPresc"
FROM "ViaAdministracionMap" vm
WHERE vm."IdCima" = o."ViaId"
  AND vm."IdPresc" IS NOT NULL
  AND o."ViaId" <> vm."IdPresc";

INSERT INTO "MedicamentoVia"("NRegistro","ViaId")
SELECT o."NRegistro", o."ViaId"
FROM "MedicamentoViaOverrides" o
LEFT JOIN "MedicamentoVia" mv
  ON mv."NRegistro" = o."NRegistro" AND mv."ViaId" = o."ViaId"
WHERE mv."NRegistro" IS NULL;

-- 8) Grafo: regenerar aristas (idempotente)
DELETE FROM graph_edge WHERE rel IN ('LAB_TITULAR','LAB_COMERCIALIZA','SE_ADMINISTRA_POR');

INSERT INTO graph_edge (src_type,src_key,rel,dst_type,dst_key,props)
SELECT 'Medicamento', m."NRegistro", 'LAB_TITULAR', 'Laboratorio',
       m."LaboratorioTitularId"::text, '{}'::jsonb
FROM "Medicamentos" m
WHERE m."LaboratorioTitularId" IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO graph_edge (src_type,src_key,rel,dst_type,dst_key,props)
SELECT 'Medicamento', m."NRegistro", 'LAB_COMERCIALIZA', 'Laboratorio',
       m."LaboratorioComercializadorId"::text, '{}'::jsonb
FROM "Medicamentos" m
WHERE m."LaboratorioComercializadorId" IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO graph_edge (src_type,src_key,rel,dst_type,dst_key,props)
SELECT 'Medicamento', mv."NRegistro", 'SE_ADMINISTRA_POR', 'ViaAdministracion',
       mv."ViaId"::text, '{}'::jsonb
FROM "MedicamentoVia" mv
ON CONFLICT DO NOTHING;

-- Índices de grafo (idempotentes)
CREATE INDEX IF NOT EXISTS idx_graph_edge_rel_src ON graph_edge (rel, src_type, src_key);
CREATE INDEX IF NOT EXISTS idx_graph_edge_rel_dst ON graph_edge (rel, dst_type, dst_key);

COMMIT;

-- ======================
-- QA / Validación rápida
-- ======================

-- A) Todos los ids de vía de CIMA tienen match textual (→ 0)
WITH json_map AS (
  SELECT DISTINCT (x->>'id')::int AS id, MIN(x->>'nombre') AS nombre
  FROM "MedicamentoDetalleRaw" d
  CROSS JOIN LATERAL jsonb_array_elements(d."Json"->'viasAdministracion') x
  WHERE d."Json" ? 'viasAdministracion'
  GROUP BY 1
)
SELECT COUNT(*) FILTER (
  WHERE NOT EXISTS (
    SELECT 1 FROM "ViaAdministracionDicStaging" v
    WHERE unaccent(upper(v."Nombre")) = unaccent(upper(json_map.nombre))
  )
) AS ids_sin_match
FROM json_map;

-- B) “ORAL” en texto sin vía ORAL (excluyendo utensilios/mixtas/bucal/liofilizado) (→ 0)
SELECT COUNT(*) AS orales_mal_rotuladas
FROM (
  SELECT DISTINCT mp."NRegistro"
  FROM "MedicamentoPresentacion" mp
  JOIN "Presentacion" p ON p."CN"=mp."CN"
  JOIN "MedicamentoVia" mv ON mv."NRegistro"=mp."NRegistro"
  JOIN "ViaAdministracionDicStaging" vd ON vd."Id"=mv."ViaId"
  WHERE unaccent(upper(p."Nombre")) ~* '\mORAL\M'
    AND unaccent(upper(p."Nombre")) !~* '(JERINGA|APLICADOR|DOSIFICADOR|TUBO)'
    AND unaccent(upper(p."Nombre")) !~* 'ORAL\s*(Y|/)\s*RECTAL'
    AND unaccent(upper(p."Nombre")) !~* 'LIOFILIZADO\s+ORAL'
    AND unaccent(upper(p."Nombre")) !~* '\mBUCAL\M'
) t
WHERE NOT EXISTS (
  SELECT 1
  FROM "MedicamentoVia" mv2
  JOIN "ViaAdministracionDicStaging" vd2 ON vd2."Id"=mv2."ViaId"
  WHERE mv2."NRegistro"=t."NRegistro"
    AND unaccent(upper(vd2."Nombre")) ~* '\mORAL\M'
);

-- C) Mapa CIMA→IdPresc sin resolver (→ 0 filas)
SELECT "IdCima","NombreCanon"
FROM "ViaAdministracionMap"
WHERE "IdPresc" IS NULL;

-- D) (Opcional) Códigos de lab usados en prescripción sin mapping (→ 0 filas)
WITH used AS (
  SELECT DISTINCT c AS codigo FROM (
    SELECT "LabTitularCodigo" AS c FROM "PrescripcionStaging_NUEVA" WHERE "LabTitularCodigo" IS NOT NULL
    UNION
    SELECT "LabComercializadorCodigo" FROM "PrescripcionStaging_NUEVA" WHERE "LabComercializadorCodigo" IS NOT NULL
  ) z
)
SELECT u.codigo
FROM used u LEFT JOIN "LaboratorioCodigoAemps" m ON m."Codigo"=u.codigo
WHERE m."Codigo" IS NULL
ORDER BY 1;
