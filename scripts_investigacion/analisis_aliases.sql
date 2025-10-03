-- Análisis de tablas de aliases
SELECT COUNT(*) as alias_biomarcador FROM "AliasBiomarcador";
SELECT COUNT(*) as alias_excipiente FROM "AliasExcipiente";
SELECT COUNT(*) as alias_sustancia FROM "AliasSustancia";

-- Ejemplos
SELECT * FROM "AliasBiomarcador" LIMIT 3;
SELECT * FROM "AliasExcipiente" LIMIT 3;
SELECT * FROM "AliasSustancia" LIMIT 3;
