# 📊 Fase 2: Desglosar el Código - Notebook 1: EDA y Regresión Logística
## Preparación para Entrevista - Análisis Detallado

**Fecha de Creación:** 11 de enero de 2026  
**Propósito:** Documentación imprimible para entender y explicar el código del primer notebook.

---

## 🎯 Estructura del Notebook 1: EDA y Regresión Logística

### ¿Por qué empezar con EDA?
- **EDA (Exploratory Data Analysis):** Entender los datos antes de modelar
- **Regresión Logística:** Modelo baseline interpretable para comparación
- **Objetivo:** Establecer línea base y entender relaciones entre variables

---

## 📦 1. Importar Librerías Necesarias

### Código Clave:
```python
# Manipulación de datos
import pandas as pd
import numpy as np

# Visualización
import matplotlib.pyplot as plt
import seaborn as sns

# Machine Learning - Preprocesamiento
from sklearn.model_selection import train_test_split, StratifiedKFold
from sklearn.preprocessing import StandardScaler, LabelEncoder

# Machine Learning - Modelo
from sklearn.linear_model import LogisticRegression

# Machine Learning - Métricas
from sklearn.metrics import (
    confusion_matrix, classification_report, 
    roc_auc_score, accuracy_score
)
```

### Explicación para Entrevista:
- **¿Por qué estas librerías?** "Uso pandas/numpy para manipulación, sklearn para ML, matplotlib/seaborn para visualizaciones."
- **¿Por qué StratifiedKFold?** "Por el desbalance de clases (80% no churn, 20% churn), mantiene proporciones en validación."

---

## 📊 2. Carga y Exploración Inicial del Dataset

### Código Clave:
```python
# Cargar el dataset
df = pd.read_csv('Churn_Modelling.csv')

# Información básica
print(f"Dimensiones: {df.shape[0]} filas x {df.shape[1]} columnas")
print(f"Memoria: {df.memory_usage(deep=True).sum() / 1024**2:.2f} MB")

# Primeras filas
df.head()

# Información de columnas
df.info()

# Estadísticas descriptivas
df.describe()
```

### Variables Identificadas:
- **Identificación:** RowNumber, CustomerId, Surname (no usar en modelo)
- **Demográficas:** Geography, Gender, Age, Tenure
- **Financieras:** CreditScore, Balance, NumOfProducts, HasCrCard, IsActiveMember, EstimatedSalary
- **Target:** Exited (0=No Churn, 1=Churn)

### Explicación para Entrevista:
- **¿Qué hiciste primero?** "Cargué los datos y verifiqué la estructura: 10,000 filas, 14 columnas útiles."
- **¿Por qué excluir IDs?** "Variables como CustomerId no aportan información predictiva, solo identifican."

---

## 🎯 3. Análisis de la Variable Objetivo

### Código Clave:
```python
churn_counts = df['Exited'].value_counts()
churn_percentages = df['Exited'].value_counts(normalize=True) * 100

print(f"Activos (0): {churn_counts[0]} ({churn_percentages[0]:.2f}%)")
print(f"Churn (1): {churn_counts[1]} ({churn_percentages[1]:.2f}%)")

# Ratio de desbalanceo
ratio = churn_counts[0] / churn_counts[1]
print(f"Ratio: {ratio:.2f}:1")
```

### Resultados:
- **Activos:** 7,963 (79.63%)
- **Churn:** 2,037 (20.37%)
- **Ratio:** 3.91:1 → **DESBALANCEADO**

### Explicación para Entrevista:
- **¿Cómo manejaste el desbalance?** "Identifiqué el desbalance y usé StratifiedKFold para mantener proporciones en validación."
- **¿Por qué importa?** "Modelos pueden sesgarse hacia la clase mayoritaria sin estrategias apropiadas."

---

## 🔍 4. Análisis Exploratorio: Variables Demográficas

### Código Clave (Ejemplo - Distribución por Edad):
```python
# Distribución de edad por churn
plt.figure(figsize=(12, 6))
sns.histplot(data=df, x='Age', hue='Exited', multiple='stack', alpha=0.7)
plt.title('Distribución de Edad por Churn')
plt.show()

# Estadísticas por grupo
print("Estadísticas de Edad por Churn:")
df.groupby('Exited')['Age'].describe()
```

### Insights Clave:
- **Edad:** Clientes que churn tienen edad promedio mayor (45 vs 37 años)
- **Género:** Mujeres tienen ligeramente mayor tasa de churn
- **Geografía:** Alemania tiene mayor churn (32%) vs Francia/España (16-17%)

### Explicación para Entrevista:
- **¿Qué patrones encontraste?** "Clientes mayores y alemanes tienen mayor riesgo de churn."
- **¿Cómo visualizaste?** "Usé histogramas y boxplots para comparar distribuciones entre grupos."

---

## 💰 5. Análisis Exploratorio: Variables Financieras

