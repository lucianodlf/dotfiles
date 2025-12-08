# My custom dotfiles

## How to use

clone repository in $HOME and copy doftile use

```bash
git clone https://github.com/lucianoldf/dotfiles.git
cd dotfile
. setup.sh
```

## Install docker engine (Ubuntu - Linux mint)

https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

> [!NOTE]
> If you use an Ubuntu derivative distro, such as Linux Mint, you may > need to use UBUNTU_CODENAME instead of VERSION_CODENAME.

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

-   Instalar

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

-   Verificar

```bash
sudo docker run hello-world
```

## TMUX

### TMP Plugin

Installing plugins

> Add new plugin to ~/.tmux.conf with set -g @plugin '...'
> Press prefix + I (capital i, as in Install) to fetch the plugin.

You're good to go! The plugin was cloned to ~/.tmux/plugins/ dir and sourced.


## Vscode
- Profile gist:

https://vscode.dev/profile/github/af1929d2b06d7b7ed0b3edad4d5bba1a

- Profile file:

`~/dotfile/code/rafiki-profile-vscode.code-profile`

## Default ZSH shell

`chsh -s $(which zsh)`
- Is your shell set to zsh? Last field of grep $USER /etc/passwd
- Is Zsh a valid login shell? grep zsh /etc/shells


## Config xfce4
- Copiar xfce4/xfconf/xfce-perchannel-xml/ en: `/home/rafiki/.config/xfce4/xfconf/xfce-perchannel-xml`

