import { ShieldAlert, Car, Baby, Users, AlertCircle } from 'lucide-react';
import type { MedicamentoDetalle } from '../../types/medicamento';

export default function SeguridadTab({ medicamento }: { medicamento: MedicamentoDetalle }) {
  return (
    <div className="space-y-6">
      <div className="bg-gray-50 rounded-lg p-4">
        <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
          <Car className="w-5 h-5" /> Restricciones de Uso
        </h3>
        <dl className="grid grid-cols-2 gap-4">
          <div><dt className="text-sm text-gray-500">Conducción</dt>
          <dd className="mt-1">{medicamento.afectaConduccion ? 
            <span className="text-red-600 font-semibold">⚠️ Afecta conducción</span> : 
            <span className="text-green-600 font-semibold">✓ No afecta</span>}</dd></div>
          <div><dt className="text-sm text-gray-500">Embarazo/Lactancia</dt>
          <dd className="mt-1 text-amber-600">⚠️ Consultar ficha técnica</dd></div>
        </dl>
      </div>

      {medicamento.notasSeguridad.length > 0 && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <h3 className="text-lg font-semibold text-red-900 mb-3 flex items-center gap-2">
            <AlertCircle className="w-5 h-5" /> Notas AEMPS ({medicamento.notasSeguridad.length})
          </h3>
          <div className="space-y-2">
            {medicamento.notasSeguridad.map(nota => (
              <div key={nota.id} className="bg-white p-3 rounded border border-red-200">
                <div className="font-semibold text-sm">{nota.titulo}</div>
                <div className="text-xs text-gray-500 mt-1">{new Date(nota.fecha).toLocaleDateString()}</div>
              </div>
            ))}
          </div>
        </div>
      )}

      {medicamento.alertasGeriatria.length > 0 && (
        <div className="bg-amber-50 border border-amber-200 rounded-lg p-4">
          <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
            <Users className="w-5 h-5" /> Alertas Geriátricas ({medicamento.alertasGeriatria.length})
          </h3>
          <div className="space-y-2">
            {medicamento.alertasGeriatria.map((alerta, idx) => (
              <div key={idx} className="bg-white p-3 rounded">
                <span className="text-xs px-2 py-1 rounded bg-amber-100 text-amber-800">{alerta.criterio}</span>
                <div className="text-sm mt-2">{alerta.descripcion}</div>
              </div>
            ))}
          </div>
        </div>
      )}

      <div className="bg-gray-50 rounded-lg p-4">
        <h3 className="text-sm font-semibold mb-2">🔗 Interacciones</h3>
        <p className="text-sm">{medicamento.interacciones} medicamentos con interacciones conocidas</p>
      </div>

      {medicamento.flags.length > 0 && (
        <div className="bg-gray-50 rounded-lg p-4">
          <h3 className="text-sm font-semibold mb-3">🏷️ Flags Activos</h3>
          <div className="flex flex-wrap gap-2">
            {medicamento.flags.map((flag, idx) => (
              <span key={idx} className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded" title={flag.descripcion}>
                {flag.codigo}
              </span>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
