#!/bin/bash

# Funciones de shell compartidas.

# Lista los componentes del PATH, uno por línea.
function path() { echo -e ${PATH//:/\n}; }

# Convierte hexadecimal a decimal.
function h2d() { printf '%d\n' 0x"$1"; }

# Convierte decimal a hexadecimal.
function d2h() { printf '%x\n' "$1"; }

# git log --author
function gla() { git log --author "$1"; }

# Imprime una tabla de colores.
function colours() {
  for i in {0..255}; do
    if ((i < 10)); then
      prefix="    "
    elif ((i < 100)); then
      prefix="   "
    else
      prefix="  "
    fi
    printf "\x1b[48;5;${i}m\x1b[38;5;$[255-i]m${prefix}${i} "
    if (((i+1)%16 == 0)); then
      printf "\n"
    fi
  done
  printf "\x1b[0m\n"
}

# Muestra el proceso que escucha en un PUERTO.
function wh() {
  if [[ $# -eq 0 ]]; then
    echo "uso: wh PUERTO"
  else
    PID=$(netstat -vanp tcp | grep "\*.$1 " | awk '{ print $9 }')
    if [[ ${PID} -eq 0 ]]; then
      echo "no hay pid para el puerto $1"
    else
        ps -a "${PID}"
    fi
  fi
}

# Corrige un error tipográfico en el comando anterior.
function fix() {
  if [[ $# -ne 2 ]]; then
    echo "uso: fix [malo] [bueno]"
  else
    local cmd
    cmd=$(fc -ln -1 | sed -e 's/^ +//' | sed -e "s/$1/$2/")
    eval "$cmd"
  fi
}

# Decodifica una URL.
function urldecode() {
  echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x\1/g;')"
}

# ls -l which $($1)
function lw() {
  if [[ $# -eq 0 ]]; then
    echo "uso: lw <ejecutable>"
  else
    eza -alm $(which "$1")
  fi
}

# Comprobación de descargas
dlc() {
  if [[ $# -ne 3 ]]; then
    echo "uso: dlc <algoritmo> <esperado> <archivo>"
  else
    case $1 in
      md5|5) command echo "$2" "$3" | md5sum --check ;;
      sha256|256) command echo "$2" "$3" | sha256sum --check ;;
      sha512|512) command echo "$2" "$3" | sha512sum --check ;;
      *) echo "el algoritmo debe ser md5, sha256 o sha512" ;;
    esac
  fi
}
