// File: Controllers/MedicamentosController.cs
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Farmai.Api.Data;
using Farmai.Api.Data.Entities;
using Farmai.Api.Models;
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
    /// <param name="comercializado">Filtrar por medicamentos comercializados: true/false - OPCIONAL</param>
    /// <param name="biosimilar">Filtrar por medicamentos biosimilares: true/false - OPCIONAL</param>
    /// <param name="hospitalario">Filtrar por uso hospitalario: true/false - OPCIONAL</param>
    /// <param name="limit">Límite de resultados (por defecto 50, máx 200)</param>
    /// <param name="offset">Offset para paginación (por defecto 0)</param>
    [HttpGet("search")]
    public async Task<IActionResult> Search(
        [FromQuery] string? q, 
        [FromQuery] bool? generico,
        [FromQuery] bool? receta,
        [FromQuery] bool? comercializado,
        [FromQuery] bool? biosimilar,
        [FromQuery] bool? hospitalario,
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

        // Aplicar filtro de comercializado
        if (comercializado.HasValue)
        {
            query = query.Where(m => m.Comercializado == comercializado.Value);
        }

        // Aplicar filtro de biosimilar
        if (biosimilar.HasValue)
        {
            query = query.Where(m => m.Biosimilar == biosimilar.Value);
        }

        // Aplicar filtro de hospitalario (desde JSON)
        if (hospitalario.HasValue)
        {
            if (hospitalario.Value)
            {
                // Buscar medicamentos con "Uso Hospitalario" en JSON
                query = query.Where(m => EF.Functions.ILike(m.RawJson, "%Uso Hospitalario%"));
            }
            else
            {
                // Buscar medicamentos SIN uso hospitalario
                query = query.Where(m => !EF.Functions.ILike(m.RawJson, "%Uso Hospitalario%"));
            }
        }

        // Obtener total antes de paginar
        var total = await query.CountAsync(ct);

        // Obtener resultados paginados con laboratorios
        var resultados = await query
            .Include(m => m.LaboratorioTitular)
            .Include(m => m.LaboratorioComercializador)
            .OrderBy(m => m.Nombre)
            .Skip(offset)
            .Take(limit)
            .Select(m => new {
                nregistro = m.NRegistro,
                nombre = m.Nombre,
                dosis = m.Dosis,
                laboratorio = m.LaboratorioTitular != null ? m.LaboratorioTitular.Nombre : m.LabTitular,
                laboratorioTitular = m.LaboratorioTitular != null ? m.LaboratorioTitular.Nombre : null,
                laboratorioComercializador = m.LaboratorioComercializador != null ? m.LaboratorioComercializador.Nombre : null,
                generico = m.Generico,
                receta = m.Receta,
                comercializado = m.Comercializado ?? true,
                biosimilar = m.Biosimilar ?? false
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
    /// Obtiene información básica de un medicamento por NRegistro.
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

    /// <summary>
    /// Obtiene el detalle COMPLETO de un medicamento parseando RawJson
    /// Si no hay RawJson, devuelve datos básicos desde columnas
    /// </summary>
    [HttpGet("{nregistro}/detalle")]
    public async Task<IActionResult> GetDetalle(string nregistro, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(nregistro))
            return BadRequest(new { error = "NRegistro es obligatorio" });

        var medicamento = await _db.Medicamentos
            .Include(m => m.LaboratorioTitular)
            .Include(m => m.LaboratorioComercializador)
            .Where(m => m.NRegistro == nregistro)
            .FirstOrDefaultAsync(ct);

        if (medicamento is null)
            return NotFound(new { error = "Medicamento no encontrado" });

        // Si no hay RawJson, devolver datos básicos desde columnas
        if (string.IsNullOrEmpty(medicamento.RawJson))
        {
            return Ok(new MedicamentoDetalleDto
            {
                Nregistro = medicamento.NRegistro!,
                Nombre = medicamento.Nombre!,
                LabTitular = medicamento.LaboratorioTitular?.Nombre ?? medicamento.LabTitular ?? "",
                LabComercializador = medicamento.LaboratorioComercializador?.Nombre,
                FechaAutorizacion = medicamento.UpdatedAt.ToString("yyyy-MM-dd"),
                Comercializado = true,
                RequiereReceta = medicamento.Receta ?? false,
                EsGenerico = medicamento.Generico ?? false,
                Dosis = medicamento.Dosis
            });
        }

        // Intentar parsear RawJson
        try
        {
            var json = JsonDocument.Parse(medicamento.RawJson);
            var root = json.RootElement;

            var detalle = new MedicamentoDetalleDto
            {
                Nregistro = medicamento.NRegistro!,
                Nombre = medicamento.Nombre!,
                LabTitular = medicamento.LaboratorioTitular?.Nombre ?? medicamento.LabTitular ?? "",
                LabComercializador = medicamento.LaboratorioComercializador?.Nombre,
                FechaAutorizacion = root.TryGetProperty("estado", out var estado) && 
                    estado.TryGetProperty("aut", out var aut) ? 
                    DateTimeOffset.FromUnixTimeMilliseconds(aut.GetInt64()).DateTime.ToString("yyyy-MM-dd") : 
                    medicamento.UpdatedAt.ToString("yyyy-MM-dd"),
                
                Comercializado = root.TryGetProperty("comerc", out var comerc) && comerc.GetBoolean(),
                AutorizadoPorEma = root.TryGetProperty("ema", out var ema) && ema.GetBoolean(),
                TieneNotas = root.TryGetProperty("notas", out var notas) && notas.GetBoolean(),
                RequiereReceta = root.TryGetProperty("receta", out var receta) && receta.GetBoolean(),
                EsGenerico = root.TryGetProperty("generico", out var generico) && generico.GetBoolean(),
                
                FormaFarmaceutica = root.TryGetProperty("formaFarmaceutica", out var ff) && ff.TryGetProperty("nombre", out var ffNombre) ? ffNombre.GetString() ?? "" : "",
                FormaFarmaceuticaSimplificada = root.TryGetProperty("formaFarmaceuticaSimplificada", out var ffs) && ffs.TryGetProperty("nombre", out var ffsNombre) ? ffsNombre.GetString() : null,
                Dosis = root.TryGetProperty("dosis", out var dosis) ? dosis.GetString() : null,
                
                AfectaConduccion = root.TryGetProperty("conduc", out var conduc) && conduc.GetBoolean(),
                TrianguloNegro = root.TryGetProperty("triangulo", out var triangulo) && triangulo.GetBoolean(),
                Huerfano = root.TryGetProperty("huerfano", out var huerfano) && huerfano.GetBoolean(),
                Biosimilar = root.TryGetProperty("biosimilar", out var biosimilar) && biosimilar.GetBoolean(),
                Psum = root.TryGetProperty("psum", out var psum) && psum.GetBoolean(),
                MaterialesInformativos = root.TryGetProperty("materialesInf", out var matInf) && matInf.GetBoolean(),
                
                Interacciones = 0 // TODO: calcular from grafo
            };

            // Parsear ATC con parsing defensivo
            if (root.TryGetProperty("atcs", out var atcs) && atcs.ValueKind == JsonValueKind.Array)
            {
                foreach (var atc in atcs.EnumerateArray())
                {
                    detalle.Atc.Add(new AtcDto
                    {
                        Codigo = atc.TryGetProperty("codigo", out var codigo) ? codigo.GetString() ?? "" : "",
                        Nombre = atc.TryGetProperty("nombre", out var nombre) ? nombre.GetString() ?? "" : "",
                        Nivel = atc.TryGetProperty("nivel", out var nivel) && nivel.ValueKind == JsonValueKind.Number ? nivel.GetInt32() : 0
                    });
                }
            }
            
            // FALLBACK ATCs: Si JSON está vacío, leer desde tablas relacionales
            if (detalle.Atc.Count == 0)
            {
                var atcsFromDb = await (from ma in _db.MedicamentoAtc
                    join a in _db.Atc on ma.Codigo equals a.Codigo into atcJoin
                    from a in atcJoin.DefaultIfEmpty()
                    where ma.NRegistro == nregistro
                    select new AtcDto
                    {
                        Codigo = ma.Codigo,
                        Nombre = a != null ? a.Nombre : "",
                        Nivel = a != null ? a.Nivel : (short)0
                    }).ToListAsync(ct);
                
                detalle.Atc.AddRange(atcsFromDb);
            }

            // VTM con parsing defensivo
            if (root.TryGetProperty("vtm", out var vtm) && vtm.ValueKind == JsonValueKind.Object)
            {
                var vtmId = vtm.TryGetProperty("id", out var id) && id.ValueKind == JsonValueKind.Number ? id.GetInt64() : 0L;
                var vtmNombre = vtm.TryGetProperty("nombre", out var nombre) ? nombre.GetString() ?? "" : "";
                
                if (vtmId > 0)
                {
                    detalle.Vtm = new VtmDto
                    {
                        Id = (int)vtmId,
                        Nombre = vtmNombre
                    };
                }
            }
            
            // FALLBACK VTM: Si no hay VTM del JSON, intentar buscar en tabla Vtm
            if (detalle.Vtm == null)
            {
                var vtmFromDb = await (from m in _db.Medicamentos
                    where m.NRegistro == nregistro && m.RawJson != null
                    select m.RawJson).FirstOrDefaultAsync(ct);
                
                if (!string.IsNullOrEmpty(vtmFromDb))
                {
                    try
                    {
                        var vtmJson = JsonDocument.Parse(vtmFromDb);
                        if (vtmJson.RootElement.TryGetProperty("vtm", out var vtmEl) && 
                            vtmEl.TryGetProperty("id", out var vtmIdEl) && 
                            vtmIdEl.ValueKind == JsonValueKind.Number)
                        {
                            var vtmIdVal = vtmIdEl.GetInt64();
                            var vtmData = await _db.Vtm.FirstOrDefaultAsync(v => v.Id == vtmIdVal, ct);
                            
                            if (vtmData != null)
                            {
                                detalle.Vtm = new VtmDto
                                {
                                    Id = (int)vtmData.Id,
                                    Nombre = vtmData.Nombre
                                };
                            }
                        }
                    }
                    catch { /* Ignorar errores de parsing */ }
                }
            }

            // Vías de administración con parsing defensivo
            if (root.TryGetProperty("viasAdministracion", out var vias) && vias.ValueKind == JsonValueKind.Array)
            {
                foreach (var via in vias.EnumerateArray())
                {
                    detalle.ViasAdministracion.Add(new ViaAdministracionDto
                    {
                        Id = via.TryGetProperty("id", out var id) && id.ValueKind == JsonValueKind.Number ? id.GetInt32() : 0,
                        Nombre = via.TryGetProperty("nombre", out var nombre) ? nombre.GetString() ?? "" : ""
                    });
                }
            }
            
            // FALLBACK Vías: Si JSON está vacío, leer desde tablas relacionales
            if (detalle.ViasAdministracion.Count == 0)
            {
                var viasFromDb = await (from mv in _db.MedicamentoVia
                    join v in _db.ViaAdministracion on mv.ViaId equals v.Id into viaJoin
                    from v in viaJoin.DefaultIfEmpty()
                    where mv.NRegistro == nregistro
                    select new ViaAdministracionDto
                    {
                        Id = mv.ViaId,
                        Nombre = v != null ? v.Nombre : ""
                    }).ToListAsync(ct);
                
                detalle.ViasAdministracion.AddRange(viasFromDb);
            }

            // Principios activos - Intentar JSON primero, fallback a tablas relacionales
            if (root.TryGetProperty("principiosActivos", out var pas) && pas.ValueKind == JsonValueKind.Array)
            {
                foreach (var pa in pas.EnumerateArray())
                {
                    detalle.PrincipiosActivos.Add(new PrincipioActivoDto
                    {
                        Id = pa.TryGetProperty("id", out var id) ? id.GetInt32() : 0,
                        Nombre = pa.TryGetProperty("nombre", out var nombre) ? nombre.GetString() ?? "" : "",
                        Cantidad = pa.TryGetProperty("cantidad", out var cant) ? cant.GetString() ?? "" : "",
                        Unidad = pa.TryGetProperty("unidad", out var unidad) ? unidad.GetString() ?? "" : ""
                    });
                }
            }
            
            // FALLBACK: Si JSON está vacío, leer desde tablas relacionales con JOIN manual
            if (detalle.PrincipiosActivos.Count == 0)
            {
                var pasFromDb = await (from ms in _db.MedicamentoSustancia
                    join sa in _db.SustanciaActiva on ms.SustanciaId equals sa.Id into saJoin
                    from sa in saJoin.DefaultIfEmpty()
                    where ms.NRegistro == nregistro
                    orderby ms.Orden
                    select new PrincipioActivoDto
                    {
                        Id = (int)ms.SustanciaId,
                        Nombre = sa != null ? sa.Nombre ?? "" : "",
                        Cantidad = ms.Cantidad,
                        Unidad = ms.Unidad
                    }).ToListAsync(ct);
                
                detalle.PrincipiosActivos.AddRange(pasFromDb);
            }

            // Excipientes con detección de alérgenos - Intentar JSON primero, fallback a tablas relacionales
            if (root.TryGetProperty("excipientes", out var excs) && excs.ValueKind == JsonValueKind.Array)
            {
                foreach (var exc in excs.EnumerateArray())
                {
                    var nombreExc = exc.TryGetProperty("nombre", out var nombre) ? nombre.GetString() ?? "" : "";
                    var nombreUpper = nombreExc.ToUpperInvariant();
                    
                    string? tipoAlergeno = null;
                    var esAlergeno = false;
                    
                    if (nombreUpper.Contains("LACTOSA")) { esAlergeno = true; tipoAlergeno = "lactosa"; }
                    else if (nombreUpper.Contains("GLUTEN") || nombreUpper.Contains("TRIGO")) { esAlergeno = true; tipoAlergeno = "gluten"; }
                    else if (nombreUpper.Contains("SOJA")) { esAlergeno = true; tipoAlergeno = "soja"; }
                    else if (nombreUpper.Contains("CACAHU")) { esAlergeno = true; tipoAlergeno = "cacahuete"; }
                    
                    detalle.Excipientes.Add(new ExcipienteDto
                    {
                        Id = exc.TryGetProperty("id", out var id) ? id.GetInt32() : 0,
                        Nombre = nombreExc,
                        Cantidad = exc.TryGetProperty("cantidad", out var cant) ? cant.GetString() : null,
                        Unidad = exc.TryGetProperty("unidad", out var unidad) ? unidad.GetString() : null,
                        Orden = exc.TryGetProperty("orden", out var orden) ? orden.GetInt32() : 0,
                        EsAlergeno = esAlergeno,
                        TipoAlergeno = tipoAlergeno
                    });
                }
            }
            
            // FALLBACK: Si JSON está vacío, leer desde tablas relacionales con JOIN manual
            if (detalle.Excipientes.Count == 0)
            {
                var excsFromDb = await (from me in _db.MedicamentoExcipiente
                    join exc in _db.Excipiente on me.ExcipienteId equals exc.Id into excJoin
                    from exc in excJoin.DefaultIfEmpty()
                    where me.NRegistro == nregistro
                    orderby me.Orden
                    select new 
                    {
                        me.ExcipienteId,
                        Nombre = exc != null ? exc.Nombre ?? "" : "",
                        me.Cantidad,
                        me.Unidad,
                        me.Orden
                    }).ToListAsync(ct);
                
                foreach (var me in excsFromDb)
                {
                    var nombreExc = me.Nombre;
                    var nombreUpper = nombreExc.ToUpperInvariant();
                    
                    string? tipoAlergeno = null;
                    var esAlergeno = false;
                    
                    if (nombreUpper.Contains("LACTOSA")) { esAlergeno = true; tipoAlergeno = "lactosa"; }
                    else if (nombreUpper.Contains("GLUTEN") || nombreUpper.Contains("TRIGO")) { esAlergeno = true; tipoAlergeno = "gluten"; }
                    else if (nombreUpper.Contains("SOJA")) { esAlergeno = true; tipoAlergeno = "soja"; }
                    else if (nombreUpper.Contains("CACAHU")) { esAlergeno = true; tipoAlergeno = "cacahuete"; }
                    
                    detalle.Excipientes.Add(new ExcipienteDto
                    {
                        Id = (int)me.ExcipienteId,
                        Nombre = nombreExc,
                        Cantidad = me.Cantidad,
                        Unidad = me.Unidad,
                        Orden = me.Orden,
                        EsAlergeno = esAlergeno,
                        TipoAlergeno = tipoAlergeno
                    });
                }
            }

            // Presentaciones
            if (root.TryGetProperty("presentaciones", out var preses) && preses.ValueKind == JsonValueKind.Array)
            {
                foreach (var pres in preses.EnumerateArray())
                {
                    detalle.Presentaciones.Add(new PresentacionDto
                    {
                        Cn = pres.TryGetProperty("cn", out var cn) ? cn.GetString() ?? "" : "",
                        Nombre = pres.TryGetProperty("nombre", out var nombre) ? nombre.GetString() ?? "" : "",
                        Pvp = pres.TryGetProperty("precio", out var precio) ? precio.GetDecimal() : null,
                        Estado = pres.TryGetProperty("estado", out var est) && est.TryGetProperty("nombre", out var estNombre) ? estNombre.GetString() ?? "" : "",
                        Comercializada = pres.TryGetProperty("comerc", out var comerc2) && comerc2.GetBoolean(),
                        Psum = pres.TryGetProperty("psum", out var psum2) && psum2.GetBoolean()
                    });
                }
            }

            // Documentos
            if (root.TryGetProperty("docs", out var docs) && docs.ValueKind == JsonValueKind.Array)
            {
                foreach (var doc in docs.EnumerateArray())
                {
                    var tipo = doc.TryGetProperty("tipo", out var tipoVal) ? tipoVal.GetInt32() : 0;
                    detalle.Documentos.Add(new DocumentoDto
                    {
                        Tipo = tipo == 1 ? "FT" : (tipo == 2 ? "P" : "MI"),
                        Url = doc.TryGetProperty("url", out var url) ? url.GetString() ?? "" : "",
                        UrlHtml = doc.TryGetProperty("urlHtml", out var urlHtml) ? urlHtml.GetString() : null,
                        Fecha = doc.TryGetProperty("fecha", out var fecha) ? 
                            DateTimeOffset.FromUnixTimeMilliseconds(fecha.GetInt64()).DateTime.ToString("yyyy-MM-dd") : "",
                        Disponible = true
                    });
                }
            }

            // Fotos
            if (root.TryGetProperty("fotos", out var fotos) && fotos.ValueKind == JsonValueKind.Object)
            {
                if (fotos.TryGetProperty("materialas", out var materialas) && materialas.ValueKind == JsonValueKind.Array)
                {
                    foreach (var foto in materialas.EnumerateArray())
                    {
                        if (foto.TryGetProperty("url", out var url))
                        {
                            detalle.Fotos.Add(new FotoDto { Tipo = "materialas", Url = url.GetString() ?? "" });
                        }
                    }
                }
                if (fotos.TryGetProperty("formafarmac", out var formafarmac) && formafarmac.ValueKind == JsonValueKind.Array)
                {
                    foreach (var foto in formafarmac.EnumerateArray())
                    {
                        if (foto.TryGetProperty("url", out var url))
                        {
                            detalle.Fotos.Add(new FotoDto { Tipo = "formafarmac", Url = url.GetString() ?? "" });
                        }
                    }
                }
            }

            return Ok(detalle);
        }
        catch (JsonException)
        {
            return StatusCode(500, new { error = "Error parseando datos del medicamento" });
        }
    }

    /// <summary>
    /// Obtiene los documentos (Ficha Técnica y Prospecto) de un medicamento
    /// Devuelve URLs HTML y PDF disponibles en CIMA
    /// </summary>
    [HttpGet("{nregistro}/documentos")]
    public async Task<IActionResult> GetDocumentos(string nregistro, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(nregistro))
            return BadRequest(new { error = "NRegistro es obligatorio" });

        // Por ahora devolver estructura mock con URLs típicas de CIMA
        // TODO: Consultar tabla Documento cuando tengamos el esquema correcto
        var result = new
        {
            nregistro = nregistro,
            documentos = new[]
            {
                new
                {
                    tipo = "Ficha Técnica",
                    urlHtml = $"https://cima.aemps.es/cima/pdfs/ft/{nregistro}/FT_{nregistro}.pdf",
                    urlPdf = $"https://cima.aemps.es/cima/pdfs/ft/{nregistro}/FT_{nregistro}.pdf"
                },
                new
                {
                    tipo = "Prospecto",
                    urlHtml = $"https://cima.aemps.es/cima/pdfs/p/{nregistro}/P_{nregistro}.pdf",
                    urlPdf = $"https://cima.aemps.es/cima/pdfs/p/{nregistro}/P_{nregistro}.pdf"
                }
            }
        };

        return Ok(result);
    }
}
