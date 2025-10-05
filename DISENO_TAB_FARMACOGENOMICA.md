# 🧬 DISEÑO TAB FARMACOGENÓMICA - FARMAI

## 📊 DATOS DISPONIBLES

### Cobertura
- **47 biomarcadores** totales en BD
- **3,026 medicamentos** con información farmacogenómica (14.93%)
- **100% tiene FuenteUrl** → podemos enlazar a FT

### Top 10 Biomarcadores
```
1. CYP2C19  → 729 medicamentos (metabolizador)
2. CYP2D6   → 526 medicamentos (metabolizador)
3. SLCO1B1  → 403 medicamentos (transportador)
4. CYP2C9   → 313 medicamentos (metabolizador)
5. CYP3A4   → 243 medicamentos (metabolizador)
6. ABCG2    → 135 medicamentos (transportador)
7. ERBB2    →  114 medicamentos (oncogén)
8. HLA-B    →  105 medicamentos (inmunogenética)
9. Deleción 5q → 101 medicamentos (citogenética)
10. ESR1    →  57 medicamentos (receptor hormonal)
```

---

## 🗂️ ESTRUCTURA DE DATOS

### Tabla `Biomarcador`
```sql
- Id: bigint
- Nombre: string (ej: "CYP2D6", "HLA-B*1502")
- NombreCanon: string (canónico lowercase)
- Tipo: "gen" | "proteina" | otros
- Descripcion: string
  Formato: "Clase: Germinal|Somático | Inclusión SNS: True|False"
- CodigoExt: jsonb {"fuente": "prescripcion_xml"}
```

### Tabla `MedicamentoBiomarcador`
```sql
- NRegistro: string
- BiomarcadorId: bigint
- TipoRelacion: "ajuste_dosis" (único valor encontrado)
- Evidencia: text ⭐ CAMPO CLAVE
  Formato: "(4.2) Texto con recomendación clínica específica..."
- NivelEvidencia: smallint (siempre 4)
- Fuente: "AEMPS XML"
- FuenteUrl: text ⭐ CAMPO CLAVE
  Formato: "4.2 Sección|4.5 Otra sección|..."
- Notas: text (opcional)
```

---

## 🎨 DISEÑO DE LA TAB

### Ejemplo Real: CITALVIR (Citalopram)

```
┌─────────────────────────────────────────────────────────────┐
│ 🧬 INFORMACIÓN FARMACOGENÓMICA                               │
│                                                              │
│ Este medicamento tiene interacciones con 1 biomarcador(es). │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 🧬 CYP2C19                                    ✅ Incluido SNS │
│                                                              │
│ Tipo: Variante Genética Germinal                            │
│                                                              │
│ ⚠️ REQUIERE AJUSTE DE DOSIS                                 │
│                                                              │
│ 📋 Recomendación Clínica:                                    │
│ Se recomienda una dosis inicial de 10 mg al día durante     │
│ las dos primeras semanas de tratamiento. Dependiendo de     │
│ la respuesta individual del paciente se puede incrementar    │
│ la dosis hasta un máximo de 20 mg al día.                   │
│                                                              │
│ 📖 Referencias en Ficha Técnica:                             │
│ • 4.2 - Posología y forma de administración                 │
│ • 4.5 - Interacciones con otros medicamentos                │
│                                                              │
│ 🔗 Ver en documento oficial → [Abrir FT]                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 COMPONENTES A IMPLEMENTAR

### 1. Backend - DTO (C#)
```csharp
public class BiomarcadorDto 
{
    public int Id { get; set; }
    public string Nombre { get; set; }  // "CYP2D6"
    public string? NombreCanon { get; set; }  // "cyp2d6"
    public string Tipo { get; set; }  // "gen"
    public string Descripcion { get; set; }  // Parseado
    public bool IncluidoSns { get; set; }  // Parseado de Descripcion
    public string ClaseBiomarcador { get; set; }  // "Germinal" | "Somático"
    
