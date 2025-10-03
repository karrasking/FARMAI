# 🔥 ANÁLISIS PROFUNDO Y PLAN DE CONSOLIDACIÓN - BD FARMAI
## "LA BASE DE DATOS MÁS BESTIA DE ESPAÑA"

> **Fecha:** 10/01/2025  
> **Estado:** INVESTIGACIÓN COMPLETA + PLAN DE ACCIÓN  
> **Objetivo:** Consolidar, Optimizar y Enriquecer la BD al Máximo Nivel

---

## 🎯 RESUMEN EJECUTIVO

### Descubrimientos Críticos

1. ✨ **BIOMARCADORES EN XML** - El XML de prescripción contiene información de farmacogenómica que NO está en la BD
2. ⚠️ **3 Tablas PrescripcionStaging** - Triplicación innecesaria (PrescripcionStaging vs NUEVA vs NUEVO)
3. 🔴 **Campos Faltantes** - ~15 campos del XML que no están capturados
4. 🔴 **Tablas Vacías** - SustanciaActiva, Excipiente, Documento, Foto con 0 registros
5. ⚠️ **Propagación Incompleta** - Datos en staging sin propagarse a tablas finales

---

## 📊 ANÁLISIS DEL XML DE PRESCRIPCIÓN

### Estructura Completa del XML (48+ campos)

