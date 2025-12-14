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
COLOR_RESET='\033[0m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_CYAN='\033[0;36m'

# Rutas del proyecto
source "./system/.dotfile_config"
#readonly PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"
FONT_DIR="$HOME/.local/share/fonts"



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

# Muestra un mensaje y espera la entrada del usuario de forma compatible.
# @param {string} prompt_text - El texto a mostrar al usuario.
# La respuesta del usuario se almacena en la variable $REPLY.
function prompt_user() {
    local prompt_text="$1"
    
    if [ -n "$ZSH_VERSION" ]; then
        # En Zsh, la sintaxis `read -p` es para coprocesos.
        # Usamos `read "var?prompt"` para mostrar un prompt.
        # -k 1 lee un solo caracter. -r evita que la barra invertida escape caracteres.
        read -k 1 -r "REPLY?${prompt_text}"
        echo # Añadir nueva línea para formato
    else
        # En Bash, `read -p` muestra un prompt.
        # -n 1 lee un solo caracter.
        read -p "$prompt_text" -n 1 -r
        echo # Añadir nueva línea para formato
    fi
}

# Muestra un mensaje de ayuda.
function show_help() {
  cat << EOF
Uso: ./install.sh [OPCION]

Script de instalación y configuración para los dotfiles.

Opciones:
  --only-fonts      Instala exclusivamente las Nerd Fonts y sale.
  --only-nodejs     Instala/actualiza exclusivamente NVM (Node Version Manager) y Node.js, y sale.
  --help            Muestra esta ayuda y sale.
EOF
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

# Instala Nerd Fonts para la terminal.
function install_nerd_fonts() {
  msg "info" "Instalando Nerd Fonts..."

  if ! command_exists "curl"; then
    msg "error" "'curl' no está instalado. No se pueden descargar las fuentes."
    return 1
  fi

  if ! command_exists "fc-cache"; then
    msg "warn" "'fontconfig' no parece estar instalado (no se encontró 'fc-cache'). No se podrá actualizar la caché de fuentes."
  fi

  mkdir -p "$FONT_DIR"

  # URLs de las fuentes a instalar. Se ha corregido 'tree' por 'raw' para obtener el archivo real.
  local nerd_font_urls=(
    "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Bold/FiraCodeNerdFontMono-Bold.ttf"
    "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Light/FiraCodeNerdFontMono-Light.ttf"
    "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Medium/FiraCodeNerdFontMono-Medium.ttf"
    "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFontMono-Regular.ttf"
    "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraCode/Retina/FiraCodeNerdFontMono-Retina.ttf"
  )

  local failed_downloads=()
  local successful_downloads=0

  for url in "${nerd_font_urls[@]}"; do
    local font_name
    font_name=$(basename "$url")
    local target_file="$FONT_DIR/$font_name"

    msg "info" "Descargando '$font_name'..."
    
    # Descargar el archivo.
    # -f: Falla silenciosamente en errores del servidor.
    # -L: Sigue redirecciones.
    # -o: Especifica el archivo de salida (sobrescribe si existe).
    curl -fLo "$target_file" "$url"
    
    if [ $? -ne 0 ]; then
      failed_downloads+=("$font_name")
      msg "error" "Falló la descarga de '$font_name'."
    else
      msg "success" "'$font_name' descargada en $FONT_DIR."
      successful_downloads=$((successful_downloads + 1))
    fi
  done

  if [ ${#failed_downloads[@]} -gt 0 ]; then
    msg "error" "No se pudieron descargar las siguientes fuentes:"
    for font in "${failed_downloads[@]}"; do
      echo -e "${COLOR_RED}- ${font}${COLOR_RESET}"
    done
  fi

  if [ "$successful_downloads" -gt 0 ] && command_exists "fc-cache"; then
    msg "info" "Actualizando la caché de fuentes del sistema..."
    fc-cache -f -v
    msg "success" "Caché de fuentes actualizada."
  fi
  
  if [ ${#failed_downloads[@]} -eq 0 ]; then
    msg "success" "Todas las Nerd Fonts se instalaron correctamente."
  fi
}


# Instala o actualiza NVM (Node Version Manager) y opcionalmente Node.js.
function install_nvm_and_node() {
  msg "info" "Iniciando la instalación/actualización de NVM y Node.js..."

  # Verificamos si NVM_DIR ya está en el entorno ANTES de hacer nada.
  local nvm_dir_loaded_from_env=false
  if [ -n "$NVM_DIR" ]; then
    nvm_dir_loaded_from_env=true
  fi

  local nvm_installer_cmd="PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'"
  local run_installer=false

  # 1. Detectar instalación existente y preguntar para actualizar.
  if [ -s "$HOME/.nvm/nvm.sh" ]; then
    msg "info" "NVM ya está instalado."
    prompt_user "¿Desea re-descargar NVM para actualizarlo? (s/n): "
    if [[ $REPLY =~ ^[Ss]$ ]]; then
      msg "info" "Actualizando NVM..."
      run_installer=true
    else
      msg "info" "Se omitió la actualización de NVM."
    fi
  else
    msg "info" "NVM no está instalado. Descargando e instalando NVM..."
    run_installer=true
  fi

  if [ "$run_installer" = true ]; then
    eval "$nvm_installer_cmd"
    if [ $? -ne 0 ]; then
      msg "error" "Falló la ejecución del script de instalación de NVM."
      return 1
    fi
    msg "success" "El script de instalación de NVM se ejecutó correctamente."
  fi

  # 2. Cargar NVM en esta sesión para poder usarlo en los siguientes pasos.
  export NVM_DIR="$HOME/.nvm"
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
  else
    msg "error" "No se pudo encontrar el script nvm.sh en '$NVM_DIR'."
    return 1
  fi

  # 3. Validar y persistir la configuración del entorno solo si no existía previamente en el entorno.
  if [ "$nvm_dir_loaded_from_env" = true ]; then
    msg "info" "La variable de entorno NVM_DIR ya existe. No se modificarán los archivos de configuración del shell."
  else
    local shell_rc_file=""
    if [[ "$SHELL" == */zsh ]]; then
        shell_rc_file="$HOME/.zshrc"
    elif [[ "$SHELL" == */bash ]]; then
        shell_rc_file="$HOME/.bashrc"
    fi

    if [ -n "$shell_rc_file" ] && [ -f "$shell_rc_file" ]; then
      if ! grep -q 'NVM_DIR' "$shell_rc_file"; then
        msg "warn" "La configuración de NVM no se encontró en '$shell_rc_file'."
        
        local nvm_config_block
        nvm_config_block=$(cat <<'EOF'

# Configuración de NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
)
        echo "El siguiente bloque de código se añadirá a su archivo de configuración:"
        echo -e "${COLOR_YELLOW}${nvm_config_block}${COLOR_RESET}"
        prompt_user "The file [$shell_rc_file] will be modified to add NVM configuration. Do you want to continue? (s/n): "
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            msg "info" "Añadiendo configuración de NVM a '$shell_rc_file'..."
            echo "$nvm_config_block" >> "$shell_rc_file"
            msg "success" "Configuración añadida."
        else
            msg "warn" "Modificación cancelada. NVM no estará disponible en nuevas terminales."
        fi
      else
        msg "info" "La configuración de NVM ya existe en '$shell_rc_file'."
      fi
    else
      msg "warn" "No se pudo detectar un shell compatible (Bash o Zsh) o el archivo rc no existe para configurar NVM de forma persistente."
    fi
  fi

  # 4. Validar que NVM esté disponible como comando.
  if ! command_exists "nvm"; then
    msg "error" "NVM no se pudo cargar como comando. Compruebe la configuración."
    return 1
  fi
  msg "success" "NVM cargado y verificado correctamente."
  
  # 5. Opcionalmente, instalar Node.js
  local stable_version
  stable_version=$(nvm version-remote stable)
  
  prompt_user "¿Desea instalar la versión estable de Node.js ($stable_version)? (s/n): "
  if [[ $REPLY =~ ^[Ss]$ ]]; then
    msg "info" "Instalando Node.js ($stable_version)..."
    nvm install stable
    if [ $? -eq 0 ]; then
      msg "success" "Node.js (stable) instalado."
      msg "info" "Versión instalada:"
      nvm list stable
    else
      msg "error" "Falló la instalación de Node.js."
      return 1
    fi
  else
    msg "info" "Instalación de Node.js omitida."
  fi
  
  msg "success" "Proceso de NVM y Node.js completado."
}


# ---
# Flujo Principal
# ---

function main() {
  # Manejo de opciones de línea de comandos.
  # Permite ejecuciones parciales del script.
  if [ $# -gt 0 ]; then
    case "$1" in
      --help)
        show_help
        return 0
        ;;
      --only-fonts)
        # Opción exclusiva para instalar solo las fuentes y terminar.
        install_nerd_fonts
        return 0
        ;;
      --only-nodejs)
        # Opción exclusiva para instalar NVM y Node.js.
        install_nvm_and_node
        return 0
        ;;
      *)
        msg "error" "Opción desconocida: $1"
        show_help
        exit 1
        ;;
    esac
  fi

  # Flujo de instalación normal
  mkdir -p "$LOG_DIR"
  msg "info" "Iniciando la instalación de los dotfiles..."

  install_packages

  if ! command_exists "fzf"; then
    msg "warn" "'fzf' no está instalado. La integración con el shell se omitirá."
  fi

  verify_zsh_plugins
  install_oh_my_zsh
  link_dotfiles

  if command_exists "tmux"; then
    install_tpm_plugins
  else
    msg "warn" "'tmux' no está instalado. Saltando la configuración de TPM y plugins."
  fi

  if [ -f "$SCRIPTS_DIR/aditionals-postinstall.sh" ]; then
    prompt_user "¿Desea ejecutar los pasos adicionales de post-instalación? (s/n): "
    if [[ $REPLY =~ ^[Ss]$ ]]; then
      bash "$SCRIPTS_DIR/aditionals-postinstall.sh"
    fi
  fi

  msg "success" "¡Instalación de dotfiles completada!"
  msg "info" "Por favor, reinicie su shell o ejecute 'source ~/.bashrc' o 'source ~/.zshrc' para aplicar los cambios."
}

main "$@"
