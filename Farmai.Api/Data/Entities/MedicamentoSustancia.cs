using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Farmai.Api.Data.Entities;

[Table("MedicamentoSustancia")]
public class MedicamentoSustancia
{
    [Key]
    [Column(Order = 0)]
    public string NRegistro { get; set; } = null!;

    [Key]
    [Column(Order = 1)]
    public long SustanciaId { get; set; }

    public string Cantidad { get; set; } = null!;
    public string Unidad { get; set; } = null!;
    public decimal? CantidadNum_mg { get; set; }
    public int? Orden { get; set; }
    public string? CodigoJson { get; set; }
}
