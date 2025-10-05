@echo off
echo ========================================
echo   LIMPIAR CACHE Y RECOMPILAR
echo ========================================
echo.

echo 1. Eliminando node_modules y cache...
if exist node_modules rmdir /s /q node_modules
if exist .vite rmdir /s /q .vite
if exist dist rmdir /s /q dist

echo.
echo 2. Instalando dependencias...
call npm install

echo.
echo 3. Limpiando cache de TypeScript...
if exist tsconfig.tsbuildinfo del tsconfig.tsbuildinfo

echo.
echo ========================================
echo   LISTO! Ahora ejecuta: npm run dev
echo ========================================
echo.
pause
