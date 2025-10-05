# 🔍 ANÁLISIS: API CIMA vs NUESTRA BASE DE DATOS

## 📊 COMPARATIVA COMPLETA

### ✅ LO QUE TENEMOS EN BD (Y coincide con CIMA):

#### Tabla `Medicamentos`:
```sql
✅ NRegistro          → nregistro (CIMA)
✅ Nombre             → nombre (CIMA)
✅ LabTitular         → labtitular (CIMA)
✅ Comercializado     → comerc (CIMA)
✅ CondPrescripcion   → cpresc (CIMA)
✅ Receta             → receta (CIMA)
✅ ATC                → atcs[] (CIMA)
✅ FechaAutorizacion  → estado.aut (CIMA)
✅ RawJson            → Contiene toda la info de CIMA
```

#### Tabla `Documento`:
```sql
✅ Tipo     → docs[].tipo (CIMA: 1=FT, 2=P, 3=IPE, 4=PGR)
✅ UrlPdf   → docs[].url (CIMA)
✅ Fecha    → docs[].fecha (CIMA)
```

---

### ❌ LO QUE NOS FALTA (pero CIMA tiene):

#### 1. **INFORMACIÓN DE ESTADO** ⭐⭐⭐
```
CIMA tiene:
- estado.aut (fecha autorización)
- estado.susp (fecha suspensión)  
- estado.rev (fecha revocación)

Nosotros:
- Solo FechaAutorizacion
- No tenemos suspensión/revocación
```

#### 2. **BANDERAS IMPORTANTES** ⭐⭐⭐
```
CIMA tiene:
- triangulo (triángulo negro - seguimiento adicional)
- huerfano (medicamento huérfano)
- biosimilar (medicamento biosimilar)
- conduc (afecta a la conducción)
- ema (registrado por procedimiento centralizado)
- nosustituible (tipo de no sustituible)

Nosotros:
- NO tenemos ninguna de estas banderas
```

#### 3. **EXCIPIENTES** ⭐⭐
```
CIMA tiene:
- excipientes[] (lista completa)
  - id
  - nombre
  - cantidad
  - unidad
  - orden

Nosotros:
- NO tenemos tabla de excipientes
```

#### 4. **FOTOS/IMÁGENES** ⭐⭐
```
CIMA tiene:
- fotos[] (imágenes del medicamento)
  - tipo (materialas / formafarmac)
  - url
  - fecha

Nosotros:
- NO tenemos URLs de fotos
```

#### 5. **NOTAS DE SEGURIDAD** ⭐⭐⭐
```
CIMA tiene:
- notas (booleano si existen)
- GET notas/:nregistro (obtenerlas)
  - tipo
  - num
  - ref
  - asunto
  - fecha
  - url

Nosotros:
- NO tenemos notas de seguridad
```

#### 6. **MATERIALES INFORMATIVOS** ⭐⭐
```
CIMA tiene:
- materialesInf (booleano)
- GET materiales/:nregistro
  - titulo
  - listaDocsPaciente[]
  - listaDocsProfesional[]
  - video

Nosotros:
- NO tenemos materiales informativos
```

#### 7. **PROBLEMAS DE SUMINISTRO** ⭐⭐⭐
```
CIMA tiene:
- psum (booleano si tiene problemas)
- GET psuministro/:codNacional
  - cn
  - nombre
  - fini (fecha inicio)
  - ffin (fecha fin)
  - observ
  - activo

Nosotros:
- NO tenemos problemas de suministro
```

#### 8. **DOCUMENTOS SEGMENTADOS (HTML)** ⭐⭐⭐
```
CIMA tiene:
- Fichas técnicas por secciones en HTML
- Prospectos por secciones en HTML
- GET docSegmentado/secciones/:tipoDoc
- GET docSegmentado/contenido/:tipoDoc

Nosotros:
- Solo tenemos PDFs completos
- NO tenemos HTML segmentado
```

#### 9. **VMP/VMPP (Descripción Clínica)** ⭐⭐
```
CIMA tiene:
- vmp (código VMP)
- vmpDesc (nombre VMP)
- vmpp (código VMPP)
- vmppDesc (nombre VMPP)
- presComerc (nº presentaciones)

Nosotros:
- NO tenemos códigos VMP/VMPP
```

