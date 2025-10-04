# 🚀 CÓMO LANZAR EL DASHBOARD FARMAI

## ✅ OPCIÓN 1: Doble clic (MÁS FÁCIL)

1. Haz **doble clic** en el archivo: `LANZAR_DASHBOARD.bat`
2. Se abrirá automáticamente tu navegador en http://localhost:5173

---

## ✅ OPCIÓN 2: Manual

1. Abre una terminal en la carpeta del proyecto
2. Ejecuta:
   ```bash
   cd farmai-dashboard
   npm run dev
   ```
3. Abre tu navegador en: http://localhost:5173

---

## 📊 ¿QUÉ VAS A VER EN EL DASHBOARD?

El dashboard tiene **3 páginas principales**:

### 🏠 PÁGINA PRINCIPAL (Dashboard)

#### 8 KPIs en Tarjetas:
- 💊 **Medicamentos**: 20,271
- 📦 **Presentaciones**: 29,540
- 🔬 **Principios Activos**: 4,885
- ⚠️ **Interacciones**: 52,325
- 🏢 **Laboratorios**: 1,351
- ⚗️ **Excipientes**: 574
- 🧬 **Biomarcadores**: 47
- 📄 **Documentos**: 309

#### 4 Gráficas Interactivas:
1. **Gráfica de Línea**: Crecimiento mensual de medicamentos (Ene-Dic 2025)
2. **Gráfica de Barras Horizontal**: Top 10 laboratorios por volumen
3. **Gráfica Donut**: Distribución de alertas de seguridad
4. **Gráfica Radar**: Estado del grafo de conocimiento

#### Tabla:
- Últimas 5 actualizaciones de medicamentos

---

### 🔄 PÁGINA DE SINCRONIZACIÓN (Sync)

#### 2 Tarjetas de Control:
1. **Sincronización Diaria**:
   - Estado: Activa
   - Última ejecución: 2025-10-04 02:00:00
   - Registros procesados: 152
   - Botones: Activar/Desactivar, Ejecutar Ahora, Ver Logs

2. **Sincronización Mensual**:
   - Estado: Pendiente
   - Última ejecución: 2025-10-01 03:15:00
   - Tamaño: 150 MB
   - Botones: Descargar Ahora, Configurar URL

#### Tabla de Historial:
- Últimas 6 sincronizaciones con:
  - Fecha y hora
  - Tipo (Diaria/Mensual)
  - Registros procesados
  - Duración
  - Estado (Éxito/Error)

---

### 🔍 PÁGINA DE BÚSQUEDA (Search)

#### Buscador:
- Input de búsqueda con icono
- Botón "Buscar"
- Botón "Filtros" (colapsable)

#### Filtros Avanzados:
1. **Genérico**: Sí / No / Todos
2. **Requiere Receta**: Sí / No / Todos

#### Resultados:
- 5 medicamentos de ejemplo:
  - IBUPROFENO CINFA 600 mg
  - DIFENADOL RAPID 400 mg
  - PARACETAMOL NORMON 1g
  - OMEPRAZOL TEVA 20 mg
  - ATORVASTATINA SANDOZ 40mg

- Cada medicamento muestra:
  - Nombre completo
  - N° Registro (badge gris)
  - Laboratorio (badge azul)
  - Genérico EFG (badge verde)
  - Receta (badge naranja)
  - Comercializado (badge verde esmeralda)
  - 2 botones: "Ver Detalle" y "Ficha Técnica"

---

## 🎨 CARACTERÍSTICAS VISUALES

### Diseño:
- ✅ **Colores**: Azul predominante (tema profesional)
- ✅ **Iconos**: Lucide React (modernos y claros)
- ✅ **Responsive**: Se adapta a móvil, tablet y desktop
- ✅ **Animaciones**: Hover effects en tarjetas y tablas
- ✅ **Tipografía**: Clara y legible

### Navegación:
- **Menú superior** con 3 opciones:
  1. 📊 Dashboard
  2. 🔄 Sincronización
  3. 🔍 Búsqueda

---

## 📝 NOTAS IMPORTANTES

### Datos Actuales:
- ⚠️ **Todos los datos son DE EJEMPLO (mock data)**
- ⚠️ Los botones muestran alertas simuladas
- ⚠️ No está conectado al backend real (aún)

### Próximos Pasos:
- Conectar al API REST cuando esté listo
- Reemplazar mock data con datos reales
- Añadir autenticación (si es necesario)

---

## ❓ PROBLEMAS COMUNES

### El dashboard no carga:
1. Verifica que el servidor esté corriendo (http://localhost:5173)
2. Revisa que no haya errores en la consola
3. Asegúrate de tener Node.js 18+ instalado

### Puerto 5173 ocupado:
- Vite asignará automáticamente otro puerto (5174, 5175, etc.)
- Revisa la terminal para ver el puerto correcto

---

## 🎯 RESUMEN

**Para verlo ahora mismo:**
1. Haz doble clic en `LANZAR_DASHBOARD.bat`
2. O abre tu navegador en: http://localhost:5173

**Verás:**
- Dashboard profesional con 8 KPIs
- 4 gráficas interactivas
- Control de sincronización
- Buscador de medicamentos
- Diseño moderno y responsive

**Datos:**
- Todo es mock data (de ejemplo)
- Listo para conectar al backend cuando quieras

---

✨ **¡Disfruta explorando el dashboard FARMAI!** ✨
