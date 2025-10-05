# 🗺️ ROADMAP COMPLETO: COMPLETAR BASE DE DATOS FARMAI

## 📅 Fecha: 05/10/2025
## 🎯 Objetivo: 100% de datos en BD antes de frontend

---

## 📊 ESTADO ACTUAL

### ✅ Lo que YA TENEMOS (Completo):
- ✅ 20,271 Medicamentos (100%)
- ✅ 29,540 Presentaciones (100%)
- ✅ 4,885 Principios Activos (100%)
- ✅ 111,191 Flags (100%)
- ✅ 52,325 Interacciones (100%)
- ✅ 5,719 Notas Seguridad (100%)
- ✅ 25,215 Alertas Geriátricas (100%)
- ✅ 47 Biomarcadores (100%)
- ✅ 41,408 Excipientes (100%)
- ✅ Grafo completo (88,661 nodos, 742,101 aristas)

### ⚠️ Lo que está INCOMPLETO:
- ⚠️ Documentos: 309/43,922 (0.7%) → Pendientes: 43,613
- ⚠️ Fotos: 44/29,540 (0.1%) → Pendientes: 29,496
- ❌ Problemas Suministro: 0 (tabla no existe)
- ❌ Materiales Informativos: 0 (tabla no existe)
- ❌ Teratogenia: 0 (campo XML no parseado)
- ❌ HTML Segmentado: 0 (formato alternativo)

---

## 🚀 ROADMAP EN 5 FASES

```
FASE 1: Completar Documentos PDFs (40K+)        [3-5 días]
   ↓
FASE 2: Parsear Teratogenia del XML              [1 día]
   ↓
FASE 3: Scraping Fotos CIMA                      [2-3 días]
   ↓
FASE 4: Problemas de Suministro (API CIMA)      [2 días]
   ↓
FASE 5: Materiales Informativos (API CIMA)      [2 días]
   ↓
FASE 6: Propagación Completa al Grafo           [1 día]
   ↓
FASE 7: Índices Optimizados + Vistas            [1 día]
   ↓
✅ BD 100% COMPLETA → FRONTEND
```

**Tiempo Total Estimado:** 12-15 días

---

## 📋 FASE 1: COMPLETAR DOCUMENTOS PDFs (43,613 PENDIENTES)

### Estado Actual:
```sql
SELECT 
    COUNT(*) FILTER (WHERE "Downloaded" = true) as descargados,
    COUNT(*) FILTER (WHERE "Downloaded" = false) as pendientes,
    COUNT(*) FILTER (WHERE "HttpStatus" = 404) as no_existen
FROM "Documento";

-- Resultado:
-- descargados: 309
-- pendientes: 43,613
-- no_existen: 179 (ya marcados)
```

### 📥 Paso 1.1: Completar Descarga Masiva (3-4 días)

**Script ya creado:** `DESCARGAR_RESTANTES_ULTRA_LENTO.ps1`

**Configuración:**
```powershell
$batchSize = 100
$delayMs = 1000-1500 (aleatorio)
$delayBetweenBatches = 30s
```

**Ejecución:**
```bash
# Sesión 1 (mañana - 4h)
.\DESCARGAR_RESTANTES_ULTRA_LENTO.ps1

# Sesión 2 (tarde - 4h)
.\DESCARGAR_RESTANTES_ULTRA_LENTO.ps1

# Sesión 3 (noche - 4h)
.\DESCARGAR_RESTANTES_ULTRA_LENTO.ps1

# Continuar hasta completar ~43K documentos
```

**Resultado Esperado:** 
- 40,000-42,000 PDFs descargados (95-98%)
- ~1,500-2,000 documentos no disponibles (404 permanentes)

### 📊 Paso 1.2: Verificación Integridad (30 min)

**Script SQL:** `scripts_investigacion/verificar_integridad_final_docs.sql`

```sql
-- Verificar documentos descargados
SELECT 
    "Tipo",
    CASE 
        WHEN "Tipo" = 1 THEN 'Ficha Técnica'
        WHEN "Tipo" = 2 THEN 'Prospecto'
        WHEN "Tipo" = 3 THEN 'IPE'
        ELSE 'Otro'
    END as "TipoNombre",
    COUNT(*) FILTER (WHERE "Downloaded" = true) as "Descargados",
    COUNT(*) FILTER (WHERE "Downloaded" = false) as "Pendientes",
    ROUND(COUNT(*) FILTER (WHERE "Downloaded" = true) * 100.0 / COUNT(*), 2) as "PorcentajeDescargado"
FROM "Documento"
GROUP BY "Tipo"
ORDER BY "Tipo";

-- Verificar archivos físicos (PowerShell)
-- Get-ChildItem "Farmai.Api/bin/Debug/net8.0/_data/documentos" -Recurse -File | Measure-Object
```

### 🔗 Paso 1.3: Propagación Documentos al Grafo (actualizado)

**Script SQL:** `scripts_propagacion/43_propagar_documentos_completos.sql`

```sql
-- Ya existe propagación básica en script 17
-- Este script actualiza con documentos nuevos

-- Actualizar nodos Documento existentes
UPDATE graph_node gn
SET props = jsonb_set(
    props,
    '{downloaded}',
    to_jsonb(d."Downloaded")
)
FROM "Documento" d
WHERE gn.node_type = 'Documento'
AND gn.node_key = d."Id"::text
AND d."Downloaded" = true;

-- Insertar nuevos documentos si no existen
INSERT INTO graph_node (node_type, node_key, props)
SELECT 
    'Documento',
    d."Id"::text,
    jsonb_build_object(
        'tipo', d."Tipo",
        'urlPdf', d."UrlPdf",
        'fecha', d."Fecha",
        'downloaded', d."Downloaded",
        'localPath', d."LocalPath"
    )
FROM "Documento" d
WHERE NOT EXISTS (
    SELECT 1 FROM graph_node gn
    WHERE gn.node_type = 'Documento'
    AND gn.node_key = d."Id"::text
);

-- Verificar propagación
SELECT 
    COUNT(*) as "NodosDocumento",
    COUNT(*) FILTER (WHERE (props->>'downloaded')::boolean = true) as "Descargados"
FROM graph_node
WHERE node_type = 'Documento';
```

