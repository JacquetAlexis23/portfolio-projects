#!/bin/bash

# ============================================================================
# PORTFOLIO DATASETS DOWNLOADER
# Script automatizado para descargar datasets desde Google Drive
# ============================================================================

set -e  # Exit on error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "=========================================="
echo "   PORTFOLIO DATASETS DOWNLOADER"
echo "=========================================="
echo -e "${NC}"

# Verificar si gdown está instalado
if ! command -v gdown &> /dev/null; then
    echo -e "${YELLOW}⚠️  gdown no está instalado. Instalando...${NC}"
    pip install -q gdown
fi

# Función para descargar y extraer
download_and_extract() {
    local url=$1
    local zip_name=$2
    local extract_dir=$3
    
    if [ -d "$extract_dir" ]; then
        echo -e "${GREEN}✓ $extract_dir ya existe, saltando...${NC}"
        return 0
    fi
    
    echo -e "${BLUE}📥 Descargando $zip_name...${NC}"
    gdown "$url" -O "$zip_name"
    
    echo -e "${BLUE}📂 Extrayendo $zip_name...${NC}"
    unzip -q "$zip_name" -d "$extract_dir"
    
    echo -e "${BLUE}🧹 Limpiando archivo temporal...${NC}"
    rm "$zip_name"
    
    echo -e "${GREEN}✅ $zip_name completado!${NC}\n"
}

# Función de ayuda
show_help() {
    echo "Uso: ./download_datasets.sh [--project PROJECT_NAME] [--all]"
    echo ""
    echo "Opciones:"
    echo "  --all                    Descargar todos los proyectos"
    echo "  --project operations     Descargar solo Operations Department"
    echo "  --project maintenance    Descargar solo Maintenance Department"
    echo "  --project sentimientos   Descargar solo Análisis de Sentimientos"
    echo "  --project henry1         Descargar solo Proyecto Henry 1"
    echo "  --project traductor      Descargar solo Traductor"
    echo "  --help                   Mostrar esta ayuda"
    echo ""
    echo "Ejemplo:"
    echo "  ./download_datasets.sh --project operations"
}

# ============================================================================
# URLS DE GOOGLE DRIVE (REEMPLAZAR CON TUS IDs REALES)
# ============================================================================

# ANALISIS SENTIMIENTOS
SENTIMIENTOS_TRAINING_URL="https://drive.google.com/uc?id=YOUR_TRAINING_ID"
SENTIMIENTOS_TESTING_URL="https://drive.google.com/uc?id=YOUR_TESTING_ID"
SENTIMIENTOS_CHECKPOINT_URL="https://drive.google.com/uc?id=YOUR_CHECKPOINT_ID"

# DS_APLICADO_NEGOCIOS - Operations Department
OPS_DATASET_URL="https://drive.google.com/uc?id=YOUR_DATASET_ID"
OPS_TEST_URL="https://drive.google.com/uc?id=YOUR_TEST_ID"
OPS_WEIGHTS_URL="https://drive.google.com/uc?id=YOUR_WEIGHTS_ID"

# DS_APLICADO_NEGOCIOS - Maintenance Department
MAINT_TRAIN_IMAGES_URL="https://drive.google.com/uc?id=YOUR_TRAIN_IMAGES_ID"
MAINT_MODELS_URL="https://drive.google.com/uc?id=YOUR_MODELS_ID"

# PROYECTO_1_HENRY
HENRY1_RESTAURANTES_URL="https://drive.google.com/uc?id=YOUR_RESTAURANTES_ID"
HENRY1_CHICAGO_URL="https://drive.google.com/uc?id=YOUR_CHICAGO_ID"

# TRADUCTOR
TRADUCTOR_DATA_URL="https://drive.google.com/uc?id=YOUR_TRADUCTOR_DATA_ID"

# ============================================================================
# FUNCIONES DE DESCARGA POR PROYECTO
# ============================================================================

