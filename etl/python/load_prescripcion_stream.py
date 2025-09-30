# etl/python/load_prescripcion_stream.py


import argparse, time, sys
from lxml import etree
import psycopg2, psycopg2.extras

def b(v):
    if v is None: return None
    v = v.strip()
    return v if v else None

def to_bool(t):
    t = b(t)
    if t == "1": return True
    if t == "0": return False
    return None

def to_num(s):
    s = b(s)
    if not s: return None
    s2 = s.replace(',', '.')
    try:
        float(s2)
    except ValueError:
        return None
    return s2  # dejar como texto para castear en SQL

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--xml", required=True)
    ap.add_argument("--dsn", required=True)
    ap.add_argument("--table", default="PrescripcionStaging_NUEVA")
    ap.add_argument("--batch", type=int, default=1000)
    args = ap.parse_args()

    ns_any = "{*}"
    start = time.time()
    count = 0
    header_date = None

    conn = psycopg2.connect(args.dsn)
    conn.autocommit = False
    cur = conn.cursor()

    # Fijar TZ a UTC (coherente con el plan)
    cur.execute("SET TIME ZONE 'UTC';")

    # Extraer header_date (si está)
    try:
        for ev, el in etree.iterparse(args.xml, tag=ns_any + "header", events=("end",)):
            v = el.findtext(".//" + ns_any + "listprescriptiondate")
            header_date = b(v)
            el.clear()
            break
    except Exception as e:
        print(f"[WARN] No se pudo leer header_date: {e}", file=sys.stderr)

    cols = (
        '"CodNacion","NRegistro","CodDcp","CodDcpf","CodDcsa",'
        '"DesNomco","DesPrese","DesDosific",'
        '"CodEnvase","Contenido","UnidadContenidoCodigo","NroConte",'
        '"UrlFictec","UrlProsp",'
        '"SwPsicotropo","SwEstupefaciente","SwAfectaConduccion","SwTrianguloNegro",'
        '"SwReceta","SwGenerico","SwSustituible","SwEnvaseClinico","SwUsoHospitalario",'
        '"SwDiagnosticoHospitalario","SwTld","SwEspecialControlMedico","SwHuerfano","SwBaseAPlantas",'
        '"Biosimilar","ImportacionParalela","Radiofarmaco","Serializacion",'
        '"LabTitularCodigo","LabComercializadorCodigo",'
        '"FechaAutorizacion","SwComercializado","FechaComercializacion",'
        '"CodSitReg","CodSitRegPresen","FechaSitReg","FechaSitRegPresen",'
        '"SwTieneExcipDeclOblig","HeaderDate"'
    )

    upsert_sql = f"""
    INSERT INTO "{args.table}"(
      {cols}
    ) VALUES %s
    ON CONFLICT ("CodNacion") DO UPDATE SET
      "NRegistro"=EXCLUDED."NRegistro","CodDcp"=EXCLUDED."CodDcp","CodDcpf"=EXCLUDED."CodDcpf",
      "CodDcsa"=EXCLUDED."CodDcsa","DesNomco"=EXCLUDED."DesNomco","DesPrese"=EXCLUDED."DesPrese",
      "DesDosific"=EXCLUDED."DesDosific","CodEnvase"=EXCLUDED."CodEnvase","Contenido"=EXCLUDED."Contenido",
      "UnidadContenidoCodigo"=EXCLUDED."UnidadContenidoCodigo","NroConte"=EXCLUDED."NroConte",
      "UrlFictec"=EXCLUDED."UrlFictec","UrlProsp"=EXCLUDED."UrlProsp",
      "SwPsicotropo"=EXCLUDED."SwPsicotropo","SwEstupefaciente"=EXCLUDED."SwEstupefaciente",
      "SwAfectaConduccion"=EXCLUDED."SwAfectaConduccion","SwTrianguloNegro"=EXCLUDED."SwTrianguloNegro",
      "SwReceta"=EXCLUDED."SwReceta","SwGenerico"=EXCLUDED."SwGenerico","SwSustituible"=EXCLUDED."SwSustituible",
      "SwEnvaseClinico"=EXCLUDED."SwEnvaseClinico","SwUsoHospitalario"=EXCLUDED."SwUsoHospitalario",
      "SwDiagnosticoHospitalario"=EXCLUDED."SwDiagnosticoHospitalario","SwTld"=EXCLUDED."SwTld",
      "SwEspecialControlMedico"=EXCLUDED."SwEspecialControlMedico","SwHuerfano"=EXCLUDED."SwHuerfano",
      "SwBaseAPlantas"=EXCLUDED."SwBaseAPlantas","Biosimilar"=EXCLUDED."Biosimilar",
      "ImportacionParalela"=EXCLUDED."ImportacionParalela","Radiofarmaco"=EXCLUDED."Radiofarmaco",
      "Serializacion"=EXCLUDED."Serializacion","LabTitularCodigo"=EXCLUDED."LabTitularCodigo",
      "LabComercializadorCodigo"=EXCLUDED."LabComercializadorCodigo","FechaAutorizacion"=EXCLUDED."FechaAutorizacion",
      "SwComercializado"=EXCLUDED."SwComercializado","FechaComercializacion"=EXCLUDED."FechaComercializacion",
      "CodSitReg"=EXCLUDED."CodSitReg","CodSitRegPresen"=EXCLUDED."CodSitRegPresen",
      "FechaSitReg"=EXCLUDED."FechaSitReg","FechaSitRegPresen"=EXCLUDED."FechaSitRegPresen",
      "SwTieneExcipDeclOblig"=EXCLUDED."SwTieneExcipDeclOblig","HeaderDate"=EXCLUDED."HeaderDate";
    """

    buf = []
    page = 0

    def flush():
        nonlocal buf, page
        if not buf: return
        psycopg2.extras.execute_values(cur, upsert_sql, buf, page_size=len(buf))
        conn.commit()
        page += 1
        print(f"[INFO] Batch commit #{page} - filas: {len(buf)} - total: {count}")
        buf.clear()

    try:
        for ev, el in etree.iterparse(args.xml, tag=ns_any+"prescription", events=("end",)):
            g = el.findtext
            rec = (
                b(g(".//"+ns_any+"cod_nacion")),
                b(g(".//"+ns_any+"nro_definitivo")),
                b(g(".//"+ns_any+"cod_dcp")),
                b(g(".//"+ns_any+"cod_dcpf")),
                b(g(".//"+ns_any+"cod_dcsa")),
                b(g(".//"+ns_any+"des_nomco")),
                b(g(".//"+ns_any+"des_prese")),
                b(g(".//"+ns_any+"des_dosific")),
                (int(b(g(".//"+ns_any+"cod_envase")) or 0) if b(g(".//"+ns_any+"cod_envase")) else None),
                to_num(g(".//"+ns_any+"contenido")),
                b(g(".//"+ns_any+"unid_contenido")),
                b(g(".//"+ns_any+"nro_conte")),
                b(g(".//"+ns_any+"url_fictec")),
                b(g(".//"+ns_any+"url_prosp")),
                to_bool(g(".//"+ns_any+"sw_psicotropo")),
                to_bool(g(".//"+ns_any+"sw_estupefaciente")),
                to_bool(g(".//"+ns_any+"sw_afecta_conduccion")),
                to_bool(g(".//"+ns_any+"sw_triangulo_negro")),
                to_bool(g(".//"+ns_any+"sw_receta")),
                to_bool(g(".//"+ns_any+"sw_generico")),
                to_bool(g(".//"+ns_any+"sw_sustituible")),
                to_bool(g(".//"+ns_any+"sw_envase_clinico")),
                to_bool(g(".//"+ns_any+"sw_uso_hospitalario")),
                to_bool(g(".//"+ns_any+"sw_diagnostico_hospitalario")),
                to_bool(g(".//"+ns_any+"sw_tld")),
                to_bool(g(".//"+ns_any+"sw_especial_control_medico")),
                to_bool(g(".//"+ns_any+"sw_huerfano")),
                to_bool(g(".//"+ns_any+"sw_base_a_plantas")),
                to_bool(g(".//"+ns_any+"biosimilar")),
                to_bool(g(".//"+ns_any+"importacion_paralela")),
                to_bool(g(".//"+ns_any+"radiofarmaco")),
                to_bool(g(".//"+ns_any+"serializacion")),
                (int(b(g(".//"+ns_any+"laboratorio_titular")) or 0) if b(g(".//"+ns_any+"laboratorio_titular")) else None),
                (int(b(g(".//"+ns_any+"laboratorio_comercializador")) or 0) if b(g(".//"+ns_any+"laboratorio_comercializador")) else None),
                b(g(".//"+ns_any+"fecha_autorizacion")),
                to_bool(g(".//"+ns_any+"sw_comercializado")),
                b(g(".//"+ns_any+"fec_comer")),
                (int(b(g(".//"+ns_any+"cod_sitreg")) or 0) if b(g(".//"+ns_any+"cod_sitreg")) else None),
                (int(b(g(".//"+ns_any+"cod_sitreg_presen")) or 0) if b(g(".//"+ns_any+"cod_sitreg_presen")) else None),
                b(g(".//"+ns_any+"fecha_situacion_registro")),
                b(g(".//"+ns_any+"fec_sitreg_presen")),
                to_bool(g(".//"+ns_any+"sw_tiene_excipientes_decl_obligatoria")),
                header_date
            )
            if rec[0] and rec[1]:
                # casteos seguros para tipos fecha/numeric se harán en SQL (Valores %s → tipos destino)
                buf.append(rec)
                count += 1

            el.clear()

            if len(buf) >= args.batch:
                flush()

        flush()
        cur.close()
        conn.close()
        print(f"[OK] Filas procesadas: {count} en {time.time()-start:.1f}s")

    except Exception as e:
        conn.rollback()
        cur.close()
        conn.close()
        print(f"[ERROR] {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
