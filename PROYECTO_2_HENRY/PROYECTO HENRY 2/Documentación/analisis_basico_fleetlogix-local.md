# FleetLogix - Documentación del Modelo Relacional
**Sistema de Gestión de Transporte y Logística**

## Resumen Ejecutivo
Este documento presenta el análisis profesional del modelo relacional FleetLogix, diseñado para gestionar operaciones de transporte y logística. El modelo está compuesto por 6 entidades interrelacionadas que capturan el ciclo completo desde la gestión de flota hasta la entrega final de paquetes.

## Arquitectura del Modelo

### Entidades Principales
El modelo sigue una arquitectura estrella modificada con `trips` como tabla de hechos central, conectando las dimensiones de vehículos, conductores y rutas, mientras extiende hacia deliveries y maintenance como tablas dependientes.

## Especificación Detallada de Entidades

### 1. VEHICLES (Gestión de Flota)
**Propósito**: Registro maestro de vehículos de la flota FleetLogix
```sql
CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL,
    capacity_kg DECIMAL(10,2),
    fuel_type VARCHAR(20),
    acquisition_date DATE,
    status VARCHAR(20) DEFAULT 'active'
);
```

**Análisis de Constraints**:
- **PK**: `vehicle_id` (SERIAL) - Identificador único autogenerado
- **UNIQUE**: `license_plate` - Garantiza unicidad de placas vehiculares
- **NOT NULL**: `license_plate`, `vehicle_type` - Campos críticos para identificación
- **Business Rules**: `status` permite seguimiento del ciclo de vida vehicular

**Índices Optimizados**:
- `idx_vehicles_status` - Facilita consultas por estado operativo
- **Recomendación**: Agregar índice en `vehicle_type` para análisis de flota por categoría

### 2. DRIVERS (Recursos Humanos)
**Propósito**: Gestión de conductores y licencias de manejo
```sql
CREATE TABLE drivers (
    driver_id SERIAL PRIMARY KEY,
    employee_code VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    license_number VARCHAR(50) UNIQUE NOT NULL,
    license_expiry DATE,
    phone VARCHAR(20),
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'active'
);
```

**Análisis de Constraints**:
- **PK**: `driver_id` (SERIAL)
- **UNIQUE**: `employee_code`, `license_number` - Doble validación de identificación
- **NOT NULL**: Campos esenciales para identificación legal del conductor
- **Data Quality**: `license_expiry` crítico para compliance regulatorio

### 3. ROUTES (Rutas Predefinidas)
**Propósito**: Catálogo de rutas operativas con métricas logísticas
```sql
CREATE TABLE routes (
    route_id SERIAL PRIMARY KEY,
    route_code VARCHAR(20) UNIQUE NOT NULL,
    origin_city VARCHAR(100) NOT NULL,
    destination_city VARCHAR(100) NOT NULL,
    distance_km DECIMAL(10,2),
    estimated_duration_hours DECIMAL(5,2),
    toll_cost DECIMAL(10,2) DEFAULT 0
);
```

**Análisis de Constraints**:
- **PK**: `route_id` (SERIAL)
- **UNIQUE**: `route_code` - Codificación estándar de rutas
- **NOT NULL**: `origin_city`, `destination_city` - Puntos geográficos obligatorios
- **Business Intelligence**: Campos métricos para análisis de costos y planificación

### 4. TRIPS (Tabla de Hechos Central)
**Propósito**: Registro transaccional de viajes ejecutados
```sql
CREATE TABLE trips (
    trip_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER REFERENCES vehicles(vehicle_id),
    driver_id INTEGER REFERENCES drivers(driver_id),
    route_id INTEGER REFERENCES routes(route_id),
    departure_datetime TIMESTAMP NOT NULL,
    arrival_datetime TIMESTAMP,
    fuel_consumed_liters DECIMAL(10,2),
    total_weight_kg DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'in_progress'
);
```

**Análisis de Relaciones**:
- **FK**: `vehicle_id`, `driver_id`, `route_id` - Triple referencia dimensional
- **Temporal**: `departure_datetime` NOT NULL, `arrival_datetime` nullable (viajes en curso)
- **Métricas**: Campos de consumo y carga para análisis operativo
- **Índice Estratégico**: `idx_trips_departure` optimiza consultas temporales

