-- Obtener 5 medicamentos aleatorios que NO tienen "docs" en su JSON

SELECT 
    m."NRegistro",
    m."Nombre",
    m."Comercializado",
    LENGTH(r."Json"::text) as tam_json,
    r."Json"::text LIKE '%"docs"%' as tiene_docs
FROM "Medicamentos" m
JOIN "MedicamentoDetalleRaw" r ON r."NRegistro" = m."NRegistro"
WHERE r."Json"::text NOT LIKE '%"docs"%'
  AND m."Comercializado" = true
ORDER BY RANDOM()
LIMIT 5;