    // Información de la relación
    public string TipoRelacion { get; set; }  // "ajuste_dosis"
    public string Evidencia { get; set; }  // Texto largo ⭐
    public int NivelEvidencia { get; set; }  // 4
    public string Fuente { get; set; }  // "AEMPS XML"
    public List<string> SeccionesFt { get; set; }  // ["4.2", "4.5"]
    public string? Notas { get; set; }
}
```

### 2. Frontend - Componente React
```tsx
// FarmacogenomicaTab.tsx
export default function FarmacogenomicaTab({ medicamento }) {
  if (!medicamento.biomarcadores || medicamento.biomarcadores.length === 0) {
    return <EmptyState />
  }

  return (
    <div className="space-y-4">
      <AlertInfo>
        Este medicamento tiene interacciones con{' '}
        {medicamento.biomarcadores.length} biomarcador(es).
      </AlertInfo>

      {medicamento.biomarcadores.map(bio => (
        <BiomarcadorCard key={bio.id} biomarcador={bio} />
      ))}
    </div>
  )
}
```

### 3. BiomarcadorCard Subcomponente
```tsx
function BiomarcadorCard({ biomarcador }) {
  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <h3>
            🧬 {biomarcador.nombre}
          </h3>
          {biomarcador.incluidoSns && (
            <Badge variant="success">✅ Incluido SNS</Badge>
          )}
        </div>
        <p>Tipo: {biomarcador.claseBiomarcador}</p>
      </CardHeader>

      <CardContent>
        {/* Alerta si requiere ajuste */}
        {biomarcador.tipoRelacion === 'ajuste_dosis' && (
          <Alert variant="warning">
            ⚠️ REQUIERE AJUSTE DE DOSIS
          </Alert>
        )}

        {/* Evidencia clínica */}
        <div>
          <h4>📋 Recomendación Clínica:</h4>
          <p>{biomarcador.evidencia}</p>
        </div>

        {/* Referencias FT */}
        <div>
          <h4>📖 Referencias en Ficha Técnica:</h4>
          <ul>
            {biomarcador.seccionesFt.map(sec => (
              <li key={sec}>• Sección {sec}</li>
            ))}
          </ul>
        </div>

        {/* Botón para abrir FT */}
        <Button onClick={() => abrirFichaTecnica()}>
          🔗 Ver en documento oficial
        </Button>
      </CardContent>
    </Card>
  )
}
```

---

## 🚀 IMPLEMENTACIÓN - PASOS

### Paso 1: Backend - Actualizar DTO
- [ ] Crear `BiomarcadorDto` en `MedicamentoDetalleDto.cs`
- [ ] Parsear campo `Descripcion` para extraer SNS/Clase
- [ ] Parsear `FuenteUrl` para extraer secciones
- [ ] JOIN con tablas en controller

### Paso 2: Backend - Controller
- [ ] Añadir query para biomarcadores en `/detalle`
- [ ] Implementar lógica de parsing
- [ ] Probar con Citalvir (66401)

### Paso 3: Frontend - TypeScript Types
- [ ] Añadir `BiomarcadorDto` en `types/medicamento.ts`
- [ ] Actualizar `MedicamentoDetalle`

### Paso 4: Frontend - Componente
- [ ] Crear `FarmacogenomicaTab.tsx`
- [ ] Crear `BiomarcadorCard.tsx`
- [ ] Añadir a `index.ts`

### Paso 5: Frontend - Tab Registration
- [ ] Añadir tab en `MedicamentoDetailModal.tsx`
- [ ] Badge 🧬 si tiene biomarcadores

### Paso 6: Testing
- [ ] Probar con Citalvir (CYP2C19)
- [ ] Probar con Tegretol (HLA-B)
- [ ] Probar con Herceptin (ERBB2)

---

## 🎨 UI/UX AVANZADO

### Badges por Tipo
```tsx
Germinal → 🧬 Verde "Variante Genética Germinal"
Somático → 🔬 Azul "Marcador Somático"
SNS      → ✅ Verde "Incluido SNS"
```

### Alertas por TipoRelacion
```tsx
ajuste_dosis → ⚠️ Amarillo "REQUIERE AJUSTE DE DOSIS"
contraindicado → 🚫 Rojo "CONTRAINDICADO"
monitorizar → 👁️ Azul "REQUIERE MONITORIZACIÓN"
```

### Niveles de Evidencia
```
4 → ⭐⭐⭐⭐ "Evidencia Alta"
3 → ⭐⭐⭐ "Evidencia Moderada"
2 → ⭐⭐ "Evidencia Baja"
1 → ⭐ "Evidencia Preliminar"
```

---

## 📈 VALOR AÑADIDO

### Para el Profesional Sanitario
1. **Prescripción Segura**: Alertas de ajuste de dosis
2. **SNS Compliance**: Sabe qué está cubierto
3. **Referencias Directas**: Enlaces a secciones FT
4. **Evidencia Clara**: Recomendaciones específicas

### Para el Sistema
1. **Único en España**: No existe nada similar
2. **Datos Oficiales**: 100% AEMPS
3. **14.93% Cobertura**: 3,026 medicamentos
4. **Actualizable**: XML de prescripción

---

## ⏱️ ESTIMACIÓN

- Backend (DTO + Controller): **1h**
- Frontend (Components): **1.5h**
- Testing & Polish: **0.5h**
- **TOTAL: 3 horas**

---

## ✅ CRITERIOS DE ÉXITO

1. ✅ Tab visible solo si hay biomarcadores
2. ✅ Badge 🧬 en resultados de búsqueda
3. ✅ Información clara y profesional
4. ✅ Enlaces funcionales a FT
5. ✅ Badges SNS correctos
6. ✅ Alertas de ajuste visibles
7. ✅ Responsive y accesible

---

**ESTADO**: Listo para implementar ✅
**NEXT**: ¿Empezamos con el backend?
