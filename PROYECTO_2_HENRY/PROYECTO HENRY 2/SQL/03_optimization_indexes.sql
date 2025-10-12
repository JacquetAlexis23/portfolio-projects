-- =====================================================
-- 🚛 FLEETLOGIX - OPTIMIZACIÓN CON ÍNDICES ESTRATÉGICOS
-- 🎯 5 Índices científicamente diseñados para máximo impacto
-- 📊 Objetivo: Reducir tiempos de ejecución en 20-80%
-- 🔬 Basado en análisis de 12 queries de negocio críticas
-- =====================================================

-- =====================================================
-- 📋 METODOLOGÍA DE OPTIMIZACIÓN
-- =====================================================
/*
ANÁLISIS CIENTÍFICO DE PATRONES DE ACCESO:

1. ANÁLISIS DE QUERIES MÁS COSTOSAS:
   - Query 4, 9, 10, 11: JOINs intensivos entre trips-routes-deliveries
   - Query 5, 6, 8: Filtros por status y fechas en trips/drivers
   - Query 7, 12: Análisis temporal en deliveries con scheduled_datetime
   - Query 9: Agregaciones en maintenance por vehicle_id

2. IDENTIFICACIÓN DE OPERACIONES COSTOSAS:
   - Sequential Scans en trips (tabla más grande: 100k registros)
   - JOINs sin índices entre trips ↔ deliveries (400k registros)
   - Filtros temporales repetitivos en departure_datetime
   - Agregaciones frecuentes por vehicle_id y driver_id

3. ESTRATEGIA DE ÍNDICES:
   - Índices compuestos para JOINs críticos
   - Índices parciales para filtros selectivos
   - Índices covering para evitar table lookups
   - Optimización específica por tipo de query
*/

-- =====================================================
-- 🏃‍♂️ BASELINE - MEDICIÓN ANTES DE OPTIMIZACIÓN
-- =====================================================
-- Ejecutar estas queries para establecer baseline de performance:

-- Activar medición de tiempos
\timing on

-- Medir Query 4 (Intermedia - JOIN intensivo)
\echo '=== BASELINE Query 4: Análisis geográfico ==='
EXPLAIN ANALYZE
SELECT r.destination_city, COUNT(DISTINCT t.trip_id), COUNT(d.delivery_id)
FROM routes r
INNER JOIN trips t ON r.route_id = t.route_id  
INNER JOIN deliveries d ON t.trip_id = d.trip_id
WHERE t.departure_datetime >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY r.destination_city;

-- Medir Query 9 (Compleja - CTEs múltiples)
\echo '=== BASELINE Query 9: Rentabilidad por ruta ==='
EXPLAIN ANALYZE
WITH ruta_metricas AS (
    SELECT r.route_id, COUNT(DISTINCT t.trip_id) as viajes
    FROM routes r
    INNER JOIN trips t ON r.route_id = t.route_id
    INNER JOIN deliveries d ON t.trip_id = d.trip_id
    WHERE t.status = 'completed'
    GROUP BY r.route_id
)
SELECT * FROM ruta_metricas WHERE viajes >= 10;

-- Medir Query 10 (Compleja - Window Functions)
\echo '=== BASELINE Query 10: Ranking conductores ==='
EXPLAIN ANALYZE
SELECT d.driver_id, COUNT(DISTINCT t.trip_id),
       RANK() OVER (ORDER BY COUNT(DISTINCT t.trip_id) DESC)
FROM drivers d
INNER JOIN trips t ON d.driver_id = t.driver_id
WHERE d.status = 'active'
GROUP BY d.driver_id;

-- =====================================================
-- 🚀 ÍNDICE 1: OPTIMIZACIÓN CRÍTICA PARA TRIPS
-- =====================================================
-- 🎯 Justificación: 8 de 12 queries usan trips como tabla principal
-- 📊 Beneficia: Query 4, 5, 6, 7, 9, 10, 11, 12
-- 🔧 Técnica: Índice compuesto que cubre JOINs más frecuentes + filtro temporal

DROP INDEX IF EXISTS idx_trips_performance_master;

CREATE INDEX idx_trips_performance_master 
ON trips(departure_datetime DESC, status, route_id, vehicle_id, driver_id, trip_id)
WHERE status IN ('completed', 'in_progress');

-- 📈 Impacto esperado: 40-60% reducción en tiempo de JOINs
-- 💡 Razón técnica: 
--   - departure_datetime DESC: Optimiza filtros temporales frecuentes
--   - status: Filtro altamente selectivo (75% completed)
--   - route_id, vehicle_id, driver_id: Claves de JOIN críticas
--   - trip_id: Covering index para evitar table access
--   - WHERE clause: Índice parcial (85% de registros relevantes)

