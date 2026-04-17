# DOCUMENTACIÓN TÉCNICA DEL PROYECTO
## Dashboard Interactivo de Ventas - TechCore
### Analista: Jacquet Alexis | DataVision Analytics

---

## RESUMEN EJECUTIVO

Este documento presenta la documentación completa del proyecto de análisis de datos desarrollado para **TechCore**, una cadena minorista especializada en computadores y accesorios tecnológicos. El proyecto abarcó tres fases principales: limpieza y transformación de datos, modelado relacional, y desarrollo de dashboard interactivo con seguridad a nivel de fila (RLS).

### Alcance del Proyecto
- **Registros procesados:** 30,000 facturas
- **Período analizado:** Septiembre 2014 - Septiembre 2025 (11 años)
- **Cobertura geográfica:** 4 ciudades (Bogotá, Cali, Medellín, Pereira)
- **Red comercial:** 6 sucursales
- **Catálogo:** 44 productos de 12 marcas diferentes

---

## FASE 1: LIMPIEZA Y TRANSFORMACIÓN DE DATOS

### Objetivo
Importar, limpiar y preparar la base de datos cruda de facturación en Power BI, dejándola lista para análisis posterior.

### Procesos Implementados

#### 1.1 Estandarización de Estructura
- **Renombrado de columnas:** Se uniformaron nombres siguiendo convención PascalCase
- **Conversión de tipos de datos:**
  - Fechas: Convertidas a formato `Date`
  - Precios: Convertidos a `Decimal Number`
  - Identificadores: Convertidos a `Text`
  - Cantidades: Convertidas a `Whole Number`

#### 1.2 Calidad de Datos
- **Duplicados eliminados:** Se removieron facturas exactamente iguales
- **Valores nulos tratados:**
  - Campos categóricos: Reemplazados por "No especificado"
  - Campos numéricos: Imputados con cero cuando fue apropiado
- **Normalización de categorías:**
  - Unificación de variaciones ortográficas ("medellin" → "Medellín")
  - Estandarización de nombres de productos y marcas

#### 1.3 Columnas Derivadas
- Extracción de componentes temporales:
  - `Año`: Año de la fecha de venta
  - `Mes`: Mes de la fecha de venta
  - `Trimestre`: Trimestre correspondiente
  - `Día`: Día del mes

### Resultados
- **Archivo generado:** `ventasTransformed.csv`
- **Registros limpios:** 30,000 facturas validadas
- **Calidad de datos:** 100% de registros consistentes

---

## FASE 2: MODELADO RELACIONAL

### Objetivo
Diseñar e implementar un modelo relacional que integre información de ventas con entidades del negocio (productos, clientes, sucursales, vendedores).

### Arquitectura del Modelo

#### 2.1 Tablas Dimensionales

**Ciudades**
- `CiudadID` (PK): Identificador único de ciudad
- `NombreCiudad`: Nombre de la ciudad
- **Registros:** 4 ciudades

**Sucursales**
- `SucursalID` (PK): Identificador único de sucursal
- `NombreSucursal`: Nombre de la sucursal
- `CiudadID` (FK → Ciudades): Ciudad donde se ubica
- **Registros:** 6 sucursales

**Vendedores**
- `VendedorID` (PK): Identificador único del vendedor
- `NombreVendedor`: Nombre completo del vendedor
- **Registros:** 10 vendedores

**Clientes**
- `ClienteID` (PK): Identificador único del cliente
- `NombreCliente`: Nombre completo
- `Genero`: Género del cliente
- `Edad`: Edad del cliente
- `Telefono`: Teléfono de contacto
- `Email`: Correo electrónico
- `Direccion`: Dirección física
- **Registros:** 17,453 clientes únicos

**Productos**
- `ProductoID` (PK): Identificador único del producto
- `NombreProducto`: Nombre completo del producto
- `Marca`: Marca del fabricante
- `PrecioUnitario`: Precio base del producto
- **Registros:** 44 productos de 12 marcas

