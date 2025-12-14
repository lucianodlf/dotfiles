#!/bin/bash

# ===
#
# aditionals-postinstall.sh
#
# Pasos de post-instalación adicionales y opcionales.
#
# ===

# --- 
# Funciones de Utilidad (copiadas de install.sh para ser autocontenido)
# --- 

# Rutas del proyecto (autocontenido)
readonly PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

# Colores para la salida
readonly COLOR_RESET='\033[0m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_CYAN='\033[0;36m'

# Muestra un mensaje con un formato estándar.
function msg() {
  local type="$1"
  local message="$2"
  local color=""

  case "$type" in
    info) color="$COLOR_CYAN";;
    success) color="$COLOR_GREEN";;
    error) color="$COLOR_RED";;
    warn) color="$COLOR_YELLOW";;
    *) color="$COLOR_RESET";;
  esac

  echo -e "${color}[$(date +'%T')] ${message}${COLOR_RESET}"
}

# Comprueba si un comando existe.
function command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# --- 
# Funciones de Instalación
# --- 

# Instala Visual Studio Code.
function install_vscode() {
  msg "info" "Instalando Visual Studio Code..."

  if command_exists "code"; then
    msg "warn" "Visual Studio Code ya está instalado."
    return
  fi

  # Fallback a método manual
  sudo apt-get install wget gpg && \
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
  sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg && \
  rm -f microsoft.gpg

    echo "Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null

    sudo apt install apt-transport-https && \
    sudo apt update && \
    sudo apt install code -y
  

  if command_exists "code"; then
    msg "success" "Visual Studio Code instalado correctamente."
  else
    msg "error" "No se pudo instalar Visual Studio Code."
  fi
}

# Instala uv (de Astral).
function install_uv() {
  msg "info" "Instalando uv..."
  if command_exists "uv"; then
    msg "warn" "uv ya está instalado."
    return
  fi

  curl -LsSf https://astral.sh/uv/install.sh | sh
  # Añadir uv al PATH para la sesión actual
  # La instalación de uv se realiza en $HOME/.local/bin
  #source "$HOME/.local/bin/uv"

  if command_exists "uv"; then
    msg "success" "uv instalado correctamente."
    # Agregar los comandos de autocompletado según el tipo de shell
    if [ -n "$ZSH_VERSION" ]; then
      echo 'eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc
      echo 'eval "$(uvx --generate-shell-completion zsh)"' >> ~/.zshrc
      msg "info" "Completado de uv y uvx para zsh añadido a ~/.zshrc."
    elif [ -n "$BASH_VERSION" ]; then
      echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc
      echo 'eval "$(uvx --generate-shell-completion bash)"' >> ~/.bashrc
      msg "info" "Completado de uv y uvx para bash añadido a ~/.bashrc."
    else
      msg "warn" "Shell no reconocido. No se añadió el completado de uv/uvx."
    fi
  else
    msg "error" "No se pudo instalar uv."
  fi
}

# Instala Docker.
function install_docker() {
  msg "info" "Instalando Docker..."
  if command_exists "docker"; then
    msg "warn" "Docker ya está instalado."
  else
    sudo apt-get update
    sudo apt-get install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo "Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-"$VERSION_CODENAME"}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc" | sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null

    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  fi

  if command_exists "docker"; then
    msg "success" "Docker instalado."
    if sudo systemctl is-active --quiet docker; then
      msg "info" "El servicio Docker ya está en ejecución."
    else
      msg "info" "Iniciando el servicio Docker..."
      sudo systemctl start docker
    fi
  else
    msg "error" "No se pudo instalar Docker."
  fi
}

# Realiza el mantenimiento del sistema.
function system_maintenance() {
  msg "info" "Realizando mantenimiento del sistema..."
  msg "info" "Eliminando dependencias de apt no utilizadas..."
  sudo apt autoremove -q -y
  msg "info" "Actualizando paquetes de apt..."
  sudo apt full-upgrade -q -y
  msg "info" "Limpiando caché de paquetes..."
  sudo apt autoclean -q -y
  msg "success" "Mantenimiento del sistema completado."
}

# Instala paquetes de Flatpak.
function install_flatpak_packages() {
  msg "info" "Instalando paquetes de Flatpak..."
  if ! command_exists "flatpak"; then
    msg "error" "Flatpak no está instalado. Saltando la instalación de paquetes."
    return
  fi

  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  
  local flatpak_packages=(
    "md.obsidian.Obsidian"
    "com.stremio.Stremio"
  )
  
  flatpak install --system -y "${flatpak_packages[@]}"
  
  msg "info" "Actualizando aplicaciones de Flatpak..."
  flatpak update -y
  msg "success" "Paquetes de Flatpak instalados y actualizados."
}

# Instala Starship.
function install_starship() {
  msg "info" "Instalando Starship..."
  if command_exists "starship"; then
    msg "warn" "Starship ya está instalado."
    return
  fi

  # Desde https://starship.rs -- instalará o actualizará
  # Asegurarse de que /usr/local/bin exista para la instalación por defecto de starship
  sudo mkdir -p /usr/local/bin
  curl -sS https://starship.rs/install.sh | sh

  if command_exists "starship"; then
    msg "success" "Starship instalado correctamente."
  else
    msg "error" "No se pudo instalar Starship."
  fi
}

# Crea un enlace simbólico para la configuración de Starship.
function link_starship_config() {
  msg "info" "Creando enlace simbólico para starship.toml..."

  local source="$PROJECT_DIR/starship/starship.toml"
  local target="$HOME/.config/starship.toml"
  local target_dir="$(dirname "$target")"

  if [ ! -f "$source" ]; then
    msg "error" "No se encontró el archivo de configuración de Starship en '$source'."
    return 1
  fi

  mkdir -p "$target_dir"

  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ -L "$target" ]; then
        rm -f "$target"
    else
        msg "warn" "Ya existe 'starship.toml'. Creando copia de seguridad en '$target.bak'."
        mv -f "$target" "$target.bak"
    fi
  fi

  ln -sfv "$source" "$target"
  msg "success" "Enlace simbólico para starship.toml creado."
}

# --- 
# Flujo Principal
# --- 

function main() {
  msg "info" "Iniciando script de post-instalación adicional..."  
  install_vscode
  install_uv
  install_docker
  install_starship
  link_starship_config
  #install_flatpak_packages
  system_maintenance

  msg "success" "Script de post-instalación adicional completado."
}

main "$@"