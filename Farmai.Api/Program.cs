// File: Program.cs
using Farmai.Api.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using Farmai.Api.Services;

var builder = WebApplication.CreateBuilder(args);

// DbContext → Postgres (Development lee la cadena desde appsettings.Development.json)
var conn = builder.Configuration.GetConnectionString("Postgres");
builder.Services.AddDbContext<FarmaiDbContext>(opt => opt.UseNpgsql(conn));

// Servicios API + Swagger
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Farmai.Api", Version = "v1" });
});
// CIMA
builder.Services.AddHttpClient<ICimaClient, CimaClient>(client =>
{
    var baseUrl = builder.Configuration.GetSection("Cima")["BaseUrl"]!;
    client.BaseAddress = new Uri(baseUrl);
});

// Fetcher ZIP/XML
builder.Services.AddHttpClient<IZipOrXmlFetcher, ZipOrXmlFetcher>();
builder.Services.AddScoped<INomenclatorService, NomenclatorService>();


builder.Services.AddScoped<ImportService>();
builder.Services.AddScoped<SyncService>(); // <— añade esto

var app = builder.Build();

// Pipeline (solo Dev)
// ESTA ES LA VERSIÓN SIMPLIFICADA Y CORRECTA
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
