# Análisis Estratégico del Ecosistema Gastronómico: Optimización de Marketing Digital

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Pandas](https://img.shields.io/badge/Pandas-1.5+-green.svg)](https://pandas.pydata.org/)
[![Status](https://img.shields.io/badge/Status-Completed-success.svg)]()

## 🎯 Resumen Ejecutivo

Este proyecto presenta un análisis comprehensivo del mercado gastronómico de Chicago, desarrollado para **optimizar estrategias de marketing digital** mediante la aplicación de técnicas avanzadas de ciencia de datos. A través de la integración de múltiples fuentes de datos y análisis estadístico riguroso, se han identificado patrones críticos de comportamiento de usuarios y factores de éxito comercial que permiten la personalización efectiva de campañas publicitarias.

### 💡 Valor Estratégico

- **ROI Optimizado**: Identificación de segmentos de alto valor para targeting preciso
- **Inteligencia Competitiva**: Benchmarking y análisis de factores diferenciadores
- **Personalización Avanzada**: Desarrollo de perfiles de usuario basados en datos
- **Decisiones Fundamentadas**: Insights accionables respaldados por evidencia empírica

## 📊 Estructura del Proyecto

```
ProyectoM1_JacquetAlexis/
│
├── 📁 Avances - Notebooks/
│   ├── 🔍 Avance_EDA.ipynb                 # Análisis Exploratorio de Datos
│   ├── 🔗 Avance_API_Yelp.ipynb           # Integración con API de Yelp
│   ├── 📈 Avance_Analisis_Final.ipynb     # KPIs y Visualizaciones Avanzadas
│   ├── 🛠️ tools.py                        # Funciones Personalizadas
│   └── 📊 Datasets/                       # Datos procesados
│
├── 📁 Documentacion/
│   ├── 📋 README.md                       # Documentación principal
│   ├── 📑 Recomendaciones.md             # Insights y recomendaciones
│   └── 📄 Recomendaciones.pdf            # Informe ejecutivo
```

## 🚀 Instalación y Configuración

### Prerrequisitos

```bash
Python 3.8+
Jupyter Notebook o VS Code
Acceso a API de Yelp (opcional para replicar extracción)
```

### Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <url-repositorio>
   cd ProyectoM1_JacquetAlexis
   ```

2. **Crear entorno virtual (recomendado)**
   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/Mac
   # o
   venv\Scripts\activate     # Windows
   ```

3. **Instalar dependencias**
   ```bash
   pip install pandas numpy matplotlib seaborn scikit-learn fuzzywuzzy requests jupyter
   ```

## 🔬 Metodología Científica

### Pipeline de Análisis

**1. Adquisición y Validación de Datos**
- Extracción controlada mediante API de Yelp con rate limiting
- Validación de integridad y completitud de datos
- Implementación de protocolos de calidad de datos

**2. Procesamiento y Enriquecimiento**
- Limpieza automatizada con detección de anomalías
- Imputación inteligente mediante segmentación estadística
- Normalización y estandarización de variables categóricas

**3. Análisis Exploratorio Avanzado**
- Análisis univariado y multivariado comprehensivo
- Detección de patrones y correlaciones significativas
- Identificación de outliers y casos atípicos

**4. Generación de Insights**
- Desarrollo de KPIs específicos para marketing digital
- Análisis de segmentación de usuarios y establecimientos
- Visualizaciones interactivas para storytelling de datos

### Técnicas Aplicadas

- **Análisis Estadístico**: Descriptivo, inferencial y correlacional
- **Visualización de Datos**: 15+ gráficos especializados con insights accionables
- **Segmentación**: Clustering basado en comportamiento y demografía
- **Sistemas de Recomendación**: Algoritmos personalizados para matching usuario-restaurante

## 📈 Principales Hallazgos y KPIs

### Segmentación de Usuarios
- **4 segmentos principales** identificados por estrato socioeconómico y preferencias
- **Correlación significativa** entre ubicación geográfica y gasto promedio
- **Patrones de comportamiento** diferenciados por grupo demográfico

### Performance de Establecimientos
- **Factores críticos de éxito**: Rating, volumen de reviews y ubicación
- **Distribución de precios** optimizada por categoría gastronómica
- **Oportunidades de mercado** en segmentos desatendidos

### Insights de Marketing
- **Targeting óptimo** por combinación de variables demográficas
- **Propuestas de valor** diferenciadas por segmento de usuario
- **ROI estimado** para campañas personalizadas vs. masivas

## 🎯 Guía de Uso

### Ejecución Secuencial Recomendada

1. **Inicio con EDA** (`Avance_EDA.ipynb`)
   - Comprensión inicial de la estructura de datos
   - Identificación de problemas de calidad
   - Análisis exploratorio fundamental

2. **Enriquecimiento de Datos** (`Avance_API_Yelp.ipynb`)
   - Integración con fuentes externas
   - Validación cruzada de información
   - Expansión del dataset base

3. **Análisis Estratégico** (`Avance_Analisis_Final.ipynb`)
   - Desarrollo de KPIs ejecutivos
   - Visualizaciones avanzadas
   - Generación de recomendaciones

### Funcionalidades Clave

```python
# Sistema de recomendación personalizado
from tools import recomendar_rest
recomendar_rest(id_usuario=123, rest=df_rest, users=df_users, top_n=5)

# Visualizaciones personalizadas
from tools import plot_custom
plot_custom(df, tipo='scatter', x='rating', y='review_count', 
           title='Análisis de Performance de Restaurantes')

# Imputación inteligente de datos faltantes
from tools import imputar
df_limpio = imputar(df=dataset, objetivo='gasto_promedio', 
                   operacion='nulo', filtro1='estrato_socioeconomico',
                   filtro2='tipo_cocina', tc='mediana')
```

## 📊 Recomendaciones Estratégicas

### Para el Departamento de Marketing

**1. Segmentación Avanzada**
- Implementar targeting por estrato socioeconómico + preferencias alimentarias
- Desarrollar mensajes personalizados por segmento identificado
- Optimizar presupuestos publicitarios según LTV por segmento

**2. Estrategias de Posicionamiento**
- Enfocar campañas en establecimientos con rating 4.0+ y 100+ reviews
- Priorizar categorías gastronómicas con mayor engagement
- Desarrollar partnerships estratégicos con restaurantes top-performers

**3. Optimización de Conversión**
- Implementar recomendaciones personalizadas en tiempo real
- A/B testing de propuestas de valor por segmento
- Tracking de métricas de engagement y conversión

## 🔮 Próximos Pasos

- **Modelado Predictivo**: Desarrollo de modelos de churn y LTV
- **Dashboard Ejecutivo**: Implementación de visualizaciones en tiempo real
- **Análisis de Sentimientos**: Integración de análisis de reviews para insights cualitativos
- **Geoanálisis**: Mapping avanzado de oportunidades por ubicación

## 👥 Autoría y Reconocimientos

**Desarrollado por:** Alexis Jacquet  
**Programa:** Henry Bootcamp - Módulo 1  
**Fecha:** Agosto 2025

**Agradecimientos especiales:**
- Equipo docente de Henry por la metodología y mentoring
- Comunidad de estudiantes por el intercambio de conocimientos
- Yelp por proporcionar acceso a datos de calidad vía API

---

## 📄 Licencia

Este proyecto se desarrolla con fines educativos como parte del programa Henry Bootcamp. Los datos utilizados cumplen con los términos de uso de la API de Yelp y políticas de privacidad aplicables.

---

**📞 Contacto:**  
Para consultas técnicas o colaboraciones, contactar al autor a través de los canales oficiales del programa Henry.

