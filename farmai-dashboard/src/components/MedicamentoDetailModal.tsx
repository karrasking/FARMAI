import { useState } from 'react';
import { X, Pill, FileText, ShieldAlert, Package, FileCheck, Info, Download, Printer } from 'lucide-react';
import type { MedicamentoDetalle } from '../types/medicamento';
import {
  GeneralTab,
  ComposicionTab,
  SeguridadTab,
  PresentacionesTab,
  DocumentosTab,
  MasInfoTab
} from './medicamento-tabs';

interface MedicamentoDetailModalProps {
  medicamento: MedicamentoDetalle;
  isOpen: boolean;
  onClose: () => void;
}

type TabType = 'general' | 'composicion' | 'seguridad' | 'presentaciones' | 'documentos' | 'mas';

const tabs = [
  { id: 'general' as TabType, label: 'General', icon: Pill },
  { id: 'composicion' as TabType, label: 'Composición', icon: FileText },
  { id: 'seguridad' as TabType, label: 'Seguridad', icon: ShieldAlert },
  { id: 'presentaciones' as TabType, label: 'Presentaciones', icon: Package },
  { id: 'documentos' as TabType, label: 'Documentos', icon: FileCheck },
  { id: 'mas' as TabType, label: 'Más Info', icon: Info },
];

export default function MedicamentoDetailModal({ medicamento, isOpen, onClose }: MedicamentoDetailModalProps) {
  const [activeTab, setActiveTab] = useState<TabType>('general');

  if (!isOpen) return null;

  const handleBackdropClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  const handleEscape = (e: React.KeyboardEvent) => {
    if (e.key === 'Escape') {
      onClose();
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4"
      onClick={handleBackdropClick}
      onKeyDown={handleEscape}
    >
      <div className="bg-white rounded-lg shadow-2xl w-full max-w-4xl max-h-[90vh] flex flex-col">
        {/* Header */}
        <div className="p-6 border-b border-gray-200 flex-shrink-0">
          <div className="flex items-start justify-between">
            <div className="flex-1">
              <div className="flex items-center gap-3 mb-2">
                <h2 className="text-2xl font-bold text-gray-900">{medicamento.nombre}</h2>
                <button
                  onClick={onClose}
                  className="text-gray-400 hover:text-gray-600 transition-colors ml-auto"
                  aria-label="Cerrar"
                >
                  <X className="w-6 h-6" />
                </button>
              </div>
              
              {/* Badges principales */}
              <div className="flex flex-wrap gap-2">
                {medicamento.esGenerico && (
                  <span className="px-2 py-1 bg-green-100 text-green-700 text-xs font-semibold rounded">
                    EFG
                  </span>
                )}
                {!medicamento.requiereReceta && (
                  <span className="px-2 py-1 bg-blue-100 text-blue-700 text-xs font-semibold rounded">
                    Sin Receta
                  </span>
                )}
                {medicamento.requiereReceta && (
                  <span className="px-2 py-1 bg-orange-100 text-orange-700 text-xs font-semibold rounded">
                    Con Receta
                  </span>
                )}
                {medicamento.comercializado && (
                  <span className="px-2 py-1 bg-emerald-100 text-emerald-700 text-xs font-semibold rounded">
                    Comercializado
                  </span>
                )}
                {medicamento.autorizadoPorEma && (
                  <span className="px-2 py-1 bg-purple-100 text-purple-700 text-xs font-semibold rounded">
                    EMA
                  </span>
                )}
                {medicamento.trianguloNegro && (
                  <span className="px-2 py-1 bg-gray-900 text-white text-xs font-semibold rounded">
                    ▼ Triángulo Negro
                  </span>
                )}
                {medicamento.huerfano && (
                  <span className="px-2 py-1 bg-amber-100 text-amber-700 text-xs font-semibold rounded">
                    Huérfano
                  </span>
                )}
                {medicamento.biosimilar && (
                  <span className="px-2 py-1 bg-indigo-100 text-indigo-700 text-xs font-semibold rounded">
                    Biosimilar
                  </span>
                )}
                {medicamento.psum && (
                  <span className="px-2 py-1 bg-red-100 text-red-700 text-xs font-semibold rounded">
                    ⚠️ Problemas Suministro
                  </span>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="border-b border-gray-200 flex-shrink-0 overflow-x-auto">
          <nav className="flex space-x-1 px-6" aria-label="Tabs">
            {tabs.map((tab) => {
              const Icon = tab.icon;
              const isActive = activeTab === tab.id;
              
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`
                    flex items-center gap-2 px-4 py-3 text-sm font-medium border-b-2 transition-colors whitespace-nowrap
                    ${isActive
                      ? 'border-blue-500 text-blue-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                    }
                  `}
                  aria-current={isActive ? 'page' : undefined}
                >
                  <Icon className="w-4 h-4" />
                  {tab.label}
                </button>
              );
            })}
          </nav>
        </div>

        {/* Tab Content */}
        <div className="flex-1 overflow-y-auto p-6">
          {activeTab === 'general' && <GeneralTab medicamento={medicamento} />}
          {activeTab === 'composicion' && <ComposicionTab medicamento={medicamento} />}
          {activeTab === 'seguridad' && <SeguridadTab medicamento={medicamento} />}
          {activeTab === 'presentaciones' && <PresentacionesTab medicamento={medicamento} />}
          {activeTab === 'documentos' && <DocumentosTab medicamento={medicamento} />}
          {activeTab === 'mas' && <MasInfoTab medicamento={medicamento} />}
        </div>

        {/* Footer */}
        <div className="p-6 border-t border-gray-200 flex justify-between items-center flex-shrink-0">
          <div className="text-sm text-gray-500">
            N° Registro: <span className="font-mono font-semibold">{medicamento.nregistro}</span>
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => alert('Generar PDF - Funcionalidad próximamente')}
              className="px-3 py-2 text-gray-700 bg-white border border-gray-300 hover:bg-gray-50 rounded-md transition-colors flex items-center gap-2"
              title="Descargar como PDF"
            >
              <Download className="w-4 h-4" />
              <span className="hidden sm:inline">PDF</span>
            </button>
            <button
              onClick={() => window.print()}
              className="px-3 py-2 text-gray-700 bg-white border border-gray-300 hover:bg-gray-50 rounded-md transition-colors flex items-center gap-2"
              title="Imprimir"
            >
              <Printer className="w-4 h-4" />
              <span className="hidden sm:inline">Imprimir</span>
            </button>
            <button
              onClick={onClose}
              className="px-4 py-2 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors"
            >
              Cerrar
            </button>
            {medicamento.documentos.find(d => d.tipo === 'FT' && d.disponible) && (
              <a
                href={medicamento.documentos.find(d => d.tipo === 'FT')?.urlHtml || medicamento.documentos.find(d => d.tipo === 'FT')?.url}
                target="_blank"
                rel="noopener noreferrer"
                className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
              >
                Ver Ficha Técnica
              </a>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
