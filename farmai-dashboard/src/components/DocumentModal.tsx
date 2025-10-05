import { X, ExternalLink, Download, FileText } from 'lucide-react'
import { useEffect } from 'react'

interface DocumentModalProps {
  isOpen: boolean
  onClose: () => void
  title: string
  url: string
  nregistro: string
}

export function DocumentModal({ isOpen, onClose, title, url, nregistro }: DocumentModalProps) {
  // Cerrar con ESC
  useEffect(() => {
    const handleEsc = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose()
    }
    
    if (isOpen) {
      window.addEventListener('keydown', handleEsc)
      // Prevenir scroll del body
      document.body.style.overflow = 'hidden'
    }
    
    return () => {
      window.removeEventListener('keydown', handleEsc)
      document.body.style.overflow = 'unset'
    }
  }, [isOpen, onClose])

  if (!isOpen) return null

  return (
    <div 
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
      onClick={onClose}
    >
      {/* Modal Container */}
      <div 
        className="relative w-[90vw] h-[90vh] bg-white rounded-lg shadow-2xl flex flex-col"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b bg-gray-50 rounded-t-lg">
          <div className="flex items-center space-x-3">
            <h2 className="text-xl font-semibold text-gray-900">{title}</h2>
            <span className="text-sm text-gray-500">N° Registro: {nregistro}</span>
          </div>
          
          <div className="flex items-center space-x-2">
            {/* Botón Descargar PDF */}
            <a
              href={url}
              download
              target="_blank"
              rel="noopener noreferrer"
              className="px-3 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 flex items-center space-x-2"
            >
              <Download className="w-4 h-4" />
              <span>Descargar PDF</span>
            </a>
            
            {/* Botón Abrir en nueva pestaña */}
            <a
              href={url}
              target="_blank"
              rel="noopener noreferrer"
              className="px-3 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 flex items-center space-x-2"
            >
              <ExternalLink className="w-4 h-4" />
              <span>Abrir en pestaña</span>
            </a>
            
            {/* Botón Cerrar */}
            <button
              onClick={onClose}
              className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-md"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Content - Instrucciones */}
        <div className="flex-1 overflow-hidden bg-gray-50 flex items-center justify-center p-8">
          <div className="text-center max-w-2xl">
            <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-blue-100 mb-6">
              <FileText className="w-10 h-10 text-blue-600" />
            </div>
            
            <h3 className="text-2xl font-semibold text-gray-900 mb-4">
              Documento Disponible
            </h3>
            
            <p className="text-gray-600 mb-6">
              Por razones de seguridad, CIMA no permite visualizar documentos directamente en esta ventana.
            </p>
            
            <div className="bg-white rounded-lg p-6 border border-gray-200 mb-6">
              <p className="text-sm text-gray-700 mb-4">
                <strong>Para ver el documento, utiliza una de estas opciones:</strong>
              </p>
              
              <div className="space-y-3">
                <div className="flex items-center space-x-3 text-left">
                  <div className="flex-shrink-0 w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center">
                    <span className="text-blue-600 font-semibold text-sm">1</span>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">Abrir en nueva pestaña</p>
                    <p className="text-xs text-gray-500">El documento se abrirá en tu navegador</p>
                  </div>
                </div>
                
                <div className="flex items-center space-x-3 text-left">
                  <div className="flex-shrink-0 w-8 h-8 rounded-full bg-green-100 flex items-center justify-center">
                    <span className="text-green-600 font-semibold text-sm">2</span>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">Descargar PDF</p>
                    <p className="text-xs text-gray-500">Guarda el archivo en tu equipo</p>
                  </div>
                </div>
              </div>
            </div>
            
            <div className="flex justify-center space-x-3">
              <a
                href={url}
                target="_blank"
                rel="noopener noreferrer"
                className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 flex items-center space-x-2 font-medium"
              >
                <ExternalLink className="w-5 h-5" />
                <span>Abrir en nueva pestaña</span>
              </a>
              
              <a
                href={url}
                download
                target="_blank"
                rel="noopener noreferrer"
                className="px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 flex items-center space-x-2 font-medium"
              >
                <Download className="w-5 h-5" />
                <span>Descargar PDF</span>
              </a>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="p-4 border-t bg-gray-50 rounded-b-lg">
          <div className="flex items-center justify-between text-sm text-gray-600">
            <p>
              Documento oficial de CIMA - Agencia Española de Medicamentos y Productos Sanitarios
            </p>
            <button
              onClick={onClose}
              className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
            >
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
