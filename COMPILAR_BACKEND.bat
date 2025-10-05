@echo off
cd /d "%~dp0Farmai.Api"
echo Compilando backend...
echo.
dotnet build --nologo
echo.
if errorlevel 1 (
    echo ERROR en compilacion
    pause
) else (
    echo Compilacion exitosa
)
