using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Farmai.Api.Data.Entities;

[Table("MedicamentoPresentacion")]
public class MedicamentoPresentacion
{
    [Key]
    [Column("NRegistro")]
    [Required]
    public string NRegistro { get; set; } = string.Empty;

    [Key]
    [Column("CN")]
    [Required]
    public string CN { get; set; } = string.Empty;
}
