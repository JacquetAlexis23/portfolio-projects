# 📊 Fase 2: Desglosar el Código - Notebook 2: Gradient Boosting y Optimización
## Preparación para Entrevista - Análisis Detallado

**Fecha de Creación:** 11 de enero de 2026  
**Propósito:** Documentación imprimible para entender y explicar el código del segundo notebook.

---

## 🎯 Estructura del Notebook 2: Gradient Boosting y Optimización

### ¿Por qué Gradient Boosting?
- **Performance Superior:** Algoritmos avanzados para mejor accuracy
- **Optimización:** GridSearch y Optuna para hiperparámetros
- **Ensemble:** Combinar múltiples modelos para robustez
- **Objetivo:** Superar el baseline de regresión logística (81% accuracy)

---

## 📦 1. Importar Librerías Avanzadas

### Código Clave:
```python
# Algoritmos de Gradient Boosting
from sklearn.ensemble import RandomForestClassifier
import xgboost as xgb
import lightgbm as lgb
import catboost as cb

# Ensemble Methods
from sklearn.ensemble import StackingClassifier

# Optimización
import optuna
from optuna.samplers import TPESampler
from optuna.pruners import MedianPruner

# Validación
from sklearn.model_selection import GridSearchCV, StratifiedKFold
```

### Explicación para Entrevista:
- **¿Por qué múltiples algoritmos?** "Cada uno tiene fortalezas: XGBoost para performance, LightGBM para velocidad, CatBoost para categóricas."
- **¿Qué es Optuna?** "Framework de optimización bayesiana para encontrar mejores hiperparámetros automáticamente."

---

## 🤖 2. Random Forest (Baseline Ensemble)

### Código Clave:
```python
# Modelo Random Forest
rf_model = RandomForestClassifier(
    n_estimators=100,
    max_depth=10,
    random_state=42,
    class_weight='balanced'  # Manejo de desbalance
)

# Entrenamiento con cross-validation
cv_scores = cross_val_score(
    rf_model, X_train_scaled, y_train, 
    cv=StratifiedKFold(n_splits=5, shuffle=True, random_state=42),
    scoring='roc_auc'
)

print(f"Random Forest CV ROC-AUC: {cv_scores.mean():.4f} (+/- {cv_scores.std()*2:.4f})")

# Entrenamiento final
rf_model.fit(X_train_scaled, y_train)
rf_pred = rf_model.predict(X_test_scaled)
rf_proba = rf_model.predict_proba(X_test_scaled)[:, 1]

print(f"Test ROC-AUC: {roc_auc_score(y_test, rf_proba):.4f}")
```

### Resultados Esperados:
- **ROC-AUC:** ~84-85%
- **Ventaja:** Maneja no linealidades mejor que regresión logística

### Explicación para Entrevista:
- **¿Por qué Random Forest?** "Es robusto, maneja outliers y captura interacciones no lineales entre variables."

---

## 🚀 3. XGBoost con GridSearch

### Código Clave:
```python
# Espacio de hiperparámetros para GridSearch
param_grid = {
    'n_estimators': [100, 200, 300],
    'max_depth': [3, 5, 7],
    'learning_rate': [0.01, 0.1, 0.2],
    'subsample': [0.8, 0.9, 1.0],
    'colsample_bytree': [0.8, 0.9, 1.0]
}

# Modelo base
xgb_model = xgb.XGBClassifier(
    objective='binary:logistic',
    random_state=42,
    eval_metric='auc'
)

# GridSearch con cross-validation
grid_search = GridSearchCV(
    xgb_model, param_grid, 
    cv=StratifiedKFold(n_splits=5),
    scoring='roc_auc',
    n_jobs=-1, verbose=1
)

# Entrenamiento
grid_search.fit(X_train_scaled, y_train)

# Mejor modelo
best_xgb = grid_search.best_estimator_
print(f"Mejores parámetros: {grid_search.best_params_}")
print(f"Mejor CV ROC-AUC: {grid_search.best_score_:.4f}")

# Evaluación en test
xgb_pred = best_xgb.predict(X_test_scaled)
xgb_proba = best_xgb.predict_proba(X_test_scaled)[:, 1]
print(f"Test ROC-AUC: {roc_auc_score(y_test, xgb_proba):.4f}")
```

