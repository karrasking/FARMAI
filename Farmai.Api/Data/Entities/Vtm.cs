using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Farmai.Api.Data.Entities;

[Table("Vtm")]
public class Vtm
{
    [Key]
    public long Id { get; set; }

    public string Nombre { get; set; } = null!;
}
