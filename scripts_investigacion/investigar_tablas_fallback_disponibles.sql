-- Investigar qué tablas relacionales tenemos disponibles para hacer fallback
-- Objetivo: Ver qué datos podemos rescatar de tablas si el JSON falla

-- 1. Ver todas las tablas relacionadas con medicamentos
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns 
     WHERE table_name = t.table_name AND table_schema = 'public') as columnas
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_name NOT LIKE '%_backup%'
  AND table_name NOT LIKE '%_old%'
ORDER BY table_name;

-- 2. Verificar tablas para ATC
SELECT 'ATCs' as entidad, COUNT(*) as registros FROM "MedicamentoATC";
SELECT 'Tabla ATC' as info, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'MedicamentoATC' 
ORDER BY ordinal_position;

-- 3. Ver ejemplo de MedicamentoATC para el 81807
SELECT * FROM "MedicamentoATC" WHERE "NRegistro" = '81807' LIMIT 5;

-- 4. Verificar tablas para VTM
SELECT 'Tabla VTM/VMP' as info;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND (table_name ILIKE '%vtm%' OR table_name ILIKE '%vmp%');

-- 5. Verificar tablas para Vías de Administración
SELECT 'ViaAdministracion' as entidad, COUNT(*) as registros 
FROM "ViaAdministracion" WHERE true;

SELECT 'Tabla ViaAdministracion' as info, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'ViaAdministracion'
ORDER BY ordinal_position;

SELECT * FROM "ViaAdministracion" LIMIT 5;

-- 6. Verificar si existe tabla de relación Medicamento-Via
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name ILIKE '%via%';

-- 7. Verificar FormaFarmaceutica
SELECT 'FormaFarmaceutica' as entidad, COUNT(*) as registros 
FROM "FormaFarmaceutica" WHERE true;

SELECT * FROM "FormaFarmaceutica" LIMIT 5;

-- 8. Verificar Documentos
SELECT 'Documento' as entidad, COUNT(*) as registros 
FROM "Documento" WHERE true;

SELECT 'Tabla Documento' as info, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'Documento'
ORDER BY ordinal_position;

SELECT * FROM "Documento" WHERE "NRegistro" = '81807' LIMIT 3;

-- 9. Verificar Presentaciones
SELECT 'PresentacionComercial' as entidad, COUNT(*) as registros 
FROM "PresentacionComercial" WHERE true;

SELECT 'Tabla PC' as info, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'PresentacionComercial'
ORDER BY ordinal_position
LIMIT 10;

SELECT * FROM "PresentacionComercial" WHERE "NRegistro" = '81807' LIMIT 3;

-- 10. RESUMEN: ¿Qué tiene el medicamento 81807 en tablas relacionales?
SELECT 
    'Medicamento 81807' as info,
    (SELECT COUNT(*) FROM "MedicamentoSustancia" WHERE "NRegistro" = '81807') as pas,
    (SELECT COUNT(*) FROM "MedicamentoExcipiente" WHERE "NRegistro" = '81807') as excipientes,
    (SELECT COUNT(*) FROM "MedicamentoATC" WHERE "NRegistro" = '81807') as atcs,
    (SELECT COUNT(*) FROM "Documento" WHERE "NRegistro" = '81807') as documentos,
    (SELECT COUNT(*) FROM "PresentacionComercial" WHERE "NRegistro" = '81807') as presentaciones;

-- 11. Ver ejemplo completo de datos del 81807 en tablas
SELECT 'PAs del 81807:' as tipo;
SELECT s."Nombre", ms."Cantidad", ms."Unidad", ms."Orden"
FROM "MedicamentoSustancia" ms
JOIN "SustanciaActiva" s ON ms."SustanciaId" = s."Id"
WHERE ms."NRegistro" = '81807'
ORDER BY ms."Orden";

SELECT 'Excipientes del 81807:' as tipo;
SELECT e."Nombre", me."Cantidad", me."Unidad", me."Orden"
FROM "MedicamentoExcipiente" me
LEFT JOIN "Excipiente" e ON me."ExcipienteId" = e."Id"
WHERE me."NRegistro" = '81807'
ORDER BY me."Orden";
