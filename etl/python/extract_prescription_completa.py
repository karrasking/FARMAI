#!/usr/bin/env python3
"""
Extrae una prescripción completa de ibuprofeno con TODOS los campos
"""
import xml.etree.ElementTree as ET
import sys

def extract_full_prescription(xml_path):
    """Extrae una prescripción completa"""
    print(f"📄 Extrayendo prescripción completa de ibuprofeno...\n")
    
    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()
        
        # Buscar primera prescripción con ibuprofeno
        for prescription in root:
            if 'prescription' in prescription.tag.lower():
                des_nomco = prescription.find('.//{http://schemas.aemps.es/prescripcion/aemps_prescripcion}des_nomco')
                if des_nomco is not None and 'ibuprofeno' in des_nomco.text.lower():
                    print("=" * 80)
                    print("PRESCRIPCIÓN COMPLETA DE IBUPROFENO")
                    print("=" * 80)
                    
                    # Mostrar XML completo
                    xml_str = ET.tostring(prescription, encoding='unicode', method='xml')
                    print(xml_str)
                    print("=" * 80)
                    
                    # Listar todos los campos estructurados
                    print("\n📋 TODOS LOS CAMPOS (45 campos):")
                    print("-" * 80)
                    count = 0
                    for child in prescription:
                        count += 1
                        tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
                        text = child.text[:100] if child.text and len(child.text) > 100 else child.text
                        print(f"{count:2}. {tag}: {text}")
                    
                    print(f"\n✅ Total de campos: {count}")
                    
                    # Identificar campos especiales
                    print("\n🔍 CAMPOS ESPECIALES IDENTIFICADOS:")
                    print("-" * 80)
                    
                    special_fields = [
                        'asunto_nota_seguridad',
                        'ref_nota_seguridad',
                        'fecha_nota_seguridad',
                        'tipo_via_admin',
                        'situacion_registro_vigente',
                        'sw_sustituible',
                        'sw_envase_clinico',
                        'sw_uso_hospitalario',
                        'sw_diagnostico_hospitalario',
                        'sw_tld',
                        'sw_especial_control_medico',
                        'sw_base_a_plantas',
                        'sw_importacion_paralela',
                        'sw_radiofarmaco',
                        'sw_serializacion',
                        'sw_tiene_excip_decl_oblig'
                    ]
                    
                    for field in special_fields:
                        ns = root.tag.split("}")[0].strip("{")
                        elem = prescription.find(f'.//{{{ns}}}{field}')
                        if elem is not None:
                            print(f"  ✓ {field}: {elem.text}")
                    
                    return True
        
        print("❌ No se encontró prescripción con ibuprofeno")
        return False
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    xml_path = sys.argv[1] if len(sys.argv) > 1 else "prescripcion.xml"
    extract_full_prescription(xml_path)
