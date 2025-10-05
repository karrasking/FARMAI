@echo off
cd /d %~dp0
echo Compilando proyecto...
echo.
call npm run build
echo.
echo Presiona cualquier tecla para salir...
pause >nul