**Calendario**
- `CalendarioID` (PK): Identificador único de fecha
- `Date`: Fecha completa
- `Año`: Año
- `Trimestre`: Trimestre (Q1-Q4)
- `Mes`: Nombre del mes
- `MesNum`: Número del mes (1-12)
- `Día`: Día del mes
- `AñoMes`: Formato Año-Mes para análisis
- `NombreMes`: Nombre completo del mes en español
- **Registros:** 4,018 fechas únicas

#### 2.2 Tablas de Hechos

**Facturas**
- `FacturaID` (PK): Identificador único de factura
- `Fecha`: Fecha de la transacción
- `Año`, `Trimestre`, `Mes`, `Dia`: Componentes temporales
- `HoraVenta`: Hora de la transacción
- `SucursalID` (FK → Sucursales): Sucursal donde se realizó la venta
- `ClienteID` (FK → Clientes): Cliente que realizó la compra
- `VendedorID` (FK → Vendedores): Vendedor que atendió
- `CalendarioID` (FK → Calendario): Referencia a dimensión temporal
- `MetodoPago`: Forma de pago utilizada
- `TotalVenta`: Monto total de la factura
- **Registros:** 30,000 facturas

**DetalleFacturas**
- `DetalleID` (PK): Identificador único del detalle
- `FacturaID` (FK → Facturas): Factura asociada
- `ProductoID` (FK → Productos): Producto vendido
- `Cantidad`: Unidades vendidas
- `Descuento`: Descuento aplicado (%)
- `Subtotal`: Monto del producto en la factura
- **Registros:** 60,059 líneas de detalle

#### 2.3 Relaciones y Cardinalidad

```
Ciudades (1) ──────────< (N) Sucursales
Sucursales (1) ────────< (N) Facturas
Vendedores (1) ────────< (N) Facturas
Clientes (1) ──────────< (N) Facturas
Calendario (1) ────────< (N) Facturas
Facturas (1) ──────────< (N) DetalleFacturas
Productos (1) ─────────< (N) DetalleFacturas
```

**Integridad Referencial:**
- ✅ Todas las claves foráneas validadas
- ✅ No existen registros huérfanos
- ✅ Todas las relaciones Many-to-One correctamente definidas

### Validaciones Implementadas

**Control de Calidad:**
- Verificación de claves primarias únicas
- Validación de claves foráneas existentes
- Comprobación de valores no nulos en campos críticos
- Verificación de rangos de valores (precios > 0, cantidades > 0)

**Reportes Exploratorios:**
- Total de ventas por marca
- Top 10 productos más vendidos
- Distribución de ventas por ciudad
- Análisis de métodos de pago

### Resultados
- **Archivo generado:** `modeloVentas.xlsx` (8 hojas con todas las tablas)
- **Documento:** `Avance_2_Modelo_Relacional.ipynb` (proceso completo documentado)
- **Diagrama ER:** Incluido en el notebook con todas las relaciones visualizadas

---

## FASE 3: DASHBOARD INTERACTIVO

### Objetivo
Desarrollar un dashboard interactivo en Power BI que transforme los datos en información estratégica para la toma de decisiones.

### 3.1 Medidas DAX Implementadas

#### Medidas Básicas
```dax
VentasTotales = SUM(Facturas[TotalVenta])
TicketPromedio = AVERAGE(Facturas[TotalVenta])
TotalCantidadVendida = SUM(DetalleFacturas[Cantidad])
TotalSubtotalProductos = SUM(DetalleFacturas[Subtotal])
```

#### Medidas de Análisis
```dax
CrecimientoMensual = 
VAR VentasActual = [VentasTotales]
VAR VentasAnterior =
    CALCULATE(
        [VentasTotales],
        DATEADD(Calendario[Date], -1, MONTH)
    )
RETURN
    IF(
        ISBLANK(VentasAnterior),
        BLANK(),
        DIVIDE(VentasActual - VentasAnterior, VentasAnterior)
    )
```

