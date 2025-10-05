// Tipos para el detalle completo del medicamento

export interface MedicamentoDetalle {
  // Información básica
  nregistro: string;
  nombre: string;
  labTitular: string;
  labComercializador?: string;
  fechaAutorizacion: string;
  
  // Estado
  comercializado: boolean;
  autorizadoPorEma: boolean;
  tieneNotas: boolean;
  requiereReceta: boolean;
  esGenerico: boolean;
  
  // Clasificación
  atc: ATC[];
  vtm?: VTM;
  formaFarmaceutica: string;
  formaFarmaceuticaSimplificada?: string;
  viasAdministracion: ViaAdministracion[];
  dosis?: string;
  
  // Flags y restricciones
  afectaConduccion: boolean;
  trianguloNegro: boolean;
  huerfano: boolean;
  biosimilar: boolean;
  psum: boolean;
  
  // Composición
  principiosActivos: PrincipioActivo[];
  excipientes: Excipiente[];
  
  // Presentaciones
  presentaciones: Presentacion[];
  
  // Documentos
  documentos: Documento[];
  fotos: Foto[];
  materialesInformativos: boolean;
  
  // Seguridad
  notasSeguridad: NotaSeguridad[];
  problemaSuministro?: ProblemaSuministro;
  alertasGeriatria: AlertaGeriatria[];
  interacciones: number; // Count
  
  // Extra
  biomarcadores?: Biomarcador[];
  flags: Flag[];
}

export interface ATC {
  codigo: string;
  nombre: string;
  nivel: number;
}

export interface VTM {
  id: number;
  nombre: string;
}

export interface ViaAdministracion {
  id: number;
  nombre: string;
}

export interface PrincipioActivo {
  id: number;
  nombre: string;
  cantidad: string;
  unidad: string;
}

export interface Excipiente {
  id: number;
  nombre: string;
  cantidad?: string;
  unidad?: string;
  orden: number;
  // Alertas especiales
  esAlergeno: boolean; // lactosa, gluten, soja, etc.
  tipoAlergeno?: 'lactosa' | 'gluten' | 'soja' | 'cacahuete';
}

export interface Presentacion {
  cn: string;
  nombre: string;
  pvp?: number;
  pvl?: number;
  estado: string;
  comercializada: boolean;
  psum: boolean;
}

export interface Documento {
  tipo: 'FT' | 'P' | 'MI'; // Ficha Técnica, Prospecto, Material Informativo
  url: string;
  urlHtml?: string;
  fecha: string;
  disponible: boolean;
}

export interface Foto {
  tipo: 'materialas' | 'formafarmac';
  url: string;
}

export interface NotaSeguridad {
  id: number;
  tipo: string;
  titulo: string;
  fecha: string;
}

export interface ProblemaSuministro {
  activo: boolean;
  fechaInicio: string;
  fechaFin?: string;
  observaciones?: string;
}

export interface AlertaGeriatria {
  criterio: string;
  descripcion: string;
  severidad: 'alta' | 'media' | 'baja';
}

// 🧬 Biomarcador (Farmacogenómica) - Versión completa
export interface Biomarcador {
  id: number;
  nombre: string;
  nombreCanon?: string;
  tipo: string;
  incluidoSns: boolean;
  claseBiomarcador: string;  // "Germinal" | "Somático"
  
  // Información de la relación
  tipoRelacion: string;  // "ajuste_dosis"
  evidencia: string;  // Texto largo
  nivelEvidencia: number;
  fuente: string;
  seccionesFt: string[];  // ["4.2", "4.5"]
  notas?: string;
}

export interface Flag {
  codigo: string;
  nombre: string;
  descripcion: string;
}
