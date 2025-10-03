# etl/python/load_diccionarios.py
import argparse, psycopg2, xml.etree.ElementTree as ET, pathlib, sys, hashlib, datetime as dt

def load_laboratorios(xml_path, conn):
    import xml.etree.ElementTree as ET
    ns = {'ns': 'http://schemas.aemps.es/prescripcion/aemps_prescripcion_laboratorios'}
    root = ET.parse(xml_path).getroot()

    rows = []
    for lab in root.findall('.//ns:laboratorios', ns):
        codigo = lab.findtext('ns:codigolaboratorio', default=None, namespaces=ns)
        nombre = lab.findtext('ns:laboratorio',       default='',   namespaces=ns)
        direccion = lab.findtext('ns:direccion',      default=None, namespaces=ns)
        cp        = lab.findtext('ns:codigopostal',   default=None, namespaces=ns)
        localidad = lab.findtext('ns:localidad',      default=None, namespaces=ns)
        cif       = lab.findtext('ns:cif',            default=None, namespaces=ns)
        if not codigo or not nombre:
            continue
        rows.append((int(codigo), nombre.strip(),
                     direccion, cp, localidad, cif))

    with conn, conn.cursor() as cur:
        cur.execute('TRUNCATE "LaboratoriosDicStaging";')
        cur.executemany(
            'INSERT INTO "LaboratoriosDicStaging"'
            '("Codigo","Nombre","Direccion","CodigoPostal","Localidad","Cif") '
            'VALUES (%s,%s,%s,%s,%s,%s) '
            'ON CONFLICT ("Codigo") DO UPDATE SET '
            '  "Nombre"=EXCLUDED."Nombre",'
            '  "Direccion"=EXCLUDED."Direccion",'
            '  "CodigoPostal"=EXCLUDED."CodigoPostal",'
            '  "Localidad"=EXCLUDED."Localidad",'
            '  "Cif"=EXCLUDED."Cif";',
            rows
        )
    return len(rows)


def load_vias(xml_path, conn):
    import xml.etree.ElementTree as ET
    ns = {'ns': 'http://schemas.aemps.es/prescripcion/aemps_prescripcion_vias_administracion'}
    root = ET.parse(xml_path).getroot()
    rows = []
    for e in root.findall('.//ns:viasadministracion', ns):
        id_ = e.findtext('ns:codigoviaadministracion', default=None, namespaces=ns)
        nombre = e.findtext('ns:viaadministracion',   default=None, namespaces=ns)
        if not id_ or not nombre:
            continue
        rows.append((int(id_), nombre.strip()))
    with conn, conn.cursor() as cur:
        cur.execute('TRUNCATE "ViaAdministracionDicStaging";')
        cur.executemany('INSERT INTO "ViaAdministracionDicStaging"("Id","Nombre") VALUES (%s,%s)', rows)
    return len(rows)


def text_or_none(elem, path, ns):
    return elem.findtext(path, default=None, namespaces=ns)

