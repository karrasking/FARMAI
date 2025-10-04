@echo off
echo ========================================
echo   FARMAI DASHBOARD - Iniciando...
echo ========================================
echo.
echo Abriendo servidor en http://localhost:5173
echo.
cd farmai-dashboard
start http://localhost:5173
npm run dev
