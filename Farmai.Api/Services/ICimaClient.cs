using System.Text.Json;

// File: Services/ICimaClient.cs
namespace Farmai.Api.Services;

public record HttpTextResponse(int StatusCode, string? ContentType, string Body);

public interface ICimaClient
{
    Task<HttpTextResponse> GetMaestrasAsync(int maestra, CancellationToken ct = default);
    Task<HttpTextResponse> GetMedicamentosByNombreAsync(string nombre, CancellationToken ct = default);

    // NUEVO:
    Task<HttpTextResponse> GetMedicamentoByNRegistroAsync(string nregistro, CancellationToken ct = default);
}


