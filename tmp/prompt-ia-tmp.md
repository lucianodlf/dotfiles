# **AI Instruction Prompt — Post-Install Automation Enhancements**

These instructions define all improvements that must be implemented in the script **`aditionals-postinstall.sh`**, as well as some additional changes required across the project.

Your task is to **automate all installation steps**, verify results, and update the project consistently, modularly, and without duplicated code.

Follow every requirement exactly.

---

# **1. Integrate Visual Studio Code Installation (apt Repository Method)**

Implement full automation of Visual Studio Code installation using the official Microsoft repository.

Your responsibilities:

### **1.1. Validate the following debconf command**

```
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
```

If the command fails, detect the error and automatically fall back to **manual repository installation**.

### **1.2. Implement the manual repository installation fallback**

Use the official method:

#### **Install Microsoft GPG key**

```
sudo apt-get install wget gpg &&
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg &&
sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg &&
rm -f microsoft.gpg
```

#### **Create the repository file**

Create `/etc/apt/sources.list.d/vscode.sources` with:

```
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
```

#### **Update cache and install**

```
sudo apt install apt-transport-https &&
sudo apt update &&
sudo apt install code
```

### **1.3. Verify installation**

* Confirm the `code` command is available.
* Output a success or error message.

---

# **2. Install `uv` (Astral) Automatically**

Use the official installation method:

```
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### **2.1. Verify installation**

* Confirm `uv` is available in PATH.
* Output appropriate success/error messages.

Reference: [https://docs.astral.sh/uv/getting-started/installation/#installation-methods](https://docs.astral.sh/uv/getting-started/installation/#installation-methods)

---

# **3. Install Docker Using the Official Repository (Ubuntu)**

Integrate the full installation method from Docker’s official documentation.

### **3.1. Add Docker GPG key and repository**

Follow these exact steps:

```
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

Create `/etc/apt/sources.list.d/docker.sources`:

```
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
```

Update and install:

```
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### **3.2. Verify installation**

* Confirm Docker service is installed.
* Check service status with:

  ```
  sudo systemctl status docker
  ```
* If not running, start it:

  ```
  sudo systemctl start docker
  ```
* Print a clear success/error result.

Reference: [https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)

---

# **4. Add System Maintenance Functions (upgrade, autoremove, clean)**

Add full support for:

```
sudo apt autoremove -q
sudo apt full-upgrade -q
sudo apt autoclean -q
# sudo apt clean
```

Include clear log messages, such as:

* “Removing unused apt dependencies…”
* “Upgrading apt packages…”
* “Cleaning package cache…”

Follow the example provided.

---

# **5. Install Specified Flatpak Packages**

Flatpak package list:

* `md.obsidian.Obsidian`
* `com.stremio.Stremio`

Use the following structure:

### **5.1. Add repository**

```
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### **5.2. Install packages system-wide**

```
flatpak install --system ${FLATPAK_INSTALL_PACKAGES[@]}
```

### **5.3. Update Flatpak apps**

```
flatpak update
```

---

# **6. Add a Symbolic Link for `system/.inputrc`**

Modify `install.sh` (inside `link_dotfiles()`) to:

* Create a symlink from `system/.inputrc` to the user’s `$HOME`.

### **6.1. Improve `system/.inputrc` with concise, relevant comments**

Base the comments on this explanation (rewrite them briefly and clearly):

* `.inputrc` configures GNU Readline.
* User-level config overrides `/etc/inputrc`.
* Include global config using `$include /etc/inputrc`.
* Explain (briefly):

  * `set editing-mode vi`
  * `set colored-stats On`
  * `set completion-ignore-case On`
  * `set mark-symlinked-directories On`
  * `set show-all-if-ambiguous On`
  * `set show-all-if-unmodified On`
  * `set visible-stats On`

Comments must be short, direct, and helpful.

---

# **7. Create a New Root-Level `README.md`**

Generate a complete project README including:

### **7.1. Overview**

Explain concisely:

* What the project is
* What the dotfiles automate
* Supported system (Ubuntu)
* Purpose of `install.sh` and `aditionals-postinstall.sh`

### **7.2. Project Structure Summary**

Describe folders:

* `bash/`
* `zsh/`
* `system/`
* `git/`
* `tmux/`
* `editors/`
* etc.

### **7.3. Installation Instructions**

Provide:

* Required commands
* How to run the installer
* How modularity works
* Recommended environment

### **7.4. Links to External References**

List all relevant documentation:

* Visual Studio Code (Linux)
* UV (Astral)
* Docker
* Flatpak
* Readline / inputrc

---

# **General Requirements**

You must follow all rules below:

### **A. Use only legacy-compatible POSIX commands**

* No non-POSIX shell features
* No external dependencies unless required by the installer itself

### **B. Output clear success/error messages**

### **C. Maintain project consistency**

* No duplicated configuration
* Respect modular design
* Integrate with:

  * `system/.shell_config`
  * all existing dotfiles structure

### **D. Maintain clean, maintainable, readable code**

---

# **Useful References**

* [https://code.visualstudio.com/docs/setup/linux#_install-vs-code-on-linux](https://code.visualstudio.com/docs/setup/linux#_install-vs-code-on-linux)
* [https://docs.astral.sh/uv/getting-started/installation/#installation-methods](https://docs.astral.sh/uv/getting-started/installation/#installation-methods)
* [https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)


