-- =====================================================
-- 🚛 FLEETLOGIX - ANÁLISIS CIENTÍFICO DE 12 QUERIES SQL
-- 📊 Ciencia de Datos Aplicada a Logística y Transporte
-- 🎯 Consultas diseñadas por: Científico de Datos Experto
-- 📅 Fecha: Octubre 2025
-- =====================================================

-- =====================================================
-- 📋 METODOLOGÍA DE ANÁLISIS
-- =====================================================
/*
ESTRUCTURA CIENTÍFICA:
- 12 queries organizadas por complejidad (Básicas → Intermedias → Complejas)
- Cada query resuelve un problema de negocio específico
- Análisis de performance con EXPLAIN ANALYZE
- Medición de tiempos antes y después de optimización
- Justificación técnica de cada consulta

NIVELES DE COMPLEJIDAD:
- BÁSICAS (3): Operaciones simples, joins básicos, agregaciones elementales
- INTERMEDIAS (5): Joins múltiples, subconsultas, funciones avanzadas
- COMPLEJAS (4): CTEs, Window Functions, análisis estadísticos avanzados
*/

-- =====================================================
-- 🟢 QUERIES BÁSICAS (3 queries)
-- Fundamentos operacionales del negocio
-- =====================================================

-- 📊 QUERY 1: Inventario de flota por tipo y estado
-- 🎯 Problema de negocio: Gestión de activos y planificación de capacidad
-- 📈 Complejidad: Básica - Agregación simple con múltiples dimensiones
-- ⏱️ Tiempo esperado: <5ms
SELECT 
    v.vehicle_type as tipo_vehiculo,
    v.status as estado_vehiculo,
    COUNT(*) as cantidad_vehiculos,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as porcentaje_flota,
    STRING_AGG(v.license_plate, ', ' ORDER BY v.license_plate) as ejemplos_placas
FROM vehicles v
GROUP BY v.vehicle_type, v.status
ORDER BY cantidad_vehiculos DESC, tipo_vehiculo;

-- 📊 QUERY 2: Conductores con certificaciones próximas a vencer  
-- 🎯 Problema de negocio: Compliance regulatorio y continuidad operacional
-- 📈 Complejidad: Básica - Filtrado temporal con cálculos de fecha
-- ⏱️ Tiempo esperado: <10ms
SELECT 
    d.driver_id,
    d.first_name || ' ' || d.last_name as conductor_completo,
    d.license_number as numero_licencia,
    d.license_expiry as fecha_vencimiento,
    d.license_expiry - CURRENT_DATE as dias_restantes,
    CASE 
        WHEN d.license_expiry < CURRENT_DATE THEN '🔴 VENCIDA'
        WHEN d.license_expiry < CURRENT_DATE + INTERVAL '15 days' THEN '🟠 CRÍTICO'
        WHEN d.license_expiry < CURRENT_DATE + INTERVAL '30 days' THEN '🟡 ALERTA'
        ELSE '🟢 OK'
    END as estado_licencia
FROM drivers d
WHERE d.status = 'active' 
    AND d.license_expiry <= CURRENT_DATE + INTERVAL '60 days'
ORDER BY d.license_expiry ASC;

-- 📊 QUERY 3: Resumen operacional de viajes por estado
-- 🎯 Problema de negocio: KPI operacional en tiempo real
-- 📈 Complejidad: Básica - Agregación con métricas de negocio
-- ⏱️ Tiempo esperado: <15ms
SELECT 
    t.status as estado_viaje,
    COUNT(*) as total_viajes,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as porcentaje,
    MIN(t.departure_datetime) as viaje_mas_antiguo,
    MAX(t.departure_datetime) as viaje_mas_reciente,
    ROUND(AVG(t.total_weight_kg), 2) as peso_promedio_kg,
    ROUND(SUM(t.fuel_consumed_liters), 2) as combustible_total_litros
FROM trips t
GROUP BY t.status
ORDER BY total_viajes DESC;

