using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Farmai.Api.Data.Entities;

[Table("MedicamentoBiomarcador")]
public class MedicamentoBiomarcador
{
    [Key]
    [Column(Order = 0)]
    public string NRegistro { get; set; } = null!;

    [Key]
    [Column(Order = 1)]
    public long BiomarcadorId { get; set; }

    public string? TipoRelacion { get; set; }
    public string? Evidencia { get; set; }
    public short? NivelEvidencia { get; set; }
    public string? Fuente { get; set; }
    public string? FuenteUrl { get; set; }
    public string? Notas { get; set; }
}
