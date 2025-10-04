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
    /// Búsqueda avanzada de medicamentos con filtros opcionales
    /// </summary>
    /// <param name="q">Texto a buscar (nombre, laboratorio, nregistro) - OPCIONAL</param>
    /// <param name="generico">Filtrar por genérico: true/false - OPCIONAL</param>
    /// <param name="receta">Filtrar por receta: true/false - OPCIONAL</param>
    /// <param name="limit">Límite de resultados (por defecto 50, máx 200)</param>
    /// <param name="offset">Offset para paginación (por defecto 0)</param>
    [HttpGet("search")]
    public async Task<IActionResult> Search(
        [FromQuery] string? q, 
        [FromQuery] bool? generico,
        [FromQuery] bool? receta,
        [FromQuery] int limit = 50, 
        [FromQuery] int offset = 0,
        CancellationToken ct = default)
    {
        // Validar límites
        limit = limit <= 0 ? 50 : (limit > 200 ? 200 : limit);
        offset = offset < 0 ? 0 : offset;

        // Construir query base
        var query = _db.Medicamentos.AsQueryable();

        // Aplicar filtro de texto si existe
        if (!string.IsNullOrWhiteSpace(q))
        {
            query = query.Where(m =>
                EF.Functions.ILike(m.Nombre, $"%{q}%") ||
                EF.Functions.ILike(m.LabTitular!, $"%{q}%") ||
                m.NRegistro!.Contains(q)
            );
        }

        // Aplicar filtro de genérico
        if (generico.HasValue)
        {
            query = query.Where(m => m.Generico == generico.Value);
        }

        // Aplicar filtro de receta
        if (receta.HasValue)
        {
            query = query.Where(m => m.Receta == receta.Value);
        }

        // Obtener total antes de paginar
        var total = await query.CountAsync(ct);

        // Obtener resultados paginados
        var resultados = await query
            .OrderBy(m => m.Nombre)
            .Skip(offset)
            .Take(limit)
            .Select(m => new {
                nregistro = m.NRegistro,
                nombre = m.Nombre,
                dosis = m.Dosis,
                laboratorio = m.LabTitular,
                generico = m.Generico,
                receta = m.Receta,
                comercializado = true // Por ahora todos true, después se puede mejorar
            })
            .ToListAsync(ct);

        return Ok(new { 
            total = total,
            count = resultados.Count,
            offset = offset,
            limit = limit,
            results = resultados 
        });
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