-- =====================================================
-- 🟡 QUERIES INTERMEDIAS (5 queries)  
-- Análisis multidimensional del negocio
-- =====================================================

-- 📊 QUERY 4: Análisis de demanda geográfica por ciudad destino
-- 🎯 Problema de negocio: Optimización de rutas y asignación de recursos
-- 📈 Complejidad: Intermedia - Joins múltiples con agregaciones temporales
-- ⏱️ Tiempo esperado: 50-100ms
SELECT 
    r.destination_city as ciudad_destino,
    COUNT(DISTINCT t.trip_id) as viajes_realizados,
    COUNT(d.delivery_id) as entregas_totales,
    ROUND(AVG(d.package_weight_kg), 2) as peso_promedio_paquete,
    ROUND(SUM(d.package_weight_kg), 2) as peso_total_kg,
    ROUND(AVG(r.distance_km), 2) as distancia_promedio_km,
    COUNT(DISTINCT t.vehicle_id) as vehiculos_utilizados,
    COUNT(DISTINCT t.driver_id) as conductores_involucrados,
    ROUND(COUNT(d.delivery_id)::NUMERIC / NULLIF(COUNT(DISTINCT t.trip_id), 0), 2) as entregas_por_viaje
FROM routes r
INNER JOIN trips t ON r.route_id = t.route_id
INNER JOIN deliveries d ON t.trip_id = d.trip_id
WHERE t.departure_datetime >= CURRENT_DATE - INTERVAL '90 days'
    AND t.status IN ('completed', 'in_progress')
GROUP BY r.destination_city
HAVING COUNT(DISTINCT t.trip_id) >= 5
ORDER BY entregas_totales DESC, peso_total_kg DESC;

-- 📊 QUERY 5: Productividad y carga laboral por conductor  
-- 🎯 Problema de negocio: Gestión de recursos humanos y balanceo de cargas
-- 📈 Complejidad: Intermedia - Análisis de RRHH con subconsultas
-- ⏱️ Tiempo esperado: 30-80ms
SELECT 
    d.driver_id,
    d.first_name || ' ' || d.last_name as conductor,
    d.hire_date as fecha_contratacion,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, d.hire_date)) as anos_experiencia,
    COUNT(DISTINCT t.trip_id) as viajes_totales,
    COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.trip_id END) as viajes_completados,
    COUNT(DISTINCT CASE WHEN t.status = 'cancelled' THEN t.trip_id END) as viajes_cancelados,
    ROUND(COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.trip_id END) * 100.0 / 
          NULLIF(COUNT(DISTINCT t.trip_id), 0), 2) as tasa_exito_pct,
    ROUND(AVG(CASE WHEN t.status = 'completed' THEN t.fuel_consumed_liters END), 2) as consumo_promedio_litros,
    ROUND(SUM(CASE WHEN t.status = 'completed' THEN t.total_weight_kg END) / 1000.0, 2) as toneladas_transportadas
FROM drivers d
LEFT JOIN trips t ON d.driver_id = t.driver_id
WHERE d.status = 'active'
    AND (t.departure_datetime IS NULL OR t.departure_datetime >= CURRENT_DATE - INTERVAL '6 months')
GROUP BY d.driver_id, d.first_name, d.last_name, d.hire_date
HAVING COUNT(DISTINCT t.trip_id) > 0
ORDER BY tasa_exito_pct DESC, viajes_completados DESC;

-- 📊 QUERY 6: Eficiencia energética por tipo de vehículo
-- 🎯 Problema de negocio: Sostenibilidad y optimización de costos operativos  
-- 📈 Complejidad: Intermedia - Análisis energético con cálculos específicos
-- ⏱️ Tiempo esperado: 40-90ms
SELECT 
    v.vehicle_type as tipo_vehiculo,
    COUNT(DISTINCT v.vehicle_id) as vehiculos_en_categoria,
    COUNT(DISTINCT t.trip_id) as viajes_realizados,
    ROUND(AVG(t.fuel_consumed_liters), 2) as consumo_promedio_viaje,
    ROUND(AVG(t.fuel_consumed_liters / NULLIF(r.distance_km, 0)) * 100, 2) as litros_per_100km,
    ROUND(AVG(t.total_weight_kg), 2) as carga_promedio_kg,
    ROUND(AVG(t.fuel_consumed_liters / NULLIF(t.total_weight_kg, 0)) * 1000, 3) as litros_per_tonelada,
    ROUND(SUM(t.fuel_consumed_liters), 2) as combustible_total_consumido,
    ROUND(SUM(r.distance_km), 2) as kilometros_totales
