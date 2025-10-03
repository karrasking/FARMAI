#!/usr/bin/env python3
"""
ETL COMPLETO - Notas Seguridad, Interacciones, Alertas Geriatría, Duplicidades
Extrae del XML de prescripciones y carga al grafo
"""
import xml.etree.ElementTree as ET
import psycopg2
from psycopg2.extras import execute_batch
import sys
from datetime import datetime

# Configuración BD
DB_CONFIG = {
    'host': 'localhost',
    'port': 5433,
    'database': 'farmai_db',
    'user': 'postgres',
    'password': 'postgres'
}

def parse_prescription_xml(xml_path):
    """Parse completo del XML de prescripciones"""
    print(f"📄 Parseando: {xml_path}")
    
    tree = ET.parse(xml_path)
    root = tree.getroot()
    ns = {'ns': 'http://schemas.aemps.es/prescripcion/aemps_prescripcion'}
    
    data = {
        'notas_seguridad': [],
        'interacciones': [],
        'alertas_geriatria': [],
        'duplicidades': []
    }
    
    count = 0
    for prescription in root.findall('.//ns:prescription', ns):
        count += 1
        if count % 1000 == 0:
            print(f"  Procesados {count} medicamentos...")
        
        nregistro = prescription.find('ns:nro_definitivo', ns)
        if nregistro is None:
            continue
        nregistro = nregistro.text
        
        # 1. NOTAS DE SEGURIDAD
        for nota in prescription.findall('.//ns:notaseguridad', ns):
            numero = nota.find('ns:numero_nota_seguridad', ns)
            referencia = nota.find('ns:referencia_nota_seguridad', ns)
            asunto = nota.find('ns:asunto_nota_seguridad', ns)
            fecha = nota.find('ns:fecha_nota_seguridad', ns)
            url = nota.find('ns:url_nota_seguridad', ns)
            
            data['notas_seguridad'].append({
                'nregistro': nregistro,
                'numero': numero.text if numero is not None else None,
                'referencia': referencia.text if referencia is not None else None,
                'asunto': asunto.text if asunto is not None else None,
                'fecha': fecha.text if fecha is not None else None,
                'url': url.text if url is not None else None
            })
        
        # 2. INTERACCIONES
        for interaccion in prescription.findall('.//ns:interacciones_atc', ns):
            atc_int = interaccion.find('ns:atc_interaccion', ns)
            desc = interaccion.find('ns:descripcion_atc_interaccion', ns)
            efecto = interaccion.find('ns:efecto_interaccion', ns)
            recomend = interaccion.find('ns:recomendacion_interaccion', ns)
            
            data['interacciones'].append({
                'nregistro': nregistro,
                'atc_interaccion': atc_int.text if atc_int is not None else None,
                'descripcion': desc.text if desc is not None else None,
                'efecto': efecto.text if efecto is not None else None,
                'recomendacion': recomend.text if recomend is not None else None
            })
        
        # 3. ALERTAS GERIATRÍA
        for alerta in prescription.findall('.//ns:desaconsejados_geriatria', ns):
            alerta_g = alerta.find('ns:alerta_geriatria', ns)
            riesgo = alerta.find('ns:riesgo_pacience_geriatria', ns)
            recomend = alerta.find('ns:recomendacion_geriatria', ns)
            
            data['alertas_geriatria'].append({
                'nregistro': nregistro,
                'alerta': alerta_g.text if alerta_g is not None else None,
                'riesgo': riesgo.text if riesgo is not None else None,
                'recomendacion': recomend.text if recomend is not None else None
            })
        
        # 4. DUPLICIDADES
        for dup in prescription.findall('.//ns:duplicidades', ns):
            atc_dup = dup.find('ns:atc_duplicidad', ns)
            desc = dup.find('ns:descripcion_atc_duplicidad', ns)
            efecto = dup.find('ns:efecto_duplicidad', ns)
            recomend = dup.find('ns:recomendacion_duplicidad', ns)
            
            data['duplicidades'].append({
                'nregistro': nregistro,
                'atc_duplicidad': atc_dup.text if atc_dup is not None else None,
                'descripcion': desc.text if desc is not None else None,
                'efecto': efecto.text if efecto is not None else None,
                'recomendacion': recomend.text if recomend is not None else None
            })
    
    print(f"✅ Procesados {count} medicamentos")
    print(f"   Notas Seguridad: {len(data['notas_seguridad'])}")
    print(f"   Interacciones: {len(data['interacciones'])}")
    print(f"   Alertas Geriatría: {len(data['alertas_geriatria'])}")
    print(f"   Duplicidades: {len(data['duplicidades'])}")
    
    return data

