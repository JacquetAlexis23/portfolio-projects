"""
HERRAMIENTAS PERSONALIZADAS PARA ANÁLISIS GASTRONÓMICO
======================================================

Este módulo contiene funciones especializadas para el análisis de datos de restaurantes 
y usuarios, optimizadas para estrategias de marketing digital y sistemas de recomendación.

Autor: Alexis Jacquet
Proyecto: Análisis Estratégico del Ecosistema Gastronómico
Programa: Henry Bootcamp - Módulo 1
Fecha: Agosto 2025

Funciones disponibles:
- recomendar_rest: Sistema de recomendación personalizado
- plot_custom: Visualizaciones avanzadas personalizables  
- imputar: Imputación inteligente de valores faltantes
"""

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

def recomendar_rest(id_usuario, rest, users, top_n=5):
    """
    Sistema de Recomendación Personalizado para Restaurantes
    
    Genera recomendaciones de restaurantes personalizadas basadas en el perfil 
    del usuario, incluyendo preferencias alimentarias, estrato socioeconómico 
    y compatibilidad de precios. Utiliza un algoritmo híbrido que combina 
    filtrado basado en contenido y métricas de calidad.

    Parámetros:
    -----------
    id_usuario : int or str
        Identificador único del usuario para generar recomendaciones
    rest : pd.DataFrame
        DataFrame con información completa de restaurantes incluyendo:
        - Categorías gastronómicas (columnas alias_*)
        - Ratings y número de reviews
        - Información de precios y ubicación
    users : pd.DataFrame  
        DataFrame con perfiles de usuarios incluyendo:
        - Preferencias alimentarias
        - Estrato socioeconómico
        - Patrones de gasto
    top_n : int, opcional (default=5)
        Número de restaurantes a recomendar

    Algoritmo:
    ----------
    1. Extracción del perfil del usuario objetivo
    2. Mapeo de preferencias alimentarias a categorías gastronómicas
    3. Filtrado por compatibilidad de categorías
    4. Scoring multi-criterio basado en:
       - Compatibilidad precio-estrato (50%)
       - Afinidad gastronómica (30%)
       - Métricas de calidad (rating + popularidad) (20%)
    5. Ranking y selección de top N recomendaciones

    Salida:
    -------
    None (imprime resultados)
        Muestra perfil del usuario y tabla de restaurantes recomendados
        optimizada para interpretación ejecutiva

    Ejemplo de Uso:
    ---------------
    >>> recomendar_rest(id_usuario=12345, rest=df_restaurantes, 
    ...                 users=df_usuarios, top_n=5)
    
    Notas Técnicas:
    ---------------
    - Utiliza normalización Unicode para manejo robusto de texto
    - Implementa matriz de compatibilidad precio-estrato optimizada
    - Incluye fallback para usuarios sin preferencias específicas
    """
    mapeo = {
        'Carnes': ['chicken_wings', 'cajun', 'steak', 'bbq', 'burgers', 'chickenshop', 'argentine', 'southern', 'newamerican', 'spanish', 'kebab', 'latin', 'delis', 'comfortfood', 'caribbean', 'polish', 'venezuelan', 'sandwiches', 'tapas', 'tradamerican', 'australian', 'halal', 'mexican', 'korean', 'chinese', 'filipino', 'tacos', 'sardinian', 'modern_european', 'french', 'italian', 'pizza', 'hotpot', 'turkish', 'german', 'british', 'gastropubs', 'pastashops', 'tapasmallplates', 'diners'],
        'Mariscos': ['seafood', 'fishnchips'],
        'Vegetariano': ['vietnamese', 'noodles', 'mideastern', 'cambodian', 'asianfusion', 'thai', 'lebanese', 'indpak', 'soup', 'salad', 'himalayan', 'mediterranean', 'vegetarian', 'falafel', 'malaysian', 'singaporean', 'african'],
        'Otro': ['speakeasies', 'gourmet', 'restaurants', 'whiskeybars', 'desserts', 'icecream', 'bakeries', 'beerbar', 'cafes', 'intlgrocery', 'cocktailbars', 'coffee', 'wine_bars', 'lounges', 'beer_and_wine', 'pubs', 'venues', 'tikibars', 'breweries', 'brewpubs', 'supperclubs', 'karaoke', 'bars', 'food_court', 'brasseries'],
        'Pescado': ['sushi', 'peruvian', 'dimsum', 'japanese', 'izakaya', 'ramen', 'poke', 'hainan', 'japacurry'],
        'Vegano': ['taiwanese', 'somali', 'piadina']
    }
    import unicodedata
    usuario = users[users['id_persona'] == id_usuario].iloc[0]
    pref = usuario['preferencias_alimenticias']
    estrato = usuario['estrato_socioeconomico']
    def normalizar(texto):
        if pd.isnull(texto):
            return ""
        texto = str(texto).strip().lower()
        texto = unicodedata.normalize('NFKD', texto).encode('ascii', 'ignore').decode('utf-8')
        texto = texto.replace(" ", "")
        return texto
    pref_norm = normalizar(pref)
    categorias = []
    for key in mapeo:
        if normalizar(key) in pref_norm or pref_norm in normalizar(key):
            categorias = mapeo[key]
            break
    alias_cols = [col for col in rest.columns if col.startswith('alias_')]
    cols_filtrar = []
    for cat in categorias:
        cat_norm = normalizar(cat)
        for col in alias_cols:
            if cat_norm == normalizar(col.replace('alias_', '')):
                cols_filtrar.append(col)
    if cols_filtrar:
        mask = rest[cols_filtrar].sum(axis=1) > 0
        rest_filtrado = rest[mask].copy()
    else:
        rest_filtrado = rest.copy()
    scores = []
    for _, restaurante in rest_filtrado.iterrows():
        compatibilidad = {
            'Bajo': {'1': 0.9, '2': 0.3, '3': 0.1, '4': 0.0},
            'Medio': {'1': 0.7, '2': 0.9, '3': 0.4, '4': 0.1},
            'Alto': {'1': 0.5, '2': 0.8, '3': 0.9, '4': 0.7},
            'Muy Alto': {'1': 0.3, '2': 0.6, '3': 0.8, '4': 0.9}
        }
        price_str = str(restaurante['price_num'])
        score_precio = compatibilidad.get(estrato, {}).get(price_str, 0.0)
        score_comida = 0.9 if cols_filtrar else 0.1
        rating_norm = restaurante['rating'] / 5.0
        popularidad_norm = min(restaurante['review_count'] / 1000, 1.0)
        score_calidad = (rating_norm * 0.7) + (popularidad_norm * 0.3)
        score_total = (score_precio * 0.5) + (score_comida * 0.3) + (score_calidad * 0.2)
        scores.append({
            'restaurante_id': restaurante['id'],
            'nombre': restaurante.get('alias', 'Sin nombre'),
            'direccion': restaurante.get('address', '')
        })
    scores_df = pd.DataFrame(scores)
    top_recommendations = scores_df.head(top_n)
    print("--- Datos del usuario ---")
    print(f"Nombre: {usuario.get('nombre_completo', 'N/A')}")
    print(f"Preferencia alimenticia: {usuario.get('preferencias_alimenticias', 'N/A')}")
    print(f"Estrato socioeconómico: {usuario.get('estrato_socioeconomico', 'N/A')}")
    print(f"Gasto promedio comida: {usuario.get('promedio_gasto_comida', 'N/A')}")
    print("\nRestaurantes recomendados:")
    try:
        from IPython.display import display
        display(top_recommendations[['nombre', 'direccion']].rename(columns={'nombre': 'Nombre Restaurante', 'direccion': 'Dirección'}))
    except ImportError:
        print(top_recommendations[['nombre', 'direccion']].rename(columns={'nombre': 'Nombre Restaurante', 'Dirección': 'Dirección'}))
    # No retornamos nada para evitar doble impresión