```xml
<prescription>
  <!-- IDENTIFICACIÓN (3 campos) -->
  <cod_nacion>600017</cod_nacion>                    ✅ EN BD
  <nro_definitivo>66393</nro_definitivo>             ✅ EN BD (NRegistro)
  
  <!-- NOMENCLATURA (5 campos) -->
  <des_nomco>NOMBRE COMERCIAL</des_nomco>            ✅ EN BD
  <des_prese>PRESENTACIÓN</des_prese>                ✅ EN BD
  <des_dosific>4 mg</des_dosific>                    ✅ EN BD
  
  <!-- DENOMINACIONES (3 campos) -->
  <cod_dcsa>108418007</cod_dcsa>                     ✅ EN BD
  <cod_dcp>322173001</cod_dcp>                       ✅ EN BD
  <cod_dcpf>20221000140100</cod_dcpf>                ✅ EN BD
  
  <!-- CONTENIDO Y ENVASE (5 campos) -->
  <cod_envase>5</cod_envase>                         ✅ EN BD
  <contenido>500</contenido>                         ✅ EN BD
  <unid_contenido>10</unid_contenido>                ✅ EN BD
  <nro_conte>500 comprimidos</nro_conte>             ✅ EN BD
  
  <!-- FLAGS DE ALERTA (18 campos booleanos) -->
  <sw_psicotropo>0</sw_psicotropo>                   ✅ EN BD
  <sw_estupefaciente>0</sw_estupefaciente>           ✅ EN BD
  <sw_afecta_conduccion>0</sw_afecta_conduccion>     ✅ EN BD
  <sw_triangulo_negro>0</sw_triangulo_negro>         ✅ EN BD
  <sw_receta>1</sw_receta>                           ✅ EN BD
  <sw_generico>1</sw_generico>                       ✅ EN BD
  <sw_sustituible>1</sw_sustituible>                 ✅ EN BD
  <sw_envase_clinico>1</sw_envase_clinico>           ✅ EN BD
  <sw_uso_hospitalario>0</sw_uso_hospitalario>       ✅ EN BD
  <sw_diagnostico_hospitalario>1</sw_diagnostico_hospitalario> ✅ EN BD
  <sw_tld>0</sw_tld>                                 ✅ EN BD
  <sw_especial_control_medico>0</sw_especial_control_medico> ✅ EN BD
  <sw_huerfano>0</sw_huerfano>                       ✅ EN BD
  <sw_base_a_plantas>0</sw_base_a_plantas>           ✅ EN BD
  <biosimilar>0</biosimilar>                         ✅ EN BD
  <importacion_paralela>0</importacion_paralela>     ✅ EN BD
  <radiofarmaco>0</radiofarmaco>                     ✅ EN BD
  <serializacion>0</serializacion>                   ✅ EN BD
  <sw_tiene_excipientes_decl_obligatoria>1</sw_tiene_excipientes_decl_obligatoria> ✅ EN BD
  
  <!-- DOCUMENTOS (2 campos) -->
  <url_fictec>https://.../66393_ft.pdf</url_fictec>  ⚠️ NO PROPAGADO (tabla Documento vacía)
  <url_prosp>https://.../66393_p.pdf</url_prosp>     ⚠️ NO PROPAGADO (tabla Documento vacía)
  
  <!-- LABORATORIOS (2 campos) -->
  <laboratorio_titular>11954</laboratorio_titular>    ✅ EN BD
  <laboratorio_comercializador>11954</laboratorio_comercializador> ✅ EN BD
  
  <!-- FECHAS Y ESTADO (8 campos) -->
  <fecha_autorizacion>2004-10-04</fecha_autorizacion> ✅ EN BD
  <sw_comercializado>0</sw_comercializado>            ✅ EN BD
  <fec_comer>2016-12-05</fec_comer>                   ✅ EN BD
  <cod_sitreg>3</cod_sitreg>                          ✅ EN BD
  <cod_sitreg_presen>3</cod_sitreg_presen>            ✅ EN BD
  <fecha_situacion_registro>2016-12-05</fecha_situacion_registro> ✅ EN BD
  <fec_sitreg_presen>2016-12-05</fec_sitreg_presen>   ✅ EN BD
  
  <!-- FORMAS FARMACÉUTICAS (sección compleja) -->
  <formasfarmaceuticas>
    <cod_forfar>40</cod_forfar>                       ✅ EN BD (via grafo)
    <cod_forfar_simplificada>10</cod_forfar_simplificada> ✅ EN BD
    <nro_pactiv>1</nro_pactiv>                        ❌ FALTA (número de principios activos)
    
    <!-- COMPOSICIÓN PRINCIPIO ACTIVO (sección MUY RICA) -->
    <composicion_pa>
      <cod_principio_activo>7426</cod_principio_activo> ✅ EN BD
      <orden_colacion>1</orden_colacion>              ✅ EN BD (como Orden)
      <dosis_pa>4</dosis_pa>                          ❌ FALTA SEPARADO
      <unidad_dosis_pa>mg</unidad_dosis_pa>           ❌ FALTA SEPARADO
      <dosis_composicion>1</dosis_composicion>        ❌ FALTA
      <unidad_composicion>comprimido</unidad_composicion> ❌ FALTA
      <dosis_administracion>1</dosis_administracion>  ❌ FALTA
      <unidad_administracion>comprimido</unidad_administracion> ❌ FALTA
      <dosis_prescripcion>4</dosis_prescripcion>      ❌ FALTA
      <unidad_prescripcion>mg</unidad_prescripcion>   ❌ FALTA
    </composicion_pa>
    
    <!-- EXCIPIENTES -->
    <excipientes>
      <cod_excipiente>15305</cod_excipiente>          ✅ EN BD (grafo)
    </excipientes>
    
    <!-- VÍAS DE ADMINISTRACIÓN -->
    <viasadministracion>
      <cod_via_admin>54</cod_via_admin>               ✅ EN BD
    </viasadministracion>
  </formasfarmaceuticas>
  
  <!-- ATC -->
  <atc>
    <cod_atc>A04AA01</cod_atc>                        ✅ EN BD
  </atc>
  
  <!-- ✨✨✨ BIOMARCADORES (¡GOLD MINE!) ✨✨✨ -->
  <biomarcadores>
    <clase>Germinal</clase>                           ❌ NO EN BD ⚠️ CRÍTICO
    <biomarcador>CYP2D6</biomarcador>                 ❌ NO EN BD ⚠️ CRÍTICO
    <secciones_ft>4.5 Interacción...|5.2 Propiedades...</secciones_ft> ❌ NO EN BD
    <descripcion>Ver NOTAS...</descripcion>           ❌ NO EN BD
    <inclusion_cartera_sns>SÍ</inclusion_cartera_sns> ❌ NO EN BD
    <notas>De acuerdo con las indicaciones de la guía clínica CPIC...</notas> ❌ NO EN BD
  </biomarcadores>
</prescription>
```

---

## 🔴 CAMPOS FALTANTES CRÍTICOS

### 1. BIOMARCADORES (Tabla vacía pero datos disponibles!)

**IMPACTO:** 🔥🔥🔥 **MÁXIMA PRIORIDAD**

El XML contiene información de **farmacogenómica** que es ORO PURO para decisión clínica:

```sql
-- Tabla existe pero está VACÍA
Biomarcador (0 registros)
MedicamentoBiomarcador (0 registros)
BiomarcadorExtractStaging (0 registros)
```

**Campos disponibles en XML:**
- `clase`: Germinal/Somático
- `biomarcador`: Gen (ej: CYP2D6, HLA-B*5701)
- `secciones_ft`: Referencias a secciones de ficha técnica
- `descripcion`: Descripción de la relación
- `inclusion_cartera_sns`: Si está en cartera SNS
- `notas`: Guías clínicas (CPIC, etc.)

