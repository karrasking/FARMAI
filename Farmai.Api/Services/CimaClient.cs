// File: Services/CimaClient.cs
using System.Net.Http.Headers;

namespace Farmai.Api.Services;

public class CimaClient(HttpClient http) : ICimaClient
{
    private static void EnsureHeaders(HttpClient h)
    {
        if (!h.DefaultRequestHeaders.Accept.Any())
            h.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
        if (!h.DefaultRequestHeaders.UserAgent.Any())
            h.DefaultRequestHeaders.UserAgent.ParseAdd("Farmai.Api/1.0 (+https://localhost)");
    }

    public async Task<HttpTextResponse> GetMaestrasAsync(int maestra, CancellationToken ct = default)
    {
        EnsureHeaders(http);
        // OJO: BaseAddress = https://cima.aemps.es/cima/rest/
        var res = await http.GetAsync($"maestras?maestra={maestra}", ct);
        var body = await res.Content.ReadAsStringAsync(ct);
        res.Content.Headers.TryGetValues("Content-Type", out var ctVals);
        return new HttpTextResponse((int)res.StatusCode, ctVals?.FirstOrDefault(), body);
    }

    public async Task<HttpTextResponse> GetMedicamentosByNombreAsync(string nombre, CancellationToken ct = default)
    {
        EnsureHeaders(http);
        var url = $"medicamentos?nombre={Uri.EscapeDataString(nombre)}";
        var res = await http.GetAsync(url, ct);
        var body = await res.Content.ReadAsStringAsync(ct);
        res.Content.Headers.TryGetValues("Content-Type", out var ctVals);
        return new HttpTextResponse((int)res.StatusCode, ctVals?.FirstOrDefault(), body);
    }

    public async Task<HttpTextResponse> GetMedicamentoByNRegistroAsync(string nregistro, CancellationToken ct = default)
    {
        EnsureHeaders(http);
        var res = await http.GetAsync($"medicamento?nregistro={Uri.EscapeDataString(nregistro)}", ct);
        var body = await res.Content.ReadAsStringAsync(ct);
        res.Content.Headers.TryGetValues("Content-Type", out var ctVals);
        return new HttpTextResponse((int)res.StatusCode, ctVals?.FirstOrDefault(), body);
    }

}
