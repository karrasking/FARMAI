using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Farmai.Api.Data.Entities;

[Table("Presentacion")]
public class Presentacion
{
    [Key]
    [Column("CN")]
    public string CN { get; set; } = string.Empty;
}

[Table("SustanciaActiva")]
public class SustanciaActiva
{
    [Key]
    public int Id { get; set; }
    public string? Nombre { get; set; }
}

[Table("Laboratorio")]
public class Laboratorio
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    [MaxLength(256)]
    public string Nombre { get; set; } = string.Empty;
    
    [MaxLength(256)]
    public string? NombreCanon { get; set; }
    
    public int? CodigoAemps { get; set; }
    
    // Navigation properties
    public ICollection<Medicamento> MedicamentosComoTitular { get; set; } = new List<Medicamento>();
    public ICollection<Medicamento> MedicamentosComoComercializador { get; set; } = new List<Medicamento>();
}

[Table("Excipiente")]
public class Excipiente
{
    [Key]
    public int Id { get; set; }
    public string? Nombre { get; set; }
}

[Table("Biomarcador")]
public class Biomarcador
{
    [Key]
    public int Id { get; set; }
    public string? Gen { get; set; }
}

[Table("Documento")]
public class Documento
{
    [Key]
    public long Id { get; set; }

    [Required]
    [MaxLength(32)]
    public string NRegistro { get; set; } = null!;

    [Required]
    public short Tipo { get; set; }  // 1=FT, 2=Prospecto, 3=IPE

    public bool? Secc { get; set; }
    public string? UrlHtml { get; set; }
    public long? FechaRaw { get; set; }
    public DateTime? Fecha { get; set; }
    public string? UrlPdf { get; set; }
    public DateTime? FechaDoc { get; set; }

    // Columnas para descarga local
    public string? UrlLocal { get; set; }
    public string? LocalPath { get; set; }
    public string? FileName { get; set; }

    // Estado de descarga
    public bool Downloaded { get; set; } = false;
    public DateTime? DownloadedAt { get; set; }
    public int DownloadAttempts { get; set; } = 0;
    public DateTime? LastAttemptAt { get; set; }

    // Metadatos del archivo
    public string? FileHash { get; set; }
    public long? FileSize { get; set; }
    public int? HttpStatus { get; set; }
    public string? ErrorMessage { get; set; }
}

[Table("DocumentDownloadBatch")]
public class DocumentDownloadBatch
{
    [Key]
    public long Id { get; set; }
    [Required]
    public int BatchNumber { get; set; }
    [Required]
    public DateTime StartedAt { get; set; } = DateTime.UtcNow;
    public DateTime? FinishedAt { get; set; }
    [Required]
    [MaxLength(50)]
    public string Status { get; set; } = "pending";
    [Required]
    public int TotalDocs { get; set; }
    public int Downloaded { get; set; } = 0;
    public int Failed { get; set; } = 0;
    public int Skipped { get; set; } = 0;
    public int? DurationSeconds { get; set; }
    [Column(TypeName = "jsonb")]
    public string? ErrorsJson { get; set; }
}

[Table("DocumentDownloadLog")]
public class DocumentDownloadLog
{
    [Key]
    public long Id { get; set; }
    public long? BatchId { get; set; }
    public long? DocumentId { get; set; }
    [Required]
    [MaxLength(32)]
    public string NRegistro { get; set; } = null!;
    [Required]
    public short Tipo { get; set; }
    [Required]
    public string UrlPdf { get; set; } = null!;
    [Required]
    public DateTime AttemptedAt { get; set; } = DateTime.UtcNow;
    [Required]
    public bool Success { get; set; }
    public int? HttpStatus { get; set; }
    public long? FileSize { get; set; }
    public int? DurationMs { get; set; }
    public string? ErrorMessage { get; set; }
    public int RetryCount { get; set; } = 0;
}

[Table("DocumentDownloadRetry")]
public class DocumentDownloadRetry
{
    [Key]
    public long Id { get; set; }
    [Required]
    public long DocumentId { get; set; }
    [Required]
    [MaxLength(32)]
    public string NRegistro { get; set; } = null!;
    [Required]
    public short Tipo { get; set; }
    [Required]
    public string UrlPdf { get; set; } = null!;
    public int Priority { get; set; } = 5;
    public int Attempts { get; set; } = 0;
    public int MaxAttempts { get; set; } = 3;
    [Required]
    public DateTime FirstFailedAt { get; set; } = DateTime.UtcNow;
    public DateTime? LastAttemptAt { get; set; }
    public DateTime? NextRetryAt { get; set; }
    public string? LastError { get; set; }
    [Required]
    [MaxLength(50)]
    public string Status { get; set; } = "pending";
}

[Table("graph_node")]
public class GraphNode
{
    [Column("node_type")]
    public string NodeType { get; set; } = string.Empty;
    
    [Column("node_key")]
    public string NodeKey { get; set; } = string.Empty;
}

[Table("graph_edge")]
public class GraphEdge
{
    [Column("src_type")]
    public string SrcType { get; set; } = string.Empty;
    
    [Column("src_key")]
    public string SrcKey { get; set; } = string.Empty;
    
    [Column("dst_type")]
    public string DstType { get; set; } = string.Empty;
    
    [Column("dst_key")]
    public string DstKey { get; set; } = string.Empty;
    
    [Column("rel")]
    public string Rel { get; set; } = string.Empty;
}
