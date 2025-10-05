import { Package, Euro } from 'lucide-react';
import type { MedicamentoDetalle } from '../../types/medicamento';

export default function PresentacionesTab({ medicamento }: { medicamento: MedicamentoDetalle }) {
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold flex items-center gap-2">
          <Package className="w-5 h-5" /> Presentaciones Disponibles
        </h3>
        <span className="text-sm text-gray-500">{medicamento.presentaciones.length} presentación(es)</span>
      </div>
      
      {medicamento.presentaciones.map((pres, idx) => (
        <div key={idx} className="bg-gray-50 rounded-lg p-4 border border-gray-200 hover:border-blue-300 transition-colors">
          <div className="flex items-start justify-between">
            <div className="flex-1">
              <div className="flex items-center gap-2 mb-2">
                <span className="font-mono text-sm bg-blue-100 text-blue-800 px-2 py-1 rounded">
                  CN {pres.cn}
                </span>
                {pres.comercializada ? (
                  <span className="text-xs px-2 py-1 bg-green-100 text-green-800 rounded">✓ Comercializada</span>
                ) : (
                  <span className="text-xs px-2 py-1 bg-gray-100 text-gray-800 rounded">No comercializada</span>
                )}
                {pres.psum && (
                  <span className="text-xs px-2 py-1 bg-red-100 text-red-800 rounded">⚠️ Problemas suministro</span>
                )}
              </div>
              <p className="text-sm text-gray-900 font-medium">{pres.nombre}</p>
              <div className="mt-2 flex items-center gap-4 text-sm text-gray-600">
                {pres.pvp && (
                  <div className="flex items-center gap-1">
                    <Euro className="w-4 h-4" />
                    <span>PVP: <span className="font-semibold">{pres.pvp.toFixed(2)}€</span></span>
                  </div>
                )}
                {pres.pvl && (
                  <div className="flex items-center gap-1">
                    <span>PVL: <span className="font-semibold">{pres.pvl.toFixed(2)}€</span></span>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      ))}
      
      {medicamento.presentaciones.length === 0 && (
        <div className="text-center py-8 text-gray-500">
          <Package className="w-12 h-12 mx-auto mb-2 opacity-50" />
          <p>No hay presentaciones registradas</p>
        </div>
      )}
    </div>
  );
}