### 📈 KPIs Fase 1:
- ✅ 95-98% documentos descargados
- ✅ Tabla `Documento` completa
- ✅ Archivos físicos almacenados
- ✅ Nodos `Documento` en grafo actualizados

---

## 🧬 FASE 2: PARSEAR TERATOGENIA DEL XML (1 DÍA)

### Estado Actual:
```
❌ Campo <teratogenia> del XML NO parseado
✅ Campo existe en prescripcion.xml
```

### 📥 Paso 2.1: Crear Tabla Teratogenia

**Migration SQL:** `scripts_propagacion/44_crear_tabla_teratogenia.sql`

```sql
-- Crear tabla Teratogenia
CREATE TABLE "Teratogenia" (
    "Id" SERIAL PRIMARY KEY,
    "NRegistro" VARCHAR(50) NOT NULL,
    "CategoriaFDA" VARCHAR(10), -- A, B, C, D, X, N (no categorizado)
    "RiesgoEmbarazo" TEXT,
    "RiesgoLactancia" TEXT,
    "ObservacionesEmbarazo" TEXT,
    "ObservacionesLactancia" TEXT,
    "Trimestre1" VARCHAR(50), -- Seguro/Riesgo/Contraindicado
    "Trimestre2" VARCHAR(50),
    "Trimestre3" VARCHAR(50),
    "FuenteInfo" VARCHAR(100), -- XML, FDA, EMA, etc.
    "FechaActualizacion" TIMESTAMP,
    CONSTRAINT "FK_Teratogenia_Medicamento" 
        FOREIGN KEY ("NRegistro") 
        REFERENCES "Medicamentos"("NRegistro")
        ON DELETE CASCADE
);

-- Índices
CREATE INDEX "IX_Teratogenia_NRegistro" ON "Teratogenia"("NRegistro");
CREATE INDEX "IX_Teratogenia_CategoriaFDA" ON "Teratogenia"("CategoriaFDA");
CREATE INDEX "IX_Teratogenia_Trimestre1" ON "Teratogenia"("Trimestre1");

-- Agregar a Entity Framework
-- public DbSet<Teratogenia> Teratogenias { get; set; }
```

### 🐍 Paso 2.2: Script Python Extracción

**Script:** `etl/python/extract_teratogenia.py`

```python
import psycopg2
import xml.etree.ElementTree as ET
from datetime import datetime

def extract_teratogenia_from_xml(xml_path):
    """
    Extrae información de teratogenia del XML CIMA
    """
    tree = ET.parse(xml_path)
    root = tree.getroot()
    
    teratogenia_data = []
    
    for medicamento in root.findall('.//medicamento'):
        nregistro = medicamento.find('nregistro').text
        
        # Buscar campo teratogenia (puede estar en varios lugares)
        terato_elem = medicamento.find('.//teratogenia')
        if terato_elem is not None:
            terato = {
                'nregistro': nregistro,
                'categoria_fda': terato_elem.find('categoriaFDA').text if terato_elem.find('categoriaFDA') is not None else None,
                'riesgo_embarazo': terato_elem.find('riesgoEmbarazo').text if terato_elem.find('riesgoEmbarazo') is not None else None,
                'riesgo_lactancia': terato_elem.find('riesgoLactancia').text if terato_elem.find('riesgoLactancia') is not None else None,
                'obs_embarazo': terato_elem.find('observacionesEmbarazo').text if terato_elem.find('observacionesEmbarazo') is not None else None,
                'obs_lactancia': terato_elem.find('observacionesLactancia').text if terato_elem.find('observacionesLactancia') is not None else None,
                'fuente': 'XML_CIMA',
                'fecha': datetime.now()
            }
            teratogenia_data.append(terato)
    
    return teratogenia_data

def insert_teratogenia_to_db(data, conn_str):
    """
    Inserta datos de teratogenia en BD
    """
    conn = psycopg2.connect(conn_str)
    cur = conn.cursor()
    
    for item in data:
        cur.execute("""
            INSERT INTO "Teratogenia" 
            ("NRegistro", "CategoriaFDA", "RiesgoEmbarazo", "RiesgoLactancia", 
             "ObservacionesEmbarazo", "ObservacionesLactancia", "FuenteInfo", "FechaActualizacion")
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT DO NOTHING
        """, (
            item['nregistro'],
            item['categoria_fda'],
            item['riesgo_embarazo'],
            item['riesgo_lactancia'],
            item['obs_embarazo'],
            item['obs_lactancia'],
            item['fuente'],
            item['fecha']
        ))
    
    conn.commit()
    cur.close()
    conn.close()

if __name__ == '__main__':
    xml_path = 'prescripcion.xml'
    conn_str = 'host=localhost port=5433 dbname=farmai_db user=postgres password=postgres'
    
    print("Extrayendo teratogenia del XML...")
    data = extract_teratogenia_from_xml(xml_path)
    
    print(f"Encontrados {len(data)} registros de teratogenia")
    
    print("Insertando en BD...")
    insert_teratogenia_to_db(data, conn_str)
    
    print("✅ Completado!")
```

### 🔗 Paso 2.3: Propagación al Grafo

**Script SQL:** `scripts_propagacion/45_propagar_teratogenia_grafo.sql`

```sql
-- Crear nodos Teratogenia
INSERT INTO graph_node (node_type, node_key, props)
SELECT 
    'Teratogenia',
    t."Id"::text,
    jsonb_build_object(
        'nregistro', t."NRegistro",
        'categoriaFDA', t."CategoriaFDA",
        'riesgoEmbarazo', t."RiesgoEmbarazo",
        'riesgoLactancia', t."RiesgoLactancia"
    )
FROM "Teratogenia" t
ON CONFLICT (node_type, node_key) DO NOTHING;

-- Crear relaciones Medicamento → Teratogenia
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Medicamento',
    m."NRegistro",
    'TIENE_TERATOGENIA',
    'Teratogenia',
    t."Id"::text,
    jsonb_build_object(
        'categoriaFDA', t."CategoriaFDA"
    )
FROM "Medicamentos" m
JOIN "Teratogenia" t ON t."NRegistro" = m."NRegistro"
ON CONFLICT (src_type, src_key, rel, dst_type, dst_key) DO NOTHING;

-- Estadísticas
SELECT 
    COUNT(*) as "TotalTeratogenia",
    COUNT(DISTINCT "NRegistro") as "MedicamentosConInfo"
FROM "Teratogenia";
```