### 5. DELIVERIES (Gestión de Entregas)
**Propósito**: Tracking granular de paquetes por viaje
```sql
CREATE TABLE deliveries (
    delivery_id SERIAL PRIMARY KEY,
    trip_id INTEGER REFERENCES trips(trip_id),
    tracking_number VARCHAR(50) UNIQUE NOT NULL,
    customer_name VARCHAR(200) NOT NULL,
    delivery_address TEXT NOT NULL,
    package_weight_kg DECIMAL(10,2),
    scheduled_datetime TIMESTAMP,
    delivered_datetime TIMESTAMP,
    delivery_status VARCHAR(20) DEFAULT 'pending',
    recipient_signature BOOLEAN DEFAULT FALSE
);
```

**Análisis de Constraints**:
- **FK**: `trip_id` - Relación 1:N con trips
- **UNIQUE**: `tracking_number` - Trazabilidad única global
- **Flujo de Estados**: `delivery_status` con índice `idx_deliveries_status`
- **SLA Tracking**: Campos temporales para métricas de cumplimiento

### 6. MAINTENANCE (Gestión de Mantenimiento)
**Propósito**: Historial y programación de mantenimiento vehicular
```sql
CREATE TABLE maintenance (
    maintenance_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER REFERENCES vehicles(vehicle_id),
    maintenance_date DATE NOT NULL,
    maintenance_type VARCHAR(50) NOT NULL,
    description TEXT,
    cost DECIMAL(10,2),
    next_maintenance_date DATE,
    performed_by VARCHAR(200)
);
```

**Análisis de Constraints**:
- **FK**: `vehicle_id` - Relación 1:N con vehicles
- **NOT NULL**: `maintenance_date`, `maintenance_type` - Campos críticos para auditoría
- **Predictive**: `next_maintenance_date` para mantenimiento preventivo

## Análisis de Cardinalidades y Relaciones

### Mapa de Relaciones Empresariales
```
VEHICLES (1) ----< TRIPS (N) >---- (1) DRIVERS
    |                |                   
    |                |                   
    v                v                   
MAINTENANCE (N)   DELIVERIES (N)       
                     |
                     v
                 ROUTES (1) ----< TRIPS (N)
```

### Cardinalidades Detalladas

**1. VEHICLES → TRIPS (1:N)**
- **Relación**: Un vehículo puede realizar múltiples viajes a lo largo del tiempo
- **Constraint**: `trips.vehicle_id REFERENCES vehicles.vehicle_id`
- **Business Rule**: Un trip activo no puede compartir vehículo simultáneamente
- **Análisis**: Permite tracking de utilización vehicular y métricas de eficiencia

**2. DRIVERS → TRIPS (1:N)**
- **Relación**: Un conductor puede realizar múltiples viajes
- **Constraint**: `trips.driver_id REFERENCES drivers.driver_id`
- **Business Rule**: Un conductor no puede tener trips simultáneos (constraint lógico)
- **Compliance**: Validación de vigencia de licencia vs. fecha del trip

**3. ROUTES → TRIPS (1:N)**
- **Relación**: Una ruta predefinida puede ser utilizada en múltiples viajes
- **Constraint**: `trips.route_id REFERENCES routes.route_id`
- **Optimización**: Permite análisis de frecuencia y rentabilidad por ruta
- **Planning**: Facilita asignación de recursos basada en rutas históricas

**4. TRIPS → DELIVERIES (1:N)**
- **Relación**: Cada viaje contiene múltiples entregas (2-6 según especificación)
- **Constraint**: `deliveries.trip_id REFERENCES trips.trip_id`
- **Business Rule**: Mínimo 2, máximo 6 deliveries por trip
- **SLA**: `scheduled_datetime` y `delivered_datetime` deben estar dentro del window del trip

**5. VEHICLES → MAINTENANCE (1:N)**
- **Relación**: Un vehículo tiene múltiples eventos de mantenimiento
- **Constraint**: `maintenance.vehicle_id REFERENCES vehicles.vehicle_id`
- **Predictive**: `next_maintenance_date` permite mantenimiento preventivo
- **Cost Control**: Tracking de costos de mantenimiento por vehículo

## Análisis de Integridad Referencial

### Constraints Críticos
1. **Integridad de Claves Primarias**: Todas las PKs son SERIAL (autoincrement) garantizando unicidad
2. **Integridad Referencial**: FKs implementadas correctamente sin ON DELETE especificado
3. **Unicidad Empresarial**: 
   - `vehicles.license_plate` - Identificación legal única
   - `drivers.employee_code` + `license_number` - Doble validación de conductor
   - `routes.route_code` - Codificación estándar
   - `deliveries.tracking_number` - Trazabilidad global

