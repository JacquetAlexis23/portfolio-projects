# 📊 Fase 1: Overview del Proyecto - Preparación para Entrevista
## Proyecto de Predicción de Churn en FinanceGuard Bank

**Fecha de Creación:** 11 de enero de 2026  
**Propósito:** Documentación imprimible para entender y explicar el proyecto en una entrevista.

---

## 🎯 Resumen Ejecutivo (2-3 minutos de explicación)

### ¿Qué es el Proyecto?
- **Nombre:** FinanceGuard Bank - Predicción de Churn de Clientes
- **Problema:** Tasa de churn del 20% anual, con pérdida estimada de $10M/año
- **Objetivo:** Desarrollar un sistema predictivo para identificar clientes en riesgo y ejecutar campañas de retención personalizadas
- **Alcance:** 10,000 clientes analizados, 14 variables predictoras, 3 enfoques de ML

### ¿Por qué es Relevante?
- **Costo de Adquisición:** Adquirir nuevo cliente cuesta 5-7x más que retener uno existente
- **Impacto de Negocio:** Predecir churn permite estrategias proactivas de retención
- **ROI Estimado:** Mejora potencial del 30-40% en retención

---

## 📊 Datos y Metodología

### Dataset: Churn_Modelling.csv
- **10,000 clientes** bancarios europeos (Francia, España, Alemania)
- **14 variables predictoras:**
  - 👤 **Demográficas:** Edad, Género, Geografía
  - 💰 **Financieras:** Balance, Salario Estimado, Credit Score
  - 📱 **Comportamentales:** IsActiveMember, NumOfProducts, Tenure
- **Target:** Exited (0 = No Churn, 1 = Churn)
- **Desbalance:** 80% No Churn / 20% Churn

### Metodología - 3 Avances
1. **Avance 1:** Regresión Logística (Baseline - Interpretabilidad)
2. **Avance 2:** Gradient Boosting (Performance - Optimización)
3. **Avance 3:** Aprendizaje No Supervisado (Insights - Segmentación)

---

## 🤖 Modelos Desarrollados

### Portfolio de Modelos (6 modelos)
| Modelo | Tipo | Características Clave |
|--------|------|----------------------|
| **Regresión Logística** | Baseline | Interpretable, coeficientes claros |
| **Random Forest** | Ensemble | Robusto, manejo de no linealidades |
| **XGBoost** | Gradient Boosting | Performance alto, GridSearch |
| **LightGBM** | Gradient Boosting | Velocidad + Accuracy |
| **CatBoost** | Gradient Boosting | Excelente con categóricas |
| **Stacking** | Meta-Ensemble | Máximo performance |

### Validación
- **StratifiedKFold:** Mantiene proporción de clases
- **Train/Test Split:** 80/20
- **Métricas Principales:** Accuracy, Precision, Recall, F1, **ROC-AUC**

---

## 🏆 Resultados Principales

### Mejor Modelo: LightGBM
- **Accuracy:** 86.8%
- **ROC-AUC:** 86.99%
- **Segmentación:** 4 clusters con tasas de churn 14%-28%
- **Features Críticas:** Edad, NumOfProducts, IsActiveMember, Balance

### Comparación con Baseline (Regresión Logística)
- **Accuracy:** 81.0% (vs 86.8% LightGBM)
- **ROC-AUC:** 77.8% (vs 86.99% LightGBM)
- **Interpretabilidad:** Alta (coeficientes explicables)

---

## 💡 Puntos Clave para Explicar en Entrevista

### Estructura tu Respuesta:
1. **Contexto (30 seg):** "Trabajé en un proyecto para FinanceGuard Bank donde el churn era un problema crítico..."
2. **Objetivo (30 seg):** "...El objetivo era predecir qué clientes abandonarían el banco para retenerlos proactivamente..."
3. **Enfoque (1 min):** "...Usé 3 enfoques: baseline con regresión logística, optimización con gradient boosting, y segmentación con clustering..."
4. **Resultados (1 min):** "...Logré un 86.8% de accuracy con LightGBM, identificando 4 segmentos de clientes..."
5. **Impacto (30 seg):** "...Esto podría mejorar la retención en 30-40% con estrategias focalizadas..."

### Preguntas Anticipadas:
- **¿Por qué ML para churn?** "ML permite analizar patrones complejos en datos históricos para predecir comportamiento futuro."
- **¿Cómo manejaste el desbalance?** "Usé StratifiedKFold y métricas como ROC-AUC que son robustas al desbalance."
- **¿Qué modelo elegirías en producción?** "LightGBM por su balance entre performance y velocidad, pero regresión logística para interpretabilidad inicial."

---

## 📝 Notas para Práctica
- **Tiempo total de explicación:** 3-5 minutos
- **Enfócate en:** Decisiones técnicas, por qué elegiste cada modelo, insights de negocio
- **Visuales clave:** ROC curves, feature importance, matriz de confusión
- **Próxima fase:** Profundizar en EDA y Regresión Logística

**Imprime esta documentación y léela varias veces antes de la entrevista.**</content>
<parameter name="filePath">c:\Users\Usuario\Desktop\HENRY\MODULO 4\Fase1_Overview_Proyecto.md