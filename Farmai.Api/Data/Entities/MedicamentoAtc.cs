using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Farmai.Api.Data.Entities;

[Table("MedicamentoAtc")]
public class MedicamentoAtc
{
    [Key]
    [Column(Order = 0)]
    public string NRegistro { get; set; } = null!;

    [Key]
    [Column(Order = 1)]
    public string Codigo { get; set; } = null!;

    // Navigation property
    public Atc? Atc { get; set; }
}

[Table("Atc")]
public class Atc
{
    [Key]
    public string Codigo { get; set; } = null!;

    public string Nombre { get; set; } = null!;
    public short Nivel { get; set; }
    public string? CodigoPadre { get; set; }
}