def load_to_graph(data):
    """Carga todos los datos al grafo"""
    print("\n🔄 Conectando a BD...")
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    
    try:
        # Obtener todos los NRegistros válidos del grafo
        print("   Obteniendo NRegistros válidos...")
        cur.execute("""
            SELECT DISTINCT node_key 
            FROM graph_node 
            WHERE node_type = 'Medicamento'
        """)
        nregistros_validos = set(row[0] for row in cur.fetchall())
        print(f"   ✅ {len(nregistros_validos)} medicamentos válidos en el grafo")
        
        # Filtrar datos para solo incluir NRegistros válidos
        print("   Filtrando datos...")
        data['notas_seguridad'] = [n for n in data['notas_seguridad'] if n['nregistro'] in nregistros_validos]
        data['interacciones'] = [i for i in data['interacciones'] if i['nregistro'] in nregistros_validos]
        data['alertas_geriatria'] = [a for a in data['alertas_geriatria'] if a['nregistro'] in nregistros_validos]
        data['duplicidades'] = [d for d in data['duplicidades'] if d['nregistro'] in nregistros_validos]
        
        print(f"   ✅ Datos filtrados:")
        print(f"      Notas Seguridad: {len(data['notas_seguridad'])}")
        print(f"      Interacciones: {len(data['interacciones'])}")
        print(f"      Alertas Geriatría: {len(data['alertas_geriatria'])}")
        print(f"      Duplicidades: {len(data['duplicidades'])}")
        
        # 1. NOTAS DE SEGURIDAD
        print("\n📢 Cargando Notas de Seguridad...")
        
        # Crear nodos NotaSeguridad únicos
        notas_unicas = {}
        for nota in data['notas_seguridad']:
            if nota['numero']:
                notas_unicas[nota['numero']] = nota
        
        print(f"   Creando {len(notas_unicas)} nodos NotaSeguridad...")
        for numero, nota in notas_unicas.items():
            cur.execute("""
                INSERT INTO graph_node (node_type, node_key, props)
                VALUES ('NotaSeguridad', %s, %s)
                ON CONFLICT DO NOTHING
            """, (
                numero,
                psycopg2.extras.Json({
                    'numero': nota['numero'],
                    'referencia': nota['referencia'],
                    'asunto': nota['asunto'],
                    'fecha': nota['fecha'],
                    'url': nota['url']
                })
            ))
        
        # Crear aristas Med -> NotaSeguridad
        print(f"   Creando aristas Med -> NotaSeguridad...")
        aristas_notas = []
        for nota in data['notas_seguridad']:
            if nota['numero']:
                aristas_notas.append((
                    'Medicamento', nota['nregistro'],
                    'TIENE_NOTA_SEGURIDAD',
                    'NotaSeguridad', nota['numero'],
                    psycopg2.extras.Json({'fecha': nota['fecha']})
                ))
        
        execute_batch(cur, """
            INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
            VALUES (%s, %s, %s, %s, %s, %s)
            ON CONFLICT DO NOTHING
        """, aristas_notas, page_size=1000)
        
        print(f"   ✅ {len(aristas_notas)} aristas NotaSeguridad creadas")
        
        # 2. INTERACCIONES
        print("\n⚠️  Cargando Interacciones Farmacológicas...")
        
        # Crear nodos Interaccion únicos (por ATC)
        atcs_unicos = set(i['atc_interaccion'] for i in data['interacciones'] if i['atc_interaccion'])
        
        print(f"   Creando {len(atcs_unicos)} nodos ATCInteraccion...")
        for atc in atcs_unicos:
            cur.execute("""
                INSERT INTO graph_node (node_type, node_key, props)
                VALUES ('ATCInteraccion', %s, %s)
                ON CONFLICT DO NOTHING
            """, (atc, psycopg2.extras.Json({'codigo_atc': atc})))
        
        # Crear aristas Med -> ATCInteraccion
        print(f"   Creando aristas Med -> ATCInteraccion...")
        aristas_int = []
        for interaccion in data['interacciones']:
            if interaccion['atc_interaccion']:
                aristas_int.append((
                    'Medicamento', interaccion['nregistro'],
                    'INTERACCIONA_CON',
                    'ATCInteraccion', interaccion['atc_interaccion'],
                    psycopg2.extras.Json({
                        'descripcion': interaccion['descripcion'],
                        'efecto': interaccion['efecto'],
                        'recomendacion': interaccion['recomendacion']
                    })
                ))
        
        execute_batch(cur, """
            INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
            VALUES (%s, %s, %s, %s, %s, %s)
            ON CONFLICT DO NOTHING
        """, aristas_int, page_size=1000)
        
        print(f"   ✅ {len(aristas_int)} aristas Interaccion creadas")
        
        # 3. ALERTAS GERIATRÍA
        print("\n👴 Cargando Alertas Geriatría...")
        
        # Crear nodos AlertaGeriatria únicos
        alertas_unicas = {}
        for alerta in data['alertas_geriatria']:
            if alerta['alerta']:
                # Usar hash del texto de alerta como key
                key = str(hash(alerta['alerta']))[:16]
                if key not in alertas_unicas:
                    alertas_unicas[key] = alerta
        
        print(f"   Creando {len(alertas_unicas)} nodos AlertaGeriatria...")
        for key, alerta in alertas_unicas.items():
            cur.execute("""
                INSERT INTO graph_node (node_type, node_key, props)
                VALUES ('AlertaGeriatria', %s, %s)
                ON CONFLICT DO NOTHING
            """, (
                key,
                psycopg2.extras.Json({
                    'alerta': alerta['alerta'],
                    'riesgo': alerta['riesgo'],
                    'recomendacion': alerta['recomendacion']
                })
            ))
        
        # Crear aristas Med -> AlertaGeriatria
        print(f"   Creando aristas Med -> AlertaGeriatria...")
        aristas_ger = []
        for alerta in data['alertas_geriatria']:
            if alerta['alerta']:
                key = str(hash(alerta['alerta']))[:16]
                aristas_ger.append((
                    'Medicamento', alerta['nregistro'],
                    'TIENE_ALERTA_GERIATRIA',
                    'AlertaGeriatria', key,
                    psycopg2.extras.Json({})
                ))
        
        execute_batch(cur, """
            INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
            VALUES (%s, %s, %s, %s, %s, %s)
            ON CONFLICT DO NOTHING
        """, aristas_ger, page_size=1000)
        
        print(f"   ✅ {len(aristas_ger)} aristas AlertaGeriatria creadas")
        
        # 4. DUPLICIDADES
        print("\n🔄 Cargando Duplicidades...")
        
        # Crear nodos ATC para duplicidades (si no existen)
        atcs_dup_unicos = set(d['atc_duplicidad'] for d in data['duplicidades'] if d['atc_duplicidad'])
        atcs_nuevos = atcs_dup_unicos - atcs_unicos
        
        if atcs_nuevos:
            print(f"   Creando {len(atcs_nuevos)} nodos ATC adicionales para duplicidades...")
            for atc in atcs_nuevos:
                cur.execute("""
                    INSERT INTO graph_node (node_type, node_key, props)
                    VALUES ('ATCInteraccion', %s, %s)
                    ON CONFLICT DO NOTHING
                """, (atc, psycopg2.extras.Json({'codigo_atc': atc})))
        
        # Crear aristas Med -> ATCDuplicidad (reusar nodos ATC si existen)
        print(f"   Creando aristas Med -> Duplicidad...")
        aristas_dup = []
        for dup in data['duplicidades']:
            if dup['atc_duplicidad']:
                aristas_dup.append((
                    'Medicamento', dup['nregistro'],
                    'DUPLICIDAD_CON',
                    'ATCInteraccion', dup['atc_duplicidad'],
                    psycopg2.extras.Json({
                        'descripcion': dup['descripcion'],
                        'efecto': dup['efecto'],
                        'recomendacion': dup['recomendacion']
                    })
                ))
        
        execute_batch(cur, """
            INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
            VALUES (%s, %s, %s, %s, %s, %s)
            ON CONFLICT DO NOTHING
        """, aristas_dup, page_size=1000)
        
        print(f"   ✅ {len(aristas_dup)} aristas Duplicidad creadas")
        
        # Commit
        conn.commit()
        
        # Stats finales
        print("\n" + "="*60)
        print("✅ CARGA COMPLETADA")
        print("="*60)
        
        cur.execute("SELECT COUNT(*) FROM graph_node WHERE node_type = 'NotaSeguridad'")
        print(f"Notas Seguridad: {cur.fetchone()[0]} nodos")
        
        cur.execute("SELECT COUNT(*) FROM graph_node WHERE node_type = 'ATCInteraccion'")
        print(f"ATC Interacción: {cur.fetchone()[0]} nodos")
        
        cur.execute("SELECT COUNT(*) FROM graph_node WHERE node_type = 'AlertaGeriatria'")
        print(f"Alertas Geriatría: {cur.fetchone()[0]} nodos")
        
        cur.execute("SELECT COUNT(*) FROM graph_edge WHERE rel = 'TIENE_NOTA_SEGURIDAD'")
        print(f"Aristas TIENE_NOTA_SEGURIDAD: {cur.fetchone()[0]}")
        
        cur.execute("SELECT COUNT(*) FROM graph_edge WHERE rel = 'INTERACCIONA_CON'")
        print(f"Aristas INTERACCIONA_CON: {cur.fetchone()[0]}")
        
        cur.execute("SELECT COUNT(*) FROM graph_edge WHERE rel = 'TIENE_ALERTA_GERIATRIA'")
        print(f"Aristas TIENE_ALERTA_GERIATRIA: {cur.fetchone()[0]}")
        
        cur.execute("SELECT COUNT(*) FROM graph_edge WHERE rel = 'DUPLICIDAD_CON'")
        print(f"Aristas DUPLICIDAD_CON: {cur.fetchone()[0]}")
        
        # Total grafo
        cur.execute("SELECT COUNT(*) FROM graph_node")
        print(f"\n🔵 TOTAL NODOS: {cur.fetchone()[0]}")
        
        cur.execute("SELECT COUNT(*) FROM graph_edge")
        print(f"🔗 TOTAL ARISTAS: {cur.fetchone()[0]}")
        
    except Exception as e:
        conn.rollback()
        print(f"❌ Error: {e}")
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    xml_path = sys.argv[1] if len(sys.argv) > 1 else \
        r"C:\Users\Victor\Desktop\FARMAI\Farmai.Api\bin\Debug\net8.0\_data\nomenclator\latest\prescripcion.xml"
    
    print("="*60)
    print("ETL COMPLETO - Notas, Interacciones, Alertas, Duplicidades")
    print("="*60)
    
    # Parse XML
    data = parse_prescription_xml(xml_path)
    
    # Load to graph
    load_to_graph(data)
    
    print("\n🎉 ¡PROCESO COMPLETADO!")
