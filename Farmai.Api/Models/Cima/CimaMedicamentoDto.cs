// File: Models/Cima/CimaMedicamentoDto.cs
namespace Farmai.Api.Models.Cima;

public class CimaMedicamentosResponse
{
    public int totalFilas { get; set; }
    public int pagina { get; set; }
    public int tamanioPagina { get; set; }
    public List<CimaMedicamentoDto> resultados { get; set; } = [];
}

public class CimaMedicamentoDto
{
    public string nregistro { get; set; } = "";
    public string nombre { get; set; } = "";
    public string? labtitular { get; set; }
    public bool? receta { get; set; }
    public bool? generico { get; set; }
    public string? dosis { get; set; }
}