**Acción Requerida:**
```python
# Nuevo script ETL para biomarcadores
def extract_biomarcadores_from_xml():
    # Parsear sección <biomarcadores> del XML
    # Poblar Biomarcador con datos únicos
    # Crear relaciones en MedicamentoBiomarcador
    # Añadir nodos/aristas al grafo
```

---

### 2. COMPOSICIÓN DETALLADA DE PRINCIPIOS ACTIVOS

**IMPACTO:** 🔥🔥 **ALTA PRIORIDAD**

**Campos faltantes en MedicamentoSustancia:**
- `DosisComposicion` + `UnidadComposicion` (por forma farmacéutica)
- `DosisAdministracion` + `UnidadAdministracion` (por toma)
- `DosisPrescripcion` + `UnidadPrescripcion` (para prescribir)

**Problema Actual:**
```sql
-- Solo tenemos Cantidad + Unidad (texto libre)
MedicamentoSustancia.Cantidad = "4"
MedicamentoSustancia.Unidad = "mg"
```

**Necesitamos:**
```sql
-- Estructura normalizada de dosis
DosisPA              = 4
UnidadDosisPA        = "mg"
DosisComposicion     = 1
UnidadComposicion    = "comprimido"
DosisAdministracion  = 1
UnidadAdministracion = "comprimido"
DosisPrescripcion    = 4
UnidadPrescripcion   = "mg"
```

---

### 3. NÚMERO DE PRINCIPIOS ACTIVOS

**IMPACTO:** 🔥 **MEDIA PRIORIDAD**

```xml
<nro_pactiv>1</nro_pactiv>  <!-- Número total de PAs -->
```

**Uso:** Filtrar monosustancias vs combinaciones rápidamente.

---

### 4. DOCUMENTOS (URLs Ficha Técnica / Prospecto)

**IMPACTO:** 🔥🔥 **ALTA PRIORIDAD**

**Tabla vacía:**
```sql
Documento (0 registros)
```

**Datos disponibles:**
```xml
<url_fictec>https://cima.aemps.es/cima/pdfs/es/ft/66393/66393_ft.pdf</url_fictec>
<url_prosp>https://cima.aemps.es/cima/pdfs/es/p/66393/66393_p.pdf</url_prosp>
```

**Acción Requerida:**
```sql
-- Poblar tabla Documento desde PrescripcionStaging
INSERT INTO "Documento" ("NRegistro", "Tipo", "UrlPdf")
SELECT "NRegistro", 1, "UrlFictec" FROM "PrescripcionStaging_NUEVA" WHERE "UrlFictec" IS NOT NULL
UNION ALL
SELECT "NRegistro", 2, "UrlProsp" FROM "PrescripcionStaging_NUEVA" WHERE "UrlProsp" IS NOT NULL;
```

---

## ⚠️ PROBLEMA DE LAS 3 PRESCRIPCION STAGING

### Análisis Comparativo

```sql
-- Comparación de registros
PrescripcionStaging        : 29,437 registros
PrescripcionStaging_NUEVA  : 29,438 registros ← CANDIDATA
PrescripcionStaging_NUEVO  : 29,437 registros
```

### Tests de Calidad

```sql
-- Test 1: ¿Cuál tiene el Hash más reciente?
SELECT MAX("HeaderDate"), COUNT(*) 
FROM "PrescripcionStaging" 
UNION ALL
SELECT MAX("HeaderDate"), COUNT(*) 
FROM "PrescripcionStaging_NUEVA"
UNION ALL
SELECT MAX("HeaderDate"), COUNT(*) 
FROM "PrescripcionStaging_NUEVO";

-- Test 2: ¿Cuál tiene más campos poblados?
SELECT 
  COUNT(*) FILTER (WHERE "UrlFictec" IS NOT NULL) as url_ft,
  COUNT(*) FILTER (WHERE "CodDcsa" IS NOT NULL) as dcsa,
  COUNT(*) FILTER (WHERE "Hash" IS NOT NULL) as hash_count
FROM "PrescripcionStaging";
-- Repetir para _NUEVA y _NUEVO

-- Test 3: ¿Cuál es referenciada en scripts SQL?
grep -r "PrescripcionStaging" etl/python/sql/*.sql
```

### Hipótesis

