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
source "./system/.dotfile_config"
#readonly PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"



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
  else
    # Instalar Oh My Zsh de forma no interactiva
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  # Comprobar e intentar establecer Zsh como shell predeterminado
  local zsh_path
  zsh_path=$(which zsh)
  if [ -z "$zsh_path" ]; then
    msg "error" "Zsh no está instalado o no se encuentra en el PATH. No se puede establecer como predeterminado."
    return 1
  fi

  if ! grep -q "$zsh_path" /etc/shells; then
    msg "info" "Añadiendo Zsh a los shells válidos..."
    echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
    if [ $? -ne 0 ]; then
      msg "error" "No se pudo añadir Zsh a /etc/shells. Se necesitan privilegios de administrador."
      return 1
    fi
  fi

  if [ "$SHELL" != "$zsh_path" ]; then
    chsh -s "$zsh_path"
    if [ $? -eq 0 ]; then
      msg "success" "Zsh establecido como el shell predeterminado. Por favor, cierre sesión y vuelva a iniciarla para que los cambios surtan efecto."
    else
      msg "error" "No se pudo establecer Zsh como el shell predeterminado. Inténtelo manualmente con: chsh -s $zsh_path"
    fi
  else
    msg "info" "Zsh ya es el shell predeterminado."
  fi
}

# Crea todos los enlaces simbólicos para los dotfiles.
function link_dotfiles() {
  msg "info" "Creando enlaces simbólicos para los dotfiles..."

  local source_target_pairs=(
    "$BASHRC_SOURCE:$BASHRC_TARGET"
    "$ZSHRC_SOURCE:$ZSHRC_TARGET"
    "$EDITORCONFIG_SOURCE:$EDITORCONFIG_TARGET"
    "$ZSH_CUSTOM_SOURCE:$ZSH_CUSTOM_TARGET"
    "$ESLINTRC_SOURCE:$ESLINTRC_TARGET"
    "$VIMRC_SOURCE:$VIMRC_TARGET"
    "$TMUX_CONF_SOURCE:$TMUX_CONF_TARGET"
    "$INPUTRC_SOURCE:$INPUTRC_TARGET"
    "$GITCONFIG_SOURCE:$GITCONFIG_TARGET"
  )

  for pair in "${source_target_pairs[@]}"; do
    local source="${pair%%:*}"
    local target="${pair##*:}"
    local target_name

    target_name=$(basename "$target")

    # Si el objetivo existe, crea una copia de seguridad.
    if [ -e "$target" ] || [ -L "$target" ]; then
      if [ -L "$target" ]; then
        rm -f "$target"
      else
        msg "warn" "Ya existe '$target_name'. Creando copia de seguridad en '$target.bak'."
        mv -f "$target" "$target.bak"
      fi
    fi

    # Crea el enlace simbólico.
    ln -svf "$source" "$target"
  done

  # Enlaces adicionales que no son dotfiles directos.
  msg "info" "Creando enlaces simbólicos adicionales..."
  mkdir -p "$HOME/.local/bin"
  ln -sfv /usr/bin/batcat "$HOME/.local/bin/bat"

  msg "success" "Enlaces simbólicos creados."
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

# Verifica la instalación de los plugins de Zsh.
function verify_zsh_plugins() {
  msg "info" "Verificando la instalación de los plugins de Zsh..."
  local a_plugin_path="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  local s_plugin_path="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  if [ -f "$a_plugin_path" ]; then
    msg "success" "zsh-autosuggestions encontrado en $a_plugin_path."
  else
    msg "error" "zsh-autosuggestions no se encontró en la ruta esperada."
  fi

  if [ -f "$s_plugin_path" ]; then
    msg "success" "zsh-syntax-highlighting encontrado en $s_plugin_path."
  else
    msg "error" "zsh-syntax-highlighting no se encontró en la ruta esperada."
  fi
}

# ---
# Flujo Principal
# ---

function main() {
  mkdir -p "$LOG_DIR"
  msg "info" "Iniciando la instalación de los dotfiles..."
  
    # Instalar paquetes
    install_packages
  
    # Verificar fzf
    if ! command_exists "fzf"; then
          msg "warn" "fzf no está instalado. La integración con el shell se omitirá."
        fi
      
        # Verificar plugins de Zsh
        verify_zsh_plugins
      
            # Instalar Oh My Zsh
            install_oh_my_zsh    
          # Crear enlaces simbólicos
          link_dotfiles
        
          # Configurar Git
          configure_git
        
          # Enlazar .tmux.conf e instalar plugins de TPM
          if command_exists "tmux"; then
            install_tpm_plugins
          else
            msg "warn" "Tmux no está instalado. Saltando la configuración de TPM y plugins."
          fi
        
          # Ejecutar script de post-instalación adicional si existe
          if [ -f "$SCRIPTS_DIR/aditionals-postinstall.sh" ]; then
            read -p "¿Desea ejecutar los pasos adicionales de post-instalación? (s/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Ss]$ ]]; then
              bash "$SCRIPTS_DIR/aditionals-postinstall.sh"
            fi
          fi
        
            msg "success" "¡Instalación de dotfiles completada!"
            msg "info" "Por favor, reinicie su shell o ejecute 'source ~/.bashrc' para aplicar los cambios."
          }        
        main "$@"
