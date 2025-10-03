#!/usr/bin/env python3
"""
Extrae el XML completo de un ibuprofeno específico del archivo de prescripciones
"""
import xml.etree.ElementTree as ET
import sys

def extract_ibuprofeno_xml(xml_path, nregistro):
    """Extrae el XML completo de un medicamento específico"""
    print(f"🔍 Analizando estructura del XML...")
    print(f"📄 Archivo: {xml_path}\n")
    
    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()
        
        print(f"Root tag: {root.tag}")
        
        # Extraer namespace si existe
        ns = {'ns': root.tag.split('}')[0].strip('{')} if '}' in root.tag else {}
        print(f"Namespace: {ns}")
        print(f"\n🔍 Mostrando primeros 5 medicamentos:\n")
        
        # Mostrar primeros 5 para ver estructura
        count = 0
        # Buscar con y sin namespace
        medicamentos = root.findall('.//ns:medicamento', ns) if ns else root.findall('.//medicamento')
        for med in medicamentos:
            count += 1
            if count > 5:
                break
            
            print(f"\n{'='*60}")
            print(f"Medicamento #{count}:")
            print(f"{'='*60}")
            
            # Mostrar TODOS los campos del medicamento
            for child in med:
                text = child.text[:100] if child.text and len(child.text) > 100 else child.text
                print(f"  {child.tag}: {text}")
            
            # Si el primero parece tener ibuprofeno, mostrar XML completo
            nombre_campo = med.find('.//nombre') or med.find('nom') or med.find('des_nomco')
            if nombre_campo is not None and nombre_campo.text:
                if 'ibuprofeno' in nombre_campo.text.lower():
                    print(f"\n{'='*80}")
                    print("XML COMPLETO (tiene ibuprofeno):")
                    print(f"{'='*80}")
                    xml_string = ET.tostring(med, encoding='unicode', method='xml')
                    print(xml_string)
                    return True
        
        print(f"\n✅ Total medicamentos analizados: {count}")
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == '__main__':
    # Buscar IBUPROFENO LLORENS 600 mg
    xml_path = "prescripcion.xml"  # Ajustar ruta si es necesario
    nregistro = "65627"
    
    # Si se pasa argumento, usarlo
    if len(sys.argv) > 1:
        nregistro = sys.argv[1]
    
    if len(sys.argv) > 2:
        xml_path = sys.argv[2]
    
    extract_ibuprofeno_xml(xml_path, nregistro)
