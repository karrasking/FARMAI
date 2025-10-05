-- ========================================
-- APLICACIÓN FASE 4: PROBLEMAS SUMINISTRO
-- ========================================
-- ⚠️ ESTE SCRIPT MODIFICA LA BD
-- ⚠️ REQUIERE AUTORIZACIÓN PREVIA

-- PASO 1: Crear tabla ProblemaSuministro
CREATE TABLE IF NOT EXISTS "ProblemaSuministro" (
    "Id" BIGSERIAL PRIMARY KEY,
    "CN" VARCHAR(10) NOT NULL,
    "NRegistro" VARCHAR(32),
    "FechaInicio" TIMESTAMP WITH TIME ZONE NOT NULL,
    "FechaFin" TIMESTAMP WITH TIME ZONE,
    "Activo" BOOLEAN NOT NULL DEFAULT true,
    "Observaciones" TEXT,
    "FechaCreacion" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "FechaActualizacion" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT "FK_ProblemaSuministro_Presentacion"
        FOREIGN KEY ("CN") 
        REFERENCES "Presentacion"("CN")
        ON DELETE CASCADE,
        
    CONSTRAINT "UQ_ProblemaSuministro_CN"
        UNIQUE ("CN")
);

-- PASO 2: Crear índices
CREATE INDEX IF NOT EXISTS "IX_ProblemaSuministro_CN" 
    ON "ProblemaSuministro"("CN");
    
CREATE INDEX IF NOT EXISTS "IX_ProblemaSuministro_NRegistro" 
    ON "ProblemaSuministro"("NRegistro");
    
CREATE INDEX IF NOT EXISTS "IX_ProblemaSuministro_Activo" 
    ON "ProblemaSuministro"("Activo");
    
CREATE INDEX IF NOT EXISTS "IX_ProblemaSuministro_FechaInicio" 
    ON "ProblemaSuministro"("FechaInicio" DESC);

-- PASO 3: Insertar datos desde JSON
INSERT INTO "ProblemaSuministro" 
    ("CN", "NRegistro", "FechaInicio", "FechaFin", "Activo", "Observaciones")
SELECT 
    pres->>'cn' as cn,
    mdr."NRegistro",
    to_timestamp((pres->'detalleProblemaSuministro'->>'fini')::bigint / 1000.0) as fecha_inicio,
    CASE 
        WHEN pres->'detalleProblemaSuministro'->>'ffin' IS NOT NULL
        THEN to_timestamp((pres->'detalleProblemaSuministro'->>'ffin')::bigint / 1000.0)
        ELSE NULL
    END as fecha_fin,
    (pres->'detalleProblemaSuministro'->>'activo')::boolean as activo,
    pres->'detalleProblemaSuministro'->>'observ' as observaciones
FROM "MedicamentoDetalleRaw" mdr,
jsonb_array_elements(mdr."Json"->'presentaciones') as pres
WHERE pres->'detalleProblemaSuministro' IS NOT NULL
ON CONFLICT ("CN") DO UPDATE
SET
    "NRegistro" = EXCLUDED."NRegistro",
    "FechaInicio" = EXCLUDED."FechaInicio",
    "FechaFin" = EXCLUDED."FechaFin",
    "Activo" = EXCLUDED."Activo",
    "Observaciones" = EXCLUDED."Observaciones",
    "FechaActualizacion" = NOW();

-- PASO 4: Verificar inserción
SELECT 
    'RESULTADO INSERCIÓN' as "Paso",
    COUNT(*) as "TotalProblemas",
    COUNT(*) FILTER (WHERE "Activo" = true) as "ProblemasActivos",
    COUNT(*) FILTER (WHERE "FechaFin" IS NULL) as "SinFechaFin"
FROM "ProblemaSuministro";

-- PASO 5: Ver distribución por estado
SELECT 
    "Activo",
    COUNT(*) as "Cantidad",
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as "Porcentaje"
FROM "ProblemaSuministro"
GROUP BY "Activo"
ORDER BY "Activo" DESC;

-- PASO 6: Problemas más recientes
SELECT 
    ps."CN",
    ps."NRegistro",
    m."Nombre",
    ps."FechaInicio"::date as "Inicio",
    ps."FechaFin"::date as "Fin",
    ps."Activo",
    LEFT(ps."Observaciones", 80) as "Observaciones"
FROM "ProblemaSuministro" ps
LEFT JOIN "Medicamentos" m ON m."NRegistro" = ps."NRegistro"
WHERE ps."Activo" = true
ORDER BY ps."FechaInicio" DESC
LIMIT 10;

-- PASO 7: Verificar integridad FK
SELECT 
    'Problemas con CN válido' as "Verificacion",
    COUNT(*) as "Cantidad"
FROM "ProblemaSuministro" ps
WHERE EXISTS (
    SELECT 1 FROM "Presentacion" p
    WHERE p."CN" = ps."CN"
);

-- PASO 8: Estadísticas temporales
SELECT 
    EXTRACT(YEAR FROM "FechaInicio") as "Año",
    COUNT(*) as "ProblemasIniciados",
    COUNT(*) FILTER (WHERE "Activo" = true) as "Activos"
FROM "ProblemaSuministro"
GROUP BY EXTRACT(YEAR FROM "FechaInicio")
ORDER BY "Año" DESC;
