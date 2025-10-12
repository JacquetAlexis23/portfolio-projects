# FleetLogix Database - Diagrama ER Profesional

## Esquema Completo del Sistema de Gestión de Flotas

erDiagram
    VEHICLES {
        int vehicle_id PK
        varchar license_plate UK
        varchar vehicle_type
        decimal capacity_kg
        varchar fuel_type
        date acquisition_date
        varchar status
    }

    DRIVERS {
        int driver_id PK
        varchar employee_code UK
        varchar first_name
        varchar last_name
        varchar license_number UK
        date license_expiry
        varchar phone
        date hire_date
        varchar status
    }

    ROUTES {
        int route_id PK
        varchar route_code UK
        varchar origin_city
        varchar destination_city
        decimal distance_km
        decimal estimated_duration_hours
        decimal toll_cost
    }

    TRIPS {
        int trip_id PK
        int vehicle_id FK
        int driver_id FK
        int route_id FK
        timestamp departure_datetime
        timestamp arrival_datetime
        decimal fuel_consumed_liters
        decimal total_weight_kg
        varchar status
    }

    DELIVERIES {
        int delivery_id PK
        int trip_id FK
        varchar tracking_number UK
        varchar customer_name
        text delivery_address
        decimal package_weight_kg
        timestamp scheduled_datetime
        timestamp delivered_datetime
        varchar delivery_status
        boolean recipient_signature
    }

    MAINTENANCE {
        int maintenance_id PK
        int vehicle_id FK
        date maintenance_date
        varchar maintenance_type
        text description
        decimal cost
        date next_maintenance_date
        varchar performed_by
    }

    VEHICLES ||--o{ TRIPS : operates
    DRIVERS ||--o{ TRIPS : conducts
    ROUTES ||--o{ TRIPS : follows
    TRIPS ||--o{ DELIVERIES : contains
    VEHICLES ||--o{ MAINTENANCE : requires


## Descripción de Relaciones

- **VEHICLES → TRIPS**: Un vehículo puede operar múltiples viajes (1:N)
- **DRIVERS → TRIPS**: Un conductor puede realizar múltiples viajes (1:N)
- **ROUTES → TRIPS**: Una ruta puede ser seguida en múltiples viajes (1:N)
- **TRIPS → DELIVERIES**: Un viaje puede contener múltiples entregas (1:N, típicamente 2-6)
- **VEHICLES → MAINTENANCE**: Un vehículo puede tener múltiples registros de mantenimiento (1:N)

## Características del Modelo

### Entidades Principales
1. **VEHICLES**: Gestión de la flota de vehículos
2. **DRIVERS**: Control de conductores y licencias
3. **ROUTES**: Definición de rutas comerciales
4. **TRIPS**: Tabla central que conecta vehículos, conductores y rutas
5. **DELIVERIES**: Gestión detallada de entregas por viaje
6. **MAINTENANCE**: Historial de mantenimiento vehicular

### Constraints Implementados
- **Primary Keys (PK)**: Identificadores únicos para cada entidad
- **Foreign Keys (FK)**: Integridad referencial entre tablas
- **Unique Keys (UK)**: Campos únicos como placas y códigos
- **NOT NULL**: Campos obligatorios para integridad de datos
- **DEFAULT Values**: Valores por defecto para estados y costos