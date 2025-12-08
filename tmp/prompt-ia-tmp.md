# Implementation of Improvements

**AI Instructions Prompt (English Version)**

You must follow all the instructions below to implement improvements in a dotfiles project.
Maintain the structure, formatting, and the technical meaning exactly as expressed.

---

## 1. Add functionality in `install.sh` to install packages (similar to `install_packages()` in `setup.sh`)

* This functionality must be the **first step** in `main`.
* Packages must be obtained from a `pkglist` file (create it under `system/`, following the example in `old-dotfiles/dotfile/pkglist`).
* Always consider creating **global configuration variables** in `.dotfile_config` to reference paths.
* The installation must be **unattended**.
* Perform a **repository update** before installation.

---

## 2. Improve `old-dotfiles/dotfile/.zshrc` following the same criteria used for `.bashrc` and create the new file at `zsh/.zshrc`:

* Import the already-created unified reusable `.aliases` file.
* If needed, modify that `.aliases` file to include aliases currently in `.zshrc` (avoid duplicates).
* Add relevant comments.
* The following code snippet must be used in a modular, separated manner so it can be reused in both `.zshrc` and `.bashrc`:

```
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

# change ollama_models
#export OLLAMA_MODELS='/home/rafiki/ollama/models'

alias lzd='lazydocker'
eval "$(starship init zsh)"

eval "$(uv generate-shell-completion zsh)"
```

* Implement all necessary modifications (use a clear modular/reusable criterion, such as a separate config file under `system/` shared by both shells).
* Integrate these changes into the new `bash/.bashrc` and `zsh/.zshrc`.

---

## 3. Add functionality in `install.sh` to install **Oh My Zsh** (similar to `install_oh_my_zsh()` in `setup.sh`)

* This functionality must be the **second step** in `main`.
* Reference command:
  `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
* Set Zsh as the default shell. Consider using `chsh -s $(which zsh)` and include alternative viable approaches.
* Verify that Zsh is correctly set as the default shell:

  * Check the last field of `grep $USER /etc/passwd`
  * Check if Zsh is a valid login shell: `grep zsh /etc/shells`
* Installation must be **unattended**.
* Verify the installation is correct.

---

## 4. Update `install.sh` to add the symlink following the example of `link_bashrc`.

---

## 5. Update `install.sh` to generate a **log file** of the execution.

Messages and errors must be recorded **both in console and in the log file**.
Include a timestamp in the log filename.

---

## 6. Update `install.sh` to add Git configuration functionality, reusing global variables from `system/.dotfile_config`

* This configuration must be integrated, coherent and consistent, producing a `.gitconfig` in `$HOME` that merges:

  * the current `old-dotfiles/dotfile/.gitconfig`
  * the values of the global variables
* The new `.gitconfig` must be placed at `git/.gitconfig`.
* Change `editor = vim` to `editor = nvim`.

---

## 7. Modify `install.sh` to create a symbolic link of `editors/.editorconfig` into `$HOME`.

---

## 8. Modify `install.sh` to install tmux plugins using **TPM**

([https://github.com/tmux-plugins/tpm](https://github.com/tmux-plugins/tpm))

* Use `old-dotfiles/dotfile/.tmux.conf` as the base.
* Create a new, organized, well-commented version under `tmux/`.
* Integrate and automate installation.
* You may use the following example, but fix anything needed to make it compatible with the current project structure.

BEGIN EXAMPLE (for reference)
-------------

## 🚀 Tmux Plugin Installation Implementation

### 1. Required Configuration Variables

To maintain **modularity**, define the tmux-related variables in your shared configuration file `system/.dotfile_config` (assuming you already have it referenced and loaded in `install.sh`).

```bash
# system/.dotfile_config (Example)
# ... other variables ...

# Tmux variables
TMUX_PLUGINS_DIR="$HOME/.tmux/plugins"
TPM_REPO="https://github.com/tmux-plugins/tpm"
TPM_PATH="$TMUX_PLUGINS_DIR/tpm"
```

### 2. `install_tpm_plugins()` Function for `install.sh`

Add this function to your `scripts/install.sh` script. Ensure that `tmux` is installed (assumed for this stage).

```bash
# scripts/install.sh (Add this function in the 'Installation Functions' section)
# ...

