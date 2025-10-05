import { Dna, Building, BarChart3 } from 'lucide-react';
import type { MedicamentoDetalle } from '../../types/medicamento';

export default function MasInfoTab({ medicamento }: { medicamento: MedicamentoDetalle }) {
  return (
    <div className="space-y-6">
      {/* Farmacogenómica */}
      {medicamento.biomarcadores && medicamento.biomarcadores.length > 0 && (
        <div className="bg-gradient-to-r from-purple-50 to-pink-50 rounded-lg p-4 border border-purple-200">
          <h3 className="text-lg font-semibold text-purple-900 mb-3 flex items-center gap-2">
            <Dna className="w-5 h-5" /> Farmacogenómica ({medicamento.biomarcadores.length} biomarcadores)
          </h3>
          <div className="space-y-3">
            {medicamento.biomarcadores.map((bio, idx) => (
              <div key={idx} className="bg-white p-3 rounded border border-purple-200">
                <div className="font-semibold text-purple-900 mb-1">{bio.gen}</div>
                <div className="text-sm text-gray-700 mb-2">{bio.descripcion}</div>
                <div className="text-xs text-purple-600 bg-purple-50 inline-block px-2 py-1 rounded">
                  {bio.impacto}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Trazabilidad */}
      <div className="bg-gray-50 rounded-lg p-4">
        <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
          <Building className="w-5 h-5" /> Trazabilidad y Producción
        </h3>
        <dl className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <dt className="text-sm font-medium text-gray-500">Laboratorio Titular</dt>
            <dd className="mt-1 text-sm text-gray-900 font-semibold">{medicamento.labTitular}</dd>
          </div>
          {medicamento.labComercializador && medicamento.labComercializador !== medicamento.labTitular && (
            <div>
              <dt className="text-sm font-medium text-gray-500">Laboratorio Comercializador</dt>
              <dd className="mt-1 text-sm text-gray-900 font-semibold">{medicamento.labComercializador}</dd>
            </div>
          )}
          <div>
            <dt className="text-sm font-medium text-gray-500">N° Registro</dt>
            <dd className="mt-1 text-sm text-gray-900 font-mono">{medicamento.nregistro}</dd>
          </div>
          <div>
            <dt className="text-sm font-medium text-gray-500">Fecha Autorización</dt>
            <dd className="mt-1 text-sm text-gray-900">
              {new Date(medicamento.fechaAutorizacion).toLocaleDateString('es-ES')}
            </dd>
          </div>
        </dl>
      </div>

      {/* Estadísticas */}
      <div className="bg-gray-50 rounded-lg p-4">
        <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
          <BarChart3 className="w-5 h-5" /> Estadísticas
        </h3>
        <dl className="grid grid-cols-2 md:grid-cols-3 gap-4 text-sm">
          <div className="bg-white p-3 rounded border">
            <dt className="text-gray-500 text-xs mb-1">Presentaciones</dt>
            <dd className="text-2xl font-bold text-blue-600">{medicamento.presentaciones.length}</dd>
          </div>
          <div className="bg-white p-3 rounded border">
            <dt className="text-gray-500 text-xs mb-1">Principios Activos</dt>
            <dd className="text-2xl font-bold text-green-600">{medicamento.principiosActivos.length}</dd>
          </div>
          <div className="bg-white p-3 rounded border">
            <dt className="text-gray-500 text-xs mb-1">Excipientes</dt>
            <dd className="text-2xl font-bold text-purple-600">{medicamento.excipientes.length}</dd>
          </div>
          <div className="bg-white p-3 rounded border">
            <dt className="text-gray-500 text-xs mb-1">Interacciones</dt>
            <dd className="text-2xl font-bold text-orange-600">{medicamento.interacciones}</dd>
          </div>
          <div className="bg-white p-3 rounded border">
            <dt className="text-gray-500 text-xs mb-1">Flags</dt>
            <dd className="text-2xl font-bold text-indigo-600">{medicamento.flags.length}</dd>
          </div>
          <div className="bg-white p-3 rounded border">
            <dt className="text-gray-500 text-xs mb-1">Documentos</dt>
            <dd className="text-2xl font-bold text-pink-600">{medicamento.documentos.filter(d => d.disponible).length}</dd>
          </div>
        </dl>
      </div>

      {/* Problema de Suministro */}
      {medicamento.problemaSuministro && medicamento.problemaSuministro.activo && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <h3 className="text-lg font-semibold text-red-900 mb-3">⚠️ Problema de Suministro Activo</h3>
          <dl className="space-y-2 text-sm">
            <div>
              <dt className="text-red-700 font-medium">Fecha Inicio:</dt>
              <dd className="text-gray-900">{new Date(medicamento.problemaSuministro.fechaInicio).toLocaleDateString()}</dd>
            </div>
            {medicamento.problemaSuministro.fechaFin && (
              <div>
                <dt className="text-red-700 font-medium">Fecha Fin Prevista:</dt>
                <dd className="text-gray-900">{new Date(medicamento.problemaSuministro.fechaFin).toLocaleDateString()}</dd>
              </div>
            )}
            {medicamento.problemaSuministro.observaciones && (
              <div>
                <dt className="text-red-700 font-medium">Observaciones:</dt>
                <dd className="text-gray-900">{medicamento.problemaSuministro.observaciones}</dd>
              </div>
            )}
          </dl>
        </div>
      )}

      {/* Info Adicional */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h3 className="text-sm font-semibold text-blue-900 mb-2">ℹ️ Información Adicional</h3>
        <ul className="space-y-1 text-sm text-blue-800">
          {medicamento.autorizadoPorEma && <li>✓ Autorizado por la Agencia Europea del Medicamento (EMA)</li>}
          {medicamento.trianguloNegro && <li>▼ Medicamento bajo seguimiento adicional</li>}
          {medicamento.huerfano && <li>✓ Designado como medicamento huérfano</li>}
          {medicamento.biosimilar && <li>✓ Medicamento biosimilar</li>}
          {medicamento.psum && <li>⚠️ Problemas de suministro reportados</li>}
        </ul>
      </div>
    </div>
  );
}
