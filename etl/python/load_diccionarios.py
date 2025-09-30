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


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dsn", required=True)
    ap.add_argument("--xml", required=True, help="Ruta al XML")
    ap.add_argument("--kind", required=True, choices=[
        "laboratorios","vias","forma","forma_simpl","sitreg"
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
    else:
        print("[ERROR] kind no soportado", file=sys.stderr); sys.exit(3)

    conn.close()

if __name__=="__main__":
    main()