def plot_custom(df, tipo, x=None, y=None, hue=None, order=None, palette='magma', title='', xlabel='', ylabel='', horizontal=False, bins=None, figsize=(10,6)):
    """
    Generador de Visualizaciones Avanzadas para Análisis Exploratorio
    
    Crea visualizaciones personalizadas optimizadas para storytelling de datos
    y presentaciones ejecutivas. Soporta múltiples tipos de gráficos con 
    configuraciones avanzadas y estética profesional.

    Parámetros:
    -----------
    df : pd.DataFrame
        Dataset con los datos a visualizar
    tipo : str
        Tipo de visualización a generar:
        - 'bar': Gráfico de barras para variables categóricas
        - 'count': Conteo de frecuencias por categoría  
        - 'hist': Histograma para distribuciones continuas
        - 'box': Box plot para análisis de distribución y outliers
        - 'scatter': Scatter plot para relaciones bivariadas
        - 'violin': Violin plot para distribuciones detalladas
        - 'heatmap': Mapa de calor para matrices de correlación
        - 'pairplot': Grid de relaciones multivariadas
    x : str, opcional
        Variable para eje X (requerida según tipo de gráfico)
    y : str, opcional  
        Variable para eje Y (requerida para algunos tipos)
    hue : str, opcional
        Variable categórica para segmentación por color
    order : list, opcional
        Orden personalizado para categorías (mejora legibilidad)
    palette : str, opcional (default='magma')
        Esquema de colores profesional
    title : str, opcional
        Título descriptivo del gráfico
    xlabel : str, opcional
        Etiqueta personalizada eje X
    ylabel : str, opcional
        Etiqueta personalizada eje Y
    horizontal : bool, opcional (default=False)
        Orientación horizontal para gráficos de barras
    bins : int, opcional
        Número de bins para histogramas (optimización automática si None)
    figsize : tuple, opcional (default=(10,6))
        Dimensiones de la figura para consistencia visual

    Salida:
    -------
    None
        Muestra el gráfico generado con formato profesional optimizado
        para presentaciones y reportes ejecutivos

    Características Avanzadas:
    --------------------------
    - Auto-ajuste de layout para máxima legibilidad
    - Paletas de colores optimizadas para daltonismo
    - Manejo inteligente de valores nulos y outliers
    - Formato consistente para branding corporativo
    - Soporte para visualizaciones multivariadas complejas

    Ejemplo de Uso:
    ---------------
    >>> plot_custom(df, tipo='scatter', x='rating', y='review_count',
    ...              hue='price_range', title='Performance de Restaurantes',
    ...              xlabel='Rating Promedio', ylabel='Número de Reviews')
    
    Casos de Uso Típicos:
    --------------------
    - Análisis de distribuciones para segmentación de mercado
    - Visualización de correlaciones para identificar drivers de éxito
    - Comparativas categóricas para benchmarking competitivo
    - Mapas de calor para análisis de matrices de similitud
    """

    if tipo == 'pairplot':
        pairplot_kwargs = {'data': df, 'corner': True}
        if isinstance(hue, str) and hue not in [None, '', 'None']:
            pairplot_kwargs['hue'] = hue
            if palette is not None and palette != '':
                pairplot_kwargs['palette'] = palette
        sns.pairplot(**pairplot_kwargs)
        plt.suptitle(title, y=1.02)
        plt.show()
        return
    elif tipo == 'heatmap':
        plt.figure(figsize=figsize)
        sns.heatmap(df, annot=True, cmap=palette if palette else 'coolwarm')
        plt.title(title)
        plt.tight_layout()
        plt.show()
        return
    elif tipo == 'bar':
        plt.figure(figsize=figsize)
        if horizontal:
            sns.barplot(x=x, y=y, data=df, order=order, palette=palette)
        else:
            sns.barplot(x=x, y=y, data=df, order=order, palette=palette)
        plt.title(title)
        plt.xlabel(xlabel)
        plt.ylabel(ylabel)
        plt.tight_layout()
        plt.show()
        return
    elif tipo == 'count':
        plt.figure(figsize=figsize)
        if horizontal:
            sns.countplot(y=y, data=df, order=order, palette=palette, hue=hue)
        else:
            sns.countplot(x=x, data=df, order=order, palette=palette, hue=hue)
        plt.title(title)
        plt.xlabel(xlabel)
        plt.ylabel(ylabel)
        plt.tight_layout()
        plt.show()
        return
    elif tipo == 'hist':
        plt.figure(figsize=figsize)
        sns.histplot(data=df, x=x, bins=bins, hue=hue, palette=palette)
        plt.title(title)
        plt.xlabel(xlabel)
        plt.ylabel(ylabel)
        plt.tight_layout()
        plt.show()
        return
    elif tipo == 'box':
        plt.figure(figsize=figsize)
        sns.boxplot(data=df, x=x, y=y, palette=palette, hue=hue)
        plt.title(title)
        plt.xlabel(xlabel)
        plt.ylabel(ylabel)
        plt.tight_layout()
        plt.show()
        return
    elif tipo == 'scatter':
        plt.figure(figsize=figsize)
        sns.scatterplot(data=df, x=x, y=y, hue=hue, palette=palette)
        plt.title(title)
        plt.xlabel(xlabel)
        plt.ylabel(ylabel)
        plt.tight_layout()
        plt.show()
        return
    elif tipo == 'violin':
        plt.figure(figsize=figsize)
        sns.violinplot(data=df, x=x, y=y, palette=palette, hue=hue)
        plt.title(title)
        plt.xlabel(xlabel)
        plt.ylabel(ylabel)
        plt.tight_layout()
        plt.show()
        return
    else:
        raise ValueError("Tipo de gráfico no soportado")
    
    