### 📈 KPIs Fase 2:
- ✅ Tabla `Teratogenia` creada
- ✅ Datos extraídos del XML
- ✅ ~5,000-10,000 registros teratogenia
- ✅ Propagado al grafo

---

## 📸 FASE 3: SCRAPING FOTOS CIMA (29,496 PENDIENTES)

### Estado Actual:
```sql
SELECT COUNT(*) FROM "Foto"; -- 44 (0.1%)
```

### 🌐 Paso 3.1: Servicio Scraping Fotos

**Servicio C#:** `Farmai.Api/Services/FotoScrapingService.cs`

```csharp
public class FotoScrapingService
{
    private readonly HttpClient _httpClient;
    private readonly FarmaiDbContext _context;
    private readonly ILogger<FotoScrapingService> _logger;
    
    // Endpoint CIMA para fotos
    private const string CimaFotosUrl = "https://cima.aemps.es/cima/rest/medicamento/{0}/fotos";
    
    public async Task<FotoScrapingResult> DescargarFotosMedicamento(string nregistro)
    {
        try
        {
            var url = string.Format(CimaFotosUrl, nregistro);
            var response = await _httpClient.GetAsync(url);
            
            if (!response.IsSuccessStatusCode)
                return new FotoScrapingResult { Success = false };
            
            var json = await response.Content.ReadAsStringAsync();
            var fotosData = JsonSerializer.Deserialize<CimaFotosDto>(json);
            
            foreach (var foto in fotosData.Fotos)
            {
                var nuevaFoto = new Foto
                {
                    NRegistro = nregistro,
                    Tipo = foto.Tipo, // "materialas" o "formafarmac"
                    Url = foto.Url,
                    Fecha = foto.Fecha
                };
                
                _context.Fotos.Add(nuevaFoto);
            }
            
            await _context.SaveChangesAsync();
            
            return new FotoScrapingResult 
            { 
                Success = true, 
                FotosDescargadas = fotosData.Fotos.Count 
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error descargando fotos para {NRegistro}", nregistro);
            return new FotoScrapingResult { Success = false, Error = ex.Message };
        }
    }
    
    public async Task<ScrapingMasivoResult> DescargarTodasLasFotos(
        int batchSize = 100, 
        int delayMs = 500)
    {
        var medicamentos = await _context.Medicamentos
            .Where(m => !_context.Fotos.Any(f => f.NRegistro == m.NRegistro))
            .Select(m => m.NRegistro)
            .ToListAsync();
        
        int total = medicamentos.Count;
        int descargados = 0;
        int fallidos = 0;
        
        for (int i = 0; i < total; i += batchSize)
        {
            var batch = medicamentos.Skip(i).Take(batchSize);
            
            foreach (var nreg in batch)
            {
                var result = await DescargarFotosMedicamento(nreg);
                if (result.Success) descargados++;
                else fallidos++;
                
                await Task.Delay(delayMs);
            }
            
            // Delay más largo entre batches
            await Task.Delay(5000);
        }
        
        return new ScrapingMasivoResult
        {
            Total = total,
            Descargados = descargados,
            Fallidos = fallidos
        };
    }
}
```

### 🎮 Paso 3.2: Controller Endpoint

**Controller:** `Farmai.Api/Controllers/FotosController.cs`

```csharp
[ApiController]
[Route("api/[controller]")]
public class FotosController : ControllerBase
{
    private readonly FotoScrapingService _fotoService;
    
    [HttpPost("scrape-all")]
    public async Task<ActionResult<ScrapingMasivoResult>> ScrapeAllFotos(
        [FromQuery] int batchSize = 100,
        [FromQuery] int delayMs = 500)
    {
        var result = await _fotoService.DescargarTodasLasFotos(batchSize, delayMs);
        return Ok(result);
    }
    
    [HttpGet("summary")]
    public async Task<ActionResult<FotosSummary>> GetSummary()
    {
        var total = await _context.Medicamentos.CountAsync();
        var conFotos = await _context.Fotos
            .Select(f => f.NRegistro)
            .Distinct()
            .CountAsync();
        
        return Ok(new FotosSummary
        {
            TotalMedicamentos = total,
            ConFotos = conFotos,
            SinFotos = total - conFotos,
            PorcentajeCompletitud = (double)conFotos / total * 100
        });
    }
}
```

### 📜 Paso 3.3: Script PowerShell Descarga

**Script:** `DESCARGAR_TODAS_FOTOS.ps1`

```powershell
$batchSize = 100
$delayMs = 500

Write-Host "Iniciando descarga masiva de fotos..." -ForegroundColor Cyan

$result = Invoke-RestMethod `
    -Uri "http://localhost:5265/api/fotos/scrape-all?batchSize=$batchSize&delayMs=$delayMs" `
    -Method POST

Write-Host "Completado!" -ForegroundColor Green
Write-Host "  Total: $($result.total)" -ForegroundColor White
Write-Host "  Descargados: $($result.descargados)" -ForegroundColor Green
Write-Host "  Fallidos: $($result.fallidos)" -ForegroundColor Red
```

### 🔗 Paso 3.4: Propagación al Grafo

**Script SQL:** `scripts_propagacion/46_propagar_fotos_grafo.sql`

