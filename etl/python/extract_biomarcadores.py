#!/usr/bin/env python3
"""
ETL Biomarcadores - Extrae farmacogenómica del XML de prescripciones
Autor: Cline AI Assistant
Fecha: 2025-10-03
"""

import xml.etree.ElementTree as ET
import psycopg2
from psycopg2.extras import execute_values
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

def parse_biomarcadores_xml(xml_path):
    """
    Parsea el XML y extrae biomarcadores
    
    Returns:
        List[Dict]: Lista de biomarcadores encontrados
    """
    print(f"📖 Parseando XML: {xml_path}")
    tree = ET.parse(xml_path)
    root = tree.getroot()
    
    # Namespace del XML AEMPS
    ns = {'aemps': 'http://schemas.aemps.es/prescripcion/aemps_prescripcion'}
    
    biomarcadores_data = []
    prescriptions_con_bio = 0
    prescriptions_total = 0
    
    for prescription in root.findall('.//aemps:prescription', ns):
        prescriptions_total += 1
        nregistro = prescription.find('aemps:nro_definitivo', ns)
        nregistro = nregistro.text if nregistro is not None else None
        
        # Buscar biomarcadores
        bio_elem = prescription.find('aemps:biomarcadores', ns)
        
        if bio_elem is not None and nregistro:
            prescriptions_con_bio += 1
            
            # Extraer campos
            clase = bio_elem.find('aemps:clase', ns)
            biomarcador = bio_elem.find('aemps:biomarcador', ns)
            secciones_ft = bio_elem.find('aemps:secciones_ft', ns)
            descripcion = bio_elem.find('aemps:descripcion', ns)
            inclusion_sns = bio_elem.find('aemps:inclusion_cartera_sns', ns)
            notas = bio_elem.find('aemps:notas', ns)
            
            bio_data = {
                'nregistro': nregistro,
                'clase': clase.text if clase is not None else None,
                'biomarcador': biomarcador.text if biomarcador is not None else None,
                'secciones_ft': secciones_ft.text if secciones_ft is not None else None,
                'descripcion': descripcion.text if descripcion is not None else None,
                'inclusion_sns': inclusion_sns.text if inclusion_sns is not None else None,
                'notas': notas.text if notas is not None else None
            }
            
            biomarcadores_data.append(bio_data)
            
            print(f"  ✓ {nregistro}: {bio_data['biomarcador']} ({bio_data['clase']})")
    
    print(f"\n📊 Resumen parsing:")
    print(f"  - Prescripciones totales: {prescriptions_total}")
    print(f"  - Con biomarcadores: {prescriptions_con_bio}")
    print(f"  - Biomarcadores únicos: {len(set(b['biomarcador'] for b in biomarcadores_data))}")
    
    return biomarcadores_data


