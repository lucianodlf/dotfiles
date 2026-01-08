#!/bin/bash
# Script para controlar el brillo de la segunda pantalla (HDMI-1-0)

if [ $# -eq 0 ]; then
    echo "Uso: $0 [brillo]"
    echo "Brillo debe ser un valor entre 0.1 y 2.0"
    echo "Ejemplos:"
    echo "  $0 0.5   # Brillo bajo"
    echo "  $0 0.8   # Brillo medio"
    echo "  $0 1.0   # Brillo normal"
    echo "  $0 1.2   # Brillo alto"
    exit 1
fi

BRILLO=$1

# Validar que el valor esté en rango razonable
if (( $(echo "$BRILLO < 0.1" | bc -l) )); then
    echo "Error: El brillo no puede ser menor a 0.1"
    exit 1
fi

if (( $(echo "$BRILLO > 2.0" | bc -l) )); then
    echo "Error: El brillo no puede ser mayor a 2.0"
    exit 1
fi

# Aplicar el brillo
xrandr --output HDMI-1-0 --brightness $BRILLO

if [ $? -eq 0 ]; then
    echo "Brillo de HDMI-1-0 ajustado a $BRILLO"
else
    echo "Error al ajustar el brillo"
    exit 1
fi