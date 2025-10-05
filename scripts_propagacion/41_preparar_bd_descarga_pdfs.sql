-- Script para preparar BD para descarga y gestión de PDFs

-- =====================================================
-- 1. AÑADIR COLUMNAS A TABLA DOCUMENTO
-- =====================================================

-- Columnas para archivos locales
ALTER TABLE "Documento" 
ADD COLUMN IF NOT EXISTS "UrlLocal" text,
ADD COLUMN IF NOT EXISTS "LocalPath" text,
ADD COLUMN IF NOT EXISTS "FileName" text;

-- Estado de descarga
ALTER TABLE "Documento"
ADD COLUMN IF NOT EXISTS "Downloaded" boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS "DownloadedAt" timestamptz,
ADD COLUMN IF NOT EXISTS "DownloadAttempts" int DEFAULT 0,
ADD COLUMN IF NOT EXISTS "LastAttemptAt" timestamptz;

-- Metadatos del archivo
ALTER TABLE "Documento"
ADD COLUMN IF NOT EXISTS "FileHash" text,  -- SHA256 del contenido
ADD COLUMN IF NOT EXISTS "FileSize" bigint,
ADD COLUMN IF NOT EXISTS "HttpStatus" int,
ADD COLUMN IF NOT EXISTS "ErrorMessage" text;

-- =====================================================
-- 2. CREAR TABLA DE BATCHES DE DESCARGA
-- =====================================================

CREATE TABLE IF NOT EXISTS "DocumentDownloadBatch" (
    "Id" bigserial PRIMARY KEY,
    "BatchNumber" int NOT NULL,
    "StartedAt" timestamptz NOT NULL DEFAULT now(),
    "FinishedAt" timestamptz,
    "Status" text NOT NULL DEFAULT 'pending',  -- pending, running, completed, failed
    "TotalDocs" int NOT NULL,
    "Downloaded" int DEFAULT 0,
    "Failed" int DEFAULT 0,
    "Skipped" int DEFAULT 0,
    "DurationSeconds" int,
    "ErrorsJson" jsonb,
    CONSTRAINT "CK_Batch_Status" CHECK ("Status" IN ('pending', 'running', 'completed', 'failed', 'cancelled'))
);

-- =====================================================
-- 3. CREAR TABLA DE LOGS DE DESCARGA
-- =====================================================

CREATE TABLE IF NOT EXISTS "DocumentDownloadLog" (
    "Id" bigserial PRIMARY KEY,
    "BatchId" bigint REFERENCES "DocumentDownloadBatch"("Id"),
    "DocumentId" bigint REFERENCES "Documento"("Id"),
    "NRegistro" varchar(32) NOT NULL,
    "Tipo" smallint NOT NULL,
    "UrlPdf" text NOT NULL,
    "AttemptedAt" timestamptz NOT NULL DEFAULT now(),
    "Success" boolean NOT NULL,
    "HttpStatus" int,
    "FileSize" bigint,
    "DurationMs" int,
    "ErrorMessage" text,
    "RetryCount" int DEFAULT 0
);

-- Índice para búsquedas rápidas
CREATE INDEX IF NOT EXISTS "IX_DocumentDownloadLog_BatchId" 
    ON "DocumentDownloadLog"("BatchId");
CREATE INDEX IF NOT EXISTS "IX_DocumentDownloadLog_NRegistro_Tipo" 
    ON "DocumentDownloadLog"("NRegistro", "Tipo");
CREATE INDEX IF NOT EXISTS "IX_DocumentDownloadLog_Success" 
    ON "DocumentDownloadLog"("Success") WHERE "Success" = false;

-- =====================================================
-- 4. CREAR TABLA DE REINTENTOS PENDIENTES
-- =====================================================