def load_forma(xml_path, conn, tabla, variante):
    import xml.etree.ElementTree as ET
    root = ET.parse(xml_path).getroot()

    if variante == "completa":
        ns = {"ns": "http://schemas.aemps.es/prescripcion/aemps_prescripcion_formas_farmaceuticas"}
        items = root.findall(".//ns:formasfarmaceuticas", ns)
        get_id  = lambda e: e.findtext("ns:codigoformafarmaceutica", default=None, namespaces=ns)
        get_nom = lambda e: e.findtext("ns:formafarmaceutica",       default="",   namespaces=ns)
        outlier_threshold = 90000
    else:  # simplificada
        ns = {"ns": "http://schemas.aemps.es/prescripcion/aemps_prescripcion_formas_farmaceuticas_simplificadas"}
        items = root.findall(".//ns:formasfarmaceuticassimplificadas", ns)
        get_id  = lambda e: e.findtext("ns:codigoformafarmaceuticasimplificada", default=None, namespaces=ns)
        get_nom = lambda e: e.findtext("ns:formafarmaceuticasimplificada",       default="",   namespaces=ns)
        outlier_threshold = 2000

    # Trazabilidad del fichero
    file_hash = hashlib.sha256(pathlib.Path(xml_path).read_bytes()).hexdigest()[:12]
    loaded_at = dt.datetime.now().isoformat(timespec="seconds")

    rows, outliers = [], []
    for e in items:
        id_txt = get_id(e); nombre = get_nom(e)
        if not id_txt or not nombre:
            continue
        try:
            id_int = int(id_txt)
        except ValueError:
            print(f"[WARN] Id no numérico: {id_txt!r}", file=sys.stderr)
            continue
        # Normalización simple de nombre
        nombre_norm = " ".join(nombre.strip().split())
        rows.append((id_int, nombre_norm))
        if id_int >= outlier_threshold:
            outliers.append((id_int, nombre_norm))

    with conn, conn.cursor() as cur:
        cur.execute(f'TRUNCATE "{tabla}";')
        cur.executemany(
            f'INSERT INTO "{tabla}"("Id","Nombre") VALUES (%s,%s) '
            f'ON CONFLICT ("Id") DO UPDATE SET "Nombre"=EXCLUDED."Nombre";',
            rows
        )

    print(f"[OK] {tabla}: {len(rows)} filas | hash={file_hash} | loaded_at={loaded_at}")
    if outliers:
        top = ", ".join(f"{i}" for i,_ in sorted(outliers, reverse=True)[:5])
        print(f"[WARN] {tabla}: {len(outliers)} Id(s) >= {outlier_threshold}. Ejemplos: {top}", file=sys.stderr)
    return len(rows)



def load_sitreg(xml_path, conn):
    import xml.etree.ElementTree as ET
    ns = {'ns': 'http://schemas.aemps.es/prescripcion/aemps_prescripcion_situacion_registro'}
    root = ET.parse(xml_path).getroot()

    rows = []
    # Los items son <situacionesregistro> (plural) dentro del namespace
    for e in root.findall('.//ns:situacionesregistro', ns):
        cod = e.findtext('ns:codigosituacionregistro', default=None, namespaces=ns)
        nom = e.findtext('ns:situacionregistro',       default=None, namespaces=ns)
        if cod and nom:
            rows.append((int(cod), nom.strip()))

    # Fallback sin namespace por si algún fichero viejo viene en MAYÚSCULAS
    if not rows:
        for e in root.findall('.//SITUACION'):
            cod = e.findtext('CODIGO')
            nom = e.findtext('NOMBRE')
            if cod and nom:
                rows.append((int(cod), nom.strip()))

    with conn, conn.cursor() as cur:
        cur.execute('TRUNCATE "SituacionRegistroDicStaging";')
        cur.executemany(
            'INSERT INTO "SituacionRegistroDicStaging"("Codigo","Nombre") VALUES (%s,%s) '
            'ON CONFLICT ("Codigo") DO UPDATE SET "Nombre"=EXCLUDED."Nombre";',
            rows
        )
    return len(rows)

