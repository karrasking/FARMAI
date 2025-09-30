// File: Services/IZipOrXmlFetcher.cs
namespace Farmai.Api.Services;

public interface IZipOrXmlFetcher
{
    // Orquestador: descarga ZIP/XML, extrae y copia a 'latest'
    Task<ZipFetchResult> FetchAllAsync(string url, CancellationToken ct = default);

    // Compatibilidad con el endpoint antiguo (wrapper sobre FetchAllAsync)
    Task<FetchPrescripcionResult> FetchPrescripcionXmlAsync(string url, CancellationToken ct = default);
}

public record FetchPrescripcionResult(
    int StatusCode,
    string? ContentType,
    string Source,
    string FileName,
    string DiskPathZip,
    string DiskPathXml,
    string DiskPathXmlLatest,
    long XmlLength,
    string? XmlPreview
);