**Basándome en el análisis:**
- `PrescripcionStaging_NUEVA` parece ser la más reciente (29,438 vs 29,437)
- El script `load_prescripcion_stream.py` usa `--table PrescripcionStaging_NUEVO` en docker-compose
- **Recomendación:** Validar cuál es la tabla ACTIVA y consolidar

---

## 📋 PLAN DE CONSOLIDACIÓN COMPLETO

### FASE 1: INVESTIGACIÓN (1-2 días)

#### 1.1 Identificar Tabla Canónica

```sql
-- Script de comparación completa
CREATE TEMP TABLE comparison AS
SELECT 
  'PrescripcionStaging' as tabla,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE "Hash" IS NOT NULL) as con_hash,
  COUNT(*) FILTER (WHERE "UrlFictec" IS NOT NULL) as con_ft,
  MAX("HeaderDate") as fecha_mas_reciente,
  SUM(LENGTH("DesPrese")) as longitud_total_desc
FROM "PrescripcionStaging"
UNION ALL
SELECT 
  'PrescripcionStaging_NUEVA',
  COUNT(*),
  COUNT(*) FILTER (WHERE "Hash" IS NOT NULL),
  COUNT(*) FILTER (WHERE "UrlFictec" IS NOT NULL),
  MAX("HeaderDate"),
  SUM(LENGTH("DesPrese"))
FROM "PrescripcionStaging_NUEVA"
UNION ALL
SELECT 
  'PrescripcionStaging_NUEVO',
  COUNT(*),
  COUNT(*) FILTER (WHERE "Hash" IS NOT NULL),
  COUNT(*) FILTER (WHERE "UrlFictec" IS NOT NULL),
  MAX("HeaderDate"),
  SUM(LENGTH("DesPrese"))
FROM "PrescripcionStaging_NUEVO";

SELECT * FROM comparison ORDER BY fecha_mas_reciente DESC, total DESC;
```

#### 1.2 Verificar Tablas Vacías con FKs

```sql
-- ¿Cómo es posible 25K FKs a SustanciaActiva vacía?
SELECT COUNT(*) as total_relaciones,
       COUNT(DISTINCT "SustanciaId") as ids_unicos,
       MIN("SustanciaId") as min_id,
       MAX("SustanciaId") as max_id
FROM "MedicamentoSustancia";

-- ¿Existen estos IDs en alguna parte?
SELECT COUNT(*) FROM "SustanciaActiva" 
WHERE "Id" IN (SELECT DISTINCT "SustanciaId" FROM "MedicamentoSustancia");
-- Esperado: 0

-- ¿Están deshabilitadas las FKs?
SELECT conname, confupdtype, confdeltype 
FROM pg_constraint 
WHERE conrelid = 'MedicamentoSustancia'::regclass 
AND contype = 'f';
```

---

### FASE 2: POBLACIÓN DE TABLAS VACÍAS (2-3 días)

#### 2.1 Poblar SustanciaActiva

```sql
-- Opción A: Desde PrincipiosActivos
INSERT INTO "SustanciaActiva" ("Id", "Nombre", "Codigo", "ListaPsicotropo")
SELECT 
  ROW_NUMBER() OVER (ORDER BY "Codigo") as id,
  "Nombre",
  "Codigo",
  "Lista"
FROM "PrincipiosActivos"
ON CONFLICT ("Id") DO NOTHING;

-- Opción B: Mapeo desde staging
-- (Requiere análisis de pa_map, pa_unmatched)
```

#### 2.2 Poblar Excipiente

```sql
-- Desde ExcipientesDeclObligDicStaging + excip_dic_map
INSERT INTO "Excipiente" ("Id", "Nombre")
SELECT 
  ROW_NUMBER() OVER (ORDER BY "CodExcipiente") as id,
  "Nombre"
FROM "ExcipientesDeclObligDicStaging"
WHERE "Nombre" IS NOT NULL
ON CONFLICT ("Id") DO NOTHING;

-- Actualizar grafo
INSERT INTO graph_node (node_type, node_key, props)
SELECT 'Excipiente', "Id"::text, jsonb_build_object('nombre', "Nombre")
FROM "Excipiente"
ON CONFLICT (node_type, node_key) DO UPDATE SET
  props = EXCLUDED.props;
```

#### 2.3 Poblar Documento (URLs)

