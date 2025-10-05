// File: Data/Entities/Medicamento.cs
using System.ComponentModel.DataAnnotations;

namespace Farmai.Api.Data.Entities;

public class Medicamento
{
    public Guid Id { get; set; } = Guid.NewGuid();

    // Clave natural de CIMA
    [MaxLength(32)]
    public string NRegistro { get; set; } = string.Empty;

    [MaxLength(512)]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(256)]
    public string? LabTitular { get; set; }

    // Foreign Keys a Laboratorio
    public int? LaboratorioTitularId { get; set; }
    public int? LaboratorioComercializadorId { get; set; }

    // Navigation properties
    public Laboratorio? LaboratorioTitular { get; set; }
    public Laboratorio? LaboratorioComercializador { get; set; }

    public bool? Receta { get; set; }
    public bool? Generico { get; set; }
    public bool? Comercializado { get; set; }

    [MaxLength(128)]
    public string? Dosis { get; set; }

    // Copia íntegra del item de CIMA (jsonb en Postgres)
    public string RawJson { get; set; } = "{}";

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
