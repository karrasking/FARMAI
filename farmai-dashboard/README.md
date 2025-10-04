# 🏥 FARMAI Dashboard - Admin Control Center

Dashboard administrativo moderno y profesional para el sistema FARMAI de gestión farmacéutica, conectado a la base de datos CIMA AEMPS.

![FARMAI Dashboard](https://img.shields.io/badge/Version-1.0.0-blue)
![React](https://img.shields.io/badge/React-18-61DAFB?logo=react)
![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?logo=typescript)
![Tailwind](https://img.shields.io/badge/Tailwind-3-38B2AC?logo=tailwind-css)

## ✨ Características

### 📊 **Dashboard Principal**
- **8 KPIs en tiempo real**: Medicamentos, Presentaciones, Principios Activos, Interacciones, Laboratorios, Excipientes, Biomarcadores y Documentos
- **4 Gráficas interactivas**:
  - Crecimiento mensual (gráfica de línea)
  - Top 10 laboratorios (gráfica de barras)
  - Distribución de alertas (gráfica donut)
  - Estado del grafo (gráfica radar)
- **Tabla de actualizaciones** con los últimos registros modificados

### 🔄 **Control de Sincronización**
- **Actualización diaria**: Sincronización incremental desde CIMA
- **Actualización mensual**: Descarga completa del XML del nomenclátor
- **Controles de activación/desactivación** para cada tipo de sincronización
- **Historial completo** de ejecuciones con estados y duraciones
- **Ejecución manual** bajo demanda

### 🔍 **Buscador Inteligente**
- **Búsqueda en tiempo real** entre 20,271 medicamentos
- **Filtros avanzados**:
  - Por tipo de medicamento (Genérico / No genérico)
  - Por requisito de receta (Sí / No)
- **Resultados detallados** con badges informativos
- **Acciones rápidas**: Ver detalle y ficha técnica

## 🚀 Inicio Rápido

### Prerrequisitos

- **Node.js** 18+ y **npm** 9+
- **Sistema operativo**: Windows, macOS o Linux

### Instalación

1. **Navega al directorio del dashboard**:
```bash
cd farmai-dashboard
```

2. **Instala las dependencias** (ya instaladas):
```bash
npm install
```

3. **Inicia el servidor de desarrollo**:
```bash
npm run dev
```

4. **Abre tu navegador** en:
```
http://localhost:5173
```

## 📦 Stack Tecnológico

### Frontend Core
- **React 18** - Biblioteca UI
- **TypeScript 5** - Type safety
- **Vite** - Build tool ultra-rápido

### Routing & Estado
- **React Router v6** - Navegación
- **TanStack Query** - Gestión de estado servidor

### UI & Estilización
- **Tailwind CSS 3** - Utility-first CSS
- **Lucide React** - Iconos modernos
- **shadcn/ui inspired** - Componentes reutilizables

### Gráficas & Visualización
- **Chart.js** - Librería de gráficas
- **react-chartjs-2** - Wrapper para React

### Forms & Validación
- **React Hook Form** - Gestión de formularios
- **Zod** - Validación de esquemas

### HTTP Client
- **Axios** - Cliente HTTP

### Utilities
- **clsx** + **tailwind-merge** - Gestión de clases CSS
- **date-fns** - Manipulación de fechas

## 📁 Estructura del Proyecto

```
farmai-dashboard/
├── src/
│   ├── components/
│   │   ├── ui/                    # Componentes base reutilizables
│   │   │   ├── button.tsx        # Componente Button
│   │   │   └── card.tsx          # Componente Card
│   │   └── Layout.tsx            # Layout principal con navegación
│   ├── pages/
│   │   ├── DashboardPage.tsx     # Página Dashboard (KPIs + gráficas)
│   │   ├── SyncPage.tsx          # Página Sincronización
│   │   └── SearchPage.tsx        # Página Buscador
│   ├── lib/
│   │   └── utils.ts              # Utilidades (cn helper)
│   ├── App.tsx                   # Componente raíz con Router
│   ├── main.tsx                  # Entry point
│   └── index.css                 # Estilos globales + Tailwind
├── public/                        # Assets estáticos
├── index.html                    # HTML template
├── package.json                  # Dependencias
├── tsconfig.json                 # Configuración TypeScript
├── vite.config.ts               # Configuración Vite
├── tailwind.config.js           # Configuración Tailwind
└── postcss.config.js            # Configuración PostCSS
```

## 🎨 Componentes Principales

### Dashboard

```typescript
// src/pages/DashboardPage.tsx
- 8 KPIs con iconos
- 4 gráficas (Line, Bar, Doughnut, Radar)
- Tabla de actualizaciones recientes
```

### Sincronización

```typescript
// src/pages/SyncPage.tsx
- Control de sincronización diaria
- Control de sincronización mensual
- Historial de ejecuciones
```

### Buscador

```typescript
// src/pages/SearchPage.tsx
- Input de búsqueda con debounce
- Filtros avanzados
- Lista de resultados con paginación
```

## 🔧 Configuración

### Variables de Entorno (Futuro)

Cuando conectes al backend real, crea un archivo `.env`:

```env
VITE_API_URL=http://localhost:5000/api
VITE_API_TIMEOUT=30000
```

### Configuración de API (Futuro)

```typescript
// src/lib/api.ts
import axios from 'axios'

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5000/api',
  timeout: 30000,
})
```

## 📊 Endpoints del Backend (Para Implementar)

### Dashboard
```http
GET /api/dashboard/kpis
GET /api/dashboard/growth-monthly
GET /api/dashboard/top-laboratorios
GET /api/dashboard/alertas-summary
GET /api/dashboard/grafo-stats
GET /api/dashboard/latest-updates
```

### Sincronización
```http
GET /api/sync/status
POST /api/sync/run-daily
POST /api/sync/nomenclator/run
GET /api/sync/history
```

### Medicamentos
```http
GET /api/medicamentos/search?q={query}&limit={limit}
GET /api/medicamentos/{nregistro}
```

## 🛠️ Scripts Disponibles

```bash
# Desarrollo
npm run dev          # Inicia servidor de desarrollo (puerto 5173)

# Build
npm run build        # Compila para producción

# Preview
npm run preview      # Previsualiza build de producción

# Lint
npm run lint         # Ejecuta ESLint
```

## 🎯 Próximos Pasos

### Para Conectar al Backend Real:

1. **Crea los endpoints** en `Farmai.Api` (ver sección de endpoints)
2. **Configura axios** en `src/lib/api.ts`
3. **Reemplaza mock data** en las páginas con llamadas a TanStack Query
4. **Añade manejo de errores** y loading states
5. **Implementa autenticación** si es necesario

### Ejemplo de Integración con TanStack Query:

```typescript
// src/hooks/useKPIs.ts
import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/api'

export function useKPIs() {
  return useQuery({
    queryKey: ['kpis'],
    queryFn: async () => {
      const { data } = await api.get('/dashboard/kpis')
      return data
    },
    staleTime: 5 * 60 * 1000, // 5 minutos
  })
}

// Uso en DashboardPage.tsx
const { data: kpis, isLoading, error } = useKPIs()
```

## 🎨 Personalización

### Cambiar Colores Primarios

Edita `src/index.css`:

```css
:root {
  --primary: 221.2 83.2% 53.3%;  /* Azul por defecto */
  /* Cambia a tu color preferido */
}
```

### Añadir Nuevos Componentes UI

Los componentes siguen el patrón de shadcn/ui. Ejemplo:

```typescript
// src/components/ui/badge.tsx
import { cn } from '@/lib/utils'

export function Badge({ className, ...props }) {
  return (
    <span className={cn("inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium", className)} {...props} />
  )
}
```

## 📝 Notas Importantes

### Mock Data
- Actualmente el dashboard usa **datos de ejemplo** (mock data)
- Los datos reflejan la estructura real de la base de datos FARMAI
- Para producción, conecta a los endpoints reales del backend

### Performance
- Las gráficas están optimizadas con `Chart.js`
- TanStack Query maneja caché automático
- Lazy loading de componentes disponible si es necesario

### Responsive Design
- El dashboard es **totalmente responsive**
- Probado en móviles, tablets y desktop
- Breakpoints: `sm: 640px`, `md: 768px`, `lg: 1024px`, `xl: 1280px`

## 🤝 Contribuciones

Este es un proyecto interno de FARMAI. Para cambios:

1. Crea una rama feature
2. Implementa tus cambios
3. Asegúrate que el build funciona (`npm run build`)
4. Crea un PR con descripción detallada

## 📄 Licencia

© 2025 FARMAI - Sistema de Gestión Farmacéutica

---

**Desarrollado con ❤️ para farmacias y médicos de España**

Para soporte o preguntas, contacta al equipo de desarrollo.