-- =====================================================
-- 🚀 ÍNDICE 2: OPTIMIZACIÓN PARA DELIVERIES TEMPORALES  
-- =====================================================
-- 🎯 Justificación: Queries 7, 12 hacen análisis temporal intensivo
-- 📊 Beneficia: Query 4, 7, 8, 9, 11, 12
-- 🔧 Técnica: Índice temporal con datos de negocio críticos

DROP INDEX IF EXISTS idx_deliveries_temporal_analysis;

CREATE INDEX idx_deliveries_temporal_analysis 
ON deliveries(scheduled_datetime DESC, delivery_status, trip_id, delivered_datetime)
INCLUDE (package_weight_kg, delivery_id);

-- 📈 Impacto esperado: 50-70% reducción en análisis temporal
-- 💡 Razón técnica:
--   - scheduled_datetime DESC: Optimiza rangos temporales
--   - delivery_status: Filtro de estado crítico
--   - trip_id: JOIN primario con trips
--   - INCLUDE: Datos necesarios sin acceso a tabla principal

-- =====================================================
-- 🚀 ÍNDICE 3: OPTIMIZACIÓN PARA ROUTES Y GEOGRAFÍA
-- =====================================================
-- 🎯 Justificación: Queries 4, 6, 9 requieren métricas de ruta rápidas
-- 📊 Beneficia: Query 4, 6, 7, 9, 10, 11
-- 🔧 Técnica: Índice covering para métricas geográficas

DROP INDEX IF EXISTS idx_routes_geographic_metrics;

CREATE INDEX idx_routes_geographic_metrics 
ON routes(route_id, destination_city, origin_city)
INCLUDE (distance_km, estimated_duration_hours, route_code);

-- 📈 Impacto esperado: 30-50% reducción en queries geográficas
-- 💡 Razón técnica:
--   - route_id: JOIN primario más frecuente
--   - destination_city: Agrupación geográfica crítica
--   - INCLUDE: Métricas sin table lookup adicional

-- =====================================================
-- 🚀 ÍNDICE 4: OPTIMIZACIÓN PARA ANÁLISIS DE CONDUCTORES
-- =====================================================
-- 🎯 Justificación: Queries 2, 5, 10 analizan performance de conductores
-- 📊 Beneficia: Query 2, 5, 8, 10
-- 🔧 Técnica: Índice compuesto para análisis de RRHH

DROP INDEX IF EXISTS idx_drivers_performance_analysis;

CREATE INDEX idx_drivers_performance_analysis 
ON drivers(status, license_expiry, driver_id, hire_date)
WHERE status = 'active';

-- 📈 Impacto esperado: 35-55% reducción en análisis de conductores  
-- 💡 Razón técnica:
--   - status = 'active': Filtro altamente selectivo (90% activos)
--   - license_expiry: Ordenamiento para compliance
--   - driver_id: JOIN primario con trips
--   - WHERE clause: Índice parcial para conductores activos

-- =====================================================
-- 🚀 ÍNDICE 5: OPTIMIZACIÓN PARA MANTENIMIENTO Y COSTOS
-- =====================================================
-- 🎯 Justificación: Query 8, 9 requieren análisis de costos rápido
-- 📊 Beneficia: Query 8, 9
-- 🔧 Técnica: Índice especializado para análisis financiero

DROP INDEX IF EXISTS idx_maintenance_cost_analysis;

CREATE INDEX idx_maintenance_cost_analysis 
ON maintenance(vehicle_id, maintenance_type, maintenance_date DESC)
INCLUDE (cost, maintenance_id);

-- 📈 Impacto esperado: 40-65% reducción en análisis de mantenimiento
-- 💡 Razón técnica:
--   - vehicle_id: JOIN crítico con vehicles
--   - maintenance_type: Agrupación por tipo de mantenimiento  
--   - maintenance_date DESC: Análisis temporal
--   - INCLUDE: Métricas financieras críticas

-- =====================================================
-- 🔧 MANTENIMIENTO Y VALIDACIÓN DE ÍNDICES
-- =====================================================

-- Actualizar estadísticas después de crear índices
ANALYZE vehicles;
ANALYZE drivers; 
ANALYZE routes;
ANALYZE trips;
ANALYZE deliveries;
ANALYZE maintenance;

-- Verificar índices creados
\echo '=== VERIFICACIÓN DE ÍNDICES CREADOS ==='
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE schemaname = 'public' 
    AND indexname LIKE 'idx_%performance%'
    OR indexname LIKE 'idx_%temporal%'
    OR indexname LIKE 'idx_%geographic%'
    OR indexname LIKE 'idx_%analysis%'
ORDER BY tablename, indexname;

-- Verificar uso de memoria por índices
SELECT 
    t.tablename,
    pg_size_pretty(pg_total_relation_size(t.tablename::regclass)) as table_size,
    COUNT(i.indexname) as num_indexes,
    pg_size_pretty(SUM(pg_relation_size(i.indexname::regclass))) as total_index_size
FROM pg_tables t
LEFT JOIN pg_indexes i ON t.tablename = i.tablename 
WHERE t.schemaname = 'public'
    AND t.tablename IN ('vehicles', 'drivers', 'routes', 'trips', 'deliveries', 'maintenance')
