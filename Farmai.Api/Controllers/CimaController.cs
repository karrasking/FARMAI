// File: Controllers/CimaController.cs
using Farmai.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Farmai.Api.Controllers;

[ApiController]
[Route("api/cima")]
public class CimaController(ICimaClient cima) : ControllerBase
{
    // GET /api/cima/maestras/3
    [HttpGet("maestras/{id:int}")]
    public async Task<IActionResult> GetMaestras(int id, CancellationToken ct)
    {
        var resp = await cima.GetMaestrasAsync(id, ct);

        // Si CIMA responde 204 o cuerpo vacío, devolvemos [] para no romper el cliente
        if (resp.StatusCode == 204 || string.IsNullOrWhiteSpace(resp.Body))
            return Content("[]", "application/json");

        // Si no es JSON, devuelve texto para diagnóstico
        var contentType = (resp.Body.StartsWith("{") || resp.Body.StartsWith("[")) ? "application/json" : "text/plain";
        return StatusCode(resp.StatusCode, new ContentResult { Content = resp.Body, ContentType = contentType }.Content);
    }

    // GET /api/cima/medicamentos?nombre=ibuprofeno   (endpoint alternativo de prueba)
    [HttpGet("medicamentos")]
    public async Task<IActionResult> GetMedicamentos([FromQuery] string nombre, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(nombre)) return BadRequest("Parámetro 'nombre' requerido.");
        var resp = await cima.GetMedicamentosByNombreAsync(nombre, ct);

        if (resp.StatusCode == 204 || string.IsNullOrWhiteSpace(resp.Body))
            return Content("[]", "application/json");

        var contentType = (resp.Body.StartsWith("{") || resp.Body.StartsWith("[")) ? "application/json" : "text/plain";
        return StatusCode(resp.StatusCode, new ContentResult { Content = resp.Body, ContentType = contentType }.Content);
    }
}
