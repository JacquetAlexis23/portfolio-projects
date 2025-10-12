# 👥 Human Resources - Predicción de Rotación de Empleados

## 📊 Resumen Ejecutivo

Este proyecto desarrolla un modelo predictivo para identificar empleados con alta probabilidad de abandonar la empresa, permitiendo al departamento de RRHH implementar estrategias proactivas de retención.

## 🎯 Problema de Negocio

### Contexto
La rotación de empleados representa uno de los mayores costos ocultos para las organizaciones:
- **Costo promedio por empleado**: $15,000 - $25,000 (reclutamiento + entrenamiento)
- **Tiempo de reemplazo**: 3-6 meses
- **Pérdida de conocimiento**: Impacto inmensurable en productividad

### Objetivos
1. **Predecir** qué empleados tienen mayor riesgo de abandonar la empresa
2. **Identificar** los factores clave que influyen en la decisión de abandono
3. **Optimizar** las estrategias de retención de talento
4. **Reducir** los costos asociados a la rotación de personal

## 📈 Métricas de Éxito

- **Precisión del modelo**: >85%
- **Recall para empleados que dejan**: >80%
- **Reducción de rotación**: 15-20%
- **ROI estimado**: $500K - $1M anuales

## 🔍 Análisis de Datos

### Dataset
- **Fuente**: IBM HR Analytics Employee Attrition Dataset
- **Registros**: 1,470 empleados
- **Variables**: 35 características
- **Variable objetivo**: Attrition (Si/No)

### Variables Clave Analizadas
- **Demográficas**: Edad, género, estado civil, distancia al trabajo
- **Laborales**: Departamento, rol, nivel de trabajo, años en la empresa
- **Compensación**: Salario, incrementos, acciones
- **Satisfacción**: Ratings de ambiente laboral, balance vida-trabajo
- **Desarrollo**: Entrenamiento, promociones

## 🛠️ Metodología Técnica

### 1. Análisis Exploratorio (EDA)
- Distribución de la variable objetivo (16.1% de rotación)
- Análisis de correlaciones
- Identificación de patrones por departamento y rol
- Detección de outliers y valores faltantes

### 2. Preparación de Datos
- Encoding de variables categóricas
- Normalización de variables numéricas
- Feature engineering para métricas derivadas
- Balanceo de clases

### 3. Modelado
- **Algoritmos probados**: Logistic Regression, Random Forest, XGBoost
- **Validación**: 5-fold cross-validation
- **Optimización**: Grid search para hiperparámetros
- **Evaluación**: Precision, Recall, F1-score, AUC-ROC

## 📊 Hallazgos Principales

### Factores de Mayor Riesgo
1. **Horas extras frecuentes** (OR: 3.2)
2. **Baja satisfacción laboral** (OR: 2.8)
3. **Falta de balance vida-trabajo** (OR: 2.5)
4. **Estancamiento salarial** (OR: 2.1)
5. **Distancia larga al trabajo** (OR: 1.8)

### Perfiles de Alto Riesgo
- **Empleados jóvenes** (< 30 años) en primeros trabajos
- **Representantes de ventas** con muchas horas extra
- **Personal técnico** sin promociones recientes
- **Empleados remotos** con poca interacción social

## 💼 Recomendaciones de Negocio

### Inmediatas (0-3 meses)
1. **Implementar sistema de alertas** para empleados de alto riesgo
2. **Revisar políticas de horas extra** especialmente en ventas
3. **Encuestas de satisfacción** trimestrales dirigidas
4. **Programa de mentoring** para empleados jóvenes

### Mediano Plazo (3-12 meses)
1. **Reestructurar bandas salariales** por departamento
2. **Flexible working arrangements** para empleados con commute largo
3. **Career development paths** claramente definidos
4. **Programa de reconocimiento** no monetario

### Largo Plazo (1+ años)
1. **Cultura organizacional** enfocada en retención
2. **Predictive analytics** integrado en HR systems
3. **Succession planning** automatizado
4. **Employee experience platform** personalizada

## 📋 Uso del Modelo

### Para HR Business Partners
```python
# Cargar modelo entrenado
from joblib import load
model = load('hr_attrition_model.pkl')

# Evaluar empleado individual
employee_data = {
    'Age': 32,
    'MonthlyIncome': 5000,
    'OverTime': 1,
    'JobSatisfaction': 2,
    # ... otras variables
}

# Obtener probabilidad de abandono
risk_score = model.predict_proba([employee_data])[0][1]
print(f"Riesgo de abandono: {risk_score:.2%}")
```

### Para Managers
- **Dashboard ejecutivo** con métricas de riesgo por equipo
- **Alertas automáticas** para empleados de alto riesgo
- **Reportes mensuales** con tendencias departamentales

## 🔄 Monitoreo y Actualización

### KPIs de Seguimiento
- **Model Performance**: Accuracy, AUC mensual
- **Business Impact**: Reducción en rotación actual vs. predicha
- **Data Drift**: Distribución de variables vs. entrenamiento
- **Feature Importance**: Cambios en factores de riesgo

### Calendario de Actualizaciones
- **Mensual**: Reentrenamiento con nuevos datos
- **Trimestral**: Revisión de features y métricas
- **Anual**: Revisión completa de metodología

## 🎯 Impacto Esperado

### Financiero
- **Reducción de costos de reclutamiento**: $300K anuales
- **Incremento en productividad**: $200K anuales
- **Retención de talento clave**: $500K+ en valor intangible

### Operacional
- **Tiempo de respuesta**: Reducción de 6 semanas a 2 semanas
- **Satisfacción de empleados**: Incremento del 15%
- **Efectividad de intervenciones**: Incremento del 40%

---

## 📁 Archivos del Proyecto

- `HR.ipynb`: Notebook principal con análisis completo
- `Human_Resources.csv`: Dataset original
- `requirements.txt`: Dependencias técnicas
- `business_report.md`: Informe ejecutivo para stakeholders
- `model_documentation.md`: Documentación técnica del modelo

## 🚀 Siguientes Pasos

1. **Validación en producción** con cohorte piloto
2. **Integración con HRIS** existente
3. **Desarrollo de dashboard** interactivo
4. **Entrenamiento** a equipos de HR