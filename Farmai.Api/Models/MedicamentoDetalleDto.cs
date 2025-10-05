namespace Farmai.Api.Models;

public class MedicamentoDetalleDto
{
    public string Nregistro { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public string LabTitular { get; set; } = string.Empty;
    public string? LabComercializador { get; set; }
    public string FechaAutorizacion { get; set; } = string.Empty;
    
    // Estado
    public bool Comercializado { get; set; }
    public bool AutorizadoPorEma { get; set; }
    public bool TieneNotas { get; set; }
    public bool RequiereReceta { get; set; }
    public bool EsGenerico { get; set; }
    
    // Clasificación
    public List<AtcDto> Atc { get; set; } = new();
    public VtmDto? Vtm { get; set; }
    public string FormaFarmaceutica { get; set; } = string.Empty;
    public string? FormaFarmaceuticaSimplificada { get; set; }
    public List<ViaAdministracionDto> ViasAdministracion { get; set; } = new();
    public string? Dosis { get; set; }
    
    // Flags y restricciones
    public bool AfectaConduccion { get; set; }
    public bool TrianguloNegro { get; set; }
    public bool Huerfano { get; set; }
    public bool Biosimilar { get; set; }
    public bool Psum { get; set; }
    
    // Composición
    public List<PrincipioActivoDto> PrincipiosActivos { get; set; } = new();
    public List<ExcipienteDto> Excipientes { get; set; } = new();
    
    // Presentaciones
    public List<PresentacionDto> Presentaciones { get; set; } = new();
    
    // Documentos
    public List<DocumentoDto> Documentos { get; set; } = new();
    public List<FotoDto> Fotos { get; set; } = new();
    public bool MaterialesInformativos { get; set; }
    
    // Seguridad (simplificado por ahora)
    public List<NotaSeguridadDto> NotasSeguridad { get; set; } = new();
    public List<AlertaGeriatriaDto> AlertasGeriatria { get; set; } = new();
    public int Interacciones { get; set; }
    
    // Extra
    public List<FlagDto> Flags { get; set; } = new();
    
    // 🧬 Biomarcadores (Farmacogenómica)
    public List<BiomarcadorDto> Biomarcadores { get; set; } = new();
}

public class AtcDto
{
    public string Codigo { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public int Nivel { get; set; }
}

public class VtmDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
}

public class ViaAdministracionDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
}

public class PrincipioActivoDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Cantidad { get; set; } = string.Empty;
    public string Unidad { get; set; } = string.Empty;
}

public class ExcipienteDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Cantidad { get; set; }
    public string? Unidad { get; set; }
    public int Orden { get; set; }
    public bool EsAlergeno { get; set; }
    public string? TipoAlergeno { get; set; }
}

public class PresentacionDto
{
    public string Cn { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public decimal? Pvp { get; set; }
    public decimal? Pvl { get; set; }
    public string Estado { get; set; } = string.Empty;
    public bool Comercializada { get; set; }
    public bool Psum { get; set; }
}

public class DocumentoDto
{
    public string Tipo { get; set; } = string.Empty;
    public string Url { get; set; } = string.Empty;
    public string? UrlHtml { get; set; }
    public string Fecha { get; set; } = string.Empty;
    public bool Disponible { get; set; }
}

public class FotoDto
{
    public string Tipo { get; set; } = string.Empty;
    public string Url { get; set; } = string.Empty;
}

public class NotaSeguridadDto
{
    public int Id { get; set; }
    public string Tipo { get; set; } = string.Empty;
    public string Titulo { get; set; } = string.Empty;
    public string Fecha { get; set; } = string.Empty;
}

public class AlertaGeriatriaDto
{
    public string Criterio { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
    public string Severidad { get; set; } = string.Empty;
}

public class FlagDto
{
    public string Codigo { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
}

// DTO para Biomarcadores (Farmacogenómica)
public class BiomarcadorDto 
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
    public string? NombreCanon { get; set; }
    public string Tipo { get; set; } = "";
    public bool IncluidoSns { get; set; }
    public string ClaseBiomarcador { get; set; } = "";  // "Germinal" | "Somático"
    
    // Información de la relación medicamento-biomarcador
    public string TipoRelacion { get; set; } = "";  // "ajuste_dosis"
    public string Evidencia { get; set; } = "";  // Texto largo ⭐
    public int NivelEvidencia { get; set; }  // 4
    public string Fuente { get; set; } = "";  // "AEMPS XML"
    public List<string> SeccionesFt { get; set; } = new();  // ["4.2", "4.5"]
    public string? Notas { get; set; }
}
