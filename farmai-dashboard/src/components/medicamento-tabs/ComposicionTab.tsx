import { TestTube, AlertTriangle, Beaker } from 'lucide-react';
import type { MedicamentoDetalle } from '../../types/medicamento';

interface ComposicionTabProps {
  medicamento: MedicamentoDetalle;
}

export default function ComposicionTab({ medicamento }: ComposicionTabProps) {
  const alergenos = medicamento.excipientes.filter(e => e.esAlergeno);
  
  return (
    <div className="space-y-6">
      {/* Principios Activos */}
      <div className="bg-gray-50 rounded-lg p-4">
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
          <TestTube className="w-5 h-5 text-blue-600" />
          Principios Activos
        </h3>
        {medicamento.principiosActivos.length > 0 ? (
          <div className="space-y-3">
            {medicamento.principiosActivos.map((pa, idx) => (
              <div key={idx} className="bg-white rounded-lg p-3 border border-gray-200">
                <div className="flex items-center justify-between">
                  <div>
                    <div className="font-semibold text-gray-900">{pa.nombre}</div>
                    <div className="text-sm text-gray-600 mt-1">
                      Cantidad: <span className="font-mono font-semibold">{pa.cantidad} {pa.unidad}</span>
                    </div>
                  </div>
                  <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                    PA #{idx + 1}
                  </span>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <p className="text-gray-500 text-sm">No se especifican principios activos</p>
        )}
      </div>

      {/* Alertas de Alérgenos */}
      {alergenos.length > 0 && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <h3 className="text-lg font-semibold text-red-900 mb-4 flex items-center gap-2">
            <AlertTriangle className="w-5 h-5 text-red-600" />
            ⚠️ Alertas de Alérgenos
          </h3>
          <div className="space-y-2">
            {alergenos.map((alergeno, idx) => (
              <div key={idx} className="bg-white rounded-lg p-3 border border-red-300">
                <div className="flex items-start gap-3">
                  <div className="flex-shrink-0">
                    <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-bold bg-red-100 text-red-800">
                      ⚠️ {alergeno.tipoAlergeno?.toUpperCase()}
                    </span>
                  </div>
                  <div className="flex-1">
                    <div className="font-semibold text-gray-900">{alergeno.nombre}</div>
                    {alergeno.cantidad && (
                      <div className="text-sm text-gray-600 mt-1">
                        {alergeno.cantidad} {alergeno.unidad}
                      </div>
                    )}
                    <div className="text-xs text-red-600 mt-2">
                      {alergeno.tipoAlergeno === 'lactosa' && 'No apto para intolerancia a lactosa'}
                      {alergeno.tipoAlergeno === 'gluten' && 'No apto para celíacos'}
                      {alergeno.tipoAlergeno === 'soja' && 'No apto para alergia a soja'}
                      {alergeno.tipoAlergeno === 'cacahuete' && 'No apto para alergia a cacahuete'}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Excipientes */}
      <div className="bg-gray-50 rounded-lg p-4">
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
          <Beaker className="w-5 h-5 text-gray-600" />
          Excipientes ({medicamento.excipientes.length})
        </h3>
        {medicamento.excipientes.length > 0 ? (
          <div className="space-y-2 max-h-96 overflow-y-auto">
            {medicamento.excipientes
              .sort((a, b) => a.orden - b.orden)
              .map((exc, idx) => (
                <div 
                  key={idx} 
                  className={`p-2 rounded ${exc.esAlergeno ? 'bg-red-50 border border-red-200' : 'bg-white border border-gray-200'}`}
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <span className="text-xs text-gray-500 font-mono">#{exc.orden}</span>
                      <span className={`text-sm ${exc.esAlergeno ? 'font-semibold text-red-900' : 'text-gray-900'}`}>
                        {exc.nombre}
                      </span>
                      {exc.esAlergeno && (
                        <AlertTriangle className="w-4 h-4 text-red-600" />
                      )}
                    </div>
                    {exc.cantidad && (
                      <span className="text-xs text-gray-600 font-mono">
                        {exc.cantidad} {exc.unidad}
                      </span>
                    )}
                  </div>
                </div>
              ))}
          </div>
        ) : (
          <p className="text-gray-500 text-sm">No se especifican excipientes</p>
        )}
      </div>

      {/* Resumen de Seguridad */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h3 className="text-sm font-semibold text-blue-900 mb-2">📋 Resumen de Composición</h3>
        <dl className="grid grid-cols-2 gap-4 text-sm">
          <div>
            <dt className="text-blue-700">Principios Activos:</dt>
            <dd className="font-semibold text-blue-900">{medicamento.principiosActivos.length}</dd>
          </div>
          <div>
            <dt className="text-blue-700">Excipientes:</dt>
            <dd className="font-semibold text-blue-900">{medicamento.excipientes.length}</dd>
          </div>
          <div>
            <dt className="text-blue-700">Alérgenos detectados:</dt>
            <dd className="font-semibold text-red-600">{alergenos.length}</dd>
          </div>
          <div>
            <dt className="text-blue-700">Advertencias:</dt>
            <dd className="font-semibold text-blue-900">
              {alergenos.length > 0 ? 'Ver alertas arriba' : 'Ninguna'}
            </dd>
          </div>
        </dl>
      </div>
    </div>
  );
}