FROM vehicles v
INNER JOIN trips t ON v.vehicle_id = t.vehicle_id
INNER JOIN routes r ON t.route_id = r.route_id
WHERE t.status = 'completed'
    AND t.fuel_consumed_liters IS NOT NULL
    AND r.distance_km > 0
    AND t.departure_datetime >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY v.vehicle_type
HAVING COUNT(DISTINCT t.trip_id) >= 20
ORDER BY litros_per_100km ASC, litros_per_tonelada ASC;

-- 📊 QUERY 7: Patrones temporales de entregas con análisis de retrasos
-- 🎯 Problema de negocio: Optimización de horarios y mejora de SLA
-- 📈 Complejidad: Intermedia - Análisis temporal con funciones de fecha
-- ⏱️ Tiempo esperado: 60-120ms  
SELECT 
    EXTRACT(DOW FROM d.scheduled_datetime) as dia_semana_num,
    TO_CHAR(d.scheduled_datetime, 'Day') as dia_semana,
    EXTRACT(HOUR FROM d.scheduled_datetime) as hora_programada,
    COUNT(*) as entregas_programadas,
    COUNT(CASE WHEN d.delivery_status = 'delivered' THEN 1 END) as entregas_exitosas,
    COUNT(CASE WHEN d.delivered_datetime IS NOT NULL 
               AND d.delivered_datetime > d.scheduled_datetime + INTERVAL '1 hour' 
               THEN 1 END) as entregas_retrasadas,
    ROUND(COUNT(CASE WHEN d.delivery_status = 'delivered' THEN 1 END) * 100.0 / 
          NULLIF(COUNT(*), 0), 2) as tasa_exito_pct,
    ROUND(COUNT(CASE WHEN d.delivered_datetime IS NOT NULL 
                     AND d.delivered_datetime > d.scheduled_datetime + INTERVAL '1 hour' 
                     THEN 1 END) * 100.0 / 
          NULLIF(COUNT(CASE WHEN d.delivery_status = 'delivered' THEN 1 END), 0), 2) as tasa_retraso_pct,
    ROUND(AVG(CASE WHEN d.delivered_datetime IS NOT NULL 
                   THEN EXTRACT(EPOCH FROM (d.delivered_datetime - d.scheduled_datetime)) / 3600.0 
              END), 2) as diferencia_promedio_horas
FROM deliveries d
WHERE d.scheduled_datetime >= CURRENT_DATE - INTERVAL '60 days'
    AND EXTRACT(HOUR FROM d.scheduled_datetime) BETWEEN 6 AND 22
GROUP BY EXTRACT(DOW FROM d.scheduled_datetime), TO_CHAR(d.scheduled_datetime, 'Day'), 
         EXTRACT(HOUR FROM d.scheduled_datetime)
ORDER BY dia_semana_num, hora_programada;