def load_atc(xml_path, conn):
    from lxml import etree
    ns = {'ns': 'http://schemas.aemps.es/prescripcion/aemps_prescripcion_atc'}
    context = etree.iterparse(xml_path, tag='{http://schemas.aemps.es/prescripcion/aemps_prescripcion_atc}atc', events=("end",))
    rows = []
    for _, atc in context:
        codigo = atc.findtext('ns:codigoatc', default=None, namespaces=ns)
        nombre = atc.findtext('ns:descatc', default=None, namespaces=ns)
        if not codigo or not nombre:
            atc.clear()
            continue
        length = len(codigo)
        if length not in (1, 3, 4, 5, 7):
            print(f"[WARN] Longitud inválida {length} para {codigo}", file=sys.stderr)
            atc.clear()
            continue
        nivel = {1: 1, 3: 2, 4: 3, 5: 4, 7: 5}[length]
        if length == 3:
            codigo_padre = codigo[0]  # e.g., "R" para "R03"
        elif length == 4:
            codigo_padre = codigo[:3]
        elif length == 5:
            codigo_padre = codigo[:4]
        elif length == 7:
            codigo_padre = codigo[:5]
        else:
            codigo_padre = None
        rows.append((codigo, nombre.strip(), nivel, codigo_padre))
        atc.clear()
    with conn, conn.cursor() as cur:
        cur.execute('TRUNCATE "AtcXmlTemp";')
        cur.executemany(
            'INSERT INTO "AtcXmlTemp" ("Codigo","Nombre","Nivel","CodigoPadre") '
            'VALUES (%s,%s,%s,%s) '
            'ON CONFLICT ("Codigo") DO UPDATE SET '
            '"Nombre"=EXCLUDED."Nombre", "Nivel"=EXCLUDED."Nivel", "CodigoPadre"=EXCLUDED."CodigoPadre";',
            rows
        )
    return len(rows)

def load_principios_activos(xml_path, conn):
    from lxml import etree
    ns = {'ns': 'http://schemas.aemps.es/prescripcion/aemps_prescripcion_principios_activos'}
    context = etree.iterparse(xml_path, tag='{http://schemas.aemps.es/prescripcion/aemps_prescripcion_principios_activos}principiosactivos', events=("end",))
    rows = []
    atc_rows = []
    invalid = 0
    for _, pa in context:
        codigo = pa.findtext('ns:nroprincipioactivo', default=None, namespaces=ns)
        nombre = pa.findtext('ns:principioactivo', default=None, namespaces=ns)
        lista = pa.findtext('ns:listapsicotropo', default=None, namespaces=ns)
        atc = pa.findtext('ns:codigoprincipioactivo', default=None, namespaces=ns)
        if not codigo or not nombre:
            print(f"[WARN] Entrada inválida: codigo={codigo}, nombre={nombre}", file=sys.stderr)
            invalid += 1
            pa.clear()
            continue
        rows.append((codigo, nombre.strip(), lista))
        if atc:
            atc_rows.append((codigo, atc))
        pa.clear()
    print(f"[INFO] Filas válidas: {len(rows)}, inválidas: {invalid}, ATC relaciones: {len(atc_rows)}", file=sys.stderr)
    with conn, conn.cursor() as cur:
        cur.execute('TRUNCATE "PrincipiosActivosXmlTemp";')
        cur.executemany(
            'INSERT INTO "PrincipiosActivosXmlTemp" ("Codigo","Nombre","Lista") '
            'VALUES (%s,%s,%s) '
            'ON CONFLICT ("Codigo") DO UPDATE SET '
            '"Nombre"=EXCLUDED."Nombre", "Lista"=EXCLUDED."Lista";',
            rows
        )
        cur.execute('TRUNCATE "PrincipiosActivos";')
        cur.executemany(
            'INSERT INTO "PrincipiosActivos" ("Codigo","Nombre","Lista") '
            'VALUES (%s,%s,%s) '
            'ON CONFLICT ("Codigo") DO UPDATE SET '
            '"Nombre"=EXCLUDED."Nombre", "Lista"=EXCLUDED."Lista";',
            rows
        )
        cur.executemany(
            'INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props) '
            'VALUES (%s,%s,%s,%s,%s,%s) '
            'ON CONFLICT (src_type, src_key, rel, dst_type, dst_key) DO NOTHING;',
            [(src_type, src_key, rel, dst_type, dst_key, '{}') 
             for src_type, src_key, rel, dst_type, dst_key in 
             [('PrincipioActivo', codigo, 'PERTENECE_A_ATC', 'ATC', atc) for codigo, atc in atc_rows]]
        )
    return len(rows)

