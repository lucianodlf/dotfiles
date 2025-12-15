# dotfiles - Mis Dotfiles (...)

## Estructura del Proyecto

- **`bash/`**: Configs Bash (`.bashrc`).
- **`zsh/`**: Configs Zsh (`.zshrc`) y sus personalizaciones (`.zsh_custom`).
- **`system/`**: Directorio centralizado para variables compartidas, alias globales, listas de paquetes y configuraciones comunes (`.dotfile_config`, `.shell_config`, `.aliases`, `pkglist`, `.inputrc`, `functions.zsh`).
- **`git/`**: Configs GIT (`.gitconfig`).
- **`tmux/`**: Configs tmux (`.tmux.conf`).
- **`editors/`**: Configuración para editores como Neovim (`nvim/`), Vim (`vim/`), y archivos de configuración genéricos (`.editorconfig`, `.eslintrc.json`).
- **`docker/`**: Confgis docker
- **`ia/`**: Configs relacionados a IA
- **`scripts/`**: Scripts de automatización (`install.sh`, `uninstall.sh`, `aditionals-postinstall.sh`).
- **`old-dotfiles/`**: Guarda las configuraciones heredadas y desorganizadas (backup)
- **`logs/`**: Directorio para almacenar los archivos de registro de la instalación.
- **`tests/`**: Docker sandbox for test

## Instrucciones de Instalación

El script principal es `scripts/install.sh`.

```bash
git clone https://github.com/lucianodlf/dotfiles.git
cd ~/dotfiles
. scripts/install.sh
```

- Instalará paquetes esenciales del sistema (definidos en `system/pkglist`).
- Instalará Oh My Zsh y configurará Zsh como el shell predeterminado.
- Creará enlaces simbólicos para todos los archivos de configuración en tu directorio `HOME` (ej. `.bashrc`, `.zshrc`, `.gitconfig`, `.tmux.conf`, etc.).
- Configurará Git con tus datos. (`.dotfile_config`)
- Instalará y configurará los plugins de Tmux.
- Verificará la instalación de plugins clave de Zsh.

## Post instalacion (adicionales)

**Ejecutar el script de post-instalación adicional (opcional):**
`scripts/aditionals-postinstall.sh`. Este script contiene instalaciones de software más específicas

- Instalación de Visual Studio Code.
- Instalación de `uv` (herramienta de Astral para Python).
- Instalación de Docker y sus componentes.
- Instalación de paquetes Flatpak (Obsidian, Stremio).
- Mantenimiento del sistema (`apt autoremove`, `full-upgrade`, `autoclean`).
- Las variables de entorno y configuraciones compartidas se centralizan en `system/.shell_config` y `system/.dotfile_config`.
- Los alias se unifican en `system/.aliases`.
- Las funciones de shell reutilizables se encuentran en `system/functions.zsh`.

### Testear

- Con Dockerfile crear imagen de test

```bash
cd ~/dotfiles
sudo docker build -f ./tests/Dockerfile -t dotfiles-test .

## opcion 1
docker run -it --rm -u rafiki -v .:/home/rafiki/dotfiles dotfiles-test:latest

## opcion 2
. ./tests/run-sandbox-container.sh
```

- Ejecutar instalacion con `. dotfiles/scripts/install.sh` dentro del docker.

### Entorno Recomendado

- Por ahora esta centrado en entornos **Ubuntu (Debian-based)**.

## Referencias útiles

- **Visual Studio Code (Linux):** [https://code.visualstudio.com/docs/setup/linux#\_install-vs-code-on-linux](https://code.visualstudio.com/docs/setup/linux#_install-vs-code-on-linux)
- **UV (Astral):** [https://docs.astral.sh/uv/getting-started/installation/#installation-methods](https://docs.astral.sh/uv/getting-started/installation/#installation-methods)
- **Docker:** [https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)
- https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH
- https://github.com/zsh-users/zsh-autosuggestions
- https://github.com/junegunn/fzf

## Gracias

Ideas e insipiraciónes:

- https://github.com/margrevm/pop-os-post-install/tree/v22.04
- https://github.com/webpro/awesome-dotfiles
- https://dotfiles.github.io/inspiration/


## Info adicional (no integrados)
- Para GNOME (Lenovo Battery Threshold): https://extensions.gnome.org/extension/4798/thinkpad-battery-threshold/



## Info adicional (no integrados)
- Para GNOME (Lenovo Battery Threshold): https://extensions.gnome.org/extension/4798/thinkpad-battery-threshold/

### Lector de huellas (Lenovo)
- sudo fwupdmgr update
- sudo apt update && sudo apt install fprintd libpam-fprintd
- sudo pam-auth-update

