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
    public int Codigo { get; set; }
    public string? Nombre { get; set; }
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
    public int Id { get; set; }
    public string? NRegistro { get; set; }
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
