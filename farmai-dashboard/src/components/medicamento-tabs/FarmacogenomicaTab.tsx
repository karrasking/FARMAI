import type { MedicamentoDetalle } from '../../types/medicamento';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../ui/card';
import { AlertCircle, Dna, CheckCircle2, FileText } from 'lucide-react';

// Badge simple (inline component)
const Badge = ({ children, variant = 'default', className = '' }: { 
  children: React.ReactNode; 
  variant?: 'default' | 'secondary' | 'outline' | 'destructive';
  className?: string;
}) => {
  const variants = {
    default: 'bg-blue-500 text-white',
    secondary: 'bg-gray-200 text-gray-800',
    outline: 'border border-gray-300 text-gray-700',
    destructive: 'bg-red-500 text-white'
  };
  return (
    <span className={`inline-flex items-center px-2 py-1 rounded text-xs font-medium ${variants[variant]} ${className}`}>
      {children}
    </span>
  );
};

interface FarmacogenomicaTabProps {
  medicamento: MedicamentoDetalle;
}

export function FarmacogenomicaTab({ medicamento }: FarmacogenomicaTabProps) {
  const biomarcadores = medicamento.biomarcadores || [];

  if (biomarcadores.length === 0) {
    return (
      <div className="p-6 text-center text-gray-500">
        <Dna className="h-12 w-12 mx-auto mb-3 text-gray-300" />
        <p>No hay información farmacogenómica disponible para este medicamento.</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Header informativo */}
      <Card className="bg-blue-50 border-blue-200">
        <CardHeader>
          <CardTitle className="text-lg flex items-center gap-2">
            <Dna className="h-5 w-5 text-blue-600" />
            Información Farmacogenómica
          </CardTitle>
          <CardDescription>
            Biomarcadores genéticos que pueden influir en la respuesta a este medicamento.
            Se han identificado {biomarcadores.length} biomarcador(es) relevante(s).
          </CardDescription>
        </CardHeader>
      </Card>

      {/* Lista de biomarcadores */}
      {biomarcadores.map((bio) => (
        <Card key={bio.id} className="hover:shadow-md transition-shadow">
          <CardHeader>
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <CardTitle className="text-xl flex items-center gap-2">
                  <Dna className="h-5 w-5 text-purple-600" />
                  {bio.nombre}
                  {bio.nombreCanon && (
                    <span className="text-sm font-normal text-gray-500">
                      ({bio.nombreCanon})
                    </span>
                  )}
                </CardTitle>
                <div className="flex gap-2 mt-2">
                  {bio.incluidoSns && (
                    <Badge variant="default" className="bg-green-600">
                      <CheckCircle2 className="h-3 w-3 mr-1" />
                      Incluido SNS
                    </Badge>
                  )}
                  <Badge variant="outline">{bio.tipo}</Badge>
                  {bio.claseBiomarcador && (
                    <Badge variant="secondary">{bio.claseBiomarcador}</Badge>
                  )}
                </div>
              </div>
            </div>
          </CardHeader>
          
          <CardContent className="space-y-4">
            {/* Tipo de relación */}
            <div>
              <h4 className="font-semibold text-sm text-gray-700 mb-1 flex items-center gap-1">
                <AlertCircle className="h-4 w-4" />
                Tipo de relación
              </h4>
              <p className="text-sm">
                <Badge variant="destructive" className="capitalize">
                  {bio.tipoRelacion.replace('_', ' ')}
                </Badge>
              </p>
            </div>

            {/* Evidencia clínica */}
            {bio.evidencia && (
              <div>
                <h4 className="font-semibold text-sm text-gray-700 mb-1">
                  Evidencia clínica
                </h4>
                <p className="text-sm text-gray-600 whitespace-pre-line">
                  {bio.evidencia}
                </p>
              </div>
            )}

            {/* Secciones FT referenciadas */}
            {bio.seccionesFt.length > 0 && (
              <div>
                <h4 className="font-semibold text-sm text-gray-700 mb-1 flex items-center gap-1">
                  <FileText className="h-4 w-4" />
                  Secciones de Ficha Técnica
                </h4>
                <div className="flex gap-2">
                  {bio.seccionesFt.map((seccion) => (
                    <Badge key={seccion} variant="outline" className="font-mono">
                      {seccion}
                    </Badge>
                  ))}
                </div>
              </div>
            )}

            {/* Metadata */}
            <div className="pt-2 border-t text-xs text-gray-500 flex items-center justify-between">
              <span>Nivel de evidencia: {bio.nivelEvidencia}</span>
              <span>Fuente: {bio.fuente}</span>
            </div>

            {/* Notas adicionales */}
            {bio.notas && (
              <div className="bg-amber-50 border border-amber-200 p-3 rounded text-sm">
                <strong className="text-amber-900">Nota:</strong>{' '}
                <span className="text-amber-800">{bio.notas}</span>
              </div>
            )}
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