def load_excipientes(xml_path, conn):
    from lxml import etree
    d = etree.parse(str(xml_path))
    rows = []
    # Cada registro es <excipientes> o <excipiente>, con hijos namespaced.
    for e in d.getroot().iter():
        tag = e.tag.split('}')[-1].lower()
        if tag not in ('excipiente', 'excipientes'):
            continue
        # Coger texto usando local-name() para ignorar namespaces
        cod = (e.xpath('string(.//*[local-name()="codexcipiente"][1])') or
               e.xpath('string(.//*[local-name()="codigoedo"][1])')).strip()
        nom = (e.xpath('string(.//*[local-name()="nombre"][1])') or
               e.xpath('string(.//*[local-name()="edo"][1])')).strip()
        if cod and nom:
            rows.append((cod, nom))
    with conn, conn.cursor() as cur:
        cur.execute('TRUNCATE "ExcipientesDeclObligDicStaging";')
        cur.executemany(
            'INSERT INTO "ExcipientesDeclObligDicStaging" ("CodExcipiente","Nombre") '
            'VALUES (%s,%s) '
            'ON CONFLICT ("CodExcipiente") DO UPDATE SET "Nombre"=EXCLUDED."Nombre";',
            rows
        )
    print(f"[OK] Excipientes detectados: {len(rows)}")
    return len(rows)

# --- NUEVO ---
def load_unidad_contenido(xml_path, conn):
    from lxml import etree
    d = etree.parse(str(xml_path))
    rows = []
    # admite dos variantes de esquema; filtramos solo nodos con ambos campos
    for e in d.iter():
        tag = e.tag.split('}')[-1].lower()
        if tag not in ('unidadcontenido', 'unidadescontenido', 'item'):
            continue
        id_txt = (e.findtext('.//codigounidadcontenido') or '').strip()
        nom    = (e.findtext('.//unidadcontenido')       or '').strip()
        if id_txt.isdigit() and nom:
            rows.append((int(id_txt), nom))
    with conn, conn.cursor() as cur:
        cur.executemany(
            'INSERT INTO "UnidadContenidoDicStaging"("Id","Nombre") VALUES (%s,%s) '
            'ON CONFLICT ("Id") DO UPDATE SET "Nombre"=EXCLUDED."Nombre";',
            rows
        )
    return len(rows)



def load_envases(xml_path, conn):
    from lxml import etree
    d = etree.parse(str(xml_path))
    rows = []
    for e in d.iter():
        tag = e.tag.split('}')[-1].lower()
        if tag not in ('envase','envases','item'):
            continue
        id_txt = (e.findtext('.//codigoenvase') or '').strip()
        nom    = (e.findtext('.//envase')       or '').strip()
        if id_txt.isdigit() and nom:
            rows.append((int(id_txt), nom))
    with conn, conn.cursor() as cur:
        cur.executemany(
            'INSERT INTO "EnvaseDicStaging"("Id","Nombre") VALUES (%s,%s) '
            'ON CONFLICT ("Id") DO UPDATE SET "Nombre"=EXCLUDED."Nombre";',
            rows
        )
    return len(rows)

# --- NUEVO: DCP / DCPF / DCSA ----------------------------------------------
def _load_cod_nombre_generic(xml_path, conn, table_staging, code_xp, name_xp, rec_tags):
    from lxml import etree
    d = etree.parse(str(xml_path))
    rows = []
    for e in d.iter():
        tag = e.tag.split('}')[-1].lower()
        if tag in rec_tags:
            cod = (e.xpath(f'string(.//{code_xp})') or '').strip()
            nom = (e.xpath(f'string(.//{name_xp})') or '').strip()
            if cod and nom:
                rows.append((cod, nom))
    with conn, conn.cursor() as cur:
        cur.executemany(
            f'INSERT INTO "{table_staging}"("Codigo","Nombre") VALUES (%s,%s) '
            f'ON CONFLICT ("Codigo") DO UPDATE SET "Nombre"=EXCLUDED."Nombre";',
            rows
        )
    return len(rows)

