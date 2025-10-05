import { FileText, Image, ExternalLink } from 'lucide-react';
import type { MedicamentoDetalle } from '../../types/medicamento';

export default function DocumentosTab({ medicamento }: { medicamento: MedicamentoDetalle }) {
  const ftDoc = medicamento.documentos.find(d => d.tipo === 'FT');
  const pDoc = medicamento.documentos.find(d => d.tipo === 'P');
  
  return (
    <div className="space-y-6">
      {/* Ficha Técnica */}
      {ftDoc && (
        <div className="bg-gray-50 rounded-lg p-4">
          <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
            <FileText className="w-5 h-5 text-blue-600" /> Ficha Técnica
          </h3>
          <div className="bg-white p-4 rounded border">
            <div className="flex items-center justify-between mb-3">
              <span className={`text-xs px-2 py-1 rounded ${ftDoc.disponible ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-600'}`}>
                {ftDoc.disponible ? '✓ Disponible' : 'No disponible'}
              </span>
              <span className="text-xs text-gray-500">
                {new Date(ftDoc.fecha).toLocaleDateString()}
              </span>
            </div>
            {ftDoc.disponible && (
              <div className="flex gap-2">
                {ftDoc.urlHtml && (
                  <a href={ftDoc.urlHtml} target="_blank" rel="noopener noreferrer"
                     className="flex items-center gap-1 px-3 py-2 bg-blue-600 text-white rounded text-sm hover:bg-blue-700">
                    <ExternalLink className="w-4 h-4" /> Ver HTML
                  </a>
                )}
                <a href={ftDoc.url} target="_blank" rel="noopener noreferrer"
                   className="flex items-center gap-1 px-3 py-2 bg-gray-600 text-white rounded text-sm hover:bg-gray-700">
                  <FileText className="w-4 h-4" /> Descargar PDF
                </a>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Prospecto */}
      {pDoc && (
        <div className="bg-gray-50 rounded-lg p-4">
          <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
            <FileText className="w-5 h-5 text-green-600" /> Prospecto
          </h3>
          <div className="bg-white p-4 rounded border">
            <div className="flex items-center justify-between mb-3">
              <span className={`text-xs px-2 py-1 rounded ${pDoc.disponible ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-600'}`}>
                {pDoc.disponible ? '✓ Disponible' : 'No disponible'}
              </span>
              <span className="text-xs text-gray-500">
                {new Date(pDoc.fecha).toLocaleDateString()}
              </span>
            </div>
            {pDoc.disponible && (
              <div className="flex gap-2">
                {pDoc.urlHtml && (
                  <a href={pDoc.urlHtml} target="_blank" rel="noopener noreferrer"
                     className="flex items-center gap-1 px-3 py-2 bg-green-600 text-white rounded text-sm hover:bg-green-700">
                    <ExternalLink className="w-4 h-4" /> Ver HTML
                  </a>
                )}
                <a href={pDoc.url} target="_blank" rel="noopener noreferrer"
                   className="flex items-center gap-1 px-3 py-2 bg-gray-600 text-white rounded text-sm hover:bg-gray-700">
                  <FileText className="w-4 h-4" /> Descargar PDF
                </a>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Fotos */}
      {medicamento.fotos.length > 0 && (
        <div className="bg-gray-50 rounded-lg p-4">
          <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
            <Image className="w-5 h-5 text-purple-600" /> Fotos ({medicamento.fotos.length})
          </h3>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            {medicamento.fotos.map((foto, idx) => (
              <div key={idx} className="bg-white p-2 rounded border">
                <img src={foto.url} alt={foto.tipo} className="w-full h-32 object-contain mb-2" />
                <p className="text-xs text-center text-gray-600">{foto.tipo === 'materialas' ? 'Envase' : 'Forma farmacéutica'}</p>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Materiales Informativos */}
      <div className="bg-gray-50 rounded-lg p-4">
        <h3 className="text-lg font-semibold mb-2 flex items-center gap-2">
          <FileText className="w-5 h-5 text-amber-600" /> Materiales Informativos
        </h3>
        <p className="text-sm text-gray-600">
          {medicamento.materialesInformativos ? 
            'Este medicamento dispone de materiales informativos adicionales' : 
            'Este medicamento no requiere materiales informativos adicionales'}
        </p>
      </div>
    </div>
  );
}
