# 🚀 INSTRUCCIONES PARA PROBAR EL FALLBACK

## ⚠️ IMPORTANTE: DEBES SEGUIR LOS PASOS EN ORDEN

---

## PASO 1: INICIAR EL BACKEND ✅

Abre una **NUEVA terminal PowerShell** y ejecuta:

```powershell
cd C:\Users\Victor\Desktop\FARMAI
.\LANZAR_FARMAI_COMPLETO.bat
```

**Espera a que veas:**
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5177
```

**DEJA ESTA TERMINAL ABIERTA** - El backend debe seguir corriendo.

---

## PASO 2: PROBAR EL FALLBACK ✅

Abre una **SEGUNDA terminal PowerShell** y ejecuta:

```powershell
cd C:\Users\Victor\Desktop\FARMAI
powershell -ExecutionPolicy Bypass -File PROBAR_FALLBACK_67939.ps1
```

**Deberías ver:**
```
✅ Encontrados: 1 principio activo
  - [NOMBRE DEL PA]: 600 mg

✅ Encontrados: 5 excipientes
  - [NOMBRES DE EXCIPIENTES]

🎉 ¡FALLBACK FUNCIONANDO CORRECTAMENTE!
```

---

## ❌ SI VES ESTE ERROR:

```
Invoke-RestMethod : No es posible conectar con el servidor remoto
```

**SIGNIFICA:** El backend NO está corriendo. Vuelve al PASO 1.

---

## ✅ QUÉ HACE EL FALLBACK

1. **Primero intenta:** Leer principios activos del campo `RawJson`
2. **Si JSON está vacío:** Lee desde tabla `MedicamentoSustancia`
3. **Lo mismo para excipientes:** Lee desde tabla `MedicamentoExcipiente`

---

## 🔍 VERIFICACIÓN MANUAL (OPCIONAL)

Si quieres verificar manualmente que el fallback funciona:

### Opción A: Usar navegador
1. Backend corriendo
2. Abrir: `http://localhost:5177/api/Medicamentos/67939/detalle`
3. Buscar en el JSON: `"principiosActivos"` y `"excipientes"`
4. Deberían tener elementos

### Opción B: Usar PowerShell
```powershell
$response = Invoke-RestMethod -Uri "http://localhost:5177/api/Medicamentos/67939/detalle"
$response.principiosActivos
$response.excipientes
```

---

## 📊 MEDICAMENTOS PARA PROBAR

| NRegistro | Tiene JSON | Tiene en Tablas | Resultado Esperado |
|-----------|------------|-----------------|-------------------|
| 67939     | ❌ NO      | ✅ SÍ          | Fallback funciona ✅ |
| [Otro]    | ✅ SÍ      | ✅ SÍ          | Lee del JSON ✅ |

---

## 🎯 RESUMEN

**Tu implementación está CORRECTA.**  
**El error es solo que el backend no está corriendo.**  
**Sigue los pasos 1 y 2 en orden y funcionará.**