```sql
-- Actualizar nodos Foto existentes
UPDATE graph_node gn
SET props = jsonb_build_object(
    'tipo', f."Tipo",
    'url', f."Url",
    'fecha', f."Fecha"
)
FROM "Foto" f
WHERE gn.node_type = 'Foto'
AND gn.node_key = f."Id"::text;

-- Insertar nuevos nodos Foto
INSERT INTO graph_node (node_type, node_key, props)
SELECT 
    'Foto',
    f."Id"::text,
    jsonb_build_object(
        'tipo', f."Tipo",
        'url', f."Url",
        'fecha', f."Fecha"
    )
FROM "Foto" f
WHERE NOT EXISTS (
    SELECT 1 FROM graph_node gn
    WHERE gn.node_type = 'Foto'
    AND gn.node_key = f."Id"::text
);

-- Crear/actualizar relaciones Medicamento → Foto
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Medicamento',
    m."NRegistro",
    'TIENE_FOTO',
    'Foto',
    f."Id"::text,
    jsonb_build_object('tipo', f."Tipo")
FROM "Medicamentos" m
JOIN "Foto" f ON f."NRegistro" = m."NRegistro"
ON CONFLICT (src_type, src_key, rel, dst_type, dst_key) DO UPDATE
SET props = EXCLUDED.props;
```

### 📈 KPIs Fase 3:
- ✅ ~25,000-28,000 fotos descargadas (85-95%)
- ✅ Tabla `Foto` completa
- ✅ Propagado al grafo

---

## ⚠️ FASE 4: PROBLEMAS DE SUMINISTRO (NUEVA TABLA)

### 📥 Paso 4.1: Crear Tabla ProblemasSuministro

**Migration SQL:** `scripts_propagacion/47_crear_tabla_problemas_suministro.sql`

```sql
-- Crear tabla Problemas de Suministro
CREATE TABLE "ProblemasSuministro" (
    "Id" SERIAL PRIMARY KEY,
    "CN" VARCHAR(20) NOT NULL, -- Código Nacional
    "NombrePresentacion" VARCHAR(500),
    "NRegistro" VARCHAR(50),
    "FechaInicio" DATE NOT NULL,
    "FechaFinPrevista" DATE,
    "FechaFinReal" DATE,
    "Observaciones" TEXT,
    "Activo" BOOLEAN DEFAULT true,
    "CausaProblema" VARCHAR(200), -- Fabricación, Logística, etc.
    "FechaActualizacion" TIMESTAMP DEFAULT NOW(),
    CONSTRAINT "FK_ProblemaSuministro_Presentacion" 
        FOREIGN KEY ("CN") 
        REFERENCES "Presentacion"("CN")
        ON DELETE CASCADE,
    CONSTRAINT "FK_ProblemaSuministro_Medicamento" 
        FOREIGN KEY ("NRegistro") 
        REFERENCES "Medicamentos"("NRegistro")
        ON DELETE CASCADE
);

-- Índices
CREATE INDEX "IX_ProblemasSuministro_CN" ON "ProblemasSuministro"("CN");
CREATE INDEX "IX_ProblemasSuministro_NRegistro" ON "ProblemasSuministro"("NRegistro");
CREATE INDEX "IX_ProblemasSuministro_Activo" ON "ProblemasSuministro"("Activo");
CREATE INDEX "IX_ProblemasSuministro_FechaInicio" ON "ProblemasSuministro"("FechaInicio");
```

### 🌐 Paso 4.2: Servicio Sincronización CIMA

**Servicio C#:** `Farmai.Api/Services/ProblemasSuministroService.cs`

```csharp
public class ProblemasSuministroService
{
    private readonly HttpClient _httpClient;
    private readonly FarmaiDbContext _context;
    private const string CimaPsumUrl = "https://cima.aemps.es/cima/rest/psuministro";
    
    public async Task<SyncResult> SincronizarProblemasActivos()
    {
        // Obtener todos los problemas activos desde API CIMA
        var response = await _httpClient.GetAsync(CimaPsumUrl);
        var json = await response.Content.ReadAsStringAsync();
        var problemas = JsonSerializer.Deserialize<List<CimaPsumDto>>(json);
        
        int nuevos = 0;
        int actualizados = 0;
        
        foreach (var prob in problemas)
        {
            var existente = await _context.ProblemasSuministro
                .FirstOrDefaultAsync(p => p.CN == prob.CN && p.Activo);
            
            if (existente == null)
            {
                // Nuevo problema
                var nuevo = new ProblemasSuministro
                {
                    CN = prob.CN,
                    NombrePresentacion = prob.Nombre,
                    NRegistro = await ObtenerNRegistroDeCN(prob.CN),
                    FechaInicio = prob.FechaInicio,
                    FechaFinPrevista = prob.FechaFinPrevista,
                    Observaciones = prob.Observaciones,
                    Activo = prob.Activo
                };
                _context.ProblemasSuministro.Add(nuevo);
                nuevos++;
            }
            else
            {
                // Actualizar problema existente
                existente.FechaFinPrevista = prob.FechaFinPrevista;
                existente.Observaciones = prob.Observaciones;
                existente.Activo = prob.Activo;
                existente.FechaActualizacion = DateTime.Now;
                actualizados++;
            }
        }
        
        // Marcar como resueltos los que ya no están en API
        var problemasActualesAPI = problemas.Select(p => p.CN).ToList();
        var problemasResolverBD = await _context.ProblemasSuministro
            .Where(p => p.Activo && !problemasActualesAPI.Contains(p.CN))
            .ToListAsync();
        
        foreach (var prob in problemasResolverBD)
        {
            prob.Activo = false;
            prob.FechaFinReal = DateTime.Today;
        }
        
        await _context.SaveChangesAsync();
        
        return new SyncResult
        {
            Nuevos = nuevos,
            Actualizados = actualizados,
            Resueltos = problemasResolverBD.Count
        };
    }
}
```

### 🔗 Paso 4.3: Propagación al Grafo

**Script SQL:** `scripts_propagacion/48_propagar_problemas_suministro_grafo.sql`

