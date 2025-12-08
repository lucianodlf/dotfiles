#!/usr/bin/env bash

# ===
#
# install.sh
#
# Instala y configura los dotfiles en un sistema Linux.
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

# Comprueba si un comando existe.
#
# @param {string} command - Comando a comprobar.
# @return {number} 0 si el comando existe, 1 en caso contrario.
function command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# ---
# Funciones de Instalación
# ---

# Crea un enlace simbólico para el archivo .bashrc.
function link_bashrc() {
  msg "info" "Creando enlace simbólico para .bashrc..."

  if [ -f "$BASHRC_TARGET" ]; then
    msg "warn" "Ya existe un archivo .bashrc. Se creará una copia de seguridad en $BASHRC_TARGET.bak."
    mv "$BASHRC_TARGET" "$BASHRC_TARGET.bak"
  fi

  ln -sfv "$BASHRC_SOURCE" "$BASHRC_TARGET"
  msg "success" "Enlace simbólico para .bashrc creado."
}

# ---
# Flujo Principal
# ---

function main() {
  msg "info" "Iniciando la instalación de los dotfiles..."

  # Crear enlaces simbólicos
  link_bashrc

  # TODO: Añadir aquí más funciones de instalación (e.g., install_packages, configure_git)
  

  msg "success" "¡Instalación de dotfiles completada!"
  msg "info" "source $BASHRC_TARGET"
  source "$BASHRC_TARGET"
}

main "$@"
