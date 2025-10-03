#!/usr/bin/env python3
"""
Explorar estructura completa del XML de prescripciones
"""
import xml.etree.ElementTree as ET
import sys

def explore_xml(xml_path):
    """Explora la estructura del XML"""
    print(f"📄 Explorando: {xml_path}\n")
    
    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()
        
        print(f"🔍 ROOT:")
        print(f"  Tag: {root.tag}")
        print(f"  Attribs: {root.attrib}")
        print(f"  Children: {len(list(root))}\n")
        
        print(f"📋 ESTRUCTURA (primeros 3 niveles):")
        print_structure(root, max_depth=3)
        
        # Buscar cualquier elemento que tenga "ibuprofeno"
        print(f"\n🔍 Buscando 'ibuprofeno' en cualquier parte...")
        found = search_text(root, 'ibuprofeno', max_results=3)
        
        if found:
            print(f"\n✅ Encontrados {len(found)} elementos con 'ibuprofeno'")
            for i, elem in enumerate(found, 1):
                print(f"\n{'='*60}")
                print(f"Elemento #{i} que contiene 'ibuprofeno':")
                print(f"{'='*60}")
                # Buscar el padre 'medicamento'
                parent = find_parent_with_tag(root, elem, 'medicamento')
                if parent:
                    xml_str = ET.tostring(parent, encoding='unicode', method='xml')
                    # Limitar la salida
                    if len(xml_str) > 5000:
                        print(xml_str[:5000] + "\n... (truncado)")
                    else:
                        print(xml_str)
                else:
                    xml_str = ET.tostring(elem, encoding='unicode', method='xml')
                    if len(xml_str) > 2000:
                        print(xml_str[:2000] + "\n... (truncado)")
                    else:
                        print(xml_str)
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

def print_structure(elem, depth=0, max_depth=3, max_children=5):
    """Imprime la estructura del XML recursivamente"""
    if depth > max_depth:
        return
    
    indent = "  " * depth
    tag = elem.tag.split('}')[-1] if '}' in elem.tag else elem.tag
    text_preview = (elem.text[:30] + "...") if elem.text and len(elem.text) > 30 else elem.text
    
    if elem.text and elem.text.strip():
        print(f"{indent}{tag}: {text_preview}")
    else:
        print(f"{indent}{tag} ({len(list(elem))} children)")
    
    children = list(elem)
    for i, child in enumerate(children):
        if i >= max_children:
            print(f"{indent}  ... ({len(children) - max_children} more)")
            break
        print_structure(child, depth + 1, max_depth, max_children)

def search_text(elem, search_term, max_results=10, results=None):
    """Busca elementos que contengan el texto especificado"""
    if results is None:
        results = []
    
    if len(results) >= max_results:
        return results
    
    # Buscar en el texto del elemento
    if elem.text and search_term.lower() in elem.text.lower():
        results.append(elem)
    
    # Buscar en los atributos
    for value in elem.attrib.values():
        if search_term.lower() in str(value).lower():
            results.append(elem)
            break
    
    # Buscar recursivamente en los hijos
    for child in elem:
        search_text(child, search_term, max_results, results)
        if len(results) >= max_results:
            break
    
    return results

def find_parent_with_tag(root, target, parent_tag):
    """Encuentra el padre con un tag específico"""
    for elem in root.iter():
        for child in elem:
            if child == target:
                # Buscar hacia arriba si elem no es el tag buscado
                parent_tag_short = parent_tag.split('}')[-1] if '}' in parent_tag else parent_tag
                if parent_tag_short in elem.tag:
                    return elem
    return None

if __name__ == '__main__':
    xml_path = sys.argv[1] if len(sys.argv) > 1 else "prescripcion.xml"
    explore_xml(xml_path)
