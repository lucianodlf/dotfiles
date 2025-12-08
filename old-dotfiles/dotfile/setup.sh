#!/usr/bin/bash

set -e

install_oh_my_zsh() {
  msg "Installing Oh My Zsh"
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    msg "Oh My Zsh already installed"
  else
    # From https://github.com/robbyrussell/oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    msg "Oh My Zsh installed"
  fi
}

install_packages() {
  msg "Installing packages"
  #while IFS= read -r line; do
  #  sudo apt-add-repository --yes "$line"
  #done <"repolist"

  sudo apt-get --assume-yes install $(cat pkglist)
  msg "Packages installed"
}

link_dotfiles() {
  msg "Linking dotfiles"

  local dotfiles
  dotfiles=$(pwd)

  local files
  files=($(find . -maxdepth 1 -name '.*' -type f))

  for i in "${files[@]}"; do
    if [[ $i = */.DS_Store ]]; then
      msg "Skipping $i"
    else
      local file
      file=${i//^../} #"$(echo $i | sed -e 's/^..//')"
      ln -fsv "$dotfiles/$file" "$HOME/$file"
    fi
  done

  # ZSH custom setup
  ln -fsv "$dotfiles/.zsh_custom" "$HOME"

  # Create the nvim configuration
  mkdir -p "$HOME/.config"
  ln -fsvn "$dotfiles/nvim" "$HOME/.config/nvim"

  # Git
  mkdir -p "$HOME/.config/git"
  ln -fsv "$dotfiles/globalignore" "$HOME/.config/git/ignore"

  # Link bat for batcat (replace cat)
  mkdir -p ~/.local/bin
  ln -fsv /usr/bin/batcat ~/.local/bin/bat

  #Theme xfce4-terminl (Dracula) probar si funca.... o si no hacer cp ..
  ln -fsv "$dotfiles/xfce4-terminl/Dracula.theme" "$HOME/.local/share/xfce4/terminal/colorschemes/Dracula.theme"
  msg "Dotfiles linked"
}

install_tpm() {
  msg "Installing tpm"
  if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    msg "tpm already installed"
  else
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    msg "tpm installed"
  fi
}


install_font() {
  msg "Installing nerd font"
  if system_profiler SPFontsDataType 2>/dev/null | grep -q "Hasklug Nerd Font Complete"; then
    msg "Nerd font already installed"
  else
    mkdir -p "$HOME/.local/share/fonts"	  
    cd "$HOME/.local/share/fonts" && {
      curl -O https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf
      cd -
    }
    msg "Nerd font installed"
  fi
}

configure_git() {
  msg "Configuring git"

  local name
  name="$(git config --global --includes user.name)" || true
  if [[ -z "$name" ]]; then
    echo "Enter your full name:"
    read -r name
    echo "Enter your email address:"
    read -r email

    echo "[user]" >>"$HOME/.gitconfig.local"
    echo "  name = $name" >>"$HOME/.gitconfig.local"
    echo "  email = $email" >>"$HOME/.gitconfig.local"

    msg "git configured"
  else
    msg "git already configured"
  fi
}

msg() {
  if [[ "$1" != "" ]]; then
    echo "[$(date +'%T')]" "$1"
  fi
}

main() {
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    install_packages
    install_oh_my_zsh
    link_dotfiles
    configure_git
    ## configure_neovim
    install_tpm
    install_font
  else
    msg "Unrecognized operating system"
  fi
}

msg "Init setup dotfiles config...."

main
return