GROUP BY t.tablename, pg_total_relation_size(t.tablename::regclass)
ORDER BY pg_total_relation_size(t.tablename::regclass) DESC;

-- =====================================================
-- 🏁 POST-OPTIMIZACIÓN - MEDICIÓN DE MEJORAS
-- =====================================================

\echo '=== POST-OPTIMIZACIÓN: Midiendo mejoras ==='

-- Re-medir Query 4 con índices
\echo '=== POST-OPT Query 4: Análisis geográfico ==='
EXPLAIN ANALYZE
SELECT r.destination_city, COUNT(DISTINCT t.trip_id), COUNT(d.delivery_id)
FROM routes r
INNER JOIN trips t ON r.route_id = t.route_id  
INNER JOIN deliveries d ON t.trip_id = d.trip_id
WHERE t.departure_datetime >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY r.destination_city;

-- Re-medir Query 9 con índices  
\echo '=== POST-OPT Query 9: Rentabilidad por ruta ==='
EXPLAIN ANALYZE
WITH ruta_metricas AS (
    SELECT r.route_id, COUNT(DISTINCT t.trip_id) as viajes
    FROM routes r
    INNER JOIN trips t ON r.route_id = t.route_id
    INNER JOIN deliveries d ON t.trip_id = d.trip_id
    WHERE t.status = 'completed'
    GROUP BY r.route_id
)
SELECT * FROM ruta_metricas WHERE viajes >= 10;

-- Re-medir Query 10 con índices
\echo '=== POST-OPT Query 10: Ranking conductores ==='
EXPLAIN ANALYZE
SELECT d.driver_id, COUNT(DISTINCT t.trip_id),
       RANK() OVER (ORDER BY COUNT(DISTINCT t.trip_id) DESC)
FROM drivers d
INNER JOIN trips t ON d.driver_id = t.driver_id
WHERE d.status = 'active'
GROUP BY d.driver_id;

-- =====================================================
-- 📊 SCRIPT DE MEDICIÓN COMPLETA DE LAS 12 QUERIES
-- =====================================================
/*
Para medir todas las queries automáticamente, ejecutar:

\timing on
\echo '=== MIDIENDO TODAS LAS 12 QUERIES ==='

-- Query 1 (Básica)
\echo 'Query 1: Inventario de flota'
\i 02_queries_analysis.sql
-- [Copiar query 1 aquí]

-- Query 2 (Básica)  
\echo 'Query 2: Licencias por vencer'
-- [Copiar query 2 aquí]

-- ... (repetir para las 12 queries)

RESULTADOS ESPERADOS:
- Queries Básicas (1-3): Reducción 20-40%
- Queries Intermedias (4-8): Reducción 30-60%  
- Queries Complejas (9-12): Reducción 40-80%
*/

-- =====================================================
-- 🎯 ÍNDICES ADICIONALES RECOMENDADOS (OPCIONALES)
-- =====================================================
/*
Para workloads específicos, considerar estos índices adicionales:

-- Para análisis frecuente de vehículos:
CREATE INDEX idx_vehicles_type_status ON vehicles(vehicle_type, status);

-- Para búsquedas rápidas por placa:
CREATE INDEX idx_vehicles_license_plate ON vehicles(license_plate);

-- Para análisis de entregas por tracking:
CREATE INDEX idx_deliveries_tracking ON deliveries(tracking_number);

-- Para análisis temporal específico de mantenimiento:
CREATE INDEX idx_maintenance_date_type ON maintenance(maintenance_date, maintenance_type);
*/

-- =====================================================
-- 📈 MONITOREO DE PERFORMANCE CONTINUO
-- =====================================================

-- Query para monitorear uso de índices
CREATE OR REPLACE VIEW v_index_usage_stats AS
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched,
    CASE WHEN idx_scan = 0 THEN 'NUNCA USADO'
         WHEN idx_scan < 100 THEN 'USO BAJO'
         WHEN idx_scan < 1000 THEN 'USO MEDIO'
         ELSE 'USO ALTO'
    END as usage_category
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;

-- Query para identificar queries lentas
CREATE OR REPLACE VIEW v_slow_queries AS
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    CASE WHEN mean_time > 1000 THEN '🔴 MUY LENTA'
         WHEN mean_time > 100 THEN '🟡 LENTA'
         ELSE '🟢 RÁPIDA'
    END as performance_status
FROM pg_stat_statements
WHERE query LIKE '%trips%' OR query LIKE '%deliveries%'
ORDER BY mean_time DESC
LIMIT 20;

\echo '=== OPTIMIZACIÓN COMPLETADA ==='
\echo '🎯 5 índices estratégicos creados'
\echo '📊 Ejecutar queries de medición para verificar mejoras'
\echo '🔧 Usar vistas de monitoreo para análisis continuo'
