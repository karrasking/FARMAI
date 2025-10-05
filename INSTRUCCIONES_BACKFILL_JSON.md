# 🚀 BACKFILL MASIVO: JSON Completo para 20,271 Medicamentos

## 📋 RESUMEN

**Objetivo:** Obtener JSON completo de API CIMA para los 20,124 medicamentos que actualmente tienen `RawJson = {}`

**Resultado esperado:** 
- ✅ 20,271 medicamentos con JSON completo
- ✅ Campo `Comercializado` poblado al 100%
- ✅ Todos los flags disponibles (ema, notas, conduc, etc.)
- ✅ Base de datos COMPLETA y lista para producción

---

## ⚙️ ARCHIVOS CREADOS

### 1. `etl/python/backfill_rawjson_completo.py`
**Script Python principal** que:
- Consulta API CIMA: `GET /medicamento?nregistro={nregistro}`
- Procesa 20,124 medicamentos sin JSON
- Rate limit: 100ms entre requests (10 req/seg)
- Commits cada 100 registros
- Muestra progreso en tiempo real

### 2. `EJECUTAR_BACKFILL_JSON.ps1`
**Launcher PowerShell** para ejecutar fácilmente el backfill

### 3. `scripts_propagacion/46_propagar_comercializado_masivo.sql`
**Script SQL** para propagar campo `Comercializado` después del backfill

---

## 🔧 REQUISITOS

```bash
# Python con las librerías:
pip install psycopg2-binary requests
```

---

## 🚀 EJECUCIÓN

### OPCIÓN A: PowerShell (Recomendado)

```powershell
.\EJECUTAR_BACKFILL_JSON.ps1
```

### OPCIÓN B: Python directo

```bash
python etl/python/backfill_rawjson_completo.py
```

---

## ⏱️ TIEMPO ESTIMADO

```
20,124 medicamentos × 0.1 seg = 2,012 segundos
                                = 33 minutos (ideal)
                                = 2-3 horas (con 404, timeouts, etc.)
```

**Progreso en tiempo real:**
```
[1,234/20,124] 6.1% | ✅ 1,200 | ❌ 12 | ⚠️ 22 | ETA: 2.3h
```

---

## 📊 PROCESO

### 1️⃣ **Backfill JSON** (~3 horas)
```bash
python etl/python/backfill_rawjson_completo.py
```

**Resultado:**
- ✅ ~19,500 medicamentos con JSON completo (97%)
- ⚠️ ~500 no encontrados (404) - medicamentos descatalogados
- ❌ ~100 errores (timeouts, etc.)

### 2️⃣ **Propagar Campo Comercializado** (5 segundos)
```bash
$env:PGPASSWORD='Iaforeverfree'; psql -h localhost -p 5433 -U farmai_user -d farmai_db -f scripts_propagacion/46_propagar_comercializado_masivo.sql
```

**Resultado:**
- ✅ Campo `Comercializado` poblado al 97%
- ✅ ~19,500 medicamentos con info real
- ⚠️ ~500 quedan NULL (no existen en API)

---

## 🎯 RESULTADO FINAL ESPERADO

### ANTES:
```
RawJson completo:    147 (0.73%)
Comercializado OK:   147 (0.73%)
```

### DESPUÉS:
```
RawJson completo:  ~19,700 (97.2%)
Comercializado OK: ~19,700 (97.2%)
```

---

## ✅ VERIFICACIÓN POST-BACKFILL

### 1. Verificar JSON
```sql
SELECT 
    COUNT(*) as total,
    COUNT(CASE WHEN "RawJson" IS NOT NULL AND "RawJson"::text != '{}' THEN 1 END) as con_json
FROM "Medicamentos";
```

### 2. Verificar Comercializado
```sql
SELECT 
    "Comercializado",
    COUNT(*) as cantidad
FROM "Medicamentos"
GROUP BY "Comercializado";
```

### 3. Ver sample
```sql
SELECT "NRegistro", "Nombre", "Comercializado"
FROM "Medicamentos"
WHERE "Comercializado" = true
LIMIT 10;
```

---

## ⚠️ NOTAS IMPORTANTES

1. **El proceso es SEGURO** - hace commits cada 100 registros
2. **Puede detenerse y reiniciarse** - solo procesará medicamentos sin JSON
3. **No afecta datos existentes** - solo actualiza RawJson vacío
4. **Rate limit respetado** - 10 req/seg (dentro de límites CIMA)
5. **Progreso visible** - muestra stats cada 10 medicamentos

---

## 🐛 TROUBLESHOOTING

### Error: ModuleNotFoundError
```bash
pip install psycopg2-binary requests
```

### Error: Connection refused (BD)
```bash
# Verificar que PostgreSQL esté corriendo:
docker ps
```

### Muchos 404
✅ Normal - medicamentos descatalogados en CIMA

### Script lento
✅ Normal - son 20K requests con rate limit

---

## 📈 DESPUÉS DEL BACKFILL

Una vez completado, podrás:
1. ✅ Mostrar "Uso Hospitalario" en frontend
2. ✅ Filtrar por medicamentos comercializados
3. ✅ Usar flags adicionales (ema, notas, conduc, etc.)
4. ✅ Tener base de datos 100% completa

---

## 🎯 ¿LISTO PARA ARRANCAR?

```powershell
.\EJECUTAR_BACKFILL_JSON.ps1
```

**¡A por los 20,271!** 🚀