### Validaciones Temporales Requeridas
```sql
-- Constraint recomendado para trips
ALTER TABLE trips ADD CONSTRAINT chk_arrival_after_departure 
CHECK (arrival_datetime IS NULL OR arrival_datetime >= departure_datetime);

-- Constraint recomendado para deliveries  
ALTER TABLE deliveries ADD CONSTRAINT chk_delivery_window
CHECK (delivered_datetime IS NULL OR 
       (delivered_datetime >= scheduled_datetime AND 
        delivered_datetime <= (SELECT arrival_datetime FROM trips WHERE trips.trip_id = deliveries.trip_id)));
```

## Estrategia de Índices y Optimización

### Índices Existentes
- `idx_trips_departure` - Optimiza consultas temporales y reportes de actividad
- `idx_deliveries_status` - Facilita monitoring de estados de entrega
- `idx_vehicles_status` - Permite filtrado rápido por estado operativo

### Índices Recomendados para Producción
```sql
-- Optimización para reportes de conductor
CREATE INDEX idx_trips_driver_departure ON trips(driver_id, departure_datetime);

-- Optimización para análisis de rutas
CREATE INDEX idx_trips_route_departure ON trips(route_id, departure_datetime);

-- Optimización para tracking de deliveries
CREATE INDEX idx_deliveries_tracking ON deliveries(tracking_number);

-- Optimización para mantenimiento preventivo
CREATE INDEX idx_maintenance_vehicle_next ON maintenance(vehicle_id, next_maintenance_date);

-- Índice compuesto para análisis de performance
CREATE INDEX idx_trips_performance ON trips(vehicle_id, departure_datetime, status);
```

## Recomendaciones de Modelado Avanzado

### 1. Gestión de Estados
**Implementar máquinas de estado para**:
- `vehicles.status`: 'active' → 'maintenance' → 'inactive' → 'retired'
- `trips.status`: 'planned' → 'in_progress' → 'completed' → 'cancelled'
- `deliveries.delivery_status`: 'pending' → 'in_transit' → 'delivered' → 'failed'

### 2. Auditoría y Trazabilidad
```sql
-- Agregar campos de auditoría a todas las tablas
ALTER TABLE trips ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE trips ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE trips ADD COLUMN created_by VARCHAR(100);
```

### 3. Particionamiento por Rendimiento
Para tablas de alto volumen (`trips`, `deliveries`):
```sql
-- Particionamiento por mes en trips
CREATE TABLE trips_202501 PARTITION OF trips 
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

### 4. Constraints de Negocio Adicionales
```sql
-- Validación de capacidad vehicular
ALTER TABLE trips ADD CONSTRAINT chk_weight_capacity
CHECK (total_weight_kg <= (SELECT capacity_kg FROM vehicles WHERE vehicles.vehicle_id = trips.vehicle_id));

-- Validación de peso de paquetes vs trip total
ALTER TABLE deliveries ADD CONSTRAINT chk_package_weight 
CHECK (package_weight_kg >= 0);
```

## Métricas y KPIs Derivados

### Métricas Operacionales
- **Utilización de Flota**: trips por vehículo por período
- **Eficiencia de Conductores**: trips completados vs. horas trabajadas
- **Performance de Rutas**: tiempo real vs. estimado, costos de combustible
- **SLA de Entregas**: % entregas a tiempo vs. scheduled_datetime

### Queries de Análisis Típicos
```sql
-- Utilización de vehículos por mes
SELECT v.license_plate, COUNT(t.trip_id) as total_trips,
       AVG(t.fuel_consumed_liters) as avg_fuel
FROM vehicles v
LEFT JOIN trips t ON v.vehicle_id = t.vehicle_id
WHERE t.departure_datetime >= '2024-01-01'
GROUP BY v.vehicle_id, v.license_plate;

-- Performance de entregas por conductor
SELECT d.first_name || ' ' || d.last_name as driver_name,
       COUNT(del.delivery_id) as total_deliveries,
       AVG(EXTRACT(EPOCH FROM (del.delivered_datetime - del.scheduled_datetime))/3600) as avg_delay_hours
FROM drivers d
JOIN trips t ON d.driver_id = t.driver_id  
JOIN deliveries del ON t.trip_id = del.trip_id
WHERE del.delivered_datetime IS NOT NULL
GROUP BY d.driver_id, driver_name;
```

---
**Documento generado por**: Análisis de Científico de Datos y Experto en SQL  
**Fecha**: 19 de septiembre de 2025  
**Versión**: 2.0 - Documentación Profesional FleetLogix
