# 📋 INSTRUCCIONES PARA CONVERTIR A PDF

## Opción 1: Usando Pandoc (Recomendado)

### Instalación de Pandoc
```bash
# Windows (con Chocolatey)
choco install pandoc

# O descargar desde: https://pandoc.org/installing.html
```

### Convertir documentos
```bash
cd "c:\Users\Usuario\Desktop\HENRY\MODULO 2\documentacion\Documentación"

# README
pandoc README.md -o README.pdf --pdf-engine=xelatex -V geometry:margin=1in

# Análisis del modelo proporcionado
pandoc Análisis_del_modelo_proporcionado.md -o Análisis_del_modelo_proporcionado.pdf --pdf-engine=xelatex -V geometry:margin=1in

# Manual Consultas SQL
pandoc Manual_Consultas_SQL.md -o Manual_Consultas_SQL.pdf --pdf-engine=xelatex -V geometry:margin=1in

# Análisis Snowflake ETL
pandoc Análisis_Snowflake_ETL.md -o Análisis_Snowflake_ETL.pdf --pdf-engine=xelatex -V geometry:margin=1in

# AWS Análisis Arquitectura
pandoc AWS_Análisis_Arquitectura.md -o AWS_Análisis_Arquitectura.pdf --pdf-engine=xelatex -V geometry:margin=1in
```

## Opción 2: Usando Visual Studio Code

1. Instalar extensión: **Markdown PDF**
2. Abrir cada archivo .md
3. Presionar `Ctrl+Shift+P`
4. Escribir: "Markdown PDF: Export (pdf)"
5. Presionar Enter

## Opción 3: Usando Microsoft Word

1. Abrir cada archivo .md en VS Code
2. Copiar el contenido renderizado
3. Pegar en Word
4. Guardar como PDF

## Opción 4: Herramienta Online

1. Ir a: https://www.markdowntopdf.com/
2. Subir cada archivo .md
3. Descargar el PDF generado

---

## 🎨 Mejoras Opcionales de Formato

### Agregar Portada Profesional
Crear un archivo `portada.yaml`:
```yaml
---
title: "FleetLogix - Sistema de Gestión de Transporte"
author: "Científico de Datos Experto"
date: "Octubre 2025"
subtitle: "Documentación Técnica Completa"
---
```

Luego usar:
```bash
pandoc portada.yaml README.md -o README.pdf --pdf-engine=xelatex
```

### Tabla de Contenidos Automática
```bash
pandoc README.md -o README.pdf --toc --toc-depth=3 --pdf-engine=xelatex
```

### Sintaxis Highlight para Código
```bash
pandoc README.md -o README.pdf --highlight-style=tango --pdf-engine=xelatex
```

---

## ✅ Verificación de PDFs

Después de generar, verificar que los PDFs contengan:
- ✓ Todos los diagramas ASCII art renderizados correctamente
- ✓ Tablas con formato apropiado
- ✓ Bloques de código con syntax highlighting
- ✓ Emojis renderizados (si el motor lo soporta)
- ✓ Enlaces funcionando (si son PDFs interactivos)

---

**Última actualización:** 9 de Octubre de 2025
