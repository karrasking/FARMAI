// File: Controllers/MedicamentosController.cs
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Farmai.Api.Data;
using Farmai.Api.Data.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Farmai.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MedicamentosController : ControllerBase
{
    private readonly FarmaiDbContext _db;

    public MedicamentosController(FarmaiDbContext db)
    {
        _db = db;
    }

    /// <summary>
    /// Búsqueda simple por nombre y laboratorio (usa ILIKE → trigram index).
    /// </summary>
    /// <param name="q">Texto a buscar (parcial, sin mayúsculas/minúsculas)</param>
    /// <param name="limit">Límite de resultados (por defecto 25, máx 200)</param>
    [HttpGet("search")]
    public async Task<IActionResult> Search([FromQuery] string q, [FromQuery] int limit = 25, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(q))
            return BadRequest(new { error = "Parámetro q es obligatorio" });

        limit = limit <= 0 ? 25 : (limit > 200 ? 200 : limit);

        var list = await _db.Medicamentos
            .Where(m =>
                EF.Functions.ILike(m.Nombre, $"%{q}%") ||
                EF.Functions.ILike(m.LabTitular!, $"%{q}%")
            )
            .OrderBy(m => m.Nombre)
            .Select(m => new {
                m.NRegistro,
                m.Nombre,
                m.Dosis,
                m.LabTitular,
                m.Generico,
                m.Receta
            })
            .Take(limit)
            .ToListAsync(ct);

        return Ok(new { total = list.Count, resultados = list });
    }

    /// <summary>
    /// Obtiene un medicamento por NRegistro exacto.
    /// </summary>
    [HttpGet("{nregistro}")]
    public async Task<IActionResult> GetByNRegistro(string nregistro, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(nregistro))
            return BadRequest(new { error = "NRegistro es obligatorio" });

        var med = await _db.Medicamentos
            .Where(m => m.NRegistro == nregistro)
            .Select(m => new {
                m.NRegistro,
                m.Nombre,
                m.Dosis,
                m.LabTitular,
                m.Generico,
                m.Receta,
                m.RawJson,
                m.UpdatedAt
            })
            .FirstOrDefaultAsync(ct);

        if (med is null) return NotFound();
        return Ok(med);
    }
}
