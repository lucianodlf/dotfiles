#!/usr/bin/env bash

# ===
#
# uninstall.sh
#
# Desinstala los dotfiles y revierte los cambios realizados por install.sh.
#
# ===

# ---
# Variables Globales
# ---

# Colores para la salida
readonly COLOR_RESET='\033[0m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_CYAN='\033[0;36m'

# Rutas del proyecto
readonly PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
source "$PROJECT_DIR/system/.dotfile_config"

# ---
# Funciones de Utilidad
# ---

# Muestra un mensaje con un formato estándar.
#
# @param {string} type - Tipo de mensaje (info, success, error, warn).
# @param {string} message - Mensaje a mostrar.
function msg() {
  local type="$1"
  local message="$2"
  local color=""

  case "$type" in
    info)
      color="$COLOR_CYAN"
      ;;
    success)
      color="$COLOR_GREEN"
      ;;
    error)
      color="$COLOR_RED"
      ;;
    warn)
      color="$COLOR_YELLOW"
      ;;
    *)
      color="$COLOR_RESET"
      ;;
  esac

  echo -e "${color}[$(date +'%T')] ${message}${COLOR_RESET}"
}

# ---
# Funciones de Desinstalación
# ---

# Elimina el enlace simbólico de .bashrc y restaura la copia de seguridad si existe.
function unlink_bashrc() {
  msg "info" "Eliminando enlace simbólico de .bashrc..."

  if [ -L "$BASHRC_TARGET" ]; then
    rm "$BASHRC_TARGET"
    if [ -f "$BASHRC_TARGET.bak" ]; then
      mv "$BASHRC_TARGET.bak" "$BASHRC_TARGET"
      msg "success" ".bashrc restaurado desde la copia de seguridad."
    else
      msg "success" "Enlace simbólico de .bashrc eliminado."
    fi
  else
    msg "warn" "No se encontró ningún enlace simbólico para .bashrc."
  fi
}

# ---
# Flujo Principal
# ---

function main() {
  msg "info" "Iniciando la desinstalación de los dotfiles..."

  # Eliminar enlaces simbólicos
  unlink_bashrc

  # TODO: Añadir aquí más funciones de desinstalación

  msg "success" "¡Desinstalación de dotfiles completada!"
}

main "$@"