```sql
-- Crear nodos ProblemasSuministro
INSERT INTO graph_node (node_type, node_key, props)
SELECT 
    'ProblemaSuministro',
    ps."Id"::text,
    jsonb_build_object(
        'cn', ps."CN",
        'fechaInicio', ps."FechaInicio",
        'fechaFinPrevista', ps."FechaFinPrevista",
        'activo', ps."Activo",
        'observaciones', ps."Observaciones"
    )
FROM "ProblemasSuministro" ps
ON CONFLICT (node_type, node_key) DO UPDATE
SET props = EXCLUDED.props;

-- Relación Presentación → ProblemaSuministro
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Presentacion',
    p."CN",
    'TIENE_PROBLEMA_SUMINISTRO',
    'ProblemaSuministro',
    ps."Id"::text,
    jsonb_build_object('activo', ps."Activo")
FROM "Presentacion" p
JOIN "ProblemasSuministro" ps ON ps."CN" = p."CN"
ON CONFLICT (src_type, src_key, rel, dst_type, dst_key) DO UPDATE
SET props = EXCLUDED.props;

-- Relación Medicamento → ProblemaSuministro
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Medicamento',
    m."NRegistro",
    'TIENE_PROBLEMA_SUMINISTRO',
    'ProblemaSuministro',
    ps."Id"::text,
    jsonb_build_object('activo', ps."Activo")
FROM "Medicamentos" m
JOIN "ProblemasSuministro" ps ON ps."NRegistro" = m."NRegistro"
ON CONFLICT (src_type, src_key, rel, dst_type, dst_key) DO UPDATE
SET props = EXCLUDED.props;
```

### 📈 KPIs Fase 4:
- ✅ Tabla `ProblemasSuministro` creada
- ✅ Sincronización automática con API CIMA
- ✅ Propagado al grafo
- ✅ Monitoreo en tiempo real

---

## 📚 FASE 5: MATERIALES INFORMATIVOS (NUEVA TABLA)

### 📥 Paso 5.1: Crear Tabla MaterialesInformativos

**Migration SQL:** `scripts_propagacion/49_crear_tabla_materiales_informativos.sql`

```sql
-- Crear tabla Materiales Informativos
CREATE TABLE "MaterialesInformativos" (
    "Id" SERIAL PRIMARY KEY,
    "NRegistro" VARCHAR(50) NOT NULL,
    "Titulo" VARCHAR(500),
    "FechaPublicacion" DATE,
    "TieneMaterialesPaciente" BOOLEAN DEFAULT false,
    "TieneMaterialesProfesional" BOOLEAN DEFAULT false,
    "TieneVideo" BOOLEAN DEFAULT false,
    "UrlVideo" TEXT,
    "FechaActualizacion" TIMESTAMP DEFAULT NOW(),
    CONSTRAINT "FK_MaterialesInformativos_Medicamento" 
        FOREIGN KEY ("NRegistro") 
        REFERENCES "Medicamentos"("NRegistro")
        ON DELETE CASCADE
);

-- Tabla de documentos dentro de materiales
CREATE TABLE "MaterialInformativoDocumento" (
    "Id" SERIAL PRIMARY KEY,
    "MaterialId" INTEGER NOT NULL,
    "TipoDestinatario" VARCHAR(50) NOT NULL, -- 'Paciente' o 'Profesional'
    "Nombre" VARCHAR(500),
    "Url" TEXT,
    "Fecha" DATE,
    CONSTRAINT "FK_MaterialDoc_Material"
        FOREIGN KEY ("MaterialId")
        REFERENCES "MaterialesInformativos"("Id")
        ON DELETE CASCADE
);

-- Índices
CREATE INDEX "IX_MaterialesInformativos_NRegistro" ON "MaterialesInformativos"("NRegistro");
CREATE INDEX "IX_MaterialInformativoDoc_MaterialId" ON "MaterialInformativoDocumento"("MaterialId");
CREATE INDEX "IX_MaterialInformativoDoc_Tipo" ON "MaterialInformativoDocumento"("TipoDestinatario");
```

### 🌐 Paso 5.2: Servicio Sincronización

**Servicio C#:** `Farmai.Api/Services/MaterialesInformativosService.cs`

```csharp
public class MaterialesInformativosService
{
    private readonly HttpClient _httpClient;
    private readonly FarmaiDbContext _context;
    private const string CimaMaterialesUrl = "https://cima.aemps.es/cima/rest/materiales/{0}";
    
    public async Task<MaterialSyncResult> SincronizarMateriales(string nregistro)
    {
        var url = string.Format(CimaMaterialesUrl, nregistro);
        var response = await _httpClient.GetAsync(url);
        
        if (!response.IsSuccessStatusCode)
            return new MaterialSyncResult { Success = false };
        
        var json = await response.Content.ReadAsStringAsync();
        var materialesDto = JsonSerializer.Deserialize<CimaMaterialesDto>(json);
        
        // Crear o actualizar material
        var material = await _context.MaterialesInformativos
            .FirstOrDefaultAsync(m => m.NRegistro == nregistro);
        
        if (material == null)
        {
            material = new MaterialesInformativos { NRegistro = nregistro };
            _context.MaterialesInformativos.Add(material);
        }
        
        material.Titulo = materialesDto.Titulo;
        material.FechaPublicacion = materialesDto.FechaPublicacion;
        material.TieneMaterialesPaciente = materialesDto.ListaDocsPaciente?.Any() ?? false;
        material.TieneMaterialesProfesional = materialesDto.ListaDocsProfesional?.Any() ?? false;
        material.TieneVideo = !string.IsNullOrEmpty(materialesDto.Video);
        material.UrlVideo = materialesDto.Video;
        material.FechaActualizacion = DateTime.Now;
        
        await _context.SaveChangesAsync();
        
        // Insertar documentos paciente
        foreach (var doc in materialesDto.ListaDocsPaciente ?? new List<DocumentoMaterialDto>())
        {
            _context.MaterialInformativoDocumento.Add(new MaterialInformativoDocumento
            {
                MaterialId = material.Id,
                TipoDestinatario = "Paciente",
                Nombre = doc.Nombre,
                Url = doc.Url,
                Fecha = doc.Fecha
            });
        }
        
        // Insertar documentos profesional
        foreach (var doc in materialesDto.ListaDocsProfesional ?? new List<DocumentoMaterialDto>())
        {
            _context.MaterialInformativoDocumento.Add(new MaterialInformativoDocumento
            {
                MaterialId = material.Id,
                TipoDestinatario = "Profesional",
                Nombre = doc.Nombre,
                Url = doc.Url,
                Fecha = doc.Fecha
            });
        }
        
        await _context.SaveChangesAsync();
        
        return new MaterialSyncResult { Success = true };
    }
}
```

