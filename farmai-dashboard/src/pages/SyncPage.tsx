import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Calendar, Clock, CheckCircle, XCircle, PlayCircle, PauseCircle, Download } from 'lucide-react'

// Mock data
const syncStatus = {
  daily: {
    enabled: true,
    lastRun: '2025-10-04 02:00:00',
    nextRun: '2025-10-05 02:00:00',
    status: 'success',
    recordsProcessed: 152,
  },
  monthly: {
    enabled: true,
    lastRun: '2025-10-01 03:15:00',
    nextRun: '2025-11-01 03:00:00',
    status: 'pending',
    fileSize: '150 MB',
  },
}

const syncHistory = [
  { date: '2025-10-04 02:00', type: 'Diaria', records: 152, status: 'success', duration: '2m 15s' },
  { date: '2025-10-03 02:00', type: 'Diaria', records: 87, status: 'success', duration: '1m 42s' },
  { date: '2025-10-02 02:00', type: 'Diaria', records: 143, status: 'success', duration: '2m 08s' },
  { date: '2025-10-01 03:15', type: 'Mensual', records: 29540, status: 'success', duration: '18m 32s' },
  { date: '2025-09-30 02:00', type: 'Diaria', records: 96, status: 'success', duration: '1m 55s' },
  { date: '2025-09-29 02:00', type: 'Diaria', records: 108, status: 'success', duration: '2m 01s' },
]

export function SyncPage() {
  const [dailyEnabled, setDailyEnabled] = useState(syncStatus.daily.enabled)
  const [monthlyEnabled, setMonthlyEnabled] = useState(syncStatus.monthly.enabled)
  const [isRunning, setIsRunning] = useState(false)

  const handleRunDaily = () => {
    setIsRunning(true)
    setTimeout(() => setIsRunning(false), 3000)
    alert('Sincronización diaria iniciada (simulado)')
  }

  const handleRunMonthly = () => {
    alert('Descarga mensual iniciada (simulado)')
  }

  return (
    <div className="space-y-8">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Sincronización</h1>
        <p className="text-gray-500 mt-1">Control de actualizaciones automáticas</p>
      </div>

      {/* Daily Sync Card */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="flex items-center space-x-2">
                <Calendar className="w-5 h-5 text-blue-600" />
                <span>Actualización Diaria</span>
              </CardTitle>
              <CardDescription>Sincronización incremental desde CIMA</CardDescription>
            </div>
            <div className="flex items-center space-x-2">
              <Button
                variant={dailyEnabled ? "destructive" : "default"}
                size="sm"
                onClick={() => setDailyEnabled(!dailyEnabled)}
              >
                {dailyEnabled ? <PauseCircle className="w-4 h-4 mr-1" /> : <PlayCircle className="w-4 h-4 mr-1" />}
                {dailyEnabled ? 'Desactivar' : 'Activar'}
              </Button>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
            <div className="bg-gray-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600 mb-1">Estado</div>
              <div className="flex items-center space-x-2">
                {dailyEnabled ? (
                  <>
                    <CheckCircle className="w-5 h-5 text-green-600" />
                    <span className="font-semibold text-green-600">Activa</span>
                  </>
                ) : (
                  <>
                    <XCircle className="w-5 h-5 text-gray-400" />
                    <span className="font-semibold text-gray-400">Inactiva</span>
                  </>
                )}
              </div>
            </div>

            <div className="bg-gray-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600 mb-1">Última ejecución</div>
              <div className="flex items-center space-x-2">
                <Clock className="w-4 h-4 text-gray-400" />
                <span className="font-semibold">{syncStatus.daily.lastRun}</span>
              </div>
              <div className="text-xs text-gray-500 mt-1">
                Procesados: {syncStatus.daily.recordsProcessed} registros
              </div>
            </div>

            <div className="bg-gray-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600 mb-1">Próxima ejecución</div>
              <div className="flex items-center space-x-2">
                <Calendar className="w-4 h-4 text-gray-400" />
                <span className="font-semibold">{syncStatus.daily.nextRun}</span>
              </div>
            </div>
          </div>

          <div className="flex space-x-2">
            <Button 
              onClick={handleRunDaily}
              disabled={isRunning}
            >
              {isRunning ? 'Ejecutando...' : 'Ejecutar Ahora'}
            </Button>
            <Button variant="outline">
              Ver Logs
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Monthly Sync Card */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="flex items-center space-x-2">
                <Download className="w-5 h-5 text-purple-600" />
                <span>Actualización Mensual (XML Completo)</span>
              </CardTitle>
              <CardDescription>Descarga completa del nomenclátor</CardDescription>
            </div>
            <div className="flex items-center space-x-2">
              <Button
                variant={monthlyEnabled ? "destructive" : "default"}
                size="sm"
                onClick={() => setMonthlyEnabled(!monthlyEnabled)}
              >
                {monthlyEnabled ? <PauseCircle className="w-4 h-4 mr-1" /> : <PlayCircle className="w-4 h-4 mr-1" />}
                {monthlyEnabled ? 'Desactivar' : 'Activar'}
              </Button>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
            <div className="bg-gray-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600 mb-1">Estado</div>
              <div className="flex items-center space-x-2">
                <Clock className="w-5 h-5 text-orange-500" />
                <span className="font-semibold text-orange-500">Pendiente</span>
              </div>
            </div>

            <div className="bg-gray-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600 mb-1">Última ejecución</div>
              <div className="flex items-center space-x-2">
                <Clock className="w-4 h-4 text-gray-400" />
                <span className="font-semibold">{syncStatus.monthly.lastRun}</span>
              </div>
              <div className="text-xs text-gray-500 mt-1">
                Tamaño: {syncStatus.monthly.fileSize}
              </div>
            </div>

            <div className="bg-gray-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600 mb-1">Próxima ejecución</div>
              <div className="flex items-center space-x-2">
                <Calendar className="w-4 h-4 text-gray-400" />
                <span className="font-semibold">{syncStatus.monthly.nextRun}</span>
              </div>
            </div>
          </div>

          <div className="flex space-x-2">
            <Button onClick={handleRunMonthly}>
              Descargar Ahora
            </Button>
            <Button variant="outline">
              Configurar URL
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Sync History Table */}
      <Card>
        <CardHeader>
          <CardTitle>Historial de Sincronizaciones</CardTitle>
          <CardDescription>Últimas 20 ejecuciones</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b">
                  <th className="text-left p-3 font-medium text-gray-700">Fecha</th>
                  <th className="text-left p-3 font-medium text-gray-700">Tipo</th>
                  <th className="text-left p-3 font-medium text-gray-700">Registros</th>
                  <th className="text-left p-3 font-medium text-gray-700">Duración</th>
                  <th className="text-left p-3 font-medium text-gray-700">Estado</th>
                </tr>
              </thead>
              <tbody>
                {syncHistory.map((item, i) => (
                  <tr key={i} className="border-b hover:bg-gray-50">
                    <td className="p-3 font-mono text-sm">{item.date}</td>
                    <td className="p-3">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        item.type === 'Mensual' 
                          ? 'bg-purple-100 text-purple-800' 
                          : 'bg-blue-100 text-blue-800'
                      }`}>
                        {item.type}
                      </span>
                    </td>
                    <td className="p-3 text-gray-600">{item.records.toLocaleString()}</td>
                    <td className="p-3 text-gray-600">{item.duration}</td>
                    <td className="p-3">
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        <CheckCircle className="w-3 h-3 mr-1" />
                        {item.status === 'success' ? 'Éxito' : 'Error'}
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