### Resultados Esperados:
- **ROC-AUC:** 85-87%
- **Mejores Parámetros:** learning_rate=0.1, max_depth=5, n_estimators=200

### Explicación para Entrevista:
- **¿Por qué GridSearch?** "Explora sistemáticamente combinaciones de hiperparámetros para encontrar óptimos."
- **¿Qué parámetros optimizaste?** "Learning rate, profundidad, número de árboles - afectan sobreajuste vs underfitting."

---

## ⚡ 4. LightGBM (Optimizado para Velocidad)

### Código Clave:
```python
# Configuración de LightGBM
lgb_model = lgb.LGBMClassifier(
    objective='binary',
    metric='auc',
    boosting_type='gbdt',
    num_leaves=31,
    learning_rate=0.1,
    n_estimators=100,
    random_state=42
)

# Entrenamiento con early stopping
lgb_model.fit(
    X_train_scaled, y_train,
    eval_set=[(X_test_scaled, y_test)],
    eval_metric='auc',
    early_stopping_rounds=10,
    verbose=False
)

# Predicciones
lgb_pred = lgb_model.predict(X_test_scaled)
lgb_proba = lgb_model.predict_proba(X_test_scaled)[:, 1]

print(f"LightGBM Test ROC-AUC: {roc_auc_score(y_test, lgb_proba):.4f}")
```

### Resultados Esperados:
- **ROC-AUC:** 86-87%
- **Ventaja:** Más rápido que XGBoost en datasets grandes

### Explicación para Entrevista:
- **¿Por qué LightGBM?** "Es eficiente computacionalmente y maneja bien datos desbalanceados con early stopping."

---

## 🐱 5. CatBoost (Manejo de Categóricas)

### Código Clave:
```python
# CatBoost puede manejar categóricas directamente
# Recrear dataset con variables categóricas originales
df_cat = pd.read_csv('Churn_Modelling.csv')
df_cat = df_cat.drop(['RowNumber', 'CustomerId', 'Surname'], axis=1)

# Variables categóricas
cat_features = ['Geography', 'Gender']

# Modelo CatBoost
cat_model = cb.CatBoostClassifier(
    iterations=1000,
    learning_rate=0.1,
    depth=6,
    cat_features=cat_features,
    verbose=False,
    random_state=42
)

# Split (CatBoost maneja categóricas)
X_cat = df_cat.drop('Exited', axis=1)
y_cat = df_cat['Exited']
X_train_cat, X_test_cat, y_train_cat, y_test_cat = train_test_split(
    X_cat, y_cat, test_size=0.2, random_state=42, stratify=y_cat
)

# Entrenamiento
cat_model.fit(X_train_cat, y_train_cat, cat_features=cat_features)

# Predicciones
cat_pred = cat_model.predict(X_test_cat)
cat_proba = cat_model.predict_proba(X_test_cat)[:, 1]

print(f"CatBoost Test ROC-AUC: {roc_auc_score(y_test_cat, cat_proba):.4f}")
```

### Resultados Esperados:
- **ROC-AUC:** 85-86%
- **Ventaja:** No necesita preprocesamiento de categóricas

### Explicación para Entrevista:
- **¿Por qué CatBoost?** "Maneja automáticamente variables categóricas, reduciendo preprocesamiento."

---

## 🔄 6. Stacking Ensemble

### Código Clave:
```python
# Modelos base
base_models = [
    ('rf', RandomForestClassifier(n_estimators=100, random_state=42)),
    ('xgb', xgb.XGBClassifier(n_estimators=100, random_state=42)),
    ('lgb', lgb.LGBMClassifier(n_estimators=100, random_state=42)),
    ('cat', cb.CatBoostClassifier(iterations=100, verbose=False, random_state=42))
]

# Meta-learner
meta_model = LogisticRegression(random_state=42)

# Stacking
stacking_model = StackingClassifier(
    estimators=base_models,
    final_estimator=meta_model,
    cv=StratifiedKFold(n_splits=5),
    stack_method='predict_proba'
)

# Entrenamiento
stacking_model.fit(X_train_scaled, y_train)

# Predicciones
stack_pred = stacking_model.predict(X_test_scaled)
stack_proba = stacking_model.predict_proba(X_test_scaled)[:, 1]

print(f"Stacking Test ROC-AUC: {roc_auc_score(y_test, stack_proba):.4f}")
```

