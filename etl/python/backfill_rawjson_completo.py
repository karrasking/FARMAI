"""
BACKFILL MASIVO: Obtener JSON completo de API CIMA para 20K medicamentos
=========================================================================
Objetivo: Completar RawJson de todos los medicamentos consultando API CIMA
Tiempo estimado: 2-3 horas (20K requests con rate limit)
"""

import psycopg2
import requests
import time
import json
from datetime import datetime

# Configuración
DB_CONFIG = {
    'host': 'localhost',
    'port': 5433,
    'database': 'farmai_db',
    'user': 'farmai_user',
    'password': 'Iaforeverfree'
}

CIMA_API_BASE = "https://cima.aemps.es/cima/rest/medicamento"
RATE_LIMIT_DELAY = 0.1  # 100ms entre requests (10 req/seg)
BATCH_SIZE = 100  # Commit cada 100 registros

def get_medicamentos_sin_json(conn):
    """Obtener medicamentos con RawJson vacío o null"""
    cur = conn.cursor()
    cur.execute("""
        SELECT "NRegistro", "Nombre"
        FROM "Medicamentos"
        WHERE "RawJson" IS NULL OR "RawJson"::text = '{}'
        ORDER BY "NRegistro"
    """)
    results = cur.fetchall()
    cur.close()
    return results

def fetch_json_from_cima(nregistro):
    """Consultar API CIMA y obtener JSON completo"""
    try:
        url = f"{CIMA_API_BASE}?nregistro={nregistro}"
        response = requests.get(url, timeout=10)
        
        if response.status_code == 200:
            return response.json()
        elif response.status_code == 404:
            print(f"  ⚠️  404 Not Found: {nregistro}")
            return None
        else:
            print(f"  ❌ Error {response.status_code}: {nregistro}")
            return None
            
    except requests.exceptions.Timeout:
        print(f"  ⏱️  Timeout: {nregistro}")
        return None
    except Exception as e:
        print(f"  ❌ Exception for {nregistro}: {str(e)}")
        return None

def update_rawjson(conn, nregistro, json_data):
    """Actualizar RawJson en base de datos"""
    cur = conn.cursor()
    try:
        cur.execute("""
            UPDATE "Medicamentos"
            SET "RawJson" = %s::jsonb,
                "UpdatedAt" = NOW()
            WHERE "NRegistro" = %s
        """, (json.dumps(json_data), nregistro))
        cur.close()
        return True
    except Exception as e:
        print(f"  ❌ DB Error for {nregistro}: {str(e)}")
        cur.close()
        return False

def main():
    print("=" * 70)
    print("BACKFILL MASIVO: RawJson desde API CIMA")
    print("=" * 70)
    
    # Conectar a BD
    conn = psycopg2.connect(**DB_CONFIG)
    conn.autocommit = False
    
    # Obtener medicamentos sin JSON
    print("\n📊 Obteniendo medicamentos sin JSON...")
    medicamentos = get_medicamentos_sin_json(conn)
    total = len(medicamentos)
    print(f"✅ Encontrados: {total:,} medicamentos")
    
    if total == 0:
        print("✅ No hay medicamentos pendientes!")
        conn.close()
        return
    
    # Confirmar
    print(f"\n⚠️  Esto tomará aproximadamente {total * RATE_LIMIT_DELAY / 3600:.1f} horas")
    respuesta = input("¿Continuar? (s/n): ")
    if respuesta.lower() != 's':
        print("❌ Cancelado")
        conn.close()
        return
    
    # Procesar
    print(f"\n🚀 Iniciando backfill... (Rate limit: {RATE_LIMIT_DELAY}s)")
    print("-" * 70)
    
    start_time = datetime.now()
    success_count = 0
    error_count = 0
    not_found_count = 0
    
    for i, (nregistro, nombre) in enumerate(medicamentos, 1):
        # Progress
        if i % 10 == 0:
            elapsed = (datetime.now() - start_time).total_seconds()
            rate = i / elapsed if elapsed > 0 else 0
            eta_seconds = (total - i) / rate if rate > 0 else 0
            eta_hours = eta_seconds / 3600
            
            print(f"\r[{i:,}/{total:,}] {(i/total*100):.1f}% | "
                  f"✅ {success_count} | ❌ {error_count} | "
                  f"⚠️  {not_found_count} | "
                  f"ETA: {eta_hours:.1f}h", end='', flush=True)
        
        # Fetch JSON
        json_data = fetch_json_from_cima(nregistro)
        
        if json_data is not None:
            # Update BD
            if update_rawjson(conn, nregistro, json_data):
                success_count += 1
                
                # Commit cada BATCH_SIZE
                if i % BATCH_SIZE == 0:
                    conn.commit()
            else:
                error_count += 1
                conn.rollback()
        else:
            not_found_count += 1
        
        # Rate limit
        time.sleep(RATE_LIMIT_DELAY)
    
    # Commit final
    conn.commit()
    
    # Resumen
    elapsed = (datetime.now() - start_time).total_seconds()
    print(f"\n\n" + "=" * 70)
    print("✅ BACKFILL COMPLETADO")
    print("=" * 70)
    print(f"Total procesados: {total:,}")
    print(f"✅ Exitosos: {success_count:,} ({success_count/total*100:.1f}%)")
    print(f"❌ Errores: {error_count:,} ({error_count/total*100:.1f}%)")
    print(f"⚠️  No encontrados (404): {not_found_count:,} ({not_found_count/total*100:.1f}%)")
    print(f"⏱️  Tiempo total: {elapsed/3600:.2f} horas")
    print("=" * 70)
    
    conn.close()

if __name__ == "__main__":
    main()