-- 📊 QUERY 8: Análisis de mantenimiento preventivo vs correctivo
-- 🎯 Problema de negocio: Optimización de costos de mantenimiento y uptime
-- 📈 Complejidad: Intermedia - Análisis de mantenimiento con subconsultas
-- ⏱️ Tiempo esperado: 25-60ms
SELECT 
    v.vehicle_type as tipo_vehiculo,
    v.vehicle_id,
    v.license_plate as placa,
    COUNT(m.maintenance_id) as mantenimientos_totales,
    COUNT(CASE WHEN m.maintenance_type = 'preventive' THEN 1 END) as preventivos,
    COUNT(CASE WHEN m.maintenance_type = 'corrective' THEN 1 END) as correctivos,
    COUNT(CASE WHEN m.maintenance_type = 'emergency' THEN 1 END) as emergencias,
    ROUND(COUNT(CASE WHEN m.maintenance_type = 'preventive' THEN 1 END) * 100.0 / 
          NULLIF(COUNT(m.maintenance_id), 0), 2) as porcentaje_preventivo,
    ROUND(SUM(m.cost), 2) as costo_total_mantenimiento,
    ROUND(AVG(m.cost), 2) as costo_promedio_por_mantenimiento,
    MIN(m.maintenance_date) as primer_mantenimiento,
    MAX(m.maintenance_date) as ultimo_mantenimiento,
    (SELECT COUNT(*) FROM trips t2 WHERE t2.vehicle_id = v.vehicle_id AND t2.status = 'completed') as viajes_completados
FROM vehicles v
LEFT JOIN maintenance m ON v.vehicle_id = m.vehicle_id
WHERE EXISTS (SELECT 1 FROM maintenance m2 WHERE m2.vehicle_id = v.vehicle_id)
GROUP BY v.vehicle_type, v.vehicle_id, v.license_plate
HAVING COUNT(m.maintenance_id) > 0
ORDER BY costo_total_mantenimiento DESC, porcentaje_preventivo DESC;

-- =====================================================
-- 🔴 QUERIES COMPLEJAS (4 queries)
-- Análisis estadísticos avanzados y business intelligence
-- =====================================================

-- 📊 QUERY 9: Análisis integral de rentabilidad por ruta con CTEs
-- 🎯 Problema de negocio: ROI por ruta para toma de decisiones estratégicas
-- 📈 Complejidad: Compleja - CTEs múltiples con análisis financiero avanzado
-- ⏱️ Tiempo esperado: 100-250ms
WITH ruta_metricas AS (
    SELECT 
        r.route_id,
        r.route_code,
        r.origin_city || ' → ' || r.destination_city as ruta_completa,
        r.distance_km,
        r.estimated_duration_hours,
        COUNT(DISTINCT t.trip_id) as viajes_realizados,
        COUNT(DISTINCT d.delivery_id) as entregas_totales,
        SUM(t.fuel_consumed_liters) as combustible_total,
        SUM(t.total_weight_kg) as peso_total_transportado,
        AVG(t.fuel_consumed_liters / NULLIF(r.distance_km, 0)) * 100 as consumo_per_100km,
        COUNT(DISTINCT t.vehicle_id) as vehiculos_utilizados,
        COUNT(DISTINCT t.driver_id) as conductores_involucrados
    FROM routes r
    INNER JOIN trips t ON r.route_id = t.route_id
    INNER JOIN deliveries d ON t.trip_id = d.trip_id
    WHERE t.status = 'completed'
        AND t.departure_datetime >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY r.route_id, r.route_code, r.origin_city, r.destination_city, 
             r.distance_km, r.estimated_duration_hours
),
costos_ruta AS (
    SELECT 
        rm.route_id,
        rm.combustible_total * 1.50 as costo_combustible, -- €1.50 por litro
        rm.viajes_realizados * rm.distance_km * 0.35 as costo_desgaste_vehiculo, -- €0.35 por km
        rm.viajes_realizados * rm.estimated_duration_hours * 15.0 as costo_conductor, -- €15 por hora
        rm.entregas_totales * 8.0 as ingreso_estimado -- €8 por entrega
    FROM ruta_metricas rm
),
rentabilidad_final AS (
    SELECT 
        rm.*,
        cr.costo_combustible,
        cr.costo_desgaste_vehiculo,
        cr.costo_conductor,
        cr.costo_combustible + cr.costo_desgaste_vehiculo + cr.costo_conductor as costo_total,
        cr.ingreso_estimado,
        cr.ingreso_estimado - (cr.costo_combustible + cr.costo_desgaste_vehiculo + cr.costo_conductor) as beneficio_neto
    FROM ruta_metricas rm
    INNER JOIN costos_ruta cr ON rm.route_id = cr.route_id
)
SELECT 
    ruta_completa,
    route_code,
    viajes_realizados,
    entregas_totales,
    ROUND(distance_km, 2) as distancia_km,
    ROUND(peso_total_transportado / 1000.0, 2) as toneladas_transportadas,
    ROUND(consumo_per_100km, 2) as consumo_per_100km,
    ROUND(costo_total, 2) as costo_total_eur,
    ROUND(ingreso_estimado, 2) as ingreso_estimado_eur,
    ROUND(beneficio_neto, 2) as beneficio_neto_eur,
    ROUND(beneficio_neto / NULLIF(costo_total, 0) * 100, 2) as margen_beneficio_pct,
    ROUND(beneficio_neto / NULLIF(viajes_realizados, 0), 2) as beneficio_por_viaje,
    vehiculos_utilizados,
    conductores_involucrados
