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
    }
}