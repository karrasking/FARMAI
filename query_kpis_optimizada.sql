-- Query única optimizada para obtener todos los KPIs en una sola consulta
-- FARMAI Dashboard - Una sola llamada a la base de datos
SELECT 
  (SELECT COUNT(*) FROM "Medicamentos") as medicamentos,
  (SELECT COUNT(*) FROM "Presentacion") as presentaciones,
  (SELECT COUNT(*) FROM "SustanciaActiva") as principios_activos,
  (SELECT COUNT(*) FROM "Laboratorio") as laboratorios,
  (SELECT COUNT(*) FROM "Excipiente") as excipientes,
  (SELECT COUNT(*) FROM "Biomarcador") as biomarcadores,
  (SELECT COUNT(*) FROM "Documento") as documentos,
  (SELECT COUNT(*) FROM graph_edge WHERE rel = 'INTERACCIONA_CON') as interacciones,
  (SELECT COUNT(*) FROM graph_node) as total_nodos,
  (SELECT COUNT(*) FROM graph_edge) as total_aristas;