#### 10. **FORMA FARMACÉUTICA SIMPLIFICADA** ⭐
```
CIMA tiene:
- formaFarmaceutica
- formaFarmaceuticaSimplificada (SNOMED)

Nosotros:
- Solo tenemos FormaFarmaceutica
- NO tenemos versión simplificada SNOMED
```

#### 11. **DOSIS FORMATEADA** ⭐
```
CIMA tiene:
- dosis (texto formateado con "/" si múltiples PAs)

Nosotros:
- Tenemos Cantidad/Unidad por PA
- NO tenemos dosis formateada en texto
```

---

## 🎯 ANÁLISIS PARA PÁGINA DETALLE

### ⭐⭐⭐ CRÍTICO - Deberías añadir:

#### 1. **Banderas de Seguridad**
```tsx
// En página de detalle mostrar:
{triangulo && <Badge variant="warning">⚠️ Seguimiento adicional</Badge>}
{huerfano && <Badge variant="info">🧬 Medicamento huérfano</Badge>}
{biosimilar && <Badge variant="info">💉 Biosimilar</Badge>}
{conduc && <Badge variant="danger">🚗 Afecta a la conducción</Badge>}
{nosustituible && <Badge variant="warning">⚠️ No sustituible</Badge>}
```

#### 2. **Problemas de Suministro**
```tsx
// Alert destacado si tiene problemas
{psum && (
  <Alert variant="warning">
    <AlertTitle>⚠️ Problema de Suministro</AlertTitle>
    <p>Fecha inicio: {fini}</p>
    <p>Fecha prevista fin: {ffin}</p>
    <p>{observ}</p>
  </Alert>
)}
```

#### 3. **Notas de Seguridad**
```tsx
// Sección de notas
{notas && (
  <Section title="📋 Notas de Seguridad">
    <NotasList nregistro={med.nregistro} />
  </Section>
)}
```

#### 4. **Estado Completo**
```tsx
// Mostrar estado detallado
<StateCard>
  <div>Autorizado: {estado.aut}</div>
  {estado.susp && <div>⚠️ Suspendido: {estado.susp}</div>}
  {estado.rev && <div>❌ Revocado: {estado.rev}</div>}
</StateCard>
```

#### 5. **Documentos HTML Segmentados**
```tsx
// Visor de FT/Prospecto por secciones
<DocumentViewer 
  nregistro={med.nregistro}
  tipo="ft"  // o "p"
  format="html"  // en lugar de PDF
/>

// Permite navegar por secciones
<Sections>
  <Section id="4.1">Indicaciones terapéuticas</Section>
  <Section id="4.2">Posología y forma de administración</Section>
  ...
</Sections>
```

---

### ⭐⭐ IMPORTANTE - Añadiría valor:

#### 6. **Fotos del Medicamento**
```tsx
<Gallery>
  {fotos.map(foto => (
    <Image 
      src={foto.url} 
      alt={foto.tipo}
      caption={foto.tipo === 'materialas' ? 'Envase' : 'Forma farmacéutica'}
    />
  ))}
</Gallery>
```

#### 7. **Materiales Informativos**
```tsx
{materialesInf && (
  <Section title="📚 Materiales Educativos">
    <Tabs>
      <Tab title="Para Pacientes">
        <DocumentList docs={listaDocsPaciente} />
      </Tab>
      <Tab title="Para Profesionales">
        <DocumentList docs={listaDocsProfesional} />
      </Tab>
      {video && <Tab title="Vídeo"><VideoPlayer src={video} /></Tab>}
    </Tabs>
  </Section>
)}
```

#### 8. **Excipientes**
```tsx
<Section title="Excipientes">
  <Table>
    <thead><tr><th>Excipiente</th><th>Cantidad</th></tr></thead>
    <tbody>
      {excipientes.map(exc => (
        <tr>
          <td>{exc.nombre}</td>
          <td>{exc.cantidad} {exc.unidad}</td>
        </tr>
      ))}
    </tbody>
  </Table>
</Section>
```

