// File: Services/ImportService.cs
using System.Text.Json;
using Farmai.Api.Data;
using Farmai.Api.Data.Entities;
using Farmai.Api.Models.Cima;
using Microsoft.EntityFrameworkCore;

namespace Farmai.Api.Services;

public class ImportService(FarmaiDbContext db)
{
    // ¡¡NUEVO!! Hacemos que la instancia del DbContext sea accesible públicamente
    // Esto permite que el ImportController la use directamente.
    public FarmaiDbContext Db => db;

    // El resto de tu código original se mantiene exactamente igual.
    public async Task<int> UpsertMedicamentosFromCimaJsonAsync(string json, CancellationToken ct)
    {
        var opts = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        var parsed = JsonSerializer.Deserialize<CimaMedicamentosResponse>(json, opts)
                    ?? new CimaMedicamentosResponse();

        var now = DateTime.UtcNow;
        int upserts = 0;

        foreach (var item in parsed.resultados)
        {
            var existing = await Db.Medicamentos // Cambiado 'db' por 'Db' para ser consistente
                .FirstOrDefaultAsync(x => x.NRegistro == item.nregistro, ct);

            if (existing is null)
            {
                Db.Medicamentos.Add(new Medicamento // Cambiado 'db' por 'Db'
                {
                    NRegistro = item.nregistro,
                    Nombre = item.nombre,
                    LabTitular = item.labtitular,
                    Receta = item.receta,
                    Generico = item.generico,
                    Dosis = item.dosis,
                    RawJson = jsonItem(json, item.nregistro) ?? "{}",
                    CreatedAt = now,
                    UpdatedAt = now
                });
                upserts++;
            }
            else
            {
                existing.Nombre = item.nombre;
                existing.LabTitular = item.labtitular;
                existing.Receta = item.receta;
                existing.Generico = item.generico;
                existing.Dosis = item.dosis;
                existing.RawJson = jsonItem(json, item.nregistro) ?? existing.RawJson;
                existing.UpdatedAt = now;
                upserts++;
            }
        }

        await Db.SaveChangesAsync(ct); // Cambiado 'db' por 'Db'
        return upserts;
    }

    private static string? jsonItem(string jsonList, string nregistro)
    {
        using var doc = JsonDocument.Parse(jsonList);
        var res = doc.RootElement.GetProperty("resultados");
        foreach (var el in res.EnumerateArray())
        {
            if (el.TryGetProperty("nregistro", out var nr) && nr.GetString() == nregistro)
                return el.GetRawText();
        }
        return null;
    }
}