### 🔗 Paso 5.3: Propagación al Grafo

**Script SQL:** `scripts_propagacion/50_propagar_materiales_informativos_grafo.sql`

```sql
-- Crear nodos MaterialInformativo
INSERT INTO graph_node (node_type, node_key, props)
SELECT 
    'MaterialInformativo',
    mi."Id"::text,
    jsonb_build_object(
        'nregistro', mi."NRegistro",
        'titulo', mi."Titulo",
        'tienePaciente', mi."TieneMaterialesPaciente",
        'tieneProfesional', mi."TieneMaterialesProfesional",
        'tieneVideo', mi."TieneVideo"
    )
FROM "MaterialesInformativos" mi
ON CONFLICT (node_type, node_key) DO UPDATE
SET props = EXCLUDED.props;

-- Relación Medicamento → MaterialInformativo
INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
SELECT 
    'Medicamento',
    m."NRegistro",
    'TIENE_MATERIAL_INFORMATIVO',
    'MaterialInformativo',
    mi."Id"::text,
    jsonb_build_object(
        'tienePaciente', mi."TieneMaterialesPaciente",
        'tieneProfesional', mi."TieneMaterialesProfesional"
    )
FROM "Medicamentos" m
JOIN "MaterialesInformativos" mi ON mi."NRegistro" = m."NRegistro"
ON CONFLICT (src_type, src_key, rel, dst_type, dst_key) DO UPDATE
SET props = EXCLUDED.props;
```

### 📈 KPIs Fase 5:
- ✅ Tabla `MaterialesInformativos` creada
- ✅ ~500-1,000 materiales informativos
- ✅ Documentos para pacientes y profesionales
- ✅ Propagado al grafo

---

## 🔗 FASE 6: PROPAGACIÓN COMPLETA AL GRAFO (1 DÍA)

### Paso 6.1: Script Maestro Propagación

**Script SQL:** `scripts_propagacion/51_propagacion_completa_final.sql`

```sql
-- PROPAGACIÓN COMPLETA CONSOLIDADA
-- Ejecuta todos los scripts de propagación en orden

-- 1. Actualizar documentos
\i scripts_propagacion/43_propagar_documentos_completos.sql

-- 2. Propagar teratogenia
\i scripts_propagacion/45_propagar_teratogenia_grafo.sql

-- 3. Propagar fotos
\i scripts_propagacion/46_propagar_fotos_grafo.sql

-- 4. Propagar problemas suministro
\i scripts_propagacion/48_propagar_problemas_suministro_grafo.sql

-- 5. Propagar materiales informativos
\i scripts_propagacion/50_propagar_materiales_informativos_grafo.sql

-- Verificación final
SELECT 
    node_type,
    COUNT(*) as "Cantidad"
FROM graph_node
GROUP BY node_type
ORDER BY COUNT(*) DESC;

SELECT 
    rel,
    COUNT(*) as "Cantidad"
FROM graph_edge
GROUP BY rel
ORDER BY COUNT(*) DESC;
```

### Paso 6.2: Actualizar Contadores Grafo

**Script SQL:** `scripts_propagacion/52_actualizar_estadisticas_grafo.sql`

```sql
-- Crear vista resumen grafo actualizada
CREATE OR REPLACE VIEW v_grafo_resumen AS
SELECT 
    'Nodos' as "Categoria",
    node_type as "Tipo",
    COUNT(*) as "Cantidad"
FROM graph_node
GROUP BY node_type
UNION ALL
SELECT 
    'Relaciones' as "Categoria",
    rel as "Tipo",
    COUNT(*) as "Cantidad"
FROM graph_edge
GROUP BY rel
ORDER BY "Categoria", "Cantidad" DESC;

-- Estadísticas globales
SELECT 
    (SELECT COUNT(*) FROM graph_node) as "TotalNodos",
    (SELECT COUNT(*) FROM graph_edge) as "TotalAristas",
    (SELECT COUNT(DISTINCT node_type) FROM graph_node) as "TiposNodos",
    (SELECT COUNT(DISTINCT rel) FROM graph_edge) as "TiposRelaciones";
```

### 📈 KPIs Fase 6:
- ✅ Todas las nuevas entidades en grafo
- ✅ Nuevos tipos de nodos: 5 (Teratogenia, ProblemaSuministro, etc.)
- ✅ Nuevas relaciones: 5 tipos
- ✅ Total nodos: ~90,000+
- ✅ Total aristas: ~750,000+

---

## 🚀 FASE 7: ÍNDICES OPTIMIZADOS + VISTAS (1 DÍA)

### Paso 7.1: Índices Completos

**Script SQL:** `scripts_propagacion/53_crear_indices_completos_finales.sql`

```sql
-- ÍNDICES PARA NUEVAS TABLAS

-- Teratogenia
CREATE INDEX CONCURRENTLY "IX_Teratogenia_CategoriaFDA_Trimestre1" 
    ON "Teratogenia"("CategoriaFDA", "Trimestre1");

-- Problemas Suministro
CREATE INDEX CONCURRENTLY "IX_ProblemasSuministro_Activo_FechaInicio" 
    ON "ProblemasSuministro"("Activo", "FechaInicio");
CREATE INDEX CONCURRENTLY "IX_ProblemasSuministro_CN_Activo" 
    ON "ProblemasSuministro"("CN", "Activo");

-- Materiales Informativos  
CREATE INDEX CONCURRENTLY "IX_MaterialesInformativos_TieneMateriales" 
    ON "MaterialesInformativos"("TieneMaterialesPaciente", "TieneMaterialesProfesional");
CREATE INDEX CONCURRENTLY "IX_MaterialInformativoDoc_MaterialId_Tipo" 
    ON "MaterialInformativoDocumento"("MaterialId", "TipoDestinatario");

-- Documento (optimización búsquedas)
CREATE INDEX CONCURRENTLY "IX_Documento_Downloaded_Tipo" 
    ON "Documento"("Downloaded", "Tipo");
CREATE INDEX CONCURRENTLY "IX_Documento_NRegistro_Downloaded" 
    ON "Documento"("NRegistro", "Downloaded");

-- Foto (optimización)
CREATE INDEX CONCURRENTLY "IX_Foto_NRegistro_Tipo" 
    ON "Foto"("NRegistro", "Tipo");

-- ÍNDICES GRAFO (si no existen)
CREATE INDEX CONCURRENTLY IF NOT EXISTS "IX_graph_node_props_gin" 
    ON graph_node USING GIN (props);
CREATE INDEX CONCURRENTLY IF NOT EXISTS "IX_graph_edge_props_gin" 
    ON graph_edge USING GIN (props);
CREATE INDEX CONCURRENTLY IF NOT EXISTS "IX_graph_edge_rel_src" 
    ON graph_edge (rel, src_type, src_key);
CREATE INDEX CONCURRENTLY IF NOT EXISTS "IX_graph_edge_rel_dst" 
    ON graph_edge (rel, dst_type, dst_key);
```

