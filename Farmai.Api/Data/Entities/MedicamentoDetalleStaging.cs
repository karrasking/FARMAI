using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Farmai.Api.Data.Entities;

[Table("MedicamentoDetalleStaging")]
public class MedicamentoDetalleStaging
{
    [Key]
    [MaxLength(32)]
    public string NRegistro { get; set; } = string.Empty;

    // Mapeamos a jsonb en Postgres
    [Column(TypeName = "jsonb")]
    public string DetalleJson { get; set; } = "{}";
}