CREATE TABLE IF NOT EXISTS "DocumentDownloadRetry" (
    "Id" bigserial PRIMARY KEY,
    "DocumentId" bigint NOT NULL REFERENCES "Documento"("Id"),
    "NRegistro" varchar(32) NOT NULL,
    "Tipo" smallint NOT NULL,
    "UrlPdf" text NOT NULL,
    "Priority" int DEFAULT 5,  -- 1=alta, 5=normal, 10=baja
    "Attempts" int DEFAULT 0,
    "MaxAttempts" int DEFAULT 3,
    "FirstFailedAt" timestamptz NOT NULL DEFAULT now(),
    "LastAttemptAt" timestamptz,
    "NextRetryAt" timestamptz,  -- Para scheduling de reintentos
    "LastError" text,
    "Status" text NOT NULL DEFAULT 'pending',  -- pending, in_progress, exhausted, manual_review
    CONSTRAINT "CK_Retry_Status" CHECK ("Status" IN ('pending', 'in_progress', 'exhausted', 'manual_review', 'resolved'))
);

-- Índices para gestión de reintentos
CREATE INDEX IF NOT EXISTS "IX_DocumentDownloadRetry_Status_NextRetry" 
    ON "DocumentDownloadRetry"("Status", "NextRetryAt") 
    WHERE "Status" = 'pending';
CREATE INDEX IF NOT EXISTS "IX_DocumentDownloadRetry_Priority" 
    ON "DocumentDownloadRetry"("Priority", "Status");

-- =====================================================
-- 5. CREAR ÍNDICES EN TABLA DOCUMENTO
-- =====================================================

CREATE INDEX IF NOT EXISTS "IX_Documento_Downloaded" 
    ON "Documento"("Downloaded") WHERE "Downloaded" = false;
CREATE INDEX IF NOT EXISTS "IX_Documento_NRegistro_Tipo" 
    ON "Documento"("NRegistro", "Tipo");
CREATE INDEX IF NOT EXISTS "IX_Documento_DownloadAttempts" 
    ON "Documento"("DownloadAttempts") 
    WHERE "DownloadAttempts" > 0 AND "Downloaded" = false;

-- =====================================================
-- 6. VISTA: DOCUMENTOS PENDIENTES DE DESCARGA
-- =====================================================

CREATE OR REPLACE VIEW "vDocumentosPendientesDescarga" AS
SELECT 
    d."Id",
    d."NRegistro",
    d."Tipo",
    CASE 
        WHEN d."Tipo" = 1 THEN 'Ficha Técnica'
        WHEN d."Tipo" = 2 THEN 'Prospecto'
        WHEN d."Tipo" = 3 THEN 'IPE'
        ELSE 'Otro'
    END as "TipoNombre",
    d."UrlPdf",
    d."DownloadAttempts",
    d."LastAttemptAt",
    d."ErrorMessage",
    m."Nombre" as "MedicamentoNombre",
    m."Comercializado"
FROM "Documento" d
JOIN "Medicamentos" m ON m."NRegistro" = d."NRegistro"
WHERE d."Downloaded" = false
ORDER BY d."DownloadAttempts", d."Id";

-- =====================================================
-- 7. VISTA: RESUMEN DE DESCARGAS
-- =====================================================

CREATE OR REPLACE VIEW "vResumenDescargas" AS
SELECT 
    COUNT(*) as "TotalDocumentos",
    COUNT(CASE WHEN "Downloaded" = true THEN 1 END) as "Descargados",
    COUNT(CASE WHEN "Downloaded" = false THEN 1 END) as "Pendientes",
    COUNT(CASE WHEN "Downloaded" = false AND "DownloadAttempts" > 0 THEN 1 END) as "ConReintentos",
    COUNT(CASE WHEN "Downloaded" = false AND "DownloadAttempts" >= 3 THEN 1 END) as "Fallidos",
    SUM("FileSize") as "TotalBytes",
    ROUND(SUM("FileSize")::numeric / 1024 / 1024, 2) as "TotalMB",
    ROUND(SUM("FileSize")::numeric / 1024 / 1024 / 1024, 2) as "TotalGB"
FROM "Documento";

-- =====================================================
-- 8. VISTA: PROGRESO POR TIPO
-- =====================================================

