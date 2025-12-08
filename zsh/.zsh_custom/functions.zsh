# List path components, one per line
function path() { echo -e ${PATH//:/\\n}; }

# Convert hex to decimal
function h2d() { printf '%d\n' 0x"$1"; }

# Convert decimal to hex
function d2h() { printf '%x\n' "$1"; }

# git log --author
function gla() { git log --author "$1"; }

# Print out a color table
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

# wh = "who has" -- print the process listening on PORT
function wh() {
  if [[ $# -eq 0 ]]; then
    echo "usage: wh PORT"
  else
    PID=$(netstat -vanp tcp | grep "\*\.$1 " | awk '{ print $9 }')
    if [[ ${PID} -eq 0 ]]; then
      echo "no pid for port $1"
    else
        ps -a "${PID}"
    fi
  fi
}

# Inspired by Brett Terpstra
# Imagine you've made a typo in a command, e.g., `car foo.txt`
# You want to rerun the previous command, changing the first instance of `car` to `cat`
# Just run `fix car cat`
function fix() {
  if [[ $# -ne 2 ]]; then
    echo "usage: fix [bad] [good]"
  else
    local cmd
    cmd=$(fc -ln -1 | sed -e 's/^ +//' | sed -e "s/$1/$2/")
    eval "$cmd"
  fi
}

# Decode a URL
function urldecode() {
  echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x\1/g;')"
}

# ls -l which $($1)
function lw() {
  if [[ $# -eq 0 ]]; then
    echo "usage: lw <executable>"
  else
    eza -alm $(which "$1")
  fi
}

# Download check
dlc() {
  if [[ $# -ne 3 ]]; then
    echo "usage: dlc <algorithm> <expected> <file>"
  else
    case $1 in
      md5|5) command echo "$2" "$3" | md5sum --check ;;
      sha256|256) command echo "$2" "$3" | sha256sum --check ;;
      sha512|512) command echo "$2" "$3" | sha512sum --check ;;
      *) echo "algorithm must be md5, sha256, or sha512" ;;
    esac
  fi
}