def load_to_database(biomarcadores_data):
    """
    Carga biomarcadores a la base de datos
    """
    if not biomarcadores_data:
        print("⚠️  No hay biomarcadores para cargar")
        return
    
    print(f"\n💾 Conectando a BD...")
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    
    try:
        # 1. Insertar biomarcadores únicos en tabla Biomarcador
        print("1. Insertando en tabla Biomarcador...")
        
        biomarcadores_unicos = {}
        for bio in biomarcadores_data:
            nombre = bio['biomarcador']
            if nombre and nombre not in biomarcadores_unicos:
                biomarcadores_unicos[nombre] = {
                    'clase': bio['clase'],
                    'inclusion_sns': bio['inclusion_sns'] == 'SÍ'
                }
        
        for nombre, data in biomarcadores_unicos.items():
            # Verificar si ya existe
            cur.execute('SELECT "Id" FROM "Biomarcador" WHERE "Nombre" = %s', (nombre,))
            existing = cur.fetchone()
            
            if existing:
                # Actualizar (todos son genes farmacogenéticos)
                cur.execute("""
                    UPDATE "Biomarcador"
                    SET "Tipo" = %s,
                        "Descripcion" = %s,
                        "CodigoExt" = %s
                    WHERE "Nombre" = %s
                """, (
                    'gen',  # Todos son genes farmacogenéticos
                    f"Clase: {data['clase']} | Inclusión SNS: {data['inclusion_sns']}", 
                    '{"fuente": "prescripcion_xml"}',
                    nombre
                ))
            else:
                # Insertar (todos son genes farmacogenéticos)
                cur.execute("""
                    INSERT INTO "Biomarcador" ("Nombre", "Tipo", "Descripcion", "CodigoExt")
                    VALUES (%s, %s, %s, %s)
                """, (
                    nombre, 
                    'gen',  # Todos son genes: CYP2D6, HLA-B, etc.
                    f"Clase: {data['clase']} | Inclusión SNS: {data['inclusion_sns']}", 
                    '{"fuente": "prescripcion_xml"}'
                ))
            
        conn.commit()
        print(f"  ✓ {len(biomarcadores_unicos)} biomarcadores únicos")
        
        # 2. Obtener IDs de biomarcadores
        cur.execute('SELECT "Id", "Nombre" FROM "Biomarcador"')
        bio_ids = {nombre: id for id, nombre in cur.fetchall()}
        
        # 3. Obtener NRegistros válidos que existen en Medicamentos
        cur.execute('SELECT "NRegistro" FROM "Medicamentos"')
        nregistros_validos = set(row[0] for row in cur.fetchall())
        
        # 4. Insertar relaciones en MedicamentoBiomarcador (solo medicamentos existentes)
        print("2. Insertando en MedicamentoBiomarcador...")
        
        relaciones = []
        skipped = 0
        for bio in biomarcadores_data:
            if bio['biomarcador'] and bio['biomarcador'] in bio_ids:
                if bio['nregistro'] in nregistros_validos:
                    relaciones.append((
                        bio['nregistro'],
                        bio_ids[bio['biomarcador']],
                        'ajuste_dosis',  # TipoRelacion (farmacogenómica implica ajuste de dosis)
                        bio['descripcion'],  # Evidencia
                        4,  # NivelEvidencia (4=CPIC A/B - Alta evidencia clínica)
                        'AEMPS XML',  # Fuente
                        bio['secciones_ft'],  # FuenteUrl (secciones FT)
                        bio['notas']  # Notas
                    ))
                else:
                    skipped += 1
        
        execute_values(cur, """
            INSERT INTO "MedicamentoBiomarcador" 
            ("NRegistro", "BiomarcadorId", "TipoRelacion", "Evidencia", "NivelEvidencia", "Fuente", "FuenteUrl", "Notas")
            VALUES %s
            ON CONFLICT ("NRegistro", "BiomarcadorId", "TipoRelacion") DO NOTHING
        """, relaciones)
        
        conn.commit()
        print(f"  ✓ {len(relaciones)} relaciones medicamento-biomarcador insertadas")
        if skipped > 0:
            print(f"  ⚠ {skipped} relaciones omitidas (medicamento no existe en BD)")
        
        # 4. Propagar al grafo
        print("3. Propagando al grafo...")
        
        # 4.1 Nodos Biomarcador
        cur.execute("""
            INSERT INTO graph_node (node_type, node_key, props)
            SELECT 
                'Biomarcador',
                "Id"::text,
                jsonb_build_object(
                    'nombre', "Nombre",
                    'tipo', "Tipo",
                    'descripcion', "Descripcion"
                )
            FROM "Biomarcador"
            ON CONFLICT (node_type, node_key) DO UPDATE
            SET props = EXCLUDED.props
        """)
        
        nodos_creados = cur.rowcount
        print(f"  ✓ {nodos_creados} nodos Biomarcador")
        
        # 4.2 Aristas Med → Biomarcador
        cur.execute("""
            INSERT INTO graph_edge (src_type, src_key, rel, dst_type, dst_key, props)
            SELECT 
                'Medicamento',
                mb."NRegistro",
                'TIENE_BIOMARCADOR',
                'Biomarcador',
                mb."BiomarcadorId"::text,
                jsonb_build_object(
                    'tipo_relacion', mb."TipoRelacion",
                    'evidencia', mb."Evidencia",
                    'nivel_evidencia', mb."NivelEvidencia",
                    'fuente_url', mb."FuenteUrl",
                    'notas', mb."Notas"
                )
            FROM "MedicamentoBiomarcador" mb
            WHERE EXISTS (
                SELECT 1 FROM graph_node gn 
                WHERE gn.node_type = 'Medicamento' 
                AND gn.node_key = mb."NRegistro"
            )
            ON CONFLICT DO NOTHING
        """)
        
        aristas_creadas = cur.rowcount
        print(f"  ✓ {aristas_creadas} aristas Med → Biomarcador")
        
        conn.commit()
        
        print(f"\n✅ ETL COMPLETADO EXITOSAMENTE")
        print(f"   Biomarcadores: {len(biomarcadores_unicos)}")
        print(f"   Relaciones: {len(relaciones)}")
        print(f"   Nodos grafo: {nodos_creados}")
        print(f"   Aristas grafo: {aristas_creadas}")
        
    except Exception as e:
        conn.rollback()
        print(f"❌ ERROR: {e}")
        raise
    finally:
        cur.close()
        conn.close()


def main():
    if len(sys.argv) < 2:
        print("Uso: python extract_biomarcadores.py <ruta_xml>")
        print("Ejemplo: python extract_biomarcadores.py prescripcion_sample.xml")
        sys.exit(1)
    
    xml_path = sys.argv[1]
    
    print("=" * 60)
    print("🧬 ETL BIOMARCADORES - FARMACOGENÓMICA")
    print("=" * 60)
    print(f"Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"XML: {xml_path}")
    print("=" * 60)
    
    # Parsear XML
    biomarcadores_data = parse_biomarcadores_xml(xml_path)
    
    # Cargar a BD
    load_to_database(biomarcadores_data)
    
    print("\n🎉 Proceso finalizado")


if __name__ == '__main__':
    main()