CREATE OR REPLACE VIEW "vProgresoDescargasPorTipo" AS
SELECT 
    "Tipo",
    CASE 
        WHEN "Tipo" = 1 THEN 'Ficha Técnica'
        WHEN "Tipo" = 2 THEN 'Prospecto'
        WHEN "Tipo" = 3 THEN 'IPE'
        ELSE 'Otro'
    END as "TipoNombre",
    COUNT(*) as "Total",
    COUNT(CASE WHEN "Downloaded" = true THEN 1 END) as "Descargados",
    COUNT(CASE WHEN "Downloaded" = false THEN 1 END) as "Pendientes",
    ROUND(100.0 * COUNT(CASE WHEN "Downloaded" = true THEN 1 END) / COUNT(*), 2) as "PorcentajeCompletado"
FROM "Documento"
GROUP BY "Tipo"
ORDER BY "Tipo";

-- =====================================================
-- 9. FUNCIÓN: GENERAR PRÓXIMO BATCH
-- =====================================================

CREATE OR REPLACE FUNCTION generar_proximo_batch(p_batch_size int DEFAULT 500)
RETURNS TABLE (
    documento_id bigint,
    nregistro varchar(32),
    tipo smallint,
    url_pdf text
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d."Id",
        d."NRegistro",
        d."Tipo",
        d."UrlPdf"
    FROM "Documento" d
    WHERE d."Downloaded" = false
      AND d."DownloadAttempts" < 3  -- Máximo 3 intentos
    ORDER BY 
        d."DownloadAttempts",  -- Primero los que no se han intentado
        d."Tipo",              -- Luego por tipo (FT primero)
        d."Id"
    LIMIT p_batch_size;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 10. FUNCIÓN: REGISTRAR DESCARGA EXITOSA
-- =====================================================

CREATE OR REPLACE FUNCTION registrar_descarga_exitosa(
    p_documento_id bigint,
    p_file_path text,
    p_file_name text,
    p_file_hash text,
    p_file_size bigint,
    p_http_status int DEFAULT 200
)
RETURNS void AS $$
BEGIN
    UPDATE "Documento"
    SET 
        "Downloaded" = true,
        "DownloadedAt" = now(),
        "LocalPath" = p_file_path,
        "FileName" = p_file_name,
        "FileHash" = p_file_hash,
        "FileSize" = p_file_size,
        "HttpStatus" = p_http_status,
        "ErrorMessage" = NULL,
        "DownloadAttempts" = "DownloadAttempts" + 1,
        "LastAttemptAt" = now()
    WHERE "Id" = p_documento_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 11. FUNCIÓN: REGISTRAR DESCARGA FALLIDA
-- =====================================================

CREATE OR REPLACE FUNCTION registrar_descarga_fallida(
    p_documento_id bigint,
    p_http_status int,
    p_error_message text
)
RETURNS void AS $$
BEGIN
    UPDATE "Documento"
    SET 
        "Downloaded" = false,
        "DownloadAttempts" = "DownloadAttempts" + 1,
        "LastAttemptAt" = now(),
        "HttpStatus" = p_http_status,
        "ErrorMessage" = p_error_message
    WHERE "Id" = p_documento_id;
    
    -- Si ya falló 3 veces, mover a tabla de reintentos
    IF (SELECT "DownloadAttempts" FROM "Documento" WHERE "Id" = p_documento_id) >= 3 THEN
        INSERT INTO "DocumentDownloadRetry" (
            "DocumentId", "NRegistro", "Tipo", "UrlPdf", 
            "Attempts", "LastError", "Status", "NextRetryAt"
        )
        SELECT 
            "Id", "NRegistro", "Tipo", "UrlPdf",
            "DownloadAttempts", p_error_message, 'pending',
            now() + interval '1 hour'  -- Reintentar en 1 hora
        FROM "Documento"
        WHERE "Id" = p_documento_id
        ON CONFLICT DO NOTHING;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 12. VERIFICAR ESTADO INICIAL
-- =====================================================

-- Ver cuántos documentos tenemos
SELECT * FROM "vResumenDescargas";

-- Ver progreso por tipo
SELECT * FROM "vProgresoDescargasPorTipo";

-- Ver primeros 10 pendientes
SELECT * FROM "vDocumentosPendientesDescarga" LIMIT 10;

-- =====================================================
-- ✅ BD PREPARADA PARA DESCARGA DE PDFs
-- =====================================================
