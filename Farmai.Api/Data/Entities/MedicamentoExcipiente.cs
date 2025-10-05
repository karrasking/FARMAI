using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Farmai.Api.Data.Entities;

[Table("MedicamentoExcipiente")]
public class MedicamentoExcipiente
{
    [Key]
    [Column(Order = 0)]
    public string NRegistro { get; set; } = null!;

    [Key]
    [Column(Order = 1)]
    public long ExcipienteId { get; set; }

    public string? Cantidad { get; set; }
    public string? Unidad { get; set; }
    public bool Obligatorio { get; set; }
    public int Orden { get; set; }
}