FROM rentabilidad_final
WHERE viajes_realizados >= 10
ORDER BY margen_beneficio_pct DESC, beneficio_neto DESC;

-- 📊 QUERY 10: Ranking avanzado de conductores con Window Functions
-- 🎯 Problema de negocio: Sistema de evaluación y bonificaciones por performance
-- 📈 Complejidad: Compleja - Window Functions avanzadas con ranking multidimensional
-- ⏱️ Tiempo esperado: 150-300ms
WITH metricas_conductor AS (
    SELECT 
        d.driver_id,
        d.first_name || ' ' || d.last_name as conductor,
        d.hire_date,
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, d.hire_date)) as anos_experiencia,
        COUNT(DISTINCT t.trip_id) as total_viajes,
        COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.trip_id END) as viajes_exitosos,
        COUNT(DISTINCT CASE WHEN t.status = 'cancelled' THEN t.trip_id END) as viajes_cancelados,
        COUNT(DISTINCT del.delivery_id) as entregas_realizadas,
        COUNT(CASE WHEN del.delivered_datetime <= del.scheduled_datetime + INTERVAL '30 minutes' 
                   THEN 1 END) as entregas_puntuales,
        ROUND(AVG(t.fuel_consumed_liters / NULLIF(r.distance_km, 0)) * 100, 2) as eficiencia_combustible,
        ROUND(SUM(t.total_weight_kg) / 1000.0, 2) as toneladas_transportadas,
        ROUND(AVG(EXTRACT(EPOCH FROM (t.arrival_datetime - t.departure_datetime)) / 3600.0), 2) as tiempo_promedio_viaje_horas
    FROM drivers d
    INNER JOIN trips t ON d.driver_id = t.driver_id
    INNER JOIN routes r ON t.route_id = r.route_id
    LEFT JOIN deliveries del ON t.trip_id = del.trip_id
    WHERE d.status = 'active'
        AND t.departure_datetime >= CURRENT_DATE - INTERVAL '6 months'
        AND t.status IN ('completed', 'cancelled')
    GROUP BY d.driver_id, d.first_name, d.last_name, d.hire_date
    HAVING COUNT(DISTINCT t.trip_id) >= 25
),
rankings_conductor AS (
    SELECT 
        *,
        ROUND(viajes_exitosos * 100.0 / NULLIF(total_viajes, 0), 2) as tasa_exito,
        ROUND(entregas_puntuales * 100.0 / NULLIF(entregas_realizadas, 0), 2) as tasa_puntualidad,
        RANK() OVER (ORDER BY viajes_exitosos * 100.0 / NULLIF(total_viajes, 0) DESC) as rank_exito,
        RANK() OVER (ORDER BY entregas_puntuales * 100.0 / NULLIF(entregas_realizadas, 0) DESC) as rank_puntualidad,
        RANK() OVER (ORDER BY eficiencia_combustible ASC) as rank_eficiencia,
        RANK() OVER (ORDER BY toneladas_transportadas DESC) as rank_productividad,
        PERCENTILE_RANK() OVER (ORDER BY viajes_exitosos * 100.0 / NULLIF(total_viajes, 0)) as percentil_exito,
        LAG(viajes_exitosos) OVER (ORDER BY viajes_exitosos DESC) as viajes_exitosos_anterior,
        LEAD(viajes_exitosos) OVER (ORDER BY viajes_exitosos DESC) as viajes_exitosos_siguiente
    FROM metricas_conductor
)
SELECT 
    conductor,
    anos_experiencia,
    total_viajes,
    viajes_exitosos,
    entregas_realizadas,
    tasa_exito,
    tasa_puntualidad,
    eficiencia_combustible,
    toneladas_transportadas,
    tiempo_promedio_viaje_horas,
    rank_exito,
    rank_puntualidad,
    rank_eficiencia,
    rank_productividad,
    ROUND((rank_exito + rank_puntualidad + rank_eficiencia + rank_productividad) / 4.0, 1) as score_promedio_ranking,
    ROUND(percentil_exito * 100, 1) as percentil_exito_pct,
    CASE 
        WHEN percentil_exito >= 0.9 THEN '⭐⭐⭐ EXCELENTE'
        WHEN percentil_exito >= 0.75 THEN '⭐⭐ MUY BUENO'
        WHEN percentil_exito >= 0.5 THEN '⭐ BUENO'
        ELSE 'NECESITA MEJORA'
    END as categoria_performance