def load_dcp(xml_path, conn):
    # Ajusta rec_tags y xpaths si tu XML usa otros nombres de elementos
    return _load_cod_nombre_generic(xml_path, conn, "DcpDicStaging",
        code_xp='*[local-name()="codigodcp"][1]',
        name_xp='*[local-name()="dcp"][1]',
        rec_tags={'dcp','dcps','item','denominacion','denominaciones'})

def load_dcpf(xml_path, conn):
    return _load_cod_nombre_generic(xml_path, conn, "DcpfDicStaging",
        code_xp='*[local-name()="codigodcpf"][1]',
        name_xp='*[local-name()="dcpf"][1]',
        rec_tags={'dcpf','dcpfs','item','denominacion','denominaciones'})

def load_dcsa(xml_path, conn):
    return _load_cod_nombre_generic(xml_path, conn, "DcsaDicStaging",
        code_xp='*[local-name()="codigodcsa"][1]',
        name_xp='*[local-name()="dcsa"][1]',
        rec_tags={'dcsa','dcsas','item','denominacion','denominaciones'})
# ---------------------------------------------------------------------------


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dsn", required=True)
    ap.add_argument("--xml", required=True, help="Ruta al XML")
    ap.add_argument("--kind", required=True, choices=[
      "laboratorios","vias","forma","forma_simpl","sitreg","atc",
      "principios_activos","excipientes","unidad_contenido","envases", "dcp", "dcsa", "dcpf"
    ])

    args = ap.parse_args()
    conn = psycopg2.connect(args.dsn); conn.autocommit = True

    xmlp = pathlib.Path(args.xml)
    if not xmlp.exists():
        print(f"[ERROR] No existe {xmlp}", file=sys.stderr); sys.exit(2)

    if args.kind=="laboratorios":
        n=load_laboratorios(xmlp, conn); print(f"[OK] Laboratorios cargados: {n}")
    elif args.kind=="vias":
        n=load_vias(xmlp, conn); print(f"[OK] Vías cargadas: {n}")
    elif args.kind=="forma":
        n=load_forma(xmlp, conn, "FormaFarmaceuticaDicStaging", "completa"); print(f"[OK] FormaFarmaceutica cargadas: {n}")

    elif args.kind=="forma_simpl":
        n=load_forma(xmlp, conn, "FormaFarmaceuticaSimplificadaDicStaging", "simplificada"); print(f"[OK] FormaFarmaceuticaSimplificada cargadas: {n}")
    elif args.kind=="sitreg":
        n=load_sitreg(xmlp, conn); print(f"[OK] SituacionRegistro cargadas: {n}")
    elif args.kind == "atc":
        n = load_atc(xmlp, conn); print(f"[OK] ATC cargados: {n}")
    elif args.kind == "principios_activos":
        n = load_principios_activos(xmlp, conn); print(f"[OK] Principios Activos cargados: {n}")
    elif args.kind == 'excipientes':
        n = load_excipientes(args.xml, conn); print(f"[OK] Excipientes cargados: {n}")
    elif args.kind=="unidad_contenido":
        n=load_unidad_contenido(xmlp, conn); print(f"[OK] UnidadContenido cargados: {n}")
    elif args.kind=="envases":
        n=load_envases(xmlp, conn); print(f"[OK] Envases cargados: {n}")
    elif args.kind=="dcp":
        n=load_dcp(xmlp, conn); print(f"[OK] DCP cargados: {n}")
    elif args.kind=="dcpf":
        n=load_dcpf(xmlp, conn); print(f"[OK] DCPF cargados: {n}")
    elif args.kind=="dcsa":
        n=load_dcsa(xmlp, conn); print(f"[OK] DCSA cargados: {n}")


    else:
        print("[ERROR] kind no soportado", file=sys.stderr); sys.exit(3)

    conn.close()

if __name__=="__main__":
    main()