### Código Clave (Ejemplo - Balance):
```python
# Balance por churn
plt.figure(figsize=(10, 6))
sns.boxplot(data=df, x='Exited', y='Balance', palette='Set2')
plt.title('Balance por Categoría de Churn')
plt.show()

# Estadísticas
df.groupby('Exited')['Balance'].describe()
```

### Insights Clave:
- **Balance:** Clientes con churn tienen balance promedio más alto
- **NumOfProducts:** Clientes con 4 productos tienen alto riesgo
- **IsActiveMember:** Miembros inactivos churn más (27% vs 14%)

### Explicación para Entrevista:
- **¿Variables más importantes?** "Edad, balance, número de productos e actividad del cliente correlacionan fuertemente con churn."

---

## 🔧 6. Preprocesamiento de Datos

### Código Clave:
```python
# Eliminar columnas irrelevantes
df_clean = df.drop(['RowNumber', 'CustomerId', 'Surname'], axis=1)

# Codificar variables categóricas
le = LabelEncoder()
df_clean['Gender'] = le.fit_transform(df_clean['Gender'])

# One-Hot Encoding para Geography
df_clean = pd.get_dummies(df_clean, columns=['Geography'], drop_first=True)

# Separar features y target
X = df_clean.drop('Exited', axis=1)
y = df_clean['Exited']

# Train/Test Split estratificado
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

# Escalado
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)
```

### Explicación para Entrevista:
- **¿Por qué escalado?** "Regresión logística es sensible a escalas; estandaricé para que coeficientes sean comparables."
- **¿Por qué stratify?** "Mantiene proporción de churn en train/test splits."

---

## 🤖 7. Modelo de Regresión Logística

### Código Clave:
```python
# Entrenar modelo
model = LogisticRegression(random_state=42, max_iter=1000)
model.fit(X_train_scaled, y_train)

# Predicciones
y_pred = model.predict(X_test_scaled)
y_pred_proba = model.predict_proba(X_test_scaled)[:, 1]

# Métricas
print("Accuracy:", accuracy_score(y_test, y_pred))
print("ROC-AUC:", roc_auc_score(y_test, y_pred_proba))

# Coeficientes
feature_names = X.columns
coefficients = model.coef_[0]
coef_df = pd.DataFrame({
    'Feature': feature_names,
    'Coefficient': coefficients
}).sort_values('Coefficient', ascending=False)
```

### Resultados:
- **Accuracy:** 81.0%
- **ROC-AUC:** 77.8%
- **Top Coeficientes Positivos:** Edad, Geography_Germany, Balance

### Explicación para Entrevista:
- **¿Por qué baseline?** "Regresión logística es interpretable y establece referencia para modelos complejos."
- **¿Cómo interpretar coeficientes?** "Coeficiente positivo significa mayor riesgo de churn (ej: edad +0.8)."

---

## 📊 8. Evaluación y Validación

### Código Clave (Matriz de Confusión):
```python
# Matriz de confusión
cm = confusion_matrix(y_test, y_pred)
disp = ConfusionMatrixDisplay(confusion_matrix=cm)
disp.plot(cmap='Blues')
plt.title('Matriz de Confusión - Regresión Logística')
plt.show()

# Classification Report
print(classification_report(y_test, y_pred))

# ROC Curve
fpr, tpr, _ = roc_curve(y_test, y_pred_proba)
roc_auc = auc(fpr, tpr)
plt.plot(fpr, tpr, label=f'ROC curve (area = {roc_auc:.2f})')
plt.plot([0, 1], [0, 1], 'k--')
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('ROC Curve - Regresión Logística')
plt.legend()
plt.show()
```

### Explicación para Entrevista:
- **¿Qué métricas priorizaste?** "ROC-AUC porque es robusto al desbalance; accuracy puede ser engañosa."
- **¿Problemas identificados?** "Recall bajo (25%) indica que pierde muchos casos de churn."

---

## 💡 Puntos Clave para Explicar

### Estructura tu Explicación:
1. **EDA (2 min):** "Analicé distribución de variables, identifiqué desbalance y correlaciones clave."
2. **Preprocesamiento (1 min):** "Limpié datos, codifiqué categóricas, escalé features."
3. **Modelo (2 min):** "Entrené regresión logística, obtuve 81% accuracy con ROC-AUC 78%."
4. **Insights (1 min):** "Edad y balance son factores críticos de churn."

### Preguntas Anticipadas:
- **¿Por qué no usar todas las variables?** "IDs no aportan información predictiva."
- **¿Cómo validarías el modelo?** "Cross-validation estratificado y métricas apropiadas para desbalance."

---

## 📝 Notas para Práctica
- **Tiempo de explicación:** 5-7 minutos por sección
- **Enfócate en:** Decisiones tomadas y por qué
- **Próxima fase:** Gradient Boosting y optimización

**Imprime y practica explicar cada sección con el código correspondiente.**</content>
<parameter name="filePath">c:\Users\Usuario\Desktop\HENRY\MODULO 4\Fase2_Notebook1_EDA_Regresion.md