#### 9. **VMP/VMPP**
```tsx
<Section title="Descripción Clínica (SNOMED)">
  <div>VMP: {vmp} - {vmpDesc}</div>
  <div>VMPP: {vmpp} - {vmppDesc}</div>
</Section>
```

---

### ⭐ OPCIONAL - Nice to have:

#### 10. **Búsqueda en Ficha Técnica**
```tsx
// Endpoint: POST buscarEnFichaTecnica
<SearchInDocument 
  placeholder="Buscar en ficha técnica..."
  sections={['4.1', '4.2', '4.3']}
/>
```

#### 11. **Registro de Cambios**
```tsx
// Mostrar historial de modificaciones
<Timeline>
  {cambios.map(cambio => (
    <TimelineItem date={cambio.fecha}>
      {cambio.tipoCambio === 1 && "🆕 Nuevo"}
      {cambio.tipoCambio === 2 && "❌ Baja"}
      {cambio.tipoCambio === 3 && "✏️ Modificado"}
      <Tags>{cambio.cambios.join(', ')}</Tags>
    </TimelineItem>
  ))}
</Timeline>
```

---

## 🔧 PLAN DE IMPLEMENTACIÓN

### Fase 1: CRÍTICO (1-2 días)
```
1. Añadir columnas a Medicamentos:
   - Triangulo (bool)
   - Huerfano (bool)
   - Biosimilar (bool)
   - Conduc (bool)
   - Ema (bool)
   - NoSustituible (string)

2. Crear tabla ProblemasSuministro:
   - Id, CN, FechaInicio, FechaFin, Observaciones, Activo

3. Crear tabla NotasSeguridad:
   - Id, NRegistro, Tipo, Numero, Referencia, Asunto, Fecha, Url

4. Actualizar frontend página detalle:
   - Mostrar banderas
   - Alert de problemas suministro
   - Sección de notas
```

### Fase 2: IMPORTANTE (3-5 días)
```
5. Crear tabla Excipientes:
   - Id, NRegistro, Nombre, Cantidad, Unidad, Orden

6. Añadir columna Fotos (JSON) a Medicamentos

7. Crear tabla MaterialesInformativos:
   - Id, NRegistro, Titulo, UrlsPaciente (JSON), UrlsProfesional (JSON), UrlVideo

8. Integrar visor HTML segmentado de FT/Prospecto

9. Actualizar servicio sync para traer estos datos
```

### Fase 3: OPCIONAL (1 semana)
```
10. Implementar búsqueda en ficha técnica
11. Historial de cambios por medicamento
12. Códigos VMP/VMPP
13. Forma farmacéutica simplificada SNOMED
```

---

## 📊 PRIORIDADES SEGÚN VALOR

### 🔥 MÁXIMA PRIORIDAD:
1. ⚠️ **Triángulo negro** (seguimiento adicional de seguridad)
2. ⚠️ **Problemas de suministro** (info crítica para pacientes)
3. 📋 **Notas de seguridad** (alertas importantes)
4. 🚗 **Afecta conducción** (info de seguridad vital)

### 🔶 ALTA PRIORIDAD:
5. 📚 **Materiales informativos** (educación pacientes)
6. 🧬 **Huérfano/Biosimilar** (clasificación útil)
7. 📄 **HTML segmentado** (mejor UX que PDF)
8. 🖼️ **Fotos** (ayuda a identificar medicamento)

### 🔵 MEDIA PRIORIDAD:
9. 💊 **Excipientes** (alergias/intolerancias)
10. 🏷️ **VMP/VMPP** (normalización SNOMED)
11. 📅 **Historial cambios** (trazabilidad)

---

## 💡 RECOMENDACIÓN FINAL

**EMPEZAR CON:**
1. Añadir banderas básicas (triangulo, huerfano, biosimilar, conduc)
2. Problemas de suministro
3. Notas de seguridad
4. Actualizar sync service para traer estos datos

**RAZÓN:** Máximo valor con mínimo esfuerzo. Son datos de seguridad críticos que CIMA ya tiene y solo necesitamos:
- Añadir columnas en BD
- Actualizar sync
- Mostrar en frontend

**TIEMPO ESTIMADO:** 2-3 días de trabajo

¿Te parece bien este análisis? ¿Quieres que empecemos por alguna fase específica?
