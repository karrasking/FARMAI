using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Farmai.Api.Data.Entities;

[Table("MedicamentoVia")]
public class MedicamentoVia
{
    [Key]
    [Column(Order = 0)]
    public string NRegistro { get; set; } = null!;

    [Key]
    [Column(Order = 1)]
    public int ViaId { get; set; }

    // Navigation property
    public ViaAdministracion? Via { get; set; }
}

[Table("ViaAdministracion")]
public class ViaAdministracion
{
    [Key]
    public int Id { get; set; }

    public string Nombre { get; set; } = null!;
    public string? Codigo { get; set; }
}