### Resultados Esperados:
- **ROC-AUC:** 87-88%
- **Ventaja:** Combina fortalezas de múltiples modelos

### Explicación para Entrevista:
- **¿Qué es stacking?** "Entrena modelos base y un meta-modelo que aprende de sus predicciones para mejor performance."

---

## 🎯 7. Optuna (Optimización Bayesiana)

### Código Clave:
```python
def objective(trial):
    # Espacio de búsqueda
    n_estimators = trial.suggest_int('n_estimators', 100, 1000)
    max_depth = trial.suggest_int('max_depth', 3, 10)
    learning_rate = trial.suggest_float('learning_rate', 0.01, 0.3)
    
    # Modelo
    model = xgb.XGBClassifier(
        n_estimators=n_estimators,
        max_depth=max_depth,
        learning_rate=learning_rate,
        random_state=42
    )
    
    # Cross-validation
    scores = cross_val_score(
        model, X_train_scaled, y_train, 
        cv=StratifiedKFold(n_splits=5), 
        scoring='roc_auc'
    )
    
    return scores.mean()

# Optimización
study = optuna.create_study(direction='maximize', sampler=TPESampler(), pruner=MedianPruner())
study.optimize(objective, n_trials=50)

print(f"Mejor ROC-AUC: {study.best_value:.4f}")
print(f"Mejores parámetros: {study.best_params}")
```

### Explicación para Entrevista:
- **¿Por qué Optuna?** "Optimización bayesiana es más eficiente que GridSearch para espacios grandes de parámetros."

---

## 📊 8. Comparación de Modelos

### Código Clave:
```python
# Crear dataframe de resultados
results_df = pd.DataFrame({
    'Modelo': ['Random Forest', 'XGBoost', 'LightGBM', 'CatBoost', 'Stacking'],
    'ROC_AUC': [rf_auc, xgb_auc, lgb_auc, cat_auc, stack_auc],
    'Accuracy': [rf_acc, xgb_acc, lgb_acc, cat_acc, stack_acc]
})

# Visualización
plt.figure(figsize=(12, 6))
sns.barplot(data=results_df, x='Modelo', y='ROC_AUC', palette='viridis')
plt.title('Comparación de ROC-AUC por Modelo')
plt.xticks(rotation=45)
plt.show()

print(results_df.sort_values('ROC_AUC', ascending=False))
```

### Resultados Esperados:
1. **Stacking/LightGBM:** 87-88% ROC-AUC
2. **XGBoost:** 86-87%
3. **CatBoost:** 85-86%
4. **Random Forest:** 84-85%

### Explicación para Entrevista:
- **¿Cuál elegirías?** "LightGBM por balance entre performance y velocidad computacional."

---

## 💡 Puntos Clave para Explicar

### Estructura tu Explicación:
1. **Motivación (1 min):** "Para superar el baseline, implementé algoritmos avanzados de gradient boosting."
2. **Modelos (3 min):** "Comparé Random Forest, XGBoost, LightGBM, CatBoost y stacking."
3. **Optimización (2 min):** "Usé GridSearch para XGBoost y Optuna para optimización bayesiana."
4. **Resultados (1 min):** "LightGBM logró 86.8% accuracy, mejorando significativamente el baseline."

### Preguntas Anticipadas:
- **¿Por qué gradient boosting?** "Construye modelos aditivos que corrigen errores iterativamente."
- **¿Cómo evitaste sobreajuste?** "Cross-validation, early stopping y regularización en hiperparámetros."
- **¿Cuál es el trade-off?** "Performance vs interpretabilidad/computación."

---

## 📝 Notas para Práctica
- **Tiempo de explicación:** 7-10 minutos
- **Enfócate en:** Elecciones técnicas y mejoras sobre baseline
- **Próxima fase:** Aprendizaje no supervisado

**Imprime y practica explicar cada modelo con sus resultados.**</content>
<parameter name="filePath">c:\Users\Usuario\Desktop\HENRY\MODULO 4\Fase2_Notebook2_GradientBoosting.md