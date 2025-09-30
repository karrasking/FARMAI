namespace Farmai.Api.Services;

using System.IO.Compression;
using System.Text.Json;
using Microsoft.AspNetCore.Hosting;

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
        _ = env; // silencia warning si no lo usamos aún

        // Carpeta base: bin/<tfm>/_data/nomenclator
        var baseDir = Path.Combine(AppContext.BaseDirectory, "_data", "nomenclator");
        Directory.CreateDirectory(baseDir);

        using var res = await http.GetAsync(url, HttpCompletionOption.ResponseHeadersRead, ct);
        var status = (int)res.StatusCode;
        var ctype = res.Content.Headers.ContentType?.MediaType
                    ?? res.Content.Headers.ContentType?.ToString()
                    ?? string.Empty;

        var stampDir = Path.Combine(baseDir, DateTime.UtcNow.ToString("yyyyMMdd_HHmmss"));
        var latestDir = Path.Combine(baseDir, "latest");
        Directory.CreateDirectory(stampDir);
        Directory.CreateDirectory(latestDir);

        var files = new List<ZipFetchFile>();

        // Descarga a disco (temporal)
        var tmpFile = Path.Combine(stampDir, "download.bin");
        await using (var fs = File.Create(tmpFile))
            await res.Content.CopyToAsync(fs, ct);

        var looksZip = ctype.Contains("zip", StringComparison.OrdinalIgnoreCase)
                       || Path.GetExtension(url).Equals(".zip", StringComparison.OrdinalIgnoreCase);

        if (looksZip)
        {
            var zipPath = Path.Combine(stampDir, "prescripcion.zip");
            File.Move(tmpFile, zipPath, overwrite: true);

            using var za = ZipFile.OpenRead(zipPath);
            foreach (var entry in za.Entries)
            {
                // Sólo ficheros
                if (string.IsNullOrEmpty(entry.Name)) continue;

                var outPath = Path.Combine(stampDir, entry.Name);
                entry.ExtractToFile(outPath, overwrite: true);

                // Copia a /latest
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
            File.Move(tmpFile, outPath, overwrite: true);

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
        await File.WriteAllTextAsync(
            manifestPath,
            JsonSerializer.Serialize(manifestObj, new JsonSerializerOptions { WriteIndented = true }),
            ct
        );

        return new ZipFetchResult(status, ctype, stampDir, latestDir, files, manifestPath);
    }

    public async Task<FetchPrescripcionResult> FetchPrescripcionXmlAsync(string url, CancellationToken ct = default)
    {
        // Reutiliza FetchAllAsync y adapta la respuesta “legacy”
        var r = await FetchAllAsync(url, ct);

        var pres = r.Files.FirstOrDefault(f =>
            string.Equals(f.FileName, "Prescripcion.xml", StringComparison.OrdinalIgnoreCase));

        var diskPathZip = Path.Combine(r.ExtractedDir, "prescripcion.zip");
        var diskPathXml = pres?.DiskPath ?? Path.Combine(r.ExtractedDir, "Prescripcion.xml");
        var diskPathXmlLatest = Path.Combine(r.LatestDir, "Prescripcion.xml");

        long len = 0;
        try { if (File.Exists(diskPathXml)) len = new FileInfo(diskPathXml).Length; } catch { }

        string? preview = null;
        try
        {
            using var sr = new StreamReader(diskPathXml);
            preview = await sr.ReadLineAsync();
        }
        catch { /* sin preview si falla */ }

        return new FetchPrescripcionResult(
            StatusCode: r.StatusCode,
            ContentType: r.ContentType,
            Source: "zip",
            FileName: Path.GetFileName(diskPathXml),
            DiskPathZip: diskPathZip,
            DiskPathXml: diskPathXml,
            DiskPathXmlLatest: diskPathXmlLatest,
            XmlLength: len,
            XmlPreview: preview
        );
    }
}
