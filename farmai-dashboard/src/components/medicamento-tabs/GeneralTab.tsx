import { Building2, Calendar, Tag, Pill } from 'lucide-react';
import type { MedicamentoDetalle } from '../../types/medicamento';

interface GeneralTabProps {
  medicamento: MedicamentoDetalle;
}

export default function GeneralTab({ medicamento }: GeneralTabProps) {
  return (
    <div className="space-y-6">
      {/* Información Básica */}
      <div className="bg-gray-50 rounded-lg p-4">
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
          <Building2 className="w-5 h-5" />
          Información Básica
        </h3>
        <dl className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <dt className="text-sm font-medium text-gray-500">N° Registro</dt>
            <dd className="mt-1 text-sm text-gray-900 font-mono">{medicamento.nregistro}</dd>
          </div>
          <div>
            <dt className="text-sm font-medium text-gray-500">Nombre Completo</dt>
            <dd className="mt-1 text-sm text-gray-900 font-semibold">{medicamento.nombre}</dd>
          </div>
          <div>
            <dt className="text-sm font-medium text-gray-500">Laboratorio Titular</dt>
            <dd className="mt-1 text-sm text-gray-900">{medicamento.labTitular}</dd>
          </div>
          {medicamento.labComercializador && medicamento.labComercializador !== medicamento.labTitular && (
            <div>
              <dt className="text-sm font-medium text-gray-500">Laboratorio Comercializador</dt>
              <dd className="mt-1 text-sm text-gray-900">{medicamento.labComercializador}</dd>
            </div>
          )}
        </dl>
      </div>

      {/* Estado */}
      <div className="bg-gray-50 rounded-lg p-4">
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
          <Calendar className="w-5 h-5" />
          Estado
        </h3>
        <dl className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <dt className="text-sm font-medium text-gray-500">Estado Comercial</dt>
            <dd className="mt-1">
              {medicamento.comercializado ? (
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                  ✓ Comercializado
                </span>
              ) : (
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                  No comercializado
                </span>
              )}
            </dd>
          </div>
          <div>
            <dt className="text-sm font-medium text-gray-500">Autorización EMA</dt>
            <dd className="mt-1">
              {medicamento.autorizadoPorEma ? (
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                  ✓ Autorizado EMA
                </span>
              ) : (
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                  No autorizado EMA
                </span>
              )}
            </dd>
          </div>
          <div>
            <dt className="text-sm font-medium text-gray-500">Fecha Autorización</dt>
            <dd className="mt-1 text-sm text-gray-900">{new Date(medicamento.fechaAutorizacion).toLocaleDateString('es-ES')}</dd>
          </div>
          {medicamento.tieneNotas && (
            <div>
              <dt className="text-sm font-medium text-gray-500">Notas AEMPS</dt>
              <dd className="mt-1">
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                  {medicamento.notasSeguridad.length} nota(s)
                </span>
              </dd>
            </div>
          )}
        </dl>
      </div>

      {/* Clasificación */}
      <div className="bg-gray-50 rounded-lg p-4">
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
          <Tag className="w-5 h-5" />
          Clasificación
        </h3>
        <dl className="space-y-4">
          {medicamento.atc.length > 0 && (
            <div>
              <dt className="text-sm font-medium text-gray-500 mb-2">Clasificación ATC</dt>
              <dd className="space-y-1">
                {medicamento.atc.map((atc, idx) => (
                  <div key={idx} className="flex items-center gap-2 text-sm">
                    <span className="font-mono font-semibold text-blue-600">{atc.codigo}</span>
                    <span className="text-gray-700">{atc.nombre}</span>
                    <span className="text-xs text-gray-500">(Nivel {atc.nivel})</span>
                  </div>
                ))}
              </dd>
            </div>
          )}
          {medicamento.vtm && (
            <div>
              <dt className="text-sm font-medium text-gray-500">VTM</dt>
              <dd className="mt-1 text-sm text-gray-900">{medicamento.vtm.nombre}</dd>
            </div>
          )}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <dt className="text-sm font-medium text-gray-500">Forma Farmacéutica</dt>
              <dd className="mt-1 text-sm text-gray-900">{medicamento.formaFarmaceutica}</dd>
            </div>
            {medicamento.formaFarmaceuticaSimplificada && (
              <div>
                <dt className="text-sm font-medium text-gray-500">Forma Simplificada</dt>
                <dd className="mt-1 text-sm text-gray-900">{medicamento.formaFarmaceuticaSimplificada}</dd>
              </div>
            )}
          </div>
          <div>
            <dt className="text-sm font-medium text-gray-500">Vías de Administración</dt>
            <dd className="mt-1 flex flex-wrap gap-2">
              {medicamento.viasAdministracion.map((via, idx) => (
                <span key={idx} className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                  {via.nombre}
                </span>
              ))}
            </dd>
          </div>
          {medicamento.dosis && (
            <div>
              <dt className="text-sm font-medium text-gray-500">Dosis</dt>
              <dd className="mt-1 text-sm text-gray-900 font-semibold">{medicamento.dosis}</dd>
            </div>
          )}
        </dl>
      </div>

      {/* Tipo de Medicamento */}
      <div className="bg-gray-50 rounded-lg p-4">
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
          <Pill className="w-5 h-5" />
          Tipo de Medicamento
        </h3>
        <div className="flex flex-wrap gap-2">
          {medicamento.esGenerico ? (
            <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
              ✓ Medicamento Genérico (EFG)
            </span>
          ) : (
            <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800">
              Medicamento de Marca
            </span>
          )}
          {medicamento.requiereReceta ? (
            <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-orange-100 text-orange-800">
              Con Receta
            </span>
          ) : (
            <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800">
              Sin Receta (OTC)
            </span>
          )}
          {medicamento.huerfano && (
            <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-amber-100 text-amber-800">
              Medicamento Huérfano
            </span>
          )}
          {medicamento.biosimilar && (
            <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-indigo-100 text-indigo-800">
              Biosimilar
            </span>
          )}
        </div>
      </div>
    </div>
  );
}
