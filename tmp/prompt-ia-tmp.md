# **AI Instruction Prompt — Implementation of Improvements**

You must implement all the improvements listed below with precision, maintaining full consistency, idempotency, and modularity across the dotfiles project.
Where “shell_config” is mentioned, it refers to: **`system/.shell_config`**.
All steps must integrate cleanly with the existing project structure.

---

# **1. Zsh Custom Directory Integration (`ZSH_CUSTOM=$HOME/.zsh_custom`)**

Because `export ZSH_CUSTOM=$HOME/.zsh_custom` was added to `zsh/.zshrc`, you must implement the following:

### **1.1. Create a symbolic link**

* Add a symlink in the installation process to link `zsh/.zsh_custom` into the user’s home directory according to the current dotfiles structure.

### **1.2. Unify configuration into `system/.shell_config`**

Perform the following consolidations:

* Add:

  ```bash
  export PATH="$PATH:$HOME/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  ```
* Move all exports currently located in `system/.env` into `system/.shell_config` (avoid duplication).
* Move all variables/export definitions currently in `zsh/.zsh_custom/env.zsh` into `system/.shell_config`.
* Once everything is unified, remove:

  * `system/.env`
  * `zsh/.zsh_custom/env.zsh`
    Ensure code consistency after removal.

### **1.3. Plugin availability verification**

For the Zsh plugins loaded through:

* `$SHARE/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh`
* `$SHARE/share/zsh-autosuggestions/zsh-autosuggestions.zsh`

Add logic that:

1. **Verifies that the plugin files exist** after installation.
2. **Notifies the user** clearly if installation paths are missing or incorrect.

---

# **2. fzf Integration**

Add fzf shell integration exactly as described below, **but only after verifying that the `fzf` package is installed**.

### **2.1. Installation verification**

* In `install.sh`, add logic that checks whether `fzf` is installed and functional.
* If not installed, print a clear message.

### **2.2. Add fzf shell integration**

For **bash**:

```bash
# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"
```

For **zsh**:

```zsh
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
```

Insert these lines into the appropriate shell config only after installation is validated.

---

# **3. Load Unified Functions File**

Integrate the loading of `system/functions.zsh` into `system/.shell_config`.
After integration:

* Remove `zsh/.zsh_custom/functions.zsh`, as it is no longer needed.

---

# **4. Improve Default-Shell-to-Zsh Logic**

Replace and enhance the current functionality that sets Zsh as the default shell.
Use the provided example as a reference for:

* idempotency
* user notifications
* validation
* logging
* fallback flows

**Important:**
You MUST maintain consistency with the existing project architecture, not simply replace the existing implementation blindly.

Include the improved version of the following logic:

* verifying that Zsh is installed
* detecting the correct Zsh path
* ensuring path exists in `/etc/shells`
* handling fallback scenarios
* notifying the user when logout/login is required

Use the example as **inspiration**, but adapt the messages, flow, and behavior to preserve coherence with the current install script.

---

# **5. Unify All Symlink Creations**

Create a single unified function named:

```
link_dotfiles()
```

This function must handle **all symlink creation tasks**, including the new links:

1. `editors/.eslintrc.json` → user’s home directory
2. `editors/vim/.vimrc` → user’s home directory
3. (Include all previously existing symlinks)

Ensure consistent logging, idempotency, path resolution, and error handling.

---

# **6. Log File Generation: Store Logs in `logs/` Directory**

Modify the logging functionality to:

* save all generated logs inside the `logs/` directory
* preserve timestamped filenames
* print messages both to console and log file

Ensure that the directory is created if it does not exist.

---

# **7. Additional Post-Install Script**

Add the following behavior to `install.sh`:

* Check whether `scripts/aditionals-postinstall.sh` exists.

* If it exists, ask the user:

  **“Do you want to run the additional post-installation steps?”**

* If the user accepts:

  * Execute the script
  * For now, the script only prints a placeholder `echo` (future expansions will be added)

* If the user declines:

  * Continue installation normally

---

# **8. Verification Function for Zsh Plugins**

Create a dedicated function that verifies correct installation and functionality of:

1. `zsh-autosuggestions`
2. `zsh-syntax-highlighting`

### **Requirements:**

* Use **legacy-compatible POSIX commands** (no dependencies).
* Verification should check:

  * plugin presence
  * plugin loadability
  * absence of missing-path errors
  * correct resolution of the expected file paths
* Output descriptive success/error messages.

---

# **Additional Requirements**

* Whenever “shell_config” is mentioned, it refers to:
  **`system/.shell_config`**
* Maintain full consistency with the existing project.
* Ensure no duplicated definitions remain.
* Maintain modularity, clarity, and maintainability.

---

# **Useful References**

* [https://github.com/ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)
* [https://github.com/junegunn/fzf](https://github.com/junegunn/fzf)
* [https://github.com/junegunn/fzf?tab=readme-ov-file#setting-up-shell-integration](https://github.com/junegunn/fzf?tab=readme-ov-file#setting-up-shell-integration)

