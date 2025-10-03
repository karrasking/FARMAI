SET search_path TO public;
INSERT INTO "PresentacionContenido"
("CN","Secuencia","EnvaseId","Envase","CantidadRaw","CantidadNum","UnidadId","Unidad","Notas")
SELECT p."CN", 1, NULL,NULL,NULL,NULL,NULL,NULL,NULL
FROM "Presentacion" p
LEFT JOIN "PresentacionContenido" pc USING ("CN")
WHERE pc."CN" IS NULL
ON CONFLICT ("CN","Secuencia") DO NOTHING;
