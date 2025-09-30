// File: Services/ZipOrXmlFetcher.cs
using System.IO.Compression;
using System.Text.Json;

namespace Farmai.Api.Services;

public interface IZipOrXmlFetcher
{
    Task<ZipFetchResult> FetchAllAsync(string url, CancellationToken ct = default);
}

public record ZipFetchFile(string FileName, string DiskPath, long Size);
public record ZipFetchResult(
    int StatusCode,
    string? ContentType,
    string ExtractedDir,
    string LatestDir,
    List<ZipFetchFile> Files,
    string ManifestPath
);

public class ZipOrXmlFetcher(HttpClient http, IWebHostEnvironment env) : IZipOrXmlFetcher
{
    public async Task<ZipFetchResult> FetchAllAsync(string url, CancellationToken ct = default)
    {
        // Carpeta base dentro de bin/netX/_data/nomenclator/...
        var baseDir = Path.Combine(AppContext.BaseDirectory, "_data", "nomenclator");
        Directory.CreateDirectory(baseDir);

        using var res = await http.GetAsync(url, HttpCompletionOption.ResponseHeadersRead, ct);
        var status = (int)res.StatusCode;
        var ctype = res.Content.Headers.ContentType?.MediaType ?? "";

        var stampDir = Path.Combine(baseDir, DateTime.UtcNow.ToString("yyyyMMdd_HHmmss"));
        var latestDir = Path.Combine(baseDir, "latest");
        Directory.CreateDirectory(stampDir);
        Directory.CreateDirectory(latestDir);

        var files = new List<ZipFetchFile>();

        // Descarga a disco (para ZIP)
        var tmpFile = Path.Combine(stampDir, "download.bin");
        await using (var fs = File.Create(tmpFile))
            await res.Content.CopyToAsync(fs, ct);

        if (ctype.Contains("zip", StringComparison.OrdinalIgnoreCase) || Path.GetExtension(url).Equals(".zip", StringComparison.OrdinalIgnoreCase))
        {
            var zipPath = Path.Combine(stampDir, "prescripcion.zip");
            File.Move(tmpFile, zipPath, true);

            using var za = ZipFile.OpenRead(zipPath);
            foreach (var entry in za.Entries)
            {
                // solo ficheros (no directorios)
                if (string.IsNullOrEmpty(entry.Name)) continue;

                var outPath = Path.Combine(stampDir, entry.Name);
                entry.ExtractToFile(outPath, overwrite: true);

                // copia a latest (idempotente)
                var latestPath = Path.Combine(latestDir, entry.Name);
                File.Copy(outPath, latestPath, overwrite: true);

                var fi = new FileInfo(outPath);
                files.Add(new ZipFetchFile(entry.Name, outPath, fi.Length));
            }
        }
        else
        {
            // XML directo
            var guessedName = "Prescripcion.xml";
            var outPath = Path.Combine(stampDir, guessedName);
            File.Move(tmpFile, outPath, true);

            var latestPath = Path.Combine(latestDir, guessedName);
            File.Copy(outPath, latestPath, overwrite: true);

            var fi = new FileInfo(outPath);
            files.Add(new ZipFetchFile(guessedName, outPath, fi.Length));
        }

        // Manifest.json
        var manifestPath = Path.Combine(stampDir, "manifest.json");
        var manifestObj = new
        {
            downloadedAtUtc = DateTime.UtcNow,
            url,
            contentType = ctype,
            files = files.Select(f => new { f.FileName, f.DiskPath, f.Size }).ToList()
        };
        await File.WriteAllTextAsync(manifestPath, JsonSerializer.Serialize(manifestObj, new JsonSerializerOptions { WriteIndented = true }), ct);

        return new ZipFetchResult(status, ctype, stampDir, latestDir, files, manifestPath);
    }

    public async Task<FetchPrescripcionResult> FetchPrescripcionXmlAsync(string url, CancellationToken ct = default)
    {
        var r = await FetchAllAsync(url, ct);

        var pres = r.Files.FirstOrDefault(f =>
            string.Equals(f.FileName, "Prescripcion.xml", StringComparison.OrdinalIgnoreCase));

        var diskPathZip = Path.Combine(r.ExtractedDir, "prescripcion.zip");
        var diskPathXml = pres?.DiskPath ?? Path.Combine(r.ExtractedDir, "Prescripcion.xml");
        var diskPathXmlLatest = Path.Combine(r.LatestDir, "Prescripcion.xml");

        long len = 0;
        try { if (File.Exists(diskPathXml)) len = new FileInfo(diskPathXml).Length; } catch { }

        string? preview = null;
        try { using var sr = new StreamReader(diskPathXml); preview = await sr.ReadLineAsync(); } catch { }

        return new FetchPrescripcionResult(
            r.StatusCode, r.ContentType, "zip",
            Path.GetFileName(diskPathXml),
            diskPathZip, diskPathXml, diskPathXmlLatest,
            len, preview
        );
    }

}
