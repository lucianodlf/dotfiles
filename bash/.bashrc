# ~/.bashrc: ejecutado por bash(1) para shells no interactivos.

# Si no se está ejecutando interactivamente, no hacer nada.
case $- in
    *i*) ;;
      *) return;;
esac

# No poner líneas duplicadas o líneas que comiencen con espacio en el historial.
HISTCONTROL=ignoreboth

# Añadir al historial, no sobrescribirlo.
shopt -s histappend

# Establecer la longitud del historial.
HISTSIZE=1000
HISTFILESIZE=2000

# Comprobar el tamaño de la ventana después de cada comando y, si es necesario,
# actualizar los valores de LINES y COLUMNS.
shopt -s checkwinsize

# Hacer 'less' más amigable para archivos de entrada no textuales.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Establecer un prompt de color si el terminal tiene la capacidad.
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt

# Si es un xterm, establecer el título a user@host:dir.
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Habilitar el soporte de color de ls.
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Cargar variables de configuración del proyecto
if [ -f "$PROJECT_DIR/system/.dotfile_config" ]; then
    source "$PROJECT_DIR/system/.dotfile_config"
fi

# Cargar alias generales.
if [ -f "$ALIASES_FILE" ]; then
    source "$ALIASES_FILE"
fi

# Habilitar las funciones de autocompletado programable.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Cargar configuración compartida de shell
if [ -f "$CONFIG_DIR/.shell_config" ]; then
    source "$CONFIG_DIR/.shell_config"
fi

eval "$(uv generate-shell-completion bash)"
eval "$(uvx --generate-shell-completion bash)"
