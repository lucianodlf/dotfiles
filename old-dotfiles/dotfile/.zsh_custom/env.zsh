ulimit -n 2048

# ZSH context highlighting
SHARE="${PACKAGES:-/usr}"
source "$SHARE/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$SHARE/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# User configuration
export PATH="$PATH:$HOME/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# For tab completion
#export FIGNORE=".o:~:Application Scripts"

#export EDITOR='nvim'
#export OSC_EDITOR='nvim' # OpenShift

# Proxy
#[[ -s $HOME/.proxy ]] && source $HOME/.proxy

# FZF
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*" --glob "!node_modules/*" --glob "!vendor/*" --glob "!build/*" --glob "!dist/*" --glob "!target/*" --glob "!.idea/*" --glob "!.cache/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='
--height 30%
--border
--cycle
--prompt=" "
--pointer="▶"
--marker="✓"
'

# zsh-completions
# fpath=($PACKAGES/share/zsh-completions $fpath)

# Import autocompletions
fpath+=~/.zfunc
#autoload -Uz compinit && compinit
#zstyle ':completion:*' menu select
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=180'
export PATH=$PATH:$HOME/.local/bin

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#export DENO_INSTALL="/home/rafiki/.deno"
#export PATH="$DENO_INSTALL/bin:$PATH"
#eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# asdf
# ASDF_DIR=$HOME/.asdf
# if [ -f $ASDF_DIR/asdf.sh ]; then
#   source $ASDF_DIR/asdf.sh
#   fpath=($ASDF_DIR/completions $fpath)
# fi

# Eliminate duplicate path entries
typeset -U PATH