FROM rankings_conductor
ORDER BY score_promedio_ranking ASC, tasa_exito DESC
LIMIT 30;

-- 📊 QUERY 11: Análisis de tendencias temporales con series de tiempo
-- 🎯 Problema de negocio: Forecasting y planificación estratégica basada en datos
-- 📈 Complejidad: Compleja - Series temporales con LAG/LEAD y análisis estadístico
-- ⏱️ Tiempo esperado: 80-180ms
WITH series_mensual AS (
    SELECT 
        DATE_TRUNC('month', t.departure_datetime) as mes,
        COUNT(DISTINCT t.trip_id) as viajes_mes,
        COUNT(DISTINCT d.delivery_id) as entregas_mes,
        ROUND(SUM(t.fuel_consumed_liters), 2) as combustible_mes,
        ROUND(SUM(t.total_weight_kg) / 1000.0, 2) as toneladas_mes,
        COUNT(DISTINCT t.vehicle_id) as vehiculos_activos,
        COUNT(DISTINCT t.driver_id) as conductores_activos,
        ROUND(AVG(EXTRACT(EPOCH FROM (t.arrival_datetime - t.departure_datetime)) / 3600.0), 2) as duracion_promedio_horas
    FROM trips t
    INNER JOIN deliveries d ON t.trip_id = d.trip_id
    WHERE t.status = 'completed'
        AND t.departure_datetime >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '24 months')
    GROUP BY DATE_TRUNC('month', t.departure_datetime)
),
tendencias_calculadas AS (
    SELECT 
        mes,
        TO_CHAR(mes, 'YYYY-MM') as periodo,
        viajes_mes,
        entregas_mes,
        combustible_mes,
        toneladas_mes,
        vehiculos_activos,
        conductores_activos,
        duracion_promedio_horas,
        LAG(viajes_mes, 1) OVER (ORDER BY mes) as viajes_mes_anterior,
        LAG(viajes_mes, 12) OVER (ORDER BY mes) as viajes_mismo_mes_ano_anterior,
        LEAD(viajes_mes, 1) OVER (ORDER BY mes) as viajes_mes_siguiente,
        AVG(viajes_mes) OVER (ORDER BY mes ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as media_movil_3m,
        AVG(viajes_mes) OVER (ORDER BY mes ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) as media_movil_6m,
        STDDEV(viajes_mes) OVER (ORDER BY mes ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) as desviacion_12m
    FROM series_mensual
)
SELECT 
    periodo,
    viajes_mes,
    entregas_mes,
    combustible_mes,
    toneladas_mes,
    vehiculos_activos,
    conductores_activos,
    duracion_promedio_horas,
    viajes_mes - viajes_mes_anterior as variacion_mensual,
    ROUND((viajes_mes - viajes_mes_anterior) * 100.0 / NULLIF(viajes_mes_anterior, 0), 2) as variacion_mensual_pct,
    viajes_mes - viajes_mismo_mes_ano_anterior as variacion_anual,
    ROUND((viajes_mes - viajes_mismo_mes_ano_anterior) * 100.0 / NULLIF(viajes_mismo_mes_ano_anterior, 0), 2) as variacion_anual_pct,
    ROUND(media_movil_3m, 1) as tendencia_3_meses,
    ROUND(media_movil_6m, 1) as tendencia_6_meses,
    ROUND(desviacion_12m, 2) as volatilidad_12m,
    CASE 
        WHEN viajes_mes > media_movil_6m + desviacion_12m THEN '📈 PICO ALTO'
        WHEN viajes_mes < media_movil_6m - desviacion_12m THEN '📉 VALLE BAJO'
        WHEN viajes_mes > media_movil_3m THEN '↗️ CRECIENDO'
        WHEN viajes_mes < media_movil_3m THEN '↘️ DECRECIENDO'
        ELSE '➡️ ESTABLE'
    END as tendencia_clasificacion
FROM tendencias_calculadas
WHERE viajes_mes_anterior IS NOT NULL
ORDER BY mes DESC
LIMIT 18;

-- 📊 QUERY 12: Matriz de análisis de entregas por segmentación temporal (PIVOT avanzado)
-- 🎯 Problema de negocio: Optimización de recursos y planificación de turnos
-- 📈 Complejidad: Compleja - Pivot dinámico con análisis multidimensional
-- ⏱️ Tiempo esperado: 120-250ms
WITH base_entregas AS (
    SELECT 
        d.delivery_id,
        d.scheduled_datetime,
        d.delivered_datetime,
        d.delivery_status,
        EXTRACT(DOW FROM d.scheduled_datetime) as dia_semana,
        EXTRACT(HOUR FROM d.scheduled_datetime) as hora,
        CASE 
            WHEN EXTRACT(HOUR FROM d.scheduled_datetime) BETWEEN 6 AND 11 THEN 'Mañana'
            WHEN EXTRACT(HOUR FROM d.scheduled_datetime) BETWEEN 12 AND 17 THEN 'Tarde'
            WHEN EXTRACT(HOUR FROM d.scheduled_datetime) BETWEEN 18 AND 21 THEN 'Noche'
            ELSE 'Madrugada'
        END as periodo_dia,
        CASE
            WHEN d.delivered_datetime IS NOT NULL 
                 AND d.delivered_datetime <= d.scheduled_datetime + INTERVAL '30 minutes' THEN 'Puntual'
            WHEN d.delivered_datetime IS NOT NULL 
                 AND d.delivered_datetime > d.scheduled_datetime + INTERVAL '30 minutes' THEN 'Retrasada'
            WHEN d.delivery_status = 'delivered' AND d.delivered_datetime IS NULL THEN 'Sin timestamp'
            ELSE 'No entregada'
        END as clasificacion_entrega,
        d.package_weight_kg
    FROM deliveries d
    WHERE d.scheduled_datetime >= CURRENT_DATE - INTERVAL '90 days'
        AND EXTRACT(HOUR FROM d.scheduled_datetime) BETWEEN 6 AND 22
),
matriz_pivot AS (
    SELECT 
        hora,
        periodo_dia,
        -- Columnas por día de la semana (0=Domingo, 6=Sábado)
        COUNT(CASE WHEN dia_semana = 1 THEN 1 END) as lunes_total,
        COUNT(CASE WHEN dia_semana = 1 AND clasificacion_entrega = 'Puntual' THEN 1 END) as lunes_puntuales,
        COUNT(CASE WHEN dia_semana = 2 THEN 1 END) as martes_total,
        COUNT(CASE WHEN dia_semana = 2 AND clasificacion_entrega = 'Puntual' THEN 1 END) as martes_puntuales,
        COUNT(CASE WHEN dia_semana = 3 THEN 1 END) as miercoles_total,
        COUNT(CASE WHEN dia_semana = 3 AND clasificacion_entrega = 'Puntual' THEN 1 END) as miercoles_puntuales,
        COUNT(CASE WHEN dia_semana = 4 THEN 1 END) as jueves_total,
        COUNT(CASE WHEN dia_semana = 4 AND clasificacion_entrega = 'Puntual' THEN 1 END) as jueves_puntuales,
        COUNT(CASE WHEN dia_semana = 5 THEN 1 END) as viernes_total,
        COUNT(CASE WHEN dia_semana = 5 AND clasificacion_entrega = 'Puntual' THEN 1 END) as viernes_puntuales,
        COUNT(CASE WHEN dia_semana = 6 THEN 1 END) as sabado_total,
        COUNT(CASE WHEN dia_semana = 6 AND clasificacion_entrega = 'Puntual' THEN 1 END) as sabado_puntuales,
        COUNT(*) as total_entregas_hora,
        COUNT(CASE WHEN clasificacion_entrega = 'Puntual' THEN 1 END) as total_puntuales_hora,
        ROUND(AVG(package_weight_kg), 2) as peso_promedio_hora
    FROM base_entregas
    GROUP BY hora, periodo_dia
)
SELECT 
    LPAD(hora::text, 2, '0') || ':00' as franja_horaria,
    periodo_dia,
    lunes_total as L_total,
    ROUND(lunes_puntuales * 100.0 / NULLIF(lunes_total, 0), 1) as L_puntualidad,
    martes_total as M_total,
    ROUND(martes_puntuales * 100.0 / NULLIF(martes_total, 0), 1) as M_puntualidad,
    miercoles_total as X_total,
    ROUND(miercoles_puntuales * 100.0 / NULLIF(miercoles_total, 0), 1) as X_puntualidad,
    jueves_total as J_total,
    ROUND(jueves_puntuales * 100.0 / NULLIF(jueves_total, 0), 1) as J_puntualidad,
    viernes_total as V_total,
    ROUND(viernes_puntuales * 100.0 / NULLIF(viernes_total, 0), 1) as V_puntualidad,
    sabado_total as S_total,
    ROUND(sabado_puntuales * 100.0 / NULLIF(sabado_total, 0), 1) as S_puntualidad,
    total_entregas_hora,
    ROUND(total_puntuales_hora * 100.0 / NULLIF(total_entregas_hora, 0), 1) as puntualidad_promedio,
    peso_promedio_hora,
    CASE 
        WHEN total_entregas_hora >= 200 THEN '🔥 ALTA DEMANDA'
        WHEN total_entregas_hora >= 100 THEN '🟡 DEMANDA MEDIA'
        WHEN total_entregas_hora >= 50 THEN '🟢 DEMANDA BAJA'
        ELSE '⚪ DEMANDA MÍNIMA'
    END as clasificacion_demanda
FROM matriz_pivot
WHERE total_entregas_hora > 0
ORDER BY hora;

-- =====================================================
-- 🔬 INSTRUCCIONES PARA ANÁLISIS DE PERFORMANCE
-- =====================================================
/*
METODOLOGÍA DE MEDICIÓN:

1. BASELINE (Sin índices):
   - Ejecutar: EXPLAIN ANALYZE [QUERY];
   - Registrar: Total runtime, Planning time, Execution time
   - Documentar: Operaciones costosas (Seq Scan, Sort, etc.)

2. POST-OPTIMIZACIÓN (Con índices):
   - Aplicar índices del archivo 03_optimization_indexes.sql
   - Re-ejecutar: EXPLAIN ANALYZE [QUERY];
   - Medir mejora: % reducción de tiempo

3. MÉTRICAS OBJETIVO:
   - Básicas: <20ms
   - Intermedias: <100ms  
   - Complejas: <300ms

COMANDO PARA MEDICIÓN AUTOMATIZADA:
\timing on
-- Ejecutar cada query 3 veces y promediar resultados
*/
