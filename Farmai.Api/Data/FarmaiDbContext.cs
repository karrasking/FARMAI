// File: Data/FarmaiDbContext.cs
using Farmai.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace Farmai.Api.Data;

public class FarmaiDbContext(DbContextOptions<FarmaiDbContext> options) : DbContext(options)
{
    // DbSet para la tabla de Medicamentos (ya lo tenías)
    public DbSet<Medicamento> Medicamentos => Set<Medicamento>();

    // ¡¡NUEVO!! Le decimos a EF Core que existe la tabla de Staging
    public DbSet<MedicamentoDetalleStaging> MedicamentoDetalleStaging => Set<MedicamentoDetalleStaging>();
    
    // Entidades para el Dashboard
    public DbSet<Presentacion> Presentacion => Set<Presentacion>();
    public DbSet<SustanciaActiva> SustanciaActiva => Set<SustanciaActiva>();
    public DbSet<Laboratorio> Laboratorio => Set<Laboratorio>();
    public DbSet<Excipiente> Excipiente => Set<Excipiente>();
    public DbSet<Biomarcador> Biomarcador => Set<Biomarcador>();
    public DbSet<Documento> Documento => Set<Documento>();
    public DbSet<GraphNode> GraphNode => Set<GraphNode>();
    public DbSet<GraphEdge> GraphEdge => Set<GraphEdge>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // --- Configuración para la entidad Medicamento ---
        var m = modelBuilder.Entity<Medicamento>();
        m.ToTable("Medicamentos");
        m.HasKey(x => x.Id);
        m.HasIndex(x => x.NRegistro).IsUnique();   // Evita duplicados por nregistro
        m.Property(x => x.RawJson).HasColumnType("jsonb"); // Le decimos que esta columna es de tipo jsonb

        // --- ¡¡NUEVO!! Configuración para la entidad de Staging ---
        // Aunque ya creaste la tabla con SQL, esto ayuda a EF Core a entenderla mejor
        var s = modelBuilder.Entity<MedicamentoDetalleStaging>();
        s.ToTable("MedicamentoDetalleStaging"); // Se asegura de que el nombre de la tabla es correcto
        s.HasKey(x => x.NRegistro); // Le decimos cuál es la clave primaria
        s.Property(x => x.DetalleJson).HasColumnType("jsonb"); // Le decimos que esta columna es de tipo jsonb
        
        // --- Configuración para entidades del Dashboard ---
        modelBuilder.Entity<Presentacion>().ToTable("Presentacion").HasKey(x => x.CN);
        modelBuilder.Entity<SustanciaActiva>().ToTable("SustanciaActiva").HasKey(x => x.Id);
        modelBuilder.Entity<Laboratorio>().ToTable("Laboratorio").HasKey(x => x.Codigo);
        modelBuilder.Entity<Excipiente>().ToTable("Excipiente").HasKey(x => x.Id);
        modelBuilder.Entity<Biomarcador>().ToTable("Biomarcador").HasKey(x => x.Id);
        modelBuilder.Entity<Documento>().ToTable("Documento").HasKey(x => x.Id);
        
        // Configuración del grafo
        modelBuilder.Entity<GraphNode>().ToTable("graph_node").HasKey(x => new { x.NodeType, x.NodeKey });
        modelBuilder.Entity<GraphEdge>().ToTable("graph_edge").HasNoKey(); // Sin PK definida
    }
}
