@echo off
title FARMAI - Activador Completo
color 0A
echo ========================================
echo   FARMAI - ACTIVADOR AUTOMATICO
echo ========================================
echo.
echo [1/5] Compilando Backend (.NET)...
echo.

cd /d "%~dp0Farmai.Api"
call dotnet build --nologo
if errorlevel 1 (
    color 0C
    echo.
    echo ❌ ERROR: El backend no compilo correctamente
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Backend compilado exitosamente
echo.
echo [2/5] Verificando dependencias del Frontend...
echo.

cd /d "%~dp0farmai-dashboard"
if not exist "node_modules\" (
    echo 📦 Instalando dependencias de npm por primera vez...
    call npm install
) else (
    echo ✅ Dependencias ya instaladas
)

echo.
echo [3/5] Iniciando Backend en nueva ventana...
echo.

cd /d "%~dp0"
start "FARMAI Backend (Puerto 5265)" cmd /k "cd Farmai.Api && echo ========================================== && echo    FARMAI BACKEND - PUERTO 5265 && echo ========================================== && echo. && dotnet run"

timeout /t 3 /nobreak >nul

echo.
echo [4/5] Iniciando Frontend en nueva ventana...
echo.

start "FARMAI Frontend (Puerto 5173)" cmd /k "cd farmai-dashboard && echo ========================================== && echo    FARMAI FRONTEND - PUERTO 5173 && echo ========================================== && echo. && npm run dev"

timeout /t 5 /nobreak >nul

echo.
echo [5/5] Abriendo navegador...
echo.

timeout /t 3 /nobreak >nul
start http://localhost:5173

echo.
echo ========================================
echo   ✅ FARMAI INICIADO CORRECTAMENTE
echo ========================================
echo.
echo 🔹 Backend corriendo en: http://localhost:5265
echo 🔹 Frontend corriendo en: http://localhost:5173
echo 🔹 Navegador abierto automaticamente
echo.
echo 📝 Para detener los servicios:
echo    - Cierra las ventanas de Backend y Frontend
echo    - O presiona Ctrl+C en cada ventana
echo.
echo 🎯 Para volver a iniciar:
echo    - Ejecuta este script: LANZAR_FARMAI_COMPLETO.bat
echo.
echo.
echo Presiona cualquier tecla para cerrar este mensaje...
pause >nul
