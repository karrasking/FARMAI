using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Farmai.Api.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddMedicamentoCols : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "Nombre",
                table: "Medicamentos",
                type: "character varying(512)",
                maxLength: 512,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<string>(
                name: "Dosis",
                table: "Medicamentos",
                type: "character varying(128)",
                maxLength: 128,
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "Generico",
                table: "Medicamentos",
                type: "boolean",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "LabTitular",
                table: "Medicamentos",
                type: "character varying(256)",
                maxLength: 256,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NRegistro",
                table: "Medicamentos",
                type: "character varying(32)",
                maxLength: 32,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "RawJson",
                table: "Medicamentos",
                type: "jsonb",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<bool>(
                name: "Receta",
                table: "Medicamentos",
                type: "boolean",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "Medicamentos",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.CreateIndex(
                name: "IX_Medicamentos_NRegistro",
                table: "Medicamentos",
                column: "NRegistro",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Medicamentos_NRegistro",
                table: "Medicamentos");

            migrationBuilder.DropColumn(
                name: "Dosis",
                table: "Medicamentos");

            migrationBuilder.DropColumn(
                name: "Generico",
                table: "Medicamentos");

            migrationBuilder.DropColumn(
                name: "LabTitular",
                table: "Medicamentos");

            migrationBuilder.DropColumn(
                name: "NRegistro",
                table: "Medicamentos");

            migrationBuilder.DropColumn(
                name: "RawJson",
                table: "Medicamentos");

            migrationBuilder.DropColumn(
                name: "Receta",
                table: "Medicamentos");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "Medicamentos");

            migrationBuilder.AlterColumn<string>(
                name: "Nombre",
                table: "Medicamentos",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(512)",
                oldMaxLength: 512);
        }
    }
}
