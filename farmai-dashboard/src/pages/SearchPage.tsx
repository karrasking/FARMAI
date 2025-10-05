import { useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { DocumentModal } from '@/components/DocumentModal'
import MedicamentoDetailModal from '@/components/MedicamentoDetailModal'
import type { MedicamentoDetalle } from '@/types/medicamento'
import { Search, Filter, Eye, FileText, AlertCircle, BookOpen, Package, Microscope, Building2, Beaker, Activity, X, Loader2 } from 'lucide-react'

// Tipos
interface Medicamento {
  nregistro: string
  nombre: string
  dosis?: string
  laboratorio?: string
  laboratorioTitular?: string
  laboratorioComercializador?: string
  generico: boolean
  receta: boolean
  comercializado: boolean
  biosimilar: boolean
}

interface SearchResponse {
  total: number
  count: number
  offset: number
  limit: number
  results: Medicamento[]
}

// Función para buscar en el API
const searchMedicamentos = async (
  query: string,
  filterGenerico: boolean | null,
  filterReceta: boolean | null,
  filterComercializado: boolean | null,
  filterBiosimilar: boolean | null,
  filterHospitalario: boolean | null
): Promise<SearchResponse> => {
  const params = new URLSearchParams()
  
  if (query) params.append('q', query)
  if (filterGenerico !== null) params.append('generico', String(filterGenerico))
  if (filterReceta !== null) params.append('receta', String(filterReceta))
  if (filterComercializado !== null) params.append('comercializado', String(filterComercializado))
  if (filterBiosimilar !== null) params.append('biosimilar', String(filterBiosimilar))
  if (filterHospitalario !== null) params.append('hospitalario', String(filterHospitalario))
  params.append('limit', '50')

  const response = await fetch(`http://localhost:5265/api/medicamentos/search?${params}`)
  if (!response.ok) throw new Error('Error al buscar medicamentos')
  return response.json()
}

export function SearchPage() {
  const [searchParams, setSearchParams] = useSearchParams()
  const activeFilter = searchParams.get('filter')
  
  const [searchTerm, setSearchTerm] = useState('')
  const [showFilters, setShowFilters] = useState(false)
  const [filterGenerico, setFilterGenerico] = useState<boolean | null>(null)
  const [filterReceta, setFilterReceta] = useState<boolean | null>(null)
  const [filterComercializado, setFilterComercializado] = useState<boolean | null>(null)
  const [filterBiosimilar, setFilterBiosimilar] = useState<boolean | null>(null)
  const [filterHospitalario, setFilterHospitalario] = useState<boolean | null>(null)
  const [shouldSearch, setShouldSearch] = useState(false)
  
  // Estados para el modal de documentos
  const [modalOpen, setModalOpen] = useState(false)
  const [modalDoc, setModalDoc] = useState<{ title: string; url: string; nregistro: string } | null>(null)
  
  // Estados para el modal de detalle
  const [detalleModalOpen, setDetalleModalOpen] = useState(false)
  const [selectedMedicamento, setSelectedMedicamento] = useState<MedicamentoDetalle | null>(null)
  const [loadingDetalle, setLoadingDetalle] = useState(false)

  // useQuery para búsqueda en API real
  const { data, isLoading, error } = useQuery({
    queryKey: ['medicamentos-search', searchTerm, filterGenerico, filterReceta, filterComercializado, filterBiosimilar, filterHospitalario],
    queryFn: () => searchMedicamentos(searchTerm, filterGenerico, filterReceta, filterComercializado, filterBiosimilar, filterHospitalario),
    enabled: shouldSearch, // Solo busca cuando el usuario hace click en Buscar
    staleTime: 30000 // Caché de 30 segundos
  })

  const results = data?.results || []
  const total = data?.total || 0

  // Configuración de filtros según la categoría
  const filterConfig = {
    'presentaciones': {
      icon: Package,
      title: 'Buscando por Presentaciones',
      description: 'Medicamentos agrupados por sus diferentes formatos y presentaciones',
      color: 'green'
    },
    'principios-activos': {
      icon: Microscope,
      title: 'Buscando por Principios Activos',
      description: 'Filtra medicamentos por su componente activo principal',
      color: 'purple'
    },
    'laboratorios': {
      icon: Building2,
      title: 'Buscando por Laboratorios',
      description: 'Medicamentos filtrados por fabricante',
      color: 'orange'
    },
    'excipientes': {
      icon: Beaker,
      title: 'Buscando por Excipientes',
      description: 'Busca medicamentos según sus componentes auxiliares',
      color: 'cyan'
    },
    'biomarcadores': {
      icon: Activity,
      title: 'Buscando por Biomarcadores',
      description: 'Medicamentos relacionados con marcadores farmacogenómicos',
      color: 'pink'
    }
  }

  const currentFilterConfig = activeFilter ? filterConfig[activeFilter as keyof typeof filterConfig] : null

  const clearFilter = () => {
    setSearchParams({})
  }

  const handleSearch = () => {
    setShouldSearch(true)
  }

  const handleClearFilters = () => {
    setFilterGenerico(null)
    setFilterReceta(null)
    setFilterComercializado(null)
    setFilterBiosimilar(null)
    setFilterHospitalario(null)
    setSearchTerm('')
    setShouldSearch(false)
  }

  const handleOpenDocument = (nregistro: string, tipo: 'ficha' | 'prospecto') => {
    const baseUrl = 'https://cima.aemps.es/cima/pdfs'
    const url = tipo === 'ficha' 
      ? `${baseUrl}/ft/${nregistro}/FT_${nregistro}.pdf`
      : `${baseUrl}/p/${nregistro}/P_${nregistro}.pdf`
    
    const title = tipo === 'ficha' ? 'Ficha Técnica' : 'Prospecto'
    
    setModalDoc({ title, url, nregistro })
    setModalOpen(true)
  }

  const handleCloseModal = () => {
    setModalOpen(false)
    setModalDoc(null)
  }

  const handleVerDetalle = async (nregistro: string) => {
    setLoadingDetalle(true)
    try {
      const response = await fetch(`http://localhost:5265/api/medicamentos/${nregistro}/detalle`)
      if (!response.ok) throw new Error('Error al cargar detalle')
      const detalle: MedicamentoDetalle = await response.json()
      setSelectedMedicamento(detalle)
      setDetalleModalOpen(true)
    } catch (error) {
      console.error('Error cargando detalle:', error)
      alert('Error al cargar el detalle del medicamento')
    } finally {
      setLoadingDetalle(false)
    }
  }

  return (
    <div className="space-y-6">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Buscador de Medicamentos</h1>
        <p className="text-gray-500 mt-1">Busca en la base de datos de 20,271 medicamentos</p>
      </div>

      {/* Active Filter Banner */}
      {currentFilterConfig && (
        <Card className={`border-l-4 border-${currentFilterConfig.color}-500`}>
          <CardContent className="py-4">
            <div className="flex items-start justify-between">
              <div className="flex items-start space-x-3">
                <div className={`p-2 rounded-lg bg-${currentFilterConfig.color}-100`}>
                  <currentFilterConfig.icon className={`w-5 h-5 text-${currentFilterConfig.color}-600`} />
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900">{currentFilterConfig.title}</h3>
                  <p className="text-sm text-gray-600 mt-1">{currentFilterConfig.description}</p>
                </div>
              </div>
              <Button
                variant="ghost"
                size="sm"
                onClick={clearFilter}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-4 h-4" />
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Search Card */}
      <Card>
        <CardContent className="pt-6">
          <div className="space-y-4">
            {/* Search Input */}
            <div className="flex space-x-2">
              <div className="flex-1 relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
                <input
                  type="text"
                                  placeholder="Buscar por Nombre, Nº registro, Laboratorio, Principio activo, Excipiente, Biomarcador o Código nacional..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
                  className="w-full pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <Button onClick={handleSearch} disabled={isLoading}>
                {isLoading ? (
                  <>
                    <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                    Buscando...
                  </>
                ) : (
                  'Buscar'
                )}
              </Button>
              <Button 
                variant="outline"
                onClick={() => setShowFilters(!showFilters)}
              >
                <Filter className="w-4 h-4 mr-2" />
                Filtros
              </Button>
            </div>

            {/* Filters Panel */}
            {showFilters && (
              <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-4 p-4 bg-gray-50 rounded-lg">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Genérico
                  </label>
                  <div className="flex space-x-2">
                    <Button
                      size="sm"
                      variant={filterGenerico === true ? "default" : "outline"}
                      onClick={() => setFilterGenerico(filterGenerico === true ? null : true)}
                    >
                      Sí
                    </Button>
                    <Button
                      size="sm"
                      variant={filterGenerico === false ? "default" : "outline"}
                      onClick={() => setFilterGenerico(filterGenerico === false ? null : false)}
                    >
                      No
                    </Button>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Requiere Receta
                  </label>
                  <div className="flex space-x-2">
                    <Button
                      size="sm"
                      variant={filterReceta === true ? "default" : "outline"}
                      onClick={() => setFilterReceta(filterReceta === true ? null : true)}
                    >
                      Sí
                    </Button>
                    <Button
                      size="sm"
                      variant={filterReceta === false ? "default" : "outline"}
                      onClick={() => setFilterReceta(filterReceta === false ? null : false)}
                    >
                      No
                    </Button>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Comercializado
                  </label>
                  <div className="flex space-x-2">
                    <Button
                      size="sm"
                      variant={filterComercializado === true ? "default" : "outline"}
                      onClick={() => setFilterComercializado(filterComercializado === true ? null : true)}
                    >
                      Sí
                    </Button>
                    <Button
                      size="sm"
                      variant={filterComercializado === false ? "default" : "outline"}
                      onClick={() => setFilterComercializado(filterComercializado === false ? null : false)}
                    >
                      No
                    </Button>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Biosimilar
                  </label>
                  <div className="flex space-x-2">
                    <Button
                      size="sm"
                      variant={filterBiosimilar === true ? "default" : "outline"}
                      onClick={() => setFilterBiosimilar(filterBiosimilar === true ? null : true)}
                    >
                      Sí
                    </Button>
                    <Button
                      size="sm"
                      variant={filterBiosimilar === false ? "default" : "outline"}
                      onClick={() => setFilterBiosimilar(filterBiosimilar === false ? null : false)}
                    >
                      No
                    </Button>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Hospitalario
                  </label>
                  <div className="flex space-x-2">
                    <Button
                      size="sm"
                      variant={filterHospitalario === true ? "default" : "outline"}
                      onClick={() => setFilterHospitalario(filterHospitalario === true ? null : true)}
                    >
                      Sí
                    </Button>
                    <Button
                      size="sm"
                      variant={filterHospitalario === false ? "default" : "outline"}
                      onClick={() => setFilterHospitalario(filterHospitalario === false ? null : false)}
                    >
                      No
                    </Button>
                  </div>
                </div>

                <div className="flex items-end col-span-full">
                  <Button
                    variant="ghost"
                    onClick={handleClearFilters}
                    className="w-full"
                  >
                    Limpiar todos los filtros
                  </Button>
                </div>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Results Info */}
      {shouldSearch && (
        <div className="flex items-center justify-between">
          <div className="text-sm text-gray-600">
            {isLoading ? (
              <span>Buscando...</span>
            ) : (
              <>
                <span className="font-semibold">{total}</span> resultados encontrados
                {results.length > 0 && <span> (mostrando {results.length})</span>}
              </>
            )}
          </div>
        </div>
      )}

      {/* Loading State */}
      {isLoading && (
        <div className="flex justify-center items-center py-12">
          <Loader2 className="w-8 h-8 animate-spin text-blue-600" />
        </div>
      )}

      {/* Error State */}
      {error && (
        <Card>
          <CardContent className="py-12">
            <div className="text-center">
              <AlertCircle className="mx-auto h-12 w-12 text-red-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">Error al buscar</h3>
              <p className="mt-1 text-sm text-gray-500">
                Hubo un problema al conectar con el servidor
              </p>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Results Grid */}
      {!isLoading && !error && shouldSearch && (
        <div className="grid grid-cols-1 gap-4">
          {results.map((med) => (
          <Card key={med.nregistro} className="hover:shadow-lg transition-shadow">
            <CardHeader>
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <CardTitle className="text-lg">{med.nombre}</CardTitle>
                  <CardDescription className="mt-2">
                    <div className="flex flex-wrap gap-2 mt-2">
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                        N° {med.nregistro}
                      </span>
                      {med.laboratorioTitular && (
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                          <Building2 className="w-3 h-3 mr-1" />
                          {med.laboratorioTitular}
                        </span>
                      )}
                      {med.laboratorioComercializador && med.laboratorioComercializador !== med.laboratorioTitular && (
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800">
                          <Package className="w-3 h-3 mr-1" />
                          {med.laboratorioComercializador}
                        </span>
                      )}
                      {med.generico && (
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                          Genérico (EFG)
                        </span>
                      )}
                      {med.receta && (
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-800">
                          <AlertCircle className="w-3 h-3 mr-1" />
                          Receta
                        </span>
                      )}
                      {med.comercializado && (
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-100 text-emerald-800">
                          Comercializado
                        </span>
                      )}
                      {med.biosimilar && (
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                          💊 Biosimilar
                        </span>
                      )}
                    </div>
                  </CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <div className="flex space-x-2">
                <Button 
                  size="sm" 
                  variant="outline"
                  onClick={() => handleVerDetalle(med.nregistro)}
                  disabled={loadingDetalle}
                >
                  {loadingDetalle ? (
                    <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                  ) : (
                    <Eye className="w-4 h-4 mr-2" />
                  )}
                  Ver Detalle
                </Button>
                <Button 
                  size="sm" 
                  variant="outline"
                  onClick={() => handleOpenDocument(med.nregistro, 'ficha')}
                >
                  <FileText className="w-4 h-4 mr-2" />
                  Ficha Técnica
                </Button>
                <Button 
                  size="sm" 
                  variant="outline"
                  onClick={() => handleOpenDocument(med.nregistro, 'prospecto')}
                >
                  <BookOpen className="w-4 h-4 mr-2" />
                  Prospecto
                </Button>
              </div>
            </CardContent>
          </Card>
          ))}
        </div>
      )}

      {/* Empty State */}
      {!isLoading && !error && shouldSearch && results.length === 0 && (
        <Card>
          <CardContent className="py-12">
            <div className="text-center">
              <Search className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">No se encontraron resultados</h3>
              <p className="mt-1 text-sm text-gray-500">
                Intenta modificar tu búsqueda o los filtros aplicados
              </p>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Initial State - No search yet */}
      {!shouldSearch && (
        <Card>
          <CardContent className="py-12">
            <div className="text-center">
              <Search className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">Comienza tu búsqueda</h3>
              <p className="mt-1 text-sm text-gray-500">
                Ingresa un término de búsqueda y presiona "Buscar" para ver resultados
              </p>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Modal de Documentos */}
      {modalDoc && (
        <DocumentModal
          isOpen={modalOpen}
          onClose={handleCloseModal}
          title={modalDoc.title}
          url={modalDoc.url}
          nregistro={modalDoc.nregistro}
        />
      )}

      {/* Modal de Detalle Medicamento */}
      {selectedMedicamento && (
        <MedicamentoDetailModal
          medicamento={selectedMedicamento}
          isOpen={detalleModalOpen}
          onClose={() => setDetalleModalOpen(false)}
        />
      )}
    </div>
  )
}
