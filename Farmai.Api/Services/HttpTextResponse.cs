namespace Farmai.Api.Services;

/// <summary>
/// Respuesta “texto crudo” de una llamada HTTP (status, content-type y body).
/// </summary>
public sealed class HttpTextResponse
{
    public int StatusCode { get; }
    public string? ContentType { get; }
    public string Body { get; }

    public HttpTextResponse(int statusCode, string? contentType, string body)
    {
        StatusCode = statusCode;
        ContentType = contentType;
        Body = body;
    }
}