#### Medidas por Contexto
```dax
VentasPorCiudad = SUM(Facturas[TotalVenta])
VentasPorMarca = SUM(DetalleFacturas[Subtotal])
VentasPorVendedor = SUM(Facturas[TotalVenta])
VentasPorMetodoPago = SUM(Facturas[TotalVenta])
```

### 3.2 Visualizaciones Implementadas

#### Página 1: Vista General

**KPIs Principales (Tarjetas)**
- Ventas Totales: $5,000 billones+
- Ticket Promedio: $152,160
- Productos Vendidos: 495,597 unidades
- Crecimiento Mensual: Variable según período

**Mapa Geográfico**
- Visualización de ventas por ciudad
- Tamaño de burbujas proporcional a ventas
- Colores diferenciados por región
- Tooltip con detalles de cada ciudad

**Gráfico de Barras - Ventas por Marca**
- Marcas ordenadas por volumen de ventas descendente
- Top marcas: Lenovo, HP, Dell, Apple
- Colores diferenciados por marca
- Etiquetas de datos visibles

**Línea de Tiempo - Evolución de Ventas**
- Tendencia mensual de ventas 2014-2025
- Jerarquía navegable: Año → Mes
- Marcadores de datos para facilitar lectura
- Área sombreada para destacar tendencia

**Método de Pago por Año**
- Gráfico de columnas apiladas
- Distribución de métodos: Billetera Digital, Efectivo, No Proporcionado, Tarjeta Crédito, Tarjeta Débito, Transferencia
- Evolución temporal de preferencias de pago

#### Página 2: Análisis Detallado

**Tabla de Productos Más Vendidos**
- Columnas: NombreProducto, TotalCantidadVendida, TotalSubtotalProductos
- Ordenada por ventas descendente
- Top productos identificados

**Análisis por Vendedor**
- Gráfico de barras con desempeño de cada vendedor
- Ordenado por ventas totales
- Top performers destacados

**Tendencias por Método de Pago**
- Evolución mensual de cada método
- Gráfico de columnas apiladas
- Identificación de tendencias de adopción

### 3.3 Filtros y Segmentaciones

**Segmentadores Implementados:**
- 🏙️ **Ciudad:** Filtro múltiple para análisis regional
- 🏢 **Marca:** Selección de marcas de productos
- 📅 **Rango de Fechas:** Selector con deslizador temporal
- 💳 **Método de Pago:** Filtro de formas de pago
- 👤 **Edad:** Rango de edad de clientes (18-61 años)

**Interactividad:**
- Filtros cruzados entre visualizaciones
- Drill-down en jerarquías temporales
- Drill-through para análisis detallado
- Tooltips personalizados con información contextual

### 3.4 Jerarquías Configuradas

**Jerarquía Temporal:**
```
Calendario
  └─ Año
      └─ Mes
          └─ Día
```

**Jerarquía Geográfica:**
```
Ubicación
  └─ Ciudad
      └─ Sucursal
```

---

## IMPLEMENTACIÓN DE SEGURIDAD (RLS)

### Objetivo
Implementar Row-Level Security para restringir acceso a información según el rol del usuario.

### 4.1 Tabla de Usuarios

**Estructura:**
- `Email`: Correo electrónico del usuario (identificador único)
- `CiudadAsociada`: Ciudad a la que tiene acceso
- `SucursalAsociada`: Sucursal específica asignada
- `Rol`: Tipo de usuario (Gerente Nacional/Regional/Sucursal)

**Usuarios Configurados:**
- 1 Gerente Nacional (acceso completo)
- 4 Gerentes Regionales (uno por ciudad)
- 6 Gerentes de Sucursal (uno por sucursal)

### 4.2 Roles y Filtros DAX

#### Rol 1: Gerente Nacional
- **Acceso:** Total, sin restricciones
- **Filtro:** Ninguno
- **Usuarios:** gerente.nacional@empresa.com

