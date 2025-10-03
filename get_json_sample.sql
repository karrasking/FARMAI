SELECT jsonb_pretty("Json") FROM "MedicamentoDetalleRaw" 
WHERE "NRegistro" = '66393' 
OR "NRegistro" IN (SELECT "NRegistro" FROM "MedicamentoDetalleRaw" WHERE jsonb_typeof("Json") = 'object' LIMIT 1);