# Create a symbolic link for the .tmux.conf file.
function link_tmux_conf() {
  local TMUX_CONF_SOURCE="$PROJECT_DIR/tmux/.tmux.conf" # Assuming this path
  local TMUX_CONF_TARGET="$HOME/.tmux.conf"

  msg "info" "Creating symbolic link for .tmux.conf..."

  if [ -f "$TMUX_CONF_TARGET" ]; then
    # Check if it is a symbolic link and remove it before recreating.
    if [ -L "$TMUX_CONF_TARGET" ]; then
        rm "$TMUX_CONF_TARGET"
    else
        msg "warn" "A non-symlink .tmux.conf already exists. A backup will be created at $TMUX_CONF_TARGET.bak."
        mv "$TMUX_CONF_TARGET" "$TMUX_CONF_TARGET.bak"
    fi
  fi

  ln -sfv "$TMUX_CONF_SOURCE" "$TMUX_CONF_TARGET"
  msg "success" "Symbolic link for .tmux.conf created."
}


# Install TPM (Tmux Plugin Manager) and the configured plugins.
function install_tpm_plugins() {
  msg "info" "Checking and installing TPM and Tmux plugins..."

  # 1. Check if TPM is already cloned
  if [ -d "$TPM_PATH" ]; then
    msg "warn" "TPM is already installed at $TPM_PATH. Skipping clone."
  else
    # 2. Clone TPM if it does not exist
    msg "info" "Cloning TPM from $TPM_REPO..."
    if command_exists "git"; then
      git clone "$TPM_REPO" "$TPM_PATH"
      if [ $? -ne 0 ]; then
        msg "error" "Failed to clone TPM. Aborting plugin installation."
        return 1
      fi
      msg "success" "TPM successfully cloned."
    else
      msg "error" "Git is not installed. Cannot clone TPM."
      return 1
    fi
  fi

  # 3. Install the plugins automatically
  if [ -f "$TPM_PATH/bin/install_plugins" ]; then
    msg "info" "Starting automatic installation of Tmux plugins (requires tmux running)."
    
    # Attempt to install plugins without starting a real tmux session
    "$TPM_PATH/bin/install_plugins"
    
    if [ $? -ne 0 ]; then
      msg "error" "TPM plugin installation script failed. Ensure tmux is available."
      return 1
    fi
    msg "success" "Tmux plugins installed automatically."
  else
    msg "error" "TPM plugin installation script not found at $TPM_PATH/bin/install_plugins."
    return 1
  fi
}
```

### 3. Integration into the `main()` of `install.sh`

Call the new linking and plugin install functions in the main flow, **after** creating the symbolic link for `.tmux.conf` to ensure the config file with the plugin list is present.

```bash
# scripts/install.sh (Modification of the main function)

function main() {
  msg "info" "Starting dotfiles installation..."

  # Create symbolic links
  link_bashrc
  # Call function to link .tmux.conf before installing plugins
  link_tmux_conf

  # Install TPM and plugins
  if command_exists "tmux"; then
    install_tpm_plugins
  else
    msg "warn" "Tmux is not installed. Skipping TPM and plugin installation."
  fi
  

  msg "success" "Dotfiles installation completed!"
  msg "info" "source $BASHRC_TARGET"
  source "$BASHRC_TARGET"
}

main "$@"
```

### Summary of Automated Flow

1. **`link_tmux_conf`**: Creates a symbolic link from `tmux/.tmux.conf` to `~/.tmux.conf`. This ensures your plugin list (`set-option -g @plugin '...'`) is available.
2. **`install_tpm_plugins`**:

   * Checks if `$HOME/.tmux/plugins/tpm` exists.
   * If not, **clones the TPM repository** using `git clone`.
   * Executes the script **`~/.tmux/plugins/tpm/bin/install_plugins`**. This script automatically reads your `~/.tmux.conf` (now linked) and clones/updates all plugins listed under `set-option -g @plugin`.

## This solution is **idempotent** because it only clones TPM if it doesn't exist, and TPM’s `install_plugins` script is designed to be safe (no unnecessary reinstalls).

END EXAMPLE

---

## 9. Finally, verify that all these changes are correct and fully integrated.

---

# Useful References

* [https://github.com/ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)
* [https://github.com/tmux-plugins/tpm](https://github.com/tmux-plugins/tpm)

---