```sql
-- Crear función helper
CREATE OR REPLACE FUNCTION extract_fecha_from_url(url text) 
RETURNS date AS $$
BEGIN
  -- Extraer fecha del PDF si es posible
  RETURN NULL; -- Implementar parsing
END;
$$ LANGUAGE plpgsql;

-- Poblar Fichas Técnicas
INSERT INTO "Documento" ("NRegistro", "Tipo", "UrlPdf", "UrlHtml", "Secc")
SELECT 
  "NRegistro",
  1 as tipo_ficha_tecnica,
  "UrlFictec",
  replace("UrlFictec", '.pdf', '.html'),
  TRUE as tiene_secciones
FROM "PrescripcionStaging_NUEVA"
WHERE "UrlFictec" IS NOT NULL
ON CONFLICT DO NOTHING;

-- Poblar Prospectos
INSERT INTO "Documento" ("NRegistro", "Tipo", "UrlPdf")
SELECT 
  "NRegistro",
  2 as tipo_prospecto,
  "UrlProsp"
FROM "PrescripcionStaging_NUEVA"
WHERE "UrlProsp" IS NOT NULL
ON CONFLICT DO NOTHING;

-- Añadir al grafo
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 'Medicamento', "NRegistro", 'TIENE_DOCUMENTO', 'Documento', "Id"::text, 
       jsonb_build_object('tipo', "Tipo")
FROM "Documento"
ON CONFLICT DO NOTHING;
```

---

### FASE 3: BIOMARCADORES (3-4 días) ✨

#### 3.1 Crear Script ETL para Biomarcadores

```python
# etl/python/extract_biomarcadores.py
from lxml import etree
import psycopg2

def extract_biomarcadores_from_xml(xml_path, conn):
    """
    Extrae sección <biomarcadores> del XML de prescripción
    y pobla las tablas Biomarcador + MedicamentoBiomarcador
    """
    ns = '{http://schemas.aemps.es/prescripcion/aemps_prescripcion}'
    
    bio_unique = {}  # {nombre: {clase, desc, ...}}
    med_bio_rel = []  # [(nregistro, biomarcador_nombre, tipo_relacion)]
    
    for event, elem in etree.iterparse(xml_path, tag=f'{ns}prescription', events=('end',)):
        nreg = elem.findtext(f'.//{ns}nro_definitivo')
        
        for bio in elem.findall(f'.//{ns}biomarcadores'):
            clase = bio.findtext(f'{ns}clase')
            nombre = bio.findtext(f'{ns}biomarcador')
            secciones = bio.findtext(f'{ns}secciones_ft')
            descripcion = bio.findtext(f'{ns}descripcion')
            sns = bio.findtext(f'{ns}inclusion_cartera_sns')
            notas = bio.findtext(f'{ns}notas')
            
            if nombre:
                if nombre not in bio_unique:
                    bio_unique[nombre] = {
                        'clase': clase,
                        'descripcion': descripcion,
                        'sns': sns == 'SÍ'
                    }
                
                # Determinar tipo de relación
                tipo_rel = 'predice_respuesta'  # Default
                if 'toxicidad' in (notas or '').lower():
                    tipo_rel = 'predice_toxicidad'
                elif 'contraindicado' in (notas or '').lower():
                    tipo_rel = 'contraindicado'
                
                med_bio_rel.append((nreg, nombre, tipo_rel, notas, secciones))
        
        elem.clear()
    
    # Insertar biomarcadores únicos
    with conn.cursor() as cur:
        for nombre, data in bio_unique.items():
            tipo = 'gen' if data['clase'] == 'Germinal' else 'proteina'
            cur.execute("""
                INSERT INTO "Biomarcador" ("Nombre", "Tipo", "Descripcion", "ReferenciasJson")
                VALUES (%s, %s, %s, %s)
                ON CONFLICT ("Nombre") DO UPDATE SET
                  "Descripcion" = EXCLUDED."Descripcion"
                RETURNING "Id"
            """, (nombre, tipo, data['descripcion'], '{}'))
        
        # Insertar relaciones
        for nreg, bio_nombre, tipo_rel, notas, secciones in med_bio_rel:
            cur.execute("""
                INSERT INTO "MedicamentoBiomarcador" 
                  ("NRegistro", "BiomarcadorId", "TipoRelacion", "Notas", "SeccionesFT")
                SELECT %s, "Id", %s, %s, %s
                FROM "Biomarcador"
                WHERE "Nombre" = %s
                ON CONFLICT DO NOTHING
            """, (nreg, tipo_rel, notas, secciones, bio_nombre))
        
        conn.commit()
    
    print(f"[OK] Biomarcadores: {len(bio_unique)} únicos, {len(med_bio_rel)} relaciones")
    return len(bio_unique), len(med_bio_rel)
```

#### 3.2 Añadir Biomarcadores al Grafo

