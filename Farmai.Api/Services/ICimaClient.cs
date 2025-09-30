// File: Services/ICimaClient.cs
namespace Farmai.Api.Services;

public interface ICimaClient
{
    Task<HttpTextResponse> GetMaestrasAsync(int maestra, CancellationToken ct = default);
    Task<HttpTextResponse> GetMedicamentosByNombreAsync(string nombre, CancellationToken ct = default);
    Task<HttpTextResponse> GetMedicamentoByNRegistroAsync(string nregistro, CancellationToken ct = default);

    // Ya lo estás usando en el diario:
    Task<HttpTextResponse> GetRegistroCambiosAsync(string fecha, CancellationToken ct = default);

    // Nuevo: descarga el XML completo (si no pasas url, usa un valor por defecto)
    Task<HttpTextResponse> GetNomenclatorXmlAsync(string? absoluteUrl = null, CancellationToken ct = default);
}

