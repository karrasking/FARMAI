import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Search, Filter, Eye, FileText, AlertCircle, BookOpen } from 'lucide-react'

// Mock data - medicamentos de ejemplo
const mockMedicamentos = [
  {
    nregistro: '70039',
    nombre: 'IBUPROFENO CINFA 600 mg comprimidos recubiertos con película EFG',
    laboratorio: 'CINFA',
    generico: true,
    receta: true,
    comercializado: true,
  },
  {
    nregistro: '74559',
    nombre: 'DIFENADOL RAPID 400 mg comprimidos recubiertos con película EFG',
    laboratorio: 'NORMON',
    generico: true,
    receta: false,
    comercializado: true,
  },
  {
    nregistro: '65432',
    nombre: 'PARACETAMOL NORMON 1 g comprimidos EFG',
    laboratorio: 'NORMON',
    generico: true,
    receta: false,
    comercializado: true,
  },
  {
    nregistro: '78901',
    nombre: 'OMEPRAZOL TEVA 20 mg cápsulas duras gastrorresistentes EFG',
    laboratorio: 'TEVA',
    generico: true,
    receta: true,
    comercializado: true,
  },
  {
    nregistro: '54321',
    nombre: 'ATORVASTATINA SANDOZ 40 mg comprimidos recubiertos con película EFG',
    laboratorio: 'SANDOZ',
    generico: true,
    receta: true,
    comercializado: true,
  },
]

export function SearchPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [showFilters, setShowFilters] = useState(false)
  const [filterGenerico, setFilterGenerico] = useState<boolean | null>(null)
  const [filterReceta, setFilterReceta] = useState<boolean | null>(null)
  const [results, setResults] = useState(mockMedicamentos)

  const handleSearch = () => {
    let filtered = mockMedicamentos.filter(med => 
      med.nombre.toLowerCase().includes(searchTerm.toLowerCase()) ||
      med.laboratorio.toLowerCase().includes(searchTerm.toLowerCase()) ||
      med.nregistro.includes(searchTerm)
    )

    if (filterGenerico !== null) {
      filtered = filtered.filter(med => med.generico === filterGenerico)
    }

    if (filterReceta !== null) {
      filtered = filtered.filter(med => med.receta === filterReceta)
    }

    setResults(filtered)
  }

  return (
    <div className="space-y-6">
      {/* Page Title */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Buscador de Medicamentos</h1>
        <p className="text-gray-500 mt-1">Busca en la base de datos de 20,271 medicamentos</p>
      </div>

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
                  placeholder="Buscar por nombre, laboratorio o nº registro..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
                  className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>
              <Button onClick={handleSearch}>
                Buscar
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
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 p-4 bg-gray-50 rounded-lg">
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
                    <Button
                      size="sm"
                      variant="ghost"
                      onClick={() => setFilterGenerico(null)}
                    >
                      Todos
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
                    <Button
                      size="sm"
                      variant="ghost"
                      onClick={() => setFilterReceta(null)}
                    >
                      Todos
                    </Button>
                  </div>
                </div>

                <div className="flex items-end">
                  <Button
                    variant="ghost"
                    onClick={() => {
                      setFilterGenerico(null)
                      setFilterReceta(null)
                      setSearchTerm('')
                      setResults(mockMedicamentos)
                    }}
                  >
                    Limpiar filtros
                  </Button>
                </div>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Results Info */}
      <div className="flex items-center justify-between">
        <div className="text-sm text-gray-600">
          <span className="font-semibold">{results.length}</span> resultados encontrados
        </div>
      </div>

      {/* Results Grid */}
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
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                        {med.laboratorio}
                      </span>
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
                    </div>
                  </CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <div className="flex space-x-2">
                <Button size="sm" variant="outline">
                  <Eye className="w-4 h-4 mr-2" />
                  Ver Detalle
                </Button>
                <Button size="sm" variant="outline">
                  <FileText className="w-4 h-4 mr-2" />
                  Ficha Técnica
                </Button>
                <Button size="sm" variant="outline">
                  <BookOpen className="w-4 h-4 mr-2" />
                  Prospecto
                </Button>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Empty State */}
      {results.length === 0 && (
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
    </div>
  )
}