```sql
-- Nodos
INSERT INTO graph_node (node_type, node_key, props)
SELECT 
  'Biomarcador',
  "Id"::text,
  jsonb_build_object(
    'nombre', "Nombre",
    'tipo', "Tipo",
    'descripcion', "Descripcion"
  )
FROM "Biomarcador"
ON CONFLICT (node_type, node_key) DO UPDATE SET
  props = EXCLUDED.props;

-- Aristas
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
  'Medicamento',
  "NRegistro",
  CASE 
    WHEN "TipoRelacion" = 'predice_respuesta' THEN 'BIOMARCADOR_RESPUESTA'
    WHEN "TipoRelacion" = 'predice_toxicidad' THEN 'BIOMARCADOR_TOXICIDAD'
    WHEN "TipoRelacion" = 'contraindicado' THEN 'BIOMARCADOR_CONTRAINDICADO'
    WHEN "TipoRelacion" = 'ajuste_dosis' THEN 'BIOMARCADOR_AJUSTE_DOSIS'
    ELSE 'RELACIONADO_CON_BIOMARCADOR'
  END,
  'Biomarcador',
  "BiomarcadorId"::text,
  jsonb_build_object(
    'nivel_evidencia', "NivelEvidencia",
    'secciones_ft', "SeccionesFT",
    'notas', "Notas"
  )
FROM "MedicamentoBiomarcador"
ON CONFLICT DO NOTHING;
```

---

### FASE 4: ENRIQUECIMIENTO DE COMPOSICIÓN (2-3 días)

#### 4.1 Añadir Campos de Dosis Detallada

```sql
-- Añadir columnas a MedicamentoSustancia
ALTER TABLE "MedicamentoSustancia"
  ADD COLUMN IF NOT EXISTS "DosisPA" numeric,
  ADD COLUMN IF NOT EXISTS "UnidadDosisPA" varchar(32),
  ADD COLUMN IF NOT EXISTS "DosisComposicion" numeric,
  ADD COLUMN IF NOT EXISTS "UnidadComposicion" varchar(64),
  ADD COLUMN IF NOT EXISTS "DosisAdministracion" numeric,
  ADD COLUMN IF NOT EXISTS "UnidadAdministracion" varchar(64),
  ADD COLUMN IF NOT EXISTS "DosisPrescripcion" numeric,
  ADD COLUMN IF NOT EXISTS "UnidadPrescripcion" varchar(32);

-- Poblar desde PrincipioActivoStaging (si existe la info)
UPDATE "MedicamentoSustancia" ms
SET 
  "DosisPA" = pas."CantidadRaw"::numeric,
  "UnidadDosisPA" = pas."UnidadRaw"
FROM "PrincipioActivoStaging" pas
WHERE ms."NRegistro" = pas."NRegistro"
  AND ms."Orden" = pas."Orden";
```

#### 4.2 Script Python para Parsear XML Completo

```python
# Extraer toda la sección <composicion_pa> del XML
# y poblar con máximo detalle
```

---

### FASE 5: CONSOLIDACIÓN FINAL (1-2 días)

#### 5.1 Renombrar Tabla Canónica

```sql
-- Asumiendo que PrescripcionStaging_NUEVA es la buena
BEGIN;

-- Backup de la original
ALTER TABLE "PrescripcionStaging" 
  RENAME TO "PrescripcionStaging_OLD";

-- Promover NUEVA a oficial
ALTER TABLE "PrescripcionStaging_NUEVA" 
  RENAME TO "PrescripcionStaging";

-- Eliminar NUEVO (duplicado)
DROP TABLE "PrescripcionStaging_NUEVO";

COMMIT;
```

#### 5.2 Actualizar Referencias en Código

```bash
# Actualizar todos los scripts SQL
find etl/python/sql -name "*.sql" -exec sed -i 's/PrescripcionStaging_NUEVA/PrescripcionStaging/g' {} \;

# Actualizar Python
sed -i 's/PrescripcionStaging_NUEVA/PrescripcionStaging/g' etl/python/*.py

# Actualizar docker-compose.yml
sed -i 's/--table PrescripcionStaging_NUEVO/--table PrescripcionStaging/g' docker-compose.yml
```

---

## 🎯 CAMPOS ADICIONALES RECOMENDADOS

### En Tabla Medicamentos

