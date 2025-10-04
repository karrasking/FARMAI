# 🏥 FARMAI - Base de Datos Farmacéutica Inteligente

> **La base de datos farmacéutica más completa de España**  
> Sistema de conocimiento farmacéutico con medicina personalizada y seguridad integrada

[![Estado](https://img.shields.io/badge/Estado-Producción-success)](.)
[![Cobertura](https://img.shields.io/badge/Cobertura-100%25%20Medicamentos%20España-blue)](.)
[![Grafo](https://img.shields.io/badge/Grafo-830K%20relaciones-purple)](.)
[![Dashboard](https://img.shields.io/badge/Dashboard-React%2018-61DAFB)](./)
[![Actualización](https://img.shields.io/badge/Última%20Actualización-04%2F10%2F2025-orange)](.)

---

## 📋 Tabla de Contenidos
1. [Resumen Ejecutivo](#-resumen-ejecutivo)
2. [Arquitectura del Sistema](#-arquitectura-del-sistema)
3. [Características Principales](#-características-principales)
4. [Grafo de Conocimiento](#-grafo-de-conocimiento-farmacéutico)
5. [Fuentes de Datos](#-fuentes-de-datos)
6. [Instalación y Configuración](#-instalación-y-configuración)
7. [Uso de la API](#-uso-de-la-api)
8. [Dashboard Administrativo](#-dashboard-administrativo)
9. [Scripts y Mantenimiento](#-scripts-y-mantenimiento)
10. [Documentación Técnica](#-documentación-técnica)
11. [Estado del Proyecto](#-estado-del-proyecto)

---

## 🎯 Resumen Ejecutivo

FARMAI es una base de datos farmacéutica avanzada que integra información de **100% de los medicamentos autorizados en España**, enriquecida con:

### 📊 Números Clave
| Métrica | Valor | Descripción |
|---------|-------|-------------|
| **Medicamentos** | 20,271 | Autorizados por AEMPS |
| **Presentaciones** | 29,540 | Códigos nacionales (CN) |
| **Nodos Grafo** | 88,661 | 27 tipos diferentes |
| **Relaciones** | 742,101 | 27 tipos de conexiones |
| **Tamaño DB** | ~650 MB | Optimizado con índices |
| **Performance** | 10-50x | Vs. queries directas |

### ✨ Capacidades Únicas
- ✅ **Medicina Personalizada**: Farmacogenómica integrada (47 genes)
- ✅ **Seguridad Avanzada**: 111K flags + alertas geriátricas
- ✅ **Interacciones**: 52K interacciones medicamentosas
- ✅ **Grafo Semántico**: Consultas complejas en milisegundos
- ✅ **Búsqueda Inteligente**: Full-text + sinónimos
- ✅ **Actualización Automática**: Sincronización mensual CIMA

---

## 🏗️ Arquitectura del Sistema

### Arquitectura de 3 Capas

```
┌────────────────────────────────────────────────────────────────┐
│                    CAPA 1: ORIGEN DE DATOS                      │
├────────────────────────────────────────────────────────────────┤
│  • XML CIMA/AEMPS (prescripcion.xml - 150 MB)                  │
│  • API REST CIMA (Documentos, Fotos)                           │
│  • APIs Externas (SNOMED CT, DrugBank, ATC/WHO)                │
│  • Diccionarios Normalización (22 diccionarios)                │
└────────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────────┐
│                 CAPA 2: STAGING Y ETL (166 MB)                  │
├────────────────────────────────────────────────────────────────┤
│  • 22 Tablas Staging (PrescripcionStaging, etc.)               │
│  • 22 Diccionarios (DCP, DCPF, DCSA, ATC, etc.)                │
│  • Scripts Python ETL (parsing, validación, normalización)      │
│  • Mapeo y Resolución de Ambigüedades                          │
└────────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────────┐
│            CAPA 3: PERSISTENCIA Y GRAFO (565 MB)                │
├────────────────────────────────────────────────────────────────┤
│  • Tablas Relacionales (PostgreSQL - 75 tablas)                │
│  • Grafo de Conocimiento (graph_node + graph_edge)             │
│  • Vistas Materializadas (5) + Vistas (36)                     │
│  • Índices Optimizados (41+) + Foreign Keys (69)               │
└────────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────────┐
│                      API REST (.NET 6)                          │
├────────────────────────────────────────────────────────────────┤
│  • Controllers: Medicamentos, CIMA, Import, Sync               │
│  • Services: CimaClient, ImportService, SyncService             │
│  • Entity Framework Core + Migrations                           │
└────────────────────────────────────────────────────────────────┘
```

### Stack Tecnológico

| Componente | Tecnología | Versión |
|------------|-----------|---------|
| **Backend** | .NET | 6.0 |
| **Base de Datos** | PostgreSQL | 14+ |
| **ORM** | Entity Framework Core | 6.0 |
| **ETL** | Python | 3.9+ |
| **Contenedores** | Docker | Latest |
| **Orquestación** | Docker Compose | v2 |

---

## 🎨 Características Principales

### 1. 🧬 Medicina Personalizada (Farmacogenómica)

**47 Biomarcadores Genéticos** que personalizan tratamientos:

| Gene | Medicamentos Afectados | Tipo Interacción |
|------|------------------------|------------------|
| CYP2D6 | 450+ | Metabolismo |
| CYP2C19 | 320+ | Metabolismo |
| CYP2C9 | 280+ | Metabolismo |
| CYP3A4/5 | 890+ | Metabolismo |
| TPMT | 12 | Toxicidad (azatioprina) |
| HLA-B*5701 | 1 | Hipersensibilidad (abacavir) |
| ... | | |

**Casos de Uso:**
- Ajuste automático de dosis según genotipo
- Alertas de incompatibilidad gen-fármaco
- Prevención de reacciones adversas graves
- Medicina de precisión poblacional

### 2. 🛡️ Sistema de Seguridad Farmacéutica

#### 111,191 Flags de Estado
- **EFG** (20,085): Medicamentos genéricos
- **Duplicidad** (36,867): Detecta combinaciones peligrosas
- **TLD** (2,453): Terapia larga duración
- **Biosimilar** (149): Biológicos similares
- **Especial** (1,421): Control especial
- Y 20 flags más...

#### 25,215 Alertas Geriátricas
- Medicamentos potencialmente inapropiados (criterios Beers/STOPP)
- Ajustes dosis por función renal
- Interacciones específicas edad avanzada

#### 5,719 Notas de Seguridad AEMPS
- Alertas de farmacovigilancia en tiempo real
- Restricciones de uso
- Cambios en ficha técnica

### 3. 🔗 Detección de Interacciones

**52,325 Interacciones Medicamentosas**
- Nivel ATC (clasificación terapéutica)
- Severidad clasificada (leve/moderada/grave)
- Mecanismo de interacción
- Recomendaciones clínicas

### 4. 🔍 Búsqueda Avanzada

#### Full-Text Search
- 5 vistas materializadas optimizadas
- Búsqueda por nombre comercial, principio activo, ATC
- Sinónimos y alias (586 mappings)
- Performance 10-50x más rápida

#### Búsqueda Semántica
- Grafo de conocimiento permite consultas complejas
- "Dame todos los medicamentos con ibuprofeno que sean EFG y tengan presentación en comprimidos"
- Navegación por relaciones (ATC → Medicamento → PA → Excipiente)

### 5. 📦 Información Completa Presentaciones

**29,540 Presentaciones** con:
- Código nacional (CN)
- Envase (65 tipos)
- Unidad contenido (57 tipos)
- Precio (PVP, PVL)
- Situación registro
- Composición detallada

---

## 🕸️ Grafo de Conocimiento Farmacéutico

### Estructura del Grafo

El corazón de FARMAI es su **grafo de conocimiento semántico** con 830K+ relaciones.

#### 27 Tipos de Nodos (88,661 total)

| # | Tipo | Cantidad | Descripción |
|---|------|----------|-------------|
| 1 | **Presentacion** | 29,540 | Códigos nacionales (CN) |
| 2 | **Medicamento** | 21,687 | Medicamentos autorizados |
| 3 | **DCPF** | 10,306 | Denominación Común Farmacéutica |
| 4 | **ATC** | 7,231 | Clasificación terapéutica |
| 5 | **DCP** | 6,951 | Denominación Común Propuesta |
| 6 | **PrincipioActivo** | 4,885 | Principios activos |
| 7 | **DCSA** | 2,463 | Denominación Común Sustancia Activa |
| 8 | **Laboratorio** | 1,351 | Fabricantes (con CIF, dirección) |
| 9 | **GrupoCIF** | 994 | Grupos empresariales |
| 10 | **Alias** | 586 | Sinónimos para búsqueda |
| ... | | | |

**Ver más:** [ANALISIS_COMPLETO_ARQUITECTURA_BD.md](ANALISIS_COMPLETO_ARQUITECTURA_BD.md)

#### 27 Tipos de Relaciones (742,101 total)

| # | Relación | Cantidad | Descripción |
|---|----------|----------|-------------|
| 1 | **TIENE_FLAG** | 111,191 | Estados medicamento |
| 2 | **PERTENECE_A_ATC** | 60,349 | Clasificación terapéutica |
| 3 | **INTERACCIONA_CON** | 52,325 | Interacciones |
| 4 | **CONTIENE_EXCIPIENTE** | 41,408 | Composición |
| 5 | **DUPLICIDAD_CON** | 36,867 | Medicamentos equivalentes |
| 6 | **TIENE_PRESENTACION** | 29,540 | Medicamento → Presentación |
| 7 | **CONTIENE_PA** | 25,073 | Principios activos |
| ... | | | |

### Consultas de Ejemplo

```cypher
// Encontrar todos los antiinflamatorios con ibuprofeno (EFG)
MATCH (m:Medicamento)-[:CONTIENE_PA]->(pa:PrincipioActivo)
WHERE pa.nombre = 'IBUPROFENO'
  AND (m)-[:TIENE_FLAG]->(f:Flag {nombre: 'EFG'})
RETURN m.nombre, m.laboratorio

// Detectar interacciones paciente polimedicado
MATCH (m1:Medicamento)-[:PERTENECE_A_ATC]->(atc1:ATC)
      -[:INTERACCIONA_CON]->(atc2:ATC)
      <-[:PERTENECE_A_ATC]-(m2:Medicamento)
WHERE m1.nregistro IN ['12345', '67890', ...]
RETURN m1.nombre, m2.nombre, interaction.severity

// Medicamentos inapropiados en geriatría
MATCH (m:Medicamento)-[:TIENE_ALERTA_GERIATRIA]->(a:AlertaGeriatria)
WHERE a.criterio IN ['BEERS', 'STOPP']
RETURN m.nombre, a.descripcion, a.severidad
```

---

## 📥 Fuentes de Datos

### 1. CIMA (Centro de Información de Medicamentos - AEMPS)

#### XML Prescripción
- **Frecuencia:** Mensual
- **Tamaño:** ~150 MB
- **Contenido:** 29,437 presentaciones completas
- **Procesamiento:** `etl/python/load_prescripcion_stream.py`

#### API REST
- **Base URL:** `https://cima.aemps.es/cima/rest/`
- **Endpoints:**
  - `/medicamento/{nregistro}` - Detalle medicamento
  - `/materiales/{nregistro}/docs` - Documentos (FT, Psum)
  - Fotos envases
- **Rate Limit:** Respetar robots.txt

### 2. APIs Externas

| API | Propósito | Datos |
|-----|-----------|-------|
| **SNOMED CT** | Farmacogenómica | 47 biomarcadores |
| **DrugBank** | Interacciones | 52K+ interacciones |
| **ATC/WHO** | Clasificación | 7,231 códigos |

### 3. Diccionarios CIMA (22 archivos)

- DCP, DCPF, DCSA (nomenclaturas)
- FormaFarmaceutica, FormaSimplificada
- ViaAdministracion
- Laboratorios, Situación Registro
- Envases, Unidades Contenido

---

## 🚀 Instalación y Configuración

### Requisitos Previos

- Docker y Docker Compose
- .NET 6 SDK
- Python 3.9+
- PostgreSQL 14+ (o vía Docker)

### Instalación Rápida

```bash
# 1. Clonar repositorio
git clone https://github.com/karrasking/FARMAI.git
cd FARMAI

# 2. Levantar servicios
docker-compose up -d

# 3. Ejecutar migraciones
cd Farmai.Api
dotnet ef database update

# 4. Cargar datos iniciales (ETL)
cd ../etl/python
pip install -r requirements.txt
python load_diccionarios.py
python load_prescripcion_stream.py

# 5. Propagar al grafo (ejecutar scripts en orden)
cd ../../scripts_propagacion
psql -h localhost -p 5433 -U postgres -d farmai_db -f 01_crear_nodos_situacion_registro.sql
# ... ejecutar scripts 01-39 en orden

# 6. Iniciar API
cd ../Farmai.Api
dotnet run
```

### Configuración

**appsettings.json:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5433;Database=farmai_db;Username=postgres;Password=postgres"
  },
  "CimaApi": {
    "BaseUrl": "https://cima.aemps.es/cima/rest/",
    "RateLimit": 10
  }
}
```

---

## 🔌 Uso de la API

### Endpoints Principales

#### Medicamentos
```http
GET /api/medicamentos
GET /api/medicamentos/{nregistro}
GET /api/medicamentos/search?q=ibuprofeno
GET /api/medicamentos/{nregistro}/interacciones
GET /api/medicamentos/{nregistro}/farmacogenetica
```

#### CIMA
```http
GET /api/cima/medicamento/{nregistro}
GET /api/cima/presentaciones/{cn}
```

#### Sincronización
```http
POST /api/sync/prescripcion
POST /api/sync/diccionarios
GET /api/sync/status
```

### Ejemplos

#### Buscar Medicamento
```bash
curl http://localhost:5000/api/medicamentos/search?q=paracetamol
```

**Respuesta:**
```json
{
  "total": 243,
  "results": [
    {
      "nregistro": "52846",
      "nombre": "GELOCATIL 1 g COMPRIMIDOS",
      "laboratorio": "GELOS",
      "atc": "N02BE01",
      "efg": true,
      "presentaciones": 3
    }
  ]
}
```

#### Verificar Interacciones
```bash
curl -X POST http://localhost:5000/api/medicamentos/interacciones \
  -H "Content-Type: application/json" \
  -d '{"nregistros": ["52846", "60823", "71042"]}'
```

---

## 🎨 Dashboard Administrativo

### Interfaz Web Moderna

FARMAI incluye un **dashboard administrativo profesional** construido con tecnologías modernas:

**Stack Tecnológico:**
- ✅ React 18 + TypeScript 5
- ✅ Vite (build ultra-rápido)
- ✅ Tailwind CSS 3 (diseño responsive)
- ✅ Chart.js (gráficas interactivas)
- ✅ TanStack Query (gestión de estado)
- ✅ Lucide React (iconografía moderna)

### Características del Dashboard

#### 📊 **Página Principal - Dashboard**
- **8 KPIs en tiempo real:**
  - Medicamentos (20,271)
  - Presentaciones (29,540)
  - Principios Activos (4,885)
  - Interacciones (52,325)
  - Laboratorios (1,351)
  - Excipientes (574)
  - Biomarcadores (47)
  - Documentos (309)

- **4 Gráficas Interactivas:**
  - Crecimiento mensual de medicamentos
  - Top 10 laboratorios por volumen
  - Distribución de alertas de seguridad
  - Estado del grafo de conocimiento

- **Tabla de Actualizaciones Recientes**

#### 🔄 **Página de Sincronización**
- Control de sincronización diaria (incremental)
- Control de sincronización mensual (XML completo)
- Activación/desactivación de tareas
- Historial completo de ejecuciones
- Métricas de rendimiento por sincronización

#### 🔍 **Buscador de Medicamentos**
- Búsqueda en tiempo real
- Filtros avanzados:
  - Por tipo (Genérico / No genérico)
  - Por requisito de receta
- Resultados con badges informativos
- Acciones rápidas (Ver detalle, Ficha técnica)

### Instalación del Dashboard

```bash
# Navegar al directorio
cd farmai-dashboard

# Instalar dependencias
npm install

# Iniciar servidor de desarrollo
npm run dev

# Abrir en navegador
# http://localhost:5173
```

### Estado del Dashboard

🟢 **COMPLETO** (con datos de ejemplo)
- ✅ 3 páginas funcionales
- ✅ Diseño responsive
- ✅ UI/UX profesional
- ✅ Listo para conectar al backend real

**Próximo paso:** Conectar endpoints del API REST para datos en tiempo real.

**Ver más:** [farmai-dashboard/README.md](farmai-dashboard/README.md)

---

## 🛠️ Scripts y Mantenimiento

### Scripts de Propagación (39 archivos SQL)

Ejecutar en orden en `scripts_propagacion/`:

| Pasos | Descripción | Tiempo |
|-------|-------------|--------|
| **01-10** | Setup inicial + Situación registro + Flags | 5 min |
| **11-20** | Sustancias activas + Excipientes + DCP | 10 min |
| **21-29** | Flags especiales (25 tipos) | 15 min |
| **30-34** | Consolidación PA + Normalización | 20 min |
| **35-39** | Vistas + Aliases + Vtm + Labs | 5 min |

**Tiempo total:** ~55 minutos

### Scripts Python ETL

En `etl/python/`:
- `load_diccionarios.py` - Carga diccionarios CIMA
- `load_prescripcion_stream.py` - Parsea XML prescripción
- `load_notas_interacciones.py` - Notas AEMPS
- `extract_biomarcadores.py` - Farmacogenómica
- `extract_prescription_completa.py` - Enriquecimiento

### Mantenimiento Mensual

```bash
# 1. Descargar nuevo XML CIMA
wget https://cima.aemps.es/cima/rest/medicamentos/prescripcion.xml

# 2. Ejecutar sincronización
python load_prescripcion_stream.py

# 3. Actualizar vistas materializadas
psql -f scripts_propagacion/35_actualizar_vistas_materializadas.sql

# 4. Verificar salud del grafo
psql -f etl/python/sql/graph_health_report.sql
```

---

## 📚 Documentación Técnica

### Documentos Disponibles

| Documento | Descripción | Estado |
|-----------|-------------|--------|
| **[ANALISIS_COMPLETO_ARQUITECTURA_BD.md](ANALISIS_COMPLETO_ARQUITECTURA_BD.md)** | Análisis exhaustivo arquitectura | ✅ |
| **[MEMORIA_ESTADO_FARMAI.md](MEMORIA_ESTADO_FARMAI.md)** | Estado actual del sistema | ✅ |
| **[LISTA_COMPLETA_PENDIENTES.md](LISTA_COMPLETA_PENDIENTES.md)** | Tareas pendientes | ✅ |
| **[INFORME_BASE_DATOS.md](INFORME_BASE_DATOS.md)** | Informe técnico BD | ✅ |
| **[README_INVESTIGACION.md](README_INVESTIGACION.md)** | Investigación y análisis | ✅ |

### Diagrams

```
docs/
├── arquitectura_sistema.png
├── flujo_etl.png
├── modelo_entidad_relacion.png
└── grafo_conocimiento.png
```

---

## 📊 Estado del Proyecto

### ✅ Completado (100% Funcional)

- ✅ **ETL Completo**: XML → Staging → Grafo
- ✅ **Grafo Semántico**: 88,661 nodos + 742,101 aristas
- ✅ **Medicina Personalizada**: 47 biomarcadores
- ✅ **Seguridad**: 111K flags + 25K alertas
- ✅ **Interacciones**: 52K relaciones
- ✅ **Búsqueda**: Full-text + sinónimos
- ✅ **Performance**: Índices + vistas materializadas
- ✅ **API REST**: .NET 6 con EF Core
- ✅ **Documentación**: Completa y actualizada

### 📈 Métricas de Calidad

| Métrica | Valor | Objetivo | Estado |
|---------|-------|----------|--------|
| Cobertura Medicamentos | 100% | 100% | ✅ |
| Cobertura Presentaciones | 100% | 100% | ✅ |
| Principios Activos | 98% | 95% | ✅ |
| Biomarcadores | 70% | 60% | ✅ |
| Performance Queries | 10-50x | 5x | ✅ |
| Integridad Referencial | 100% | 100% | ✅ |

### 🚧 Oportunidades de Mejora

1. **Documentos**: 1.5% completitud (309/20K+) → Scraping masivo
2. **Fotos**: 0.2% completitud (44/29K+) → Scraping masivo
3. **Teratogenia**: Campo XML no parseado → Script Python
4. **Farmacogenómica Avanzada**: Diplotipos + fenotipos
5. **NLP**: Extracción información de fichas técnicas

---

## 🤝 Contribución

¿Quieres contribuir? ¡Excelente!

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto está bajo licencia MIT. Ver archivo [LICENSE](LICENSE) para más detalles.

---

## 👥 Equipo

- **Arquitectura y Desarrollo**: Victor
- **Base de Datos**: PostgreSQL 14
- **Fuente Oficial**: AEMPS/CIMA

---

## 📞 Contacto

- **GitHub**: [@karrasking](https://github.com/karrasking)
- **Proyecto**: [FARMAI](https://github.com/karrasking/FARMAI)

---

## 🙏 Agradecimientos

- **AEMPS** (Agencia Española de Medicamentos y Productos Sanitarios)
- **CIMA** (Centro de Información de Medicamentos)
- Comunidad open-source de herramientas médicas

---

**⚡ FARMAI - Transformando la información farmacéutica en conocimiento accionable**

*Última actualización: 04/10/2025*