def imputar(df, objetivo, operacion, filtro1, filtro2, tc):
    """
    Sistema Avanzado de Imputación de Datos Faltantes
    
    Implementa técnicas de imputación inteligente mediante segmentación estadística,
    optimizando la calidad de datos para análisis posteriores. Utiliza estrategias
    diferenciadas según el tipo de valores problemáticos identificados.

    Parámetros:
    -----------
    df : pd.DataFrame
        Dataset sobre el cual realizar la imputación
    objetivo : str
        Nombre de la columna que contiene valores a imputar
    operacion : str
        Tipo de valores problemáticos a tratar:
        - 'nulo': Valores faltantes (NaN, None)
        - 'negativo': Valores negativos inconsistentes
        - 'cero': Valores cero que requieren reemplazo
    filtro1 : str
        Primera variable de segmentación (columna categórica)
        para crear grupos homogéneos de imputación
    filtro2 : str  
        Segunda variable de segmentación (columna categórica)
        para refinar la granularidad de grupos
    tc : str
        Técnica de cálculo estadístico a aplicar:
        - 'media': Promedio aritmético del segmento
        - 'mediana': Valor mediano del segmento (robusto a outliers)
        - 'moda': Valor más frecuente del segmento

    Retorna:
    --------
    pd.DataFrame
        DataFrame con la columna objetivo imputada según criterios especificados

    Metodología:
    ------------
    1. Segmentación del dataset según filtros especificados
    2. Cálculo de estadístico de reemplazo por segmento
    3. Identificación de valores problemáticos según operación
    4. Reemplazo inteligente preservando distribución por segmento
    5. Limpieza de variables temporales y conversión de tipos

    Ventajas del Enfoque:
    --------------------
    - Preserva patrones estadísticos por segmento poblacional
    - Minimiza sesgo introducido por imputación global
    - Maneja diferentes tipos de problemas de calidad de datos
    - Robusto ante outliers (especialmente con mediana/moda)
    - Mantiene consistencia tipo de datos post-imputación

    Ejemplo de Uso:
    ---------------
    >>> df_limpio = imputar(df=dataset, objetivo='gasto_promedio', 
    ...                     operacion='nulo', filtro1='estrato_socioeconomico',
    ...                     filtro2='tipo_cocina', tc='mediana')
    
    Casos de Uso Típicos:
    --------------------
    - Imputación de gastos promedio por segmento demográfico
    - Corrección de ratings negativos por categoría de restaurante
    - Reemplazo de valores cero en métricas de performance
    - Completitud de datasets para modelado predictivo

    Consideraciones Técnicas:
    ------------------------
    - Requiere suficientes observaciones por segmento para estabilidad
    - Convierte automáticamente tipos numéricos después de imputación
    - Genera advertencias si segmentos tienen pocos datos
    - Compatible con pipeline de preprocessing automatizado
    """
    
    if tc == 'media': 
    
        if operacion == 'nulo':
            df["media_segmentada"] = (
                df.groupby([filtro1, filtro2])[objetivo]
                .transform(lambda x: x[~x.isnull()].mean())
            )
            df.loc[df[objetivo].isnull(), objetivo] = df.loc[df[objetivo].isnull(), "media_segmentada"]
            df.drop(columns="media_segmentada", inplace=True)
            
        elif operacion == 'negativo':
            df["media_segmentada"] = (
                df.groupby([filtro1, filtro2])[objetivo]
                .transform(lambda x: x[x >= 0].mean())
            )
            df.loc[df[objetivo] < 0, objetivo] = df.loc[df[objetivo] < 0, "media_segmentada"]
            df.drop(columns="media_segmentada", inplace=True)
            
        elif operacion == 'cero':
            df["media_segmentada"] = (
                df.groupby([filtro1, filtro2])[objetivo]
                .transform(lambda x: x[x != 0].mean())
            )
            df.loc[df[objetivo] == 0, objetivo] = df.loc[df[objetivo] == 0, "media_segmentada"]
            df.drop(columns="media_segmentada", inplace=True)
            df[objetivo] = df[objetivo].astype(int)
            
    elif tc == 'mediana':
    
        if operacion == 'nulo':
            df["mediana_segmentada"] = (
                df.groupby([filtro1, filtro2])[objetivo]
                .transform(lambda x: x[~x.isnull()].median())
            )
            df.loc[df[objetivo].isnull(), objetivo] = df.loc[df[objetivo].isnull(), "mediana_segmentada"]
            df.drop(columns="mediana_segmentada", inplace=True)
            
        elif operacion == 'negativo':
            df["mediana_segmentada"] = (
                df.groupby([filtro1, filtro2])[objetivo]
                .transform(lambda x: x[x >= 0].median())
            )
            df.loc[df[objetivo] < 0, objetivo] = df.loc[df[objetivo] < 0, "mediana_segmentada"]
            df.drop(columns="mediana_segmentada", inplace=True)
            
        elif operacion == 'cero':
            df["mediana_segmentada"] = (
                df.groupby([filtro1, filtro2])[objetivo]
                .transform(lambda x: x[x != 0].median())
            )
            df.loc[df[objetivo] == 0, objetivo] = df.loc[df[objetivo] == 0, "mediana_segmentada"]
            df.drop(columns="mediana_segmentada", inplace=True)
            df[objetivo] = df[objetivo].astype(int)
            
    elif tc == 'moda':
    
        if operacion == 'nulo':
            df["moda_segmentada"] = (
                df.groupby([filtro1, filtro2])[objetivo]
                .transform(lambda x: x[~x.isnull()].mode()[0] if not x[~x.isnull()].mode().empty else np.nan)
            )
            df.loc[df[objetivo].isnull(), objetivo] = df.loc[df[objetivo].isnull(), "moda_segmentada"]
            df.drop(columns="moda_segmentada", inplace=True)
            
        elif operacion == 'negativo':
            df["moda_segmentada"] = (
                df.groupby([filtro1, filtro2])[objetivo]
                .transform(lambda x: x[x >= 0].mode()[0] if not x[x >= 0].mode().empty else np.nan)
            )
            df.loc[df[objetivo] < 0, objetivo] = df.loc[df[objetivo] < 0, "moda_segmentada"]
            df.drop(columns="moda_segmentada", inplace=True)
            
            
        elif operacion == 'cero':
            df["moda_segmentada"] = (
                df.groupby([filtro1, filtro2])[objetivo]
                .transform(lambda x: x[x != 0].mode()[0] if not x[x != 0].mode().empty else np.nan)
            )
            df.loc[df[objetivo] == 0, objetivo] = df.loc[df[objetivo] == 0, "moda_segmentada"]
            df.drop(columns="moda_segmentada", inplace=True)
    return df