-- pc_from_prescripcion.sql (DML-ONLY)
-- 1) Presentacion desde PrescripcionStaging_NUEVA
INSERT INTO "Presentacion" ("CN","Nombre")
SELECT DISTINCT p."CodNacion",
       COALESCE(NULLIF(p."DesPrese",''), NULLIF(p."DesNomco",''))
FROM "PrescripcionStaging_NUEVA" p
LEFT JOIN "Presentacion" pr ON pr."CN" = p."CodNacion"
WHERE pr."CN" IS NULL
  AND p."CodNacion" IS NOT NULL
  AND COALESCE(NULLIF(p."DesPrese",''), NULLIF(p."DesNomco",'')) IS NOT NULL;

-- 2) Staging de contenido
INSERT INTO "PresentacionContenidoStaging"
  ("CN","Secuencia","EnvaseId","Envase","CantidadRaw","CantidadNum","UnidadId","Unidad","Notas")
SELECT
  p."CodNacion", 1,
  CASE WHEN trim(COALESCE(p."CodEnvase"::text,'')) ~ '^[0-9]+$' THEN p."CodEnvase"::int END,
  ed."Nombre",
  NULLIF(trim(COALESCE(p."Contenido"::text,'')),''),
  CASE WHEN regexp_replace(COALESCE(p."Contenido"::text,''),'\s+','','g') ~ '^[0-9]+([.,][0-9]+)?$'
       THEN replace(regexp_replace(p."Contenido"::text,'\s+','','g'),',','.')::numeric END,
  CASE WHEN trim(COALESCE(p."UnidadContenidoCodigo"::text,'')) ~ '^[0-9]+$' THEN p."UnidadContenidoCodigo"::int END,
  uc."Nombre",
  NULL
FROM "PrescripcionStaging_NUEVA" p
LEFT JOIN "EnvaseDicStaging" ed ON ed."Id" = CASE WHEN trim(COALESCE(p."CodEnvase"::text,'')) ~ '^[0-9]+$' THEN p."CodEnvase"::int END
LEFT JOIN "UnidadContenidoDicStaging" uc ON uc."Id" = CASE WHEN trim(COALESCE(p."UnidadContenidoCodigo"::text,'')) ~ '^[0-9]+$' THEN p."UnidadContenidoCodigo"::int END
WHERE p."CodNacion" IS NOT NULL
ON CONFLICT ("CN","Secuencia") DO UPDATE SET
  "EnvaseId"    = COALESCE(EXCLUDED."EnvaseId","PresentacionContenidoStaging"."EnvaseId"),
  "Envase"      = COALESCE(EXCLUDED."Envase","PresentacionContenidoStaging"."Envase"),
  "CantidadRaw" = COALESCE(EXCLUDED."CantidadRaw","PresentacionContenidoStaging"."CantidadRaw"),
  "CantidadNum" = COALESCE(EXCLUDED."CantidadNum","PresentacionContenidoStaging"."CantidadNum"),
  "UnidadId"    = COALESCE(EXCLUDED."UnidadId","PresentacionContenidoStaging"."UnidadId"),
  "Unidad"      = COALESCE(EXCLUDED."Unidad","PresentacionContenidoStaging"."Unidad"),
  "Notas"       = COALESCE(EXCLUDED."Notas","PresentacionContenidoStaging"."Notas");

-- 3) Volcado a final
INSERT INTO "PresentacionContenido"
  ("CN","Secuencia","EnvaseId","Envase","CantidadRaw","CantidadNum","UnidadId","Unidad","Notas")
SELECT "CN","Secuencia","EnvaseId","Envase","CantidadRaw","CantidadNum","UnidadId","Unidad","Notas"
FROM "PresentacionContenidoStaging"
ON CONFLICT ("CN","Secuencia") DO UPDATE SET
  "EnvaseId"=EXCLUDED."EnvaseId","Envase"=EXCLUDED."Envase",
  "CantidadRaw"=EXCLUDED."CantidadRaw","CantidadNum"=EXCLUDED."CantidadNum",
  "UnidadId"=EXCLUDED."UnidadId","Unidad"=EXCLUDED."Unidad","Notas"=EXCLUDED."Notas";