### Paso 7.2: Vistas Materializadas Actualizadas

**Script SQL:** `scripts_propagacion/54_actualizar_vistas_materializadas_final.sql`

```sql
-- Actualizar vistas materializadas existentes
REFRESH MATERIALIZED VIEW CONCURRENTLY search_terms_mv;
REFRESH MATERIALIZED VIEW CONCURRENTLY v_presentacion_golden;
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_med_excip_agg;
REFRESH MATERIALIZED VIEW CONCURRENTLY meds_ft_mv;
REFRESH MATERIALIZED VIEW CONCURRENTLY v_catalogo_cobertura;

-- Nueva vista materializada: Medicamentos con alertas completas
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_medicamentos_alertas_completas AS
SELECT 
    m."NRegistro",
    m."Nombre",
    -- Flags
    (SELECT COUNT(*) FROM graph_edge ge 
     WHERE ge.src_type = 'Medicamento' 
     AND ge.src_key = m."NRegistro" 
     AND ge.rel = 'TIENE_FLAG') as "CantidadFlags",
    -- Alertas Geriátricas
    (SELECT COUNT(*) FROM graph_edge ge 
     WHERE ge.src_type = 'Medicamento' 
     AND ge.src_key = m."NRegistro" 
     AND ge.rel = 'TIENE_ALERTA_GERIATRIA') as "AlertasGeriatricas",
    -- Notas Seguridad
    (SELECT COUNT(*) FROM graph_edge ge 
     WHERE ge.src_type = 'Medicamento' 
     AND ge.src_key = m."NRegistro" 
     AND ge.rel = 'TIENE_NOTA_SEGURIDAD') as "NotasSeguridad",
    -- Interacciones
    (SELECT COUNT(*) FROM graph_edge ge1
     JOIN graph_edge ge2 ON ge2.rel = 'INTERACCIONA_CON'
     WHERE ge1.src_type = 'Medicamento'
     AND ge1.src_key = m."NRegistro"
     AND ge1.rel = 'PERTENECE_A_ATC'
     AND ge1.dst_key = ge2.src_key) as "Interacciones",
    -- Biomarcadores
    (SELECT COUNT(*) FROM graph_edge ge 
     WHERE ge.src_type = 'Medicamento' 
     AND ge.src_key = m."NRegistro" 
     AND ge.rel = 'TIENE_BIOMARCADOR') as "Biomarcadores",
    -- Teratogenia
    EXISTS(SELECT 1 FROM "Teratogenia" t WHERE t."NRegistro" = m."NRegistro") as "TieneTeratogenia",
    -- Problemas Suministro Activos
    EXISTS(SELECT 1 FROM "ProblemasSuministro" ps 
           WHERE ps."NRegistro" = m."NRegistro" AND ps."Activo" = true) as "TieneProblemasSuministro",
    -- Materiales Informativos
    EXISTS(SELECT 1 FROM "MaterialesInformativos" mi 
           WHERE mi."NRegistro" = m."NRegistro") as "TieneMaterialesInformativos",
    -- Documentos
    (SELECT COUNT(*) FROM "Documento" d 
     WHERE d."NRegistro" = m."NRegistro" AND d."Downloaded" = true) as "DocumentosDescargados",
    -- Fotos
    (SELECT COUNT(*) FROM "Foto" f WHERE f."NRegistro" = m."NRegistro") as "Fotos"
FROM "Medicamentos" m;

CREATE UNIQUE INDEX ON mv_medicamentos_alertas_completas ("NRegistro");

-- Nueva vista: Búsqueda completa con todo
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_busqueda_completa AS
SELECT 
    m."NRegistro",
    m."Nombre",
    m."DCI",
    m."ATC",
    m."LabTitular",
    m."FormaFarmaceutica",
    m."Comercializado",
    -- Alertas y flags
    ma."CantidadFlags",
    ma."AlertasGeriatricas",
    ma."NotasSeguridad",
    ma."Interacciones",
    ma."Biomarcadores",
    ma."TieneTeratogenia",
    ma."TieneProblemasSuministro",
    ma."TieneMaterialesInformativos",
    ma."DocumentosDescargados",
    ma."Fotos",
    -- Para búsqueda full-text
    to_tsvector('spanish', 
        COALESCE(m."Nombre", '') || ' ' || 
        COALESCE(m."DCI", '') || ' ' ||
        COALESCE(m."ATC", '')
    ) as "SearchVector"
FROM "Medicamentos" m
LEFT JOIN mv_medicamentos_alertas_completas ma ON ma."NRegistro" = m."NRegistro";

CREATE INDEX ON mv_busqueda_completa USING GIN ("SearchVector");
CREATE UNIQUE INDEX ON mv_busqueda_completa ("NRegistro");
```

### Paso 7.3: Funciones de Búsqueda Optimizadas

**Script SQL:** `scripts_propagacion/55_funciones_busqueda_optimizadas.sql`