download_sentimientos() {
    echo -e "${YELLOW}📊 Descargando Análisis de Sentimientos...${NC}\n"
    cd "ANALISIS SENTIMIENTOS (TWITTER)(NLPxRNC)"
    
    if [ ! -f "Training.csv" ]; then
        echo -e "${BLUE}📥 Descargando Training.csv...${NC}"
        gdown "$SENTIMIENTOS_TRAINING_URL" -O "Training.csv"
    fi
    
    if [ ! -f "Testing.csv" ]; then
        echo -e "${BLUE}📥 Descargando Testing.csv...${NC}"
        gdown "$SENTIMIENTOS_TESTING_URL" -O "Testing.csv"
    fi
    
    download_and_extract "$SENTIMIENTOS_CHECKPOINT_URL" "CheckPoint.zip" "CheckPoint"
    
    cd ..
    echo -e "${GREEN}✅ Análisis de Sentimientos completado!${NC}\n"
}

download_operations() {
    echo -e "${YELLOW}🏥 Descargando Operations Department...${NC}\n"
    cd "DS_APLICADO_NEGOCIOS/4. Operations Department"
    
    download_and_extract "$OPS_DATASET_URL" "Dataset.zip" "Dataset"
    download_and_extract "$OPS_TEST_URL" "Test.zip" "Test"
    
    if [ ! -f "weights.weights.h5" ]; then
        echo -e "${BLUE}📥 Descargando weights.weights.h5...${NC}"
        gdown "$OPS_WEIGHTS_URL" -O "weights.weights.h5"
    fi
    
    cd ../..
    echo -e "${GREEN}✅ Operations Department completado!${NC}\n"
}

download_maintenance() {
    echo -e "${YELLOW}⚙️ Descargando Maintenance Department...${NC}\n"
    cd "DS_APLICADO_NEGOCIOS/6. Maintenance Department"
    
    download_and_extract "$MAINT_TRAIN_IMAGES_URL" "train_images.zip" "train_images"
    download_and_extract "$MAINT_MODELS_URL" "models.zip" "."
    
    cd ../..
    echo -e "${GREEN}✅ Maintenance Department completado!${NC}\n"
}

download_henry1() {
    echo -e "${YELLOW}🍽️ Descargando Proyecto Henry 1...${NC}\n"
    cd "PROYECTO_1_HENRY/Avances - Notebooks"
    
    if [ ! -f "base_datos_restaurantes_USA_v2.csv" ]; then
        echo -e "${BLUE}📥 Descargando base_datos_restaurantes_USA_v2.csv...${NC}"
        gdown "$HENRY1_RESTAURANTES_URL" -O "base_datos_restaurantes_USA_v2.csv"
    fi
    
    download_and_extract "$HENRY1_CHICAGO_URL" "chicago_data.zip" "."
    
    cd ../..
    echo -e "${GREEN}✅ Proyecto Henry 1 completado!${NC}\n"
}

download_traductor() {
    echo -e "${YELLOW}🌐 Descargando Traductor...${NC}\n"
    cd "TRADUCTOR  (TRANSFORMER)"
    
    download_and_extract "$TRADUCTOR_DATA_URL" "data.zip" "data"
    
    cd ..
    echo -e "${GREEN}✅ Traductor completado!${NC}\n"
}

# ============================================================================
# MAIN
# ============================================================================

# Parse arguments
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

case "$1" in
    --help)
        show_help
        exit 0
        ;;
    --all)
        echo -e "${BLUE}📦 Descargando TODOS los proyectos...${NC}\n"
        download_sentimientos
        download_operations
        download_maintenance
        download_henry1
        download_traductor
        ;;
    --project)
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Error: Especifica el nombre del proyecto${NC}"
            show_help
            exit 1
        fi
        
        case "$2" in
            operations)
                download_operations
                ;;
            maintenance)
                download_maintenance
                ;;
            sentimientos)
                download_sentimientos
                ;;
            henry1)
                download_henry1
                ;;
            traductor)
                download_traductor
                ;;
            *)
                echo -e "${RED}❌ Error: Proyecto '$2' no reconocido${NC}"
                show_help
                exit 1
                ;;
        esac
        ;;
    *)
        echo -e "${RED}❌ Error: Opción '$1' no reconocida${NC}"
        show_help
        exit 1
        ;;
esac

echo -e "${GREEN}"
echo "=========================================="
echo "   ✅ DESCARGA COMPLETADA"
echo "=========================================="
echo -e "${NC}"
echo "Los archivos están listos para usar."
echo "Ejecuta los notebooks normalmente."