#### Rol 2: Gerente Regional
- **Acceso:** Solo datos de su ciudad asignada
- **Filtro en tabla Ciudades:**
```dax
[NombreCiudad] = 
LOOKUPVALUE(
    Usuarios[CiudadAsociada], 
    Usuarios[Email], 
    USERPRINCIPALNAME()
)
```
- **Usuarios:**
  - gerente.bogota@empresa.com → Bogotá
  - gerente.cali@empresa.com → Cali
  - gerente.medellin@empresa.com → Medellín
  - gerente.pereira@empresa.com → Pereira

#### Rol 3: Gerente Sucursal
- **Acceso:** Solo datos de su sucursal específica
- **Filtro en tabla Sucursales:**
```dax
[NombreSucursal] = 
LOOKUPVALUE(
    Usuarios[SucursalAsociada], 
    Usuarios[Email], 
    USERPRINCIPALNAME()
)
```
- **Usuarios:**
  - sucursal.bogota1@empresa.com → TechCore Bogotá #1
  - sucursal.bogota2@empresa.com → TechCore Bogotá #2
  - sucursal.cali@empresa.com → TechCore Cali
  - sucursal.medellin1@empresa.com → TechCore Medellín #1
  - sucursal.medellin2@empresa.com → TechCore Medellín #2
  - sucursal.pereira@empresa.com → TechCore Pereira

### 4.3 Arquitectura de Seguridad

**Flujo de Filtrado:**
```
Usuario autenticado (USERPRINCIPALNAME)
    ↓
Búsqueda en tabla Usuarios (LOOKUPVALUE)
    ↓
Aplicación de filtro en dimensión (Ciudad/Sucursal)
    ↓
Propagación automática a través de relaciones
    ↓
Filtrado de Facturas → DetalleFacturas
```

**Características:**
- ✅ Filtros obligatorios (no evitables por usuarios)
- ✅ Validación contra Azure AD en producción
- ✅ Sin relaciones físicas entre Usuarios y otras tablas
- ✅ Propagación eficiente a través del modelo existente

### 4.4 Pruebas de Seguridad

**Casos de Prueba Validados:**
1. ✅ Gerente Nacional: Acceso a todas las ciudades y sucursales
2. ✅ Gerente Regional Bogotá: Solo ve datos de Bogotá (ambas sucursales)
3. ✅ Gerente Sucursal Bogotá #1: Solo ve datos de TechCore Bogotá #1

---

## INSIGHTS ESTRATÉGICOS

### 5.1 Análisis de Desempeño por Ciudad

**Distribución de Ventas:**
- **Bogotá:** Ciudad líder en volumen de ventas (visualizado en mapa)
- **Medellín:** Segunda ciudad en importancia comercial
- **Cali y Pereira:** Mercados emergentes con potencial de crecimiento

**Oportunidades:**
- Expansión de sucursales en ciudades de alto desempeño
- Estrategias diferenciadas por región según comportamiento local

### 5.2 Análisis de Productos y Marcas

**Marcas Líderes:**
- **Lenovo:** Marca dominante en ventas totales
- **HP:** Segunda posición con fuerte presencia
- **Dell y Apple:** Marcas premium con buen desempeño

**Productos Estrella:**
- Top 10 productos concentran gran parte de las ventas
- Apple MacBook Pro 14 y 16: Productos de alto ticket
- Acer y Asus: Productos de volumen con buena rotación

**Recomendaciones:**
- Fortalecer inventario de productos estrella
- Promociones específicas en marcas de menor rotación
- Análisis de rentabilidad por marca

### 5.3 Comportamiento Temporal

**Estacionalidad:**
- Picos de venta observados en ciertos meses (visible en línea de tiempo)
- Tendencia general positiva en el período analizado
- Septiembre 2025: Caída significativa (-91%) requiere análisis detallado

**Estrategias:**
- Planificación de inventario basada en estacionalidad histórica
- Campañas promocionales en meses de baja
- Preparación para temporadas altas

### 5.4 Métodos de Pago

**Evolución:**
- Crecimiento de métodos digitales (Billetera Digital, Transferencia)
- Reducción gradual de efectivo
- Tarjetas de crédito/débito: Método más estable

