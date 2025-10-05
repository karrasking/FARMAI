-- Verificar estado después del backfill

-- 1. Total con JSON
SELECT 
    'Total medicamentos con JSON' as metrica,
    COUNT(*) as cantidad
FROM "MedicamentoDetalleRaw";

-- 2. Ver tabla MedicamentoDetalleNotFound (los que no se pudieron obtener)
SELECT 
    'Medicamentos NO encontrados en CIMA' as metrica,
    COUNT(*) as cantidad
FROM "MedicamentoDetalleNotFound";

-- 3. Comparar con total de medicamentos
SELECT 
    'Total medicamentos en tabla Medicamentos' as metrica,
    COUNT(*) as cantidad
FROM "Medicamentos";

-- 4. Medicamentos CON docs en su JSON
SELECT 
    'Medicamentos con docs en JSON' as metrica,
    COUNT(*) as cantidad
FROM "Medicamentos"
WHERE "RawJson"::text LIKE '%"docs"%';

-- 5. Ver el último SyncRun
SELECT 
    "Id",
    "Kind",
    "StartedAt",
    "FinishedAt",
    "Ok",
    "ApiCalls",
    "Found",
    "Changed",
    "Unchanged"
FROM "SyncRun"
ORDER BY "Id" DESC
LIMIT 3;
