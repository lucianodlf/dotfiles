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

  echo -e "${color}[$(date +'%T')] ${message}${COLOR_RESET}" | tee -a "$LOG_FILE"
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

# Instala los paquetes listados en el archivo pkglist.
function install_packages() {
  msg "info" "Instalando paquetes..."

  if [ ! -f "$PKGLIST_FILE" ]; then
    msg "error" "No se encontró el archivo de lista de paquetes en $PKGLIST_FILE."
    return 1
  fi

  # Intenta actualizar; si falla, el script se detiene aquí, ya que es un fallo crítico.
  msg "info" "Update repos..."
  sudo apt-get update -qq || { msg "error" "Error al actualizar apt. Saliendo."; exit 1; }

  # Instalar paquetes
  sudo apt-get --assume-yes install -q --no-install-recommends $(cat "$PKGLIST_FILE")
  msg "success" "Paquetes instalados."
}

# Instala Oh My Zsh y lo establece como el shell predeterminado.
function install_oh_my_zsh() {
  msg "info" "Instalando Oh My Zsh..."

  if [ -d "$HOME/.oh-my-zsh" ]; then
    msg "warn" "Oh My Zsh ya está instalado. Saltando la instalación."
    return
  fi

  # Instalar Oh My Zsh de forma no interactiva
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # Establecer Zsh como el shell predeterminado
  if [ "$SHELL" != "$(which zsh)" ]; then
    if grep -q "$(which zsh)" /etc/shells; then
      chsh -s "$(which zsh)"
      if [ $? -eq 0 ]; then
        msg "success" "Zsh establecido como el shell predeterminado."
        source 
      else
        msg "error" "No se pudo establecer Zsh como el shell predeterminado."
      fi
    else
      msg "error" "Zsh no es un shell de inicio de sesión válido."
    fi
  fi
}

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

# Crea un enlace simbólico para el archivo .zshrc.
function link_zshrc() {
  msg "info" "Creando enlace simbólico para .zshrc..."

  if [ -f "$ZSHRC_TARGET" ]; then
    msg "warn" "Ya existe un archivo .zshrc. Se creará una copia de seguridad en $ZSHRC_TARGET.bak."
    mv "$ZSHRC_TARGET" "$ZSHRC_TARGET.bak"
  fi

  ln -sfv "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
  msg "success" "Enlace simbólico para .zshrc creado."
}

# Configura Git con los valores de las variables globales.
function configure_git() {
  msg "info" "Configurando Git..."

  if [ ! -f "$GITCONFIG_SOURCE" ]; then
    msg "error" "No se encontró el archivo de configuración de Git en $GITCONFIG_SOURCE."
    return 1
  fi

  # Reemplazar los valores de las variables en el archivo .gitconfig
  sed -e "s/{{GIT_AUTHOR_NAME}}/$GIT_AUTHOR_NAME/g" \
      -e "s/{{GIT_AUTHOR_EMAIL}}/$GIT_AUTHOR_EMAIL/g" \
      "$GITCONFIG_SOURCE" > "$GITCONFIG_TARGET"

  msg "success" "Git configurado."
}

# Crea un enlace simbólico para el archivo .editorconfig.
function link_editorconfig() {
  msg "info" "Creando enlace simbólico para .editorconfig..."

  if [ -f "$EDITORCONFIG_TARGET" ]; then
    msg "warn" "Ya existe un archivo .editorconfig. Se creará una copia de seguridad en $EDITORCONFIG_TARGET.bak."
    mv "$EDITORCONFIG_TARGET" "$EDITORCONFIG_TARGET.bak"
  fi

  ln -sfv "$EDITORCONFIG_SOURCE" "$EDITORCONFIG_TARGET"
  msg "success" "Enlace simbólico para .editorconfig creado."
}

# Crea un enlace simbólico para el archivo .tmux.conf.
function link_tmux_conf() {
  msg "info" "Creando enlace simbólico para .tmux.conf..."

  if [ -f "$TMUX_CONF_TARGET" ]; then
    if [ -L "$TMUX_CONF_TARGET" ]; then
        rm "$TMUX_CONF_TARGET"
    else
        msg "warn" "Ya existe un archivo .tmux.conf no simbólico. Se creará una copia de seguridad en $TMUX_CONF_TARGET.bak."
        mv "$TMUX_CONF_TARGET" "$TMUX_CONF_TARGET.bak"
    fi
  fi

  ln -sfv "$TMUX_CONF_SOURCE" "$TMUX_CONF_TARGET"
  msg "success" "Enlace simbólico para .tmux.conf creado."
}

# Otros enlaces
function link_others() {
  msg "info" "Creando enlace simbólico para remplazar cat (batcat)..."

  # Link bat for batcat (replace cat)
  mkdir -p ~/.local/bin
  ln -fsv /usr/bin/batcat ~/.local/bin/bat

  msg "success" "Enlace simbólico para .tmux.conf creado."
}

# Instala TPM (Tmux Plugin Manager) y los plugins configurados.
function install_tpm_plugins() {
  msg "info" "Comprobando e instalando TPM y plugins de Tmux..."

  if [ -d "$TPM_PATH" ]; then
    msg "warn" "TPM ya está instalado en $TPM_PATH. Saltando la clonación."
  else
    msg "info" "Clonando TPM desde $TPM_REPO..."
    if command_exists "git"; then
      git clone "$TPM_REPO" "$TPM_PATH"
      if [ $? -ne 0 ]; then
        msg "error" "No se pudo clonar TPM. Abortando la instalación de plugins."
        return 1
      fi
      msg "success" "TPM clonado correctamente."
    else
      msg "error" "Git no está instalado. No se puede clonar TPM."
      return 1
    fi
  fi

  if [ -f "$TPM_PATH/bin/install_plugins" ]; then
    msg "info" "Iniciando la instalación automática de plugins de Tmux..."
    "$TPM_PATH/bin/install_plugins"
    if [ $? -ne 0 ]; then
      msg "error" "El script de instalación de plugins de TPM falló. Asegúrate de que tmux esté disponible."
      return 1
    fi
    msg "success" "Plugins de Tmux instalados automáticamente."
  else
    msg "error" "No se encontró el script de instalación de plugins de TPM en $TPM_PATH/bin/install_plugins."
    return 1
  fi
}

# ---
# Flujo Principal
# ---

function main() {
  msg "info" "Iniciando la instalación de los dotfiles..."
  
  # Instalar paquetes
  install_packages
  
  # Instalar Oh My Zsh
  install_oh_my_zsh

  # Crear enlaces simbólicos
  link_bashrc
  link_zshrc
  link_editorconfig
  link_others

  # Configurar Git
  configure_git

  # Enlazar .tmux.conf e instalar plugins de TPM
  if command_exists "tmux"; then
    link_tmux_conf
    install_tpm_plugins
  else
    msg "warn" "Tmux no está instalado. Saltando la configuración de TPM y plugins."
  fi

  msg "success" "¡Instalación de dotfiles completada!"
  msg "info" "source $BASHRC_TARGET"
  source "$BASHRC_TARGET"
}

main "$@"
