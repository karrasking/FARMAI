-- ============================================================
-- ACTUALIZAR VISTAS MATERIALIZADAS
-- Refrescar para performance óptima
-- ============================================================

-- 1. Ver estado actual de vistas materializadas
SELECT 
    schemaname,
    matviewname,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || matviewname)) as size
FROM pg_matviews
ORDER BY matviewname;

-- 2. Actualizar search_terms_mv
REFRESH MATERIALIZED VIEW CONCURRENTLY search_terms_mv;
SELECT 'search_terms_mv actualizada' as resultado;

-- 3. Actualizar meds_ft_mv
REFRESH MATERIALIZED VIEW CONCURRENTLY meds_ft_mv;
SELECT 'meds_ft_mv actualizada' as resultado;

-- 4. Actualizar mv_med_excip_agg
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_med_excip_agg;
SELECT 'mv_med_excip_agg actualizada' as resultado;

-- 5. Ver estado final
SELECT 
    schemaname,
    matviewname,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || matviewname)) as size,
    'Actualizada' as estado
FROM pg_matviews
ORDER BY matviewname;

SELECT '✅ VISTAS MATERIALIZADAS ACTUALIZADAS' as resultado;