**Implicaciones:**
- Inversión en infraestructura de pagos digitales
- Alianzas estratégicas con plataformas de pago
- Capacitación en nuevos métodos de pago

### 5.5 Análisis de Vendedores

**Desempeño:**
- Distribución equitativa de ventas entre vendedores
- Top performers identificados: Ana Sofía Llopis Blázquez, Liliana Jordá Armengol

**Acciones:**
- Programa de reconocimiento para top performers
- Capacitación para vendedores de menor desempeño
- Establecimiento de metas individuales

---

## CONCLUSIONES Y RECOMENDACIONES

### Logros del Proyecto

1. **Calidad de Datos:** Se logró un dataset 100% limpio y validado
2. **Modelo Robusto:** Arquitectura relacional escalable y con integridad referencial completa
3. **Dashboard Funcional:** Visualizaciones interactivas que facilitan la toma de decisiones
4. **Seguridad Implementada:** RLS configurado correctamente para proteger información sensible

### Valor Generado para TechCore

- **Visibilidad:** Dashboard proporciona visión 360° del negocio
- **Agilidad:** Análisis en tiempo real vs. reportes manuales tradicionales
- **Seguridad:** Información protegida según jerarquía organizacional
- **Escalabilidad:** Modelo preparado para incorporar nuevos datos

### Recomendaciones Estratégicas

**Corto Plazo (1-3 meses):**
1. Investigar la caída de septiembre 2025 y tomar acciones correctivas
2. Implementar el dashboard en Power BI Service con usuarios reales
3. Capacitar a gerentes en uso de filtros y análisis

**Mediano Plazo (3-6 meses):**
1. Ampliar análisis con métricas de rentabilidad por producto
2. Integrar datos de inventario para optimización de stock
3. Desarrollar modelos predictivos de ventas

**Largo Plazo (6-12 meses):**
1. Expandir el modelo a análisis de competencia
2. Integrar satisfacción del cliente y NPS
3. Desarrollar dashboard para clientes finales (programa de lealtad)

### Próximos Pasos

1. **Publicación:** Subir dashboard a Power BI Service
2. **Asignación:** Configurar usuarios y roles en producción
3. **Capacitación:** Sesiones de entrenamiento con stakeholders
4. **Monitoreo:** Establecer métricas de uso del dashboard
5. **Mejora Continua:** Ciclo de feedback y actualizaciones

---

## ARCHIVOS ENTREGABLES

### Fase 1 - Limpieza
- ✅ `Avance_1_Limpieza_Transformacion.pbix`
- ✅ `ventasTransformed.csv`

### Fase 2 - Modelado
- ✅ `Avance_2_Modelo_Relacional.ipynb`
- ✅ `modeloVentas.xlsx`
- ✅ Diagrama Entidad-Relación (incluido en notebook)

### Fase 3 - Dashboard
- ✅ `Avance_3_Dashboard_Interactivo.pbix`
- ✅ `medidas_powerbi.txt` (todas las medidas DAX)
- ✅ `usuarios_rls.csv` (tabla de seguridad)
- ✅ `RLS_Documentacion.txt` (documentación de seguridad)

### Documentación
- ✅ Este documento técnico completo
- ✅ Análisis de insights estratégicos

---

## TECNOLOGÍAS UTILIZADAS

- **Power BI Desktop:** Versión actualizada
- **Power Query:** Transformación y limpieza de datos
- **DAX:** Lenguaje de fórmulas para medidas calculadas
- **Python 3.x:** Pandas, NumPy para modelado relacional
- **Excel:** Almacenamiento intermedio del modelo

---

## CONTACTO

**Analista:** Jacquet Alexis  
**Proyecto:** Dashboard Interactivo TechCore  
**Cliente:** DataVision Analytics  
**Fecha:** Noviembre 2025

---

*Documentación generada como parte del proceso de selección para Analista de Datos Junior*
*Todos los derechos reservados © 2025*
