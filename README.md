# 🎯 Portfolio de Proyectos - Data Science & Machine Learning

<div align="center">

[![GitHub](https://img.shields.io/badge/GitHub-Profile-181717?style=for-the-badge&logo=github)](https://github.com/JacquetAlexis23)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/tu-perfil)
[![Portfolio](https://img.shields.io/badge/Portfolio-Website-4285F4?style=for-the-badge&logo=google-chrome)](https://jacquetalexis23.github.io)

**Alexis Jacquet** - Data Scientist & ML Engineer

</div>

---

## 📋 Índice de Proyectos

Este repositorio contiene proyectos profesionales de Data Science y Machine Learning, organizados por dominio y complejidad.

| # | Proyecto | Tecnologías | Dominio | Estado |
|---|----------|-------------|---------|--------|
| 1 | [Análisis de Sentimientos en Twitter](#1-análisis-de-sentimientos-en-twitter) | NLP, RNN, TensorFlow | Redes Sociales | ✅ Completo |
| 2 | [Clasificación de Rayos X (COVID-19)](#2-clasificación-de-rayos-x-covid-19) | ResNet50, Transfer Learning | Salud | ✅ Completo |
| 3 | [Sistema de Mantenimiento Predictivo](#3-sistema-de-mantenimiento-predictivo) | ResNet, U-Net, CV | Manufactura | ✅ Completo |
| 4 | [Análisis de Negocios Multi-Departamental](#4-análisis-de-negocios-multi-departamental) | ML, AutoML, Forecasting | Business | ✅ Completo |
| 5 | [Traductor Español-Inglés (Transformer)](#5-traductor-español-inglés-transformer) | Transformer, NLP | Lingüística | ✅ Completo |
| 6 | [Proyecto Henry 1 - Análisis de Restaurantes](#6-proyecto-henry-1) | EDA, APIs, Big Data | Gastronomía | ✅ Completo |
| 7 | [Proyecto Henry 2 - FleetLogix](#7-proyecto-henry-2) | SQL, ETL, AWS | Logística | ✅ Completo |

---

## ⚠️ IMPORTANTE: Descarga de Datasets

Los datasets pesados **NO están incluidos en este repositorio** para evitar límites de tamaño de GitHub.

### 🔗 Acceso a Archivos Pesados

Todos los datasets, modelos pre-entrenados y archivos grandes están alojados en **Google Drive**:

📦 **[ENLACE A CARPETA PRINCIPAL DE GOOGLE DRIVE](https://drive.google.com/drive/folders/1d84B04fIzC7O70x6ftGjaHeIDh3y9sLE?usp=sharing)**

Dentro encontrarás:
```
Portfolio_Data/
├── ANALISIS_SENTIMIENTOS/
├── DS_APLICADO_NEGOCIOS/
└── TRADUCTOR_TRANSFORMER/
```

### 📥 Opciones de Descarga

#### **Opción 1: Descarga Automática (Recomendado para Colab)**

Cada notebook incluye una celda de descarga automática. Simplemente:

1. Abre el notebook en Google Colab
2. Ejecuta la celda de "AUTOMATIC DATASET DOWNLOADER"
3. Los archivos se descargarán automáticamente

#### **Opción 2: Descarga Manual**

1. Accede al enlace de Drive arriba
2. Navega a la carpeta del proyecto específico
3. Descarga los archivos ZIP necesarios
4. Extrae en las ubicaciones especificadas en cada README

#### **Opción 3: Script Bash (Linux/Mac)**

```bash
# Descargar script automatizado
curl -O https://raw.githubusercontent.com/JacquetAlexis23/portfolio-projects/main/download_datasets.sh
chmod +x download_datasets.sh

# Ejecutar para proyecto específico
./download_datasets.sh --project operations_department
```

---

## 📂 Estructura del Repositorio

```
portfolio-projects/
│
├── ANALISIS SENTIMIENTOS (TWITTER)(NLPxRNC)/
│   ├── ANALISIS_SENTIMIENTOS(TWITTER).ipynb
│   ├── README.md
│   ├── requirements.txt
│   └── [Datasets en Drive]
│
├── DS_APLICADO_NEGOCIOS/
│   ├── 1. Human Resources/
│   ├── 2. Marketing Department/
│   ├── 3. Sales Department Data/
│   ├── 4. Operations Department/      ⭐ Proyecto destacado
│   ├── 5. Public Relations Department/
│   └── 6. Maintenance Department/     ⭐ Proyecto destacado
│
├── PROYECTO_1_HENRY/
│   └── Avances - Notebooks/
│
├── PROYECTO_2_HENRY/
│   ├── Documentación/
│   ├── SQL/
│   └── Scripts/
│
├── TRADUCTOR (TRANSFORMER)/
│   ├── Transformer_para_NLP.ipynb
│   ├── data/
│   └── docs/
│
└── README.md (este archivo)
```

---

## 1. Análisis de Sentimientos en Twitter

<details>
<summary>📊 Ver detalles del proyecto</summary>

### Descripción
Clasificador de sentimientos en tweets usando Redes Neuronales Recurrentes (RNN) con arquitectura LSTM.

### Tecnologías
- **Framework**: TensorFlow/Keras
- **Técnicas**: Word Embeddings, LSTM, Dropout
- **Dataset**: 1.6M tweets etiquetados

### Archivos Pesados en Drive
- `Training.csv` (227 MB)
- `Testing.csv` (50 MB)
- `CheckPoint/` (152 MB)

### [📖 README completo](./ANALISIS%20SENTIMIENTOS%20(TWITTER)(NLPxRNC)/README.md) | [📓 Notebook](./ANALISIS%20SENTIMIENTOS%20(TWITTER)(NLPxRNC)/ANALISIS_SENTIMIENTOS(TWITTER).ipynb)

</details>

---

## 2. Clasificación de Rayos X (COVID-19)

<details>
<summary>🏥 Ver detalles del proyecto</summary>

### Descripción
Sistema de clasificación automatizada de rayos X para detectar COVID-19, neumonía viral/bacteriana y casos normales.

### Tecnologías
- **Arquitectura**: ResNet50 (Transfer Learning)
- **Técnicas**: Data Augmentation, Early Stopping
- **Precisión**: 95%

### Archivos Pesados en Drive
- `Dataset.zip` (400 MB) - Imágenes de entrenamiento
- `Test.zip` (100 MB) - Imágenes de prueba  
- `weights.weights.h5` (90 MB) - Modelo pre-entrenado

### [📖 README completo](./DS_APLICADO_NEGOCIOS/4.%20Operations%20Department/README.md) | [📓 Notebook](./DS_APLICADO_NEGOCIOS/4.%20Operations%20Department/OD.ipynb)

</details>

---

## 3. Sistema de Mantenimiento Predictivo

<details>
<summary>⚙️ Ver detalles del proyecto</summary>

### Descripción
Detección y segmentación de defectos en productos manufacturados usando Computer Vision.

### Tecnologías
- **Clasificación**: ResNet
- **Segmentación**: U-Net
- **Dataset**: 25,000 imágenes de defectos

### Archivos Pesados en Drive
- `train_images.zip` (1.2 GB) - Imágenes de entrenamiento
- `test_images.zip` (300 MB)
- `resnet-weights.weights.h5` (94 MB)
- `resunet-segmentation-weights.weights.h5` (198 MB)

### [📖 README completo](./DS_APLICADO_NEGOCIOS/6.%20Maintenance%20Department/README.md) | [📓 Notebook](./DS_APLICADO_NEGOCIOS/6.%20Maintenance%20Department/DMM.ipynb)

</details>

---

## 4. Análisis de Negocios Multi-Departamental

<details>
<summary>💼 Ver detalles del proyecto</summary>

### Descripción
Suite de análisis de datos para 6 departamentos corporativos (HR, Marketing, Sales, Operations, PR, Maintenance).

### Proyectos incluidos
1. **HR**: Predicción de rotación de empleados
2. **Marketing**: Clustering de clientes con Autoencoders
3. **Sales**: Forecasting de ventas con Prophet
4. **Operations**: Clasificación de rayos X
5. **PR**: Análisis de sentimientos de productos
6. **Maintenance**: Detección de defectos

### Archivos Pesados en Drive
Cada departamento tiene sus propios datasets en Drive.

### [📂 Ver carpeta completa](./DS_APLICADO_NEGOCIOS/)

</details>

---

## 5. Traductor Español-Inglés (Transformer)

<details>
<summary>🌐 Ver detalles del proyecto</summary>

### Descripción
Modelo de traducción automática Español↔Inglés implementado desde cero con arquitectura Transformer.

### Tecnologías
- **Arquitectura**: Transformer (Attention is All You Need)
- **Corpus**: Europarl (2M pares de frases)
- **Técnicas**: Multi-Head Attention, Positional Encoding

### Archivos Pesados en Drive
- `europarl-v7.es-en.es` (300 MB)
- `europarl-v7.es-en.en` (280 MB)

### [📖 README completo](./TRADUCTOR%20(TRANSFORMER)/README.md) | [📓 Notebook](./TRADUCTOR%20(TRANSFORMER)/Transformer_para_NLP.ipynb)

</details>

---

## 6. Proyecto Henry 1

<details>
<summary>🍽️ Ver detalles del proyecto</summary>

### Descripción
Análisis de datos de restaurantes en USA con integración de APIs de Yelp y Google Maps.

### Archivos Pesados en Drive
- `base_datos_restaurantes_USA_v2.csv` (150 MB)
- `rest_chicago.csv` (80 MB)
- `users_chicago.csv` (50 MB)

### [📂 Ver carpeta](./PROYECTO_1_HENRY/)

</details>

---

## 7. Proyecto Henry 2

<details>
<summary>🚚 Ver detalles del proyecto</summary>

### Descripción
Sistema FleetLogix - Análisis de datos logísticos con PostgreSQL, ETL pipelines y despliegue en AWS.

### Archivos Pesados
No requiere datasets grandes (solo scripts SQL y Python).

### [📂 Ver carpeta](./PROYECTO_2_HENRY/)

</details>

---

## 🛠️ Stack Tecnológico General

### Lenguajes & Frameworks
- **Python** (NumPy, Pandas, Scikit-learn)
- **TensorFlow/Keras** (Deep Learning)
- **SQL** (PostgreSQL, MySQL)

### Herramientas
- **Jupyter Notebooks**
- **Google Colab**
- **Git/GitHub**
- **VS Code**

### Bibliotecas ML/DL
- TensorFlow, Keras
- Scikit-learn
- XGBoost, LightGBM
- OpenCV
- NLTK, spaCy

---

## 📚 Instalación y Configuración

### Prerequisitos
- Python 3.8+
- pip/conda
- Git

### Instalación Rápida

```bash
# Clonar el repositorio
git clone https://github.com/JacquetAlexis23/portfolio-projects.git
cd portfolio-projects

# Crear entorno virtual
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias generales
pip install -r requirements.txt

# Descargar datasets (ver sección de Descarga de Datasets arriba)
```

### Instalación por Proyecto

Cada proyecto tiene su propio `requirements.txt`. Para instalar dependencias específicas:

```bash
cd "DS_APLICADO_NEGOCIOS/4. Operations Department"
pip install -r requirements.txt
```

---

## 🎓 Cómo Usar Este Portfolio

### Para Reclutadores

1. **Vista rápida**: Revisa los READMEs de cada proyecto
2. **Notebooks interactivos**: Abre en Colab con un clic (enlaces en cada README)
3. **Resultados**: Todos los notebooks incluyen outputs guardados

### Para Desarrolladores

1. Clona el repositorio
2. Descarga datasets necesarios desde Drive
3. Instala dependencias del proyecto específico
4. Ejecuta notebooks localmente o en Colab

### Para Ejecutar sin Descargar

Usa los badges de Binder en cada README para ejecutar notebooks en la nube sin instalación.

---

## 📞 Contacto

**Alexis Jacquet**

- 📧 Email: [tu-email@example.com](mailto:tu-email@example.com)
- 💼 LinkedIn: [linkedin.com/in/tu-perfil](https://linkedin.com/in/tu-perfil)
- 🐙 GitHub: [@JacquetAlexis23](https://github.com/JacquetAlexis23)
- 🌐 Portfolio: [jacquetalexis23.github.io](https://jacquetalexis23.github.io)

---

## 📄 Licencia

Este portfolio es de uso personal y educativo. Los códigos están disponibles bajo MIT License. Los datasets pertenecen a sus respectivos propietarios originales.

---

## 🙏 Agradecimientos

- Datasets: Kaggle, GitHub COVID-19 Dataset, Europarl Corpus
- Frameworks: TensorFlow, Keras, Scikit-learn
- Educación: Henry, Coursera, Fast.ai

---

<div align="center">

**⭐ Si este portfolio te resulta útil, considera darle una estrella!**

Última actualización: Octubre 2025

</div>