```sql
-- Función buscar medicamentos con info completa
CREATE OR REPLACE FUNCTION buscar_medicamentos_completo(
    p_query TEXT,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    "NRegistro" VARCHAR,
    "Nombre" VARCHAR,
    "LabTitular" VARCHAR,
    "Comercializado" BOOLEAN,
    "TieneAlertas" BOOLEAN,
    "TieneProblemasSuministro" BOOLEAN,
    "Relevancia" REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mb."NRegistro",
        mb."Nombre",
        mb."LabTitular",
        mb."Comercializado",
        (mb."AlertasGeriatricas" > 0 OR mb."NotasSeguridad" > 0) as "TieneAlertas",
        mb."TieneProblemasSuministro",
        ts_rank(mb."SearchVector", plainto_tsquery('spanish', p_query)) as "Relevancia"
    FROM mv_busqueda_completa mb
    WHERE mb."SearchVector" @@ plainto_tsquery('spanish', p_query)
    ORDER BY "Relevancia" DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Función obtener resumen completo medicamento
CREATE OR REPLACE FUNCTION obtener_medicamento_resumen(p_nregistro VARCHAR)
RETURNS JSON AS $$
DECLARE
    v_resultado JSON;
BEGIN
    SELECT json_build_object(
        'medicamento', row_to_json(m),
        'alertas', (SELECT json_build_object(
            'flags', ma."CantidadFlags",
            'geriatricas', ma."AlertasGeriatricas",
            'notasSeguridad', ma."NotasSeguridad",
            'interacciones', ma."Interacciones",
            'biomarcadores', ma."Biomarcadores"
        ) FROM mv_medicamentos_alertas_completas ma WHERE ma."NRegistro" = p_nregistro),
        'riesgos', (SELECT row_to_json(t) FROM "Teratogenia" t WHERE t."NRegistro" = p_nregistro),
        'suministro', (SELECT json_agg(row_to_json(ps)) FROM "ProblemasSuministro" ps 
                       WHERE ps."NRegistro" = p_nregistro AND ps."Activo" = true),
        'materiales', (SELECT row_to_json(mi) FROM "MaterialesInformativos" mi 
                      WHERE mi."NRegistro" = p_nregistro),
        'documentos', (SELECT json_agg(row_to_json(d)) FROM "Documento" d 
                      WHERE d."NRegistro" = p_nregistro AND d."Downloaded" = true),
        'fotos', (SELECT json_agg(row_to_json(f)) FROM "Foto" f 
                 WHERE f."NRegistro" = p_nregistro)
    ) INTO v_resultado
    FROM "Medicamentos" m
    WHERE m."NRegistro" = p_nregistro;
    
    RETURN v_resultado;
END;
$$ LANGUAGE plpgsql;
```

### 📈 KPIs Fase 7:
- ✅ 15+ índices nuevos creados
- ✅ 2 vistas materializadas nuevas
- ✅ Funciones de búsqueda optimizadas
- ✅ Performance queries 50-100x más rápido

---

## ✅ RESUMEN FINAL Y CHECKLIST

### 📊 Estado Final Esperado (100% Completo):

| Entidad | Antes | Después | % Completitud |
|---------|-------|---------|---------------|
| **Medicamentos** | 20,271 | 20,271 | 100% |
| **Presentaciones** | 29,540 | 29,540 | 100% |
| **Documentos** | 309 (0.7%) | ~42,000 (95%+) | **95%+** ✅ |
| **Fotos** | 44 (0.1%) | ~27,000 (90%+) | **90%+** ✅ |
| **Teratogenia** | 0 | ~8,000 | **100%** ✅ |
| **Problemas Suministro** | 0 | ~500 | **100%** ✅ |
| **Materiales Informativos** | 0 | ~1,000 | **100%** ✅ |
| **Índices** | 41 | 56+ | **100%** ✅ |
| **Vistas Materializadas** | 5 | 7 | **100%** ✅ |
| **Nodos Grafo** | 88,661 | ~95,000 | **100%** ✅ |
| **Aristas Grafo** | 742,101 | ~760,000 | **100%** ✅ |

---

## 📅 CRONOGRAMA SUGERIDO

### Semana 1 (Días 1-5):
- **Día 1-2:** Documentos (sesiones largas)
- **Día 3:** Documentos (finalizar) + Teratogenia
- **Día 4-5:** Fotos (scraping masivo)

### Semana 2 (Días 6-10):
- **Día 6-7:** Fotos (completar) + Problemas Suministro
- **Día 8:** Materiales Informativos
- **Día 9:** Propagación completa al grafo
- **Día 10:** Índices + Vistas + Testing

### Semana 3 (Días 11-15):
- **Día 11-12:** Verificación + Correcciones
- **Día 13-14:** Testing exhaustivo + Documentación
- **Día 15:** **✅ BD 100% COMPLETA → FRONTEND**

---

## 🎯 PRÓXIMOS PASOS INMEDIATOS

### 1. **HOY (05/10/2025):**
```bash
# Ejecutar descarga documentos (sesión tarde)
.\DESCARGAR_RESTANTES_ULTRA_LENTO.ps1
```

### 2. **Mañana (06/10/2025):**
```bash
# Sesión mañana documentos
.\DESCARGAR_RESTANTES_ULTRA_LENTO.ps1

# Parsear teratogenia
python etl/python/extract_teratogenia.py
psql -f scripts_propagacion/45_propagar_teratogenia_grafo.sql
```

### 3. **Siguiente semana:**
- Fotos, Problemas Suministro, Materiales Informativos
- Propagación completa
- Índices y vistas

---

## 🎉 CONCLUSIÓN

Al completar este roadmap tendrás:

✅ **La base de datos farmacéutica más completa de España**
✅ **100% de datos necesarios para frontend avanzado**
✅ **Performance optimizada (50-100x)**
✅ **Grafo semántico completo (95K nodos, 760K aristas)**
✅ **Medicina personalizada + Seguridad + Teratogenia**
✅ **Sistema listo para producción**

**Total:** 12-15 días de trabajo → BD 100% completa → Frontend

---

**FIN DEL ROADMAP**  
*Documento generado: 05/10/2025*  
*Próxima actualización: Según avance fases*