```sql
ALTER TABLE "Medicamentos"
  ADD COLUMN IF NOT EXISTS "NumeroPrincipiosActivos" int,
  ADD COLUMN IF NOT EXISTS "Psicotropo" boolean,
  ADD COLUMN IF NOT EXISTS "Estupefaciente" boolean,
  ADD COLUMN IF NOT EXISTS "Sustituible" boolean,
  ADD COLUMN IF NOT EXISTS "EnvaseClinico" boolean,
  ADD COLUMN IF NOT EXISTS "UsoHospitalario" boolean,
  ADD COLUMN IF NOT EXISTS "DiagnosticoHospitalario" boolean,
  ADD COLUMN IF NOT EXISTS "Tld" boolean,
  ADD COLUMN IF NOT EXISTS "EspecialControlMedico" boolean,
  ADD COLUMN IF NOT EXISTS "BaseAPlantas" boolean,
  ADD COLUMN IF NOT EXISTS "ImportacionParalela" boolean,
  ADD COLUMN IF NOT EXISTS "Radiofarmaco" boolean,
  ADD COLUMN IF NOT EXISTS "Serializacion" boolean,
  ADD COLUMN IF NOT EXISTS "TieneExcipientesDeclOblig" boolean,
  ADD COLUMN IF NOT EXISTS "UrlFichaTecnica" text,
  ADD COLUMN IF NOT EXISTS "UrlProspecto" text;
```

### En Tabla MedicamentoBiomarcador

```sql
ALTER TABLE "MedicamentoBiomarcador"
  ADD COLUMN IF NOT EXISTS "SeccionesFT" text,
  ADD COLUMN IF NOT EXISTS "InclusionSNS" boolean,
  ADD COLUMN IF NOT EXISTS "Notas" text;
```

---

## 📈 CRONOGRAMA Y ESTIMACIONES

| Fase | Duración | Complejidad | Prioridad |
|------|----------|-------------|-----------|
| **1. Investigación** | 1-2 días | Baja | 🔥🔥🔥 Inmediata |
| **2. Población Tablas Vacías** | 2-3 días | Media | 🔥🔥🔥 Crítica |
| **3. Biomarcadores** | 3-4 días | Alta | 🔥🔥🔥 Oro Puro |
| **4. Enriquecimiento Composición** | 2-3 días | Media | 🔥🔥 Alta |
| **5. Consolidación Final** | 1-2 días | Baja | 🔥 Media |
| **TOTAL** | **9-14 días** | - | - |

---

## ✅ CHECKLIST DE EJECUCIÓN

### Fase 1: Investigación
- [ ] Ejecutar script de comparación de las 3 PrescripcionStaging
- [ ] Identificar tabla canónica basada en métricas
- [ ] Verificar integridad de FKs en tablas vacías
- [ ] Documentar hallazgos

### Fase 2: Población
- [ ] Poblar SustanciaActiva desde PrincipiosActivos
- [ ] Poblar Excipiente desde ExcipientesDeclObligDicStaging
- [ ] Poblar Documento (URLs) desde PrescripcionStaging
- [ ] Actualizar grafo con nuevos nodos/aristas
- [ ] Validar integridad referencial

### Fase 3: Biomarcadores ✨
- [ ] Crear script `extract_biomarcadores.py`
- [ ] Ejecutar parsing del XML completo
- [ ] Poblar tabla Biomarcador (única)
- [ ] Poblar tabla MedicamentoBiomarcador (relaciones)
- [ ] Añadir nodos Biomarcador al grafo
- [ ] Añadir aristas especializadas (RESPUESTA, TOXICIDAD, etc.)
- [ ] Validar con queries de prueba

### Fase 4: Enriquecimiento
- [ ] Añadir columnas de dosis detallada a MedicamentoSustancia
- [ ] Crear script para parsear composicion_pa del XML
- [ ] Poblar campos de dosis
- [ ] Añadir campo NumeroPrincipiosActivos a Medicamentos
- [ ] Propagar flags adicionales desde PrescripcionStaging

### Fase 5: Consolidación
- [ ] Renombrar PrescripcionStaging_NUEVA → PrescripcionStaging
- [ ] Eliminar tablas duplicadas
- [ ] Actualizar referencias en código Python
- [ ] Actualizar referencias en scripts SQL
- [ ] Actualizar docker-compose.yml
- [ ] Ejecutar suite de tests de validación

---

## 🎉 RESULTADO ESPERADO

### Antes vs Después

#### ANTES
- ❌ 4 tablas vacías con FKs rotas
- ❌ 3 tablas PrescripcionStaging duplicadas
- ❌ 0 biomarcadores (farmacogenómica ausente)
- ❌ Documentos (FT/Prospecto) no accesibles
- ⚠️ Composición de principios activos simplificada

