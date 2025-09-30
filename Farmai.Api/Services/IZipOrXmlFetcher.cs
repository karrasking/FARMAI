// File: Services/IZipOrXmlFetcher.cs
namespace Farmai.Api.Services;

public interface IZipOrXmlFetcher
{
    // Nuevo orquestador (ZIP completo + manifest + copia a latest)
    Task<ZipFetchResult> FetchAllAsync(string url, CancellationToken ct = default);

    // Compatibilidad con tu endpoint antiguo (lo implementaremos como wrapper)
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
