import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Pill, Package, Microscope, AlertTriangle, Building2, Beaker, Activity, FileText } from 'lucide-react'
import { Line, Bar, Doughnut, Radar } from 'react-chartjs-2'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  RadialLinearScale,
  Title,
  Tooltip,
  Legend,
  Filler,
} from 'chart.js'

// Register ChartJS components
ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  RadialLinearScale,
  Title,
  Tooltip,
  Legend,
  Filler
)

// Mock data - En producción vendría del API
const kpis = {
  medicamentos: 20271,
  presentaciones: 29540,
  principiosActivos: 4885,
  interacciones: 52325,
  laboratorios: 1351,
  excipientes: 574,
  biomarcadores: 47,
  documentos: 309,
}

const growthData = {
  labels: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
  datasets: [{
    label: 'Medicamentos',
    data: [18500, 18800, 19100, 19350, 19600, 19850, 20000, 20100, 20150, 20200, 20250, 20271],
    borderColor: 'rgb(59, 130, 246)',
    backgroundColor: 'rgba(59, 130, 246, 0.1)',
    tension: 0.4,
    fill: true,
  }],
}

const topLabsData = {
  labels: ['CINFA', 'NORMON', 'KERN PHARMA', 'SANDOZ', 'TEVA', 'STADA', 'RATIOPHARM', 'BAYER', 'PFIZER', 'NOVARTIS'],
  datasets: [{
    label: 'Medicamentos',
    data: [1250, 1180, 1050, 980, 920, 850, 780, 720, 680, 650],
    backgroundColor: 'rgba(59, 130, 246, 0.8)',
  }],
}

const alertasData = {
  labels: ['Interacciones', 'Alerta Geriatría', 'Duplicidad', 'Otros'],
  datasets: [{
    data: [52325, 1250, 850, 420],
    backgroundColor: [
      'rgba(239, 68, 68, 0.8)',
      'rgba(245, 158, 11, 0.8)',
      'rgba(59, 130, 246, 0.8)',
      'rgba(107, 114, 128, 0.8)',
    ],
  }],
}

const grafoData = {
  labels: ['Medicamentos', 'Presentaciones', 'P. Activos', 'Excipientes', 'Laboratorios', 'Documentos'],
  datasets: [{
    label: 'Nodos en Grafo',
    data: [20271, 29540, 4885, 574, 1351, 309],
    backgroundColor: 'rgba(59, 130, 246, 0.2)',
    borderColor: 'rgb(59, 130, 246)',
    pointBackgroundColor: 'rgb(59, 130, 246)',
  }],
}

const latestUpdates = [
  { nregistro: '70039', nombre: 'IBUPROFENO CINFA 600 mg', fecha: '2025-10-04', estado: 'Activo' },
  { nregistro: '74559', nombre: 'DIFENADOL RAPID 400 mg', fecha: '2025-10-04', estado: 'Activo' },
  { nregistro: '65432', nombre: 'PARACETAMOL NORMON 1g', fecha: '2025-10-03', estado: 'Activo' },
  { nregistro: '78901', nombre: 'OMEPRAZOL TEVA 20 mg', fecha: '2025-10-03', estado: 'Activo' },
  { nregistro: '54321', nombre: 'ATORVASTATINA SANDOZ 40mg', fecha: '2025-10-02', estado: 'Activo' },
]

export function DashboardPage() {
  return (
    <div className="space-y-8">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-500 mt-1">Visión general del sistema FARMAI</p>
      </div>

      {/* KPIs Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Medicamentos</CardTitle>
            <Pill className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{kpis.medicamentos.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground mt-1">Base de datos CIMA</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Presentaciones</CardTitle>
            <Package className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{kpis.presentaciones.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground mt-1">Diferentes formatos</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Principios Activos</CardTitle>
            <Microscope className="h-4 w-4 text-purple-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{kpis.principiosActivos.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground mt-1">Componentes únicos</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Interacciones</CardTitle>
            <AlertTriangle className="h-4 w-4 text-red-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{kpis.interacciones.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground mt-1">Relaciones detectadas</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Laboratorios</CardTitle>
            <Building2 className="h-4 w-4 text-orange-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{kpis.laboratorios.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground mt-1">Fabricantes registrados</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Excipientes</CardTitle>
            <Beaker className="h-4 w-4 text-cyan-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{kpis.excipientes.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground mt-1">Componentes auxiliares</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Biomarcadores</CardTitle>
            <Activity className="h-4 w-4 text-pink-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{kpis.biomarcadores.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground mt-1">Marcadores biológicos</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Documentos</CardTitle>
            <FileText className="h-4 w-4 text-indigo-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{kpis.documentos.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground mt-1">Fichas técnicas</p>
          </CardContent>
        </Card>
      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Growth Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Crecimiento Mensual</CardTitle>
            <CardDescription>Evolución de medicamentos en 2025</CardDescription>
          </CardHeader>
          <CardContent>
            <Line 
              data={growthData} 
              options={{
                responsive: true,
                maintainAspectRatio: true,
                aspectRatio: 2,
                plugins: {
                  legend: { display: false },
                },
                scales: {
                  y: { beginAtZero: false, min: 18000 },
                },
              }} 
            />
          </CardContent>
        </Card>

        {/* Top Labs Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Top 10 Laboratorios</CardTitle>
            <CardDescription>Por cantidad de medicamentos</CardDescription>
          </CardHeader>
          <CardContent>
            <Bar 
              data={topLabsData}
              options={{
                indexAxis: 'y' as const,
                responsive: true,
                maintainAspectRatio: true,
                aspectRatio: 2,
                plugins: {
                  legend: { display: false },
                },
              }}
            />
          </CardContent>
        </Card>

        {/* Alertas Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Distribución de Alertas</CardTitle>
            <CardDescription>Por tipo de alerta</CardDescription>
          </CardHeader>
          <CardContent className="flex justify-center">
            <div className="w-64 h-64">
              <Doughnut 
                data={alertasData}
                options={{
                  responsive: true,
                  maintainAspectRatio: true,
                  plugins: {
                    legend: { position: 'bottom' },
                  },
                }}
              />
            </div>
          </CardContent>
        </Card>

        {/* Grafo Stats Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Estado del Grafo</CardTitle>
            <CardDescription>Nodos por tipo</CardDescription>
          </CardHeader>
          <CardContent className="flex justify-center">
            <div className="w-64 h-64">
              <Radar 
                data={grafoData}
                options={{
                  responsive: true,
                  maintainAspectRatio: true,
                  plugins: {
                    legend: { display: false },
                  },
                  scales: {
                    r: { beginAtZero: true },
                  },
                }}
              />
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Latest Updates Table */}
      <Card>
        <CardHeader>
          <CardTitle>Últimas Actualizaciones</CardTitle>
          <CardDescription>Medicamentos actualizados recientemente</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b">
                  <th className="text-left p-3 font-medium text-gray-700">N° Registro</th>
                  <th className="text-left p-3 font-medium text-gray-700">Medicamento</th>
                  <th className="text-left p-3 font-medium text-gray-700">Fecha</th>
                  <th className="text-left p-3 font-medium text-gray-700">Estado</th>
                </tr>
              </thead>
              <tbody>
                {latestUpdates.map((item, i) => (
                  <tr key={i} className="border-b hover:bg-gray-50">
                    <td className="p-3 font-mono text-sm">{item.nregistro}</td>
                    <td className="p-3">{item.nombre}</td>
                    <td className="p-3 text-gray-600">{item.fecha}</td>
                    <td className="p-3">
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        ✓ {item.estado}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