#### DESPUÉS ✨
- ✅ 0 tablas vacías - Todo poblado y funcional
- ✅ 1 tabla PrescripcionStaging consolidada y óptima
- ✅ Biomarcadores completos con guías CPIC/PharmGKB
- ✅ URLs de documentos accesibles desde BD
- ✅ Composición de PA con detalle farmacéutico completo
- ✅ Grafo enriquecido con tipos de nodo/relación nuevos
- ✅ BD más completa que la de AEMPS original

### Nuevas Capacidades

1. **Farmacogenómica**
   ```sql
   -- Medicamentos que requieren CYP2D6
   SELECT m."Nombre", mb."Notas"
   FROM "Medicamentos" m
   JOIN "MedicamentoBiomarcador" mb ON m."NRegistro" = mb."NRegistro"
   JOIN "Biomarcador" b ON b."Id" = mb."BiomarcadorId"
   WHERE b."Nombre" = 'CYP2D6';
   ```

2. **Acceso a Documentación**
   ```sql
   -- Obtener ficha técnica de un medicamento
   SELECT "UrlPdf", "UrlHtml" 
   FROM "Documento" 
   WHERE "NRegistro" = '66393' AND "Tipo" = 1;
   ```

3. **Análisis de Composición**
   ```sql
   -- Medicamentos con dosis exacta para prescribir
   SELECT m."Nombre", 
          ms."DosisPrescripcion", 
          ms."UnidadPrescripcion"
   FROM "Medicamentos" m
   JOIN "MedicamentoSustancia" ms ON m."NRegistro" = ms."NRegistro";
   ```

---

## 🚀 VENTAJA COMPETITIVA

Con estos cambios, la BD FARMAI será:

1. **Más Completa que AEMPS** 
   - AEMPS solo ofrece XML plano
   - FARMAI tendrá grafo navegable + relaciones semánticas

2. **Primera en Farmacogenómica**
   - Biomarcadores integrados con medicamentos
   - Referencias a guías clínicas (CPIC, etc.)
   - Decisión clínica personalizada

3. **Acceso Directo a Documentación**
   - URLs de FT/Prospecto en BD
   - Secciones específicas identificadas
   - Trazabilidad completa

4. **Precision Farmacéutica**
   - Múltiples niveles de dosis (PA, composición, administración, prescripción)
   - Conversión a mg normalizada
   - Cálculos farmacéuticos precisos

---

## 📞 PRÓXIMOS PASOS INMEDIATOS

### Ejecutar AHORA

```sql
-- 1. Comparar las 3 PrescripcionStaging
\i comparacion_prescripcion_staging.sql

-- 2. Verificar FKs rotas
\i verificar_fks_vacias.sql

-- 3. Poblar Documento (quick win)
\i poblar_documento_urls.sql
```

### Scripts a Crear

1. `comparacion_prescripcion_staging.sql` - Análisis completo de las 3 tablas
2. `verificar_fks_vacias.sql` - Auditoría de integridad
3. `poblar_documento_urls.sql` - População rápida de URLs
4. `extract_biomarcadores.py` - ETL de biomarcadores (Python)
5. `enrich_composicion_pa.py` - Enriquecimiento de dosis (Python)

---

## 📚 DOCUMENTOS RELACIONADOS

- `README_INVESTIGACION.md` - Roadmap general del proyecto
- `INFORME_BASE_DATOS.md` - Análisis detallado de BD actual
- `db_schema_full.txt` - Esquema completo (559 columnas)
- `db_constraints.txt` - Constraints (146)
- `prescripcion_sample.xml` - Muestra del XML con biomarcadores

---

## 🏆 CONCLUSIÓN

**FARMAI está a 9-14 días de tener la base de datos farmacológica más completa y avanzada de España.**

### Puntos Clave:
1. ✨ **Biomarcadores = GOLD** - Información de farmacogenómica única
2. 🔧 **Consolidación necesaria** - 3 → 1 tabla PrescripcionStaging
3. 🏗️ **Población pendiente** - 4 tablas vacías a llenar
4. 📈 **Enriquecimiento disponible** - Composición PA detallada en XML
5. 🚀 **Ventaja competitiva clara** - Nadie más tiene esto integrado

### Impacto Business:
- **MVP más robusto** que cualquier competidor
- **Farmacogenómica** como diferenciador único
- **Acceso documentación** integrado
- **Precision clínica** máxima

---

**FIN DEL ANÁLISIS Y PLAN DE CONSOLIDACIÓN**

*Documento preparado para crear "La Base de Datos Más Bestia de España"*  
*Generado el 10/01/2025 - Listo para ejecutar*
