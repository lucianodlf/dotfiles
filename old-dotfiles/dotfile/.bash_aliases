#TMP de proyectos
alias inncd='cd ~/Projects/app-innovat'
alias innup='cd ~/Projects/app-innovat && dk compose -f dev.yml up'
alias innbe='(cd ~/Projects/app-innovat/backend && code .)'
alias innfe='(cd ~/Projects/app-innovat/frontend && code .)'
#SSH
alias sshinn='ssh fede@ingarue.santafe-conicet.gov.ar'


alias cat='bat --theme TwoDark'
alias cpwd='pwd | tr -d "\n" | pbcopy'
alias l='ls -la'
alias ll="ls -alF --color=auto"
alias ls="ls -A --color=auto"
alias lt='tree'
alias pubkey='pbcopy < ~/.ssh/id_ed25519.pub'
alias sz='source ~/.zshrc'
alias web='python -m http.server'
alias cc="clear"

#docker
alias dcls="sudo docker container ls"
alias dcps="sudo docker container ps"
alias dcstr="sudo docker container start"
alias dcstp="sudo docker container stop"
alias dk="sudo docker"

alias cat='bat --theme TwoDark'
alias cpwd='pwd | tr -d "\n" | pbcopy'
alias l='ls -la'
alias ll="ls -alF --color=auto"
alias ls="ls -A --color=auto"
alias lt='tree'
alias pubkey='pbcopy < ~/.ssh/id_ed25519.pub'
alias sz='source ~/.zshrc'
alias web='python -m http.server'
alias cc="clear"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  alias xclipc='xclip -in -selection clip'
  alias xclipp='xclip -out -selection clip'
  alias pbcopy='xclip -in -selection clip'
  alias pbpaste='xclip -out -selection clip'
fi

# Git
#alias git='hub'
alias clone='git clone'
alias gbls="git for-each-ref --format='%(committerdate) %09 %(authorname) %09 %(refname)' | sort -k5n -k2M -k3n -k4n"
alias gcm='git commit -m'
alias get='git'
#alias gfa='git fetch --all'
#alias gkd='git ksdiff'
alias glc='git log -p --follow -n 1'
alias gs='git status'
alias gti='git'
alias merge='git merge'
alias pull='git pull'
alias push='git push'
alias switch='git switch'

#docker
alias dcls="sudo docker container ls"
alias dcps="sudo docker container ps"
alias dcstr="sudo docker container start"
alias dcstp="sudo docker container stop"
alias dk="sudo docker"
