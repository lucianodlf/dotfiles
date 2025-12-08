# GEMINI Code Assistant Project Context (Refactored Dotfiles)

This file provides context for the Gemini code assistant to understand the structure and purpose of this refactored "dotfiles" project. The goal is to establish a **consistent, robust, and automated development environment** setup for Linux, evolving from a set of legacy configurations.

## Project Goal: Progressive Improvement

This project aims to progressively build an automated system for installing and configuring a Linux development environment. It starts by analyzing and migrating configurations from the disorganized legacy directory, `old-dotfiles`, into a new, structured, and consistent project layout.

## Directory Overview

This is a "dotfiles" repository used to store and manage configuration files for various command-line tools and applications.

| Directory | Purpose | Status |
| :--- | :--- | :--- |
| `bash` | Bash shell configurations. | **Active** |
| `docker` | Docker-related configuration/files. | **New** |
| `docs` | Project documentation. | **New** |
| `editors` | Editor configurations (e.g., `nvim`, `vim`). | **New** |
| `git` | Git configuration files. | **Active** |
| `ia` | AI/scripting related files. | **New** |
| `old-dotfiles` | **Legacy configurations** (Used as a source for migration/improvement). | **To be retired** |
| `postgres` | PostgreSQL-related configuration/files. | **New** |
| `scripts` | **Core project automation scripts.** | **Key Focus** |
| `system` | **Shared configuration variables** and system-wide settings. | **Key Focus** |
| `tmux` | Tmux terminal multiplexer configuration. | **Active** |
| `tmp` | Temporary files (excluded from Git via `.gitignore`). | **New** |
| `zsh` | Zsh shell configurations. | **Active** |

---

## Key Files and Shared Configuration

The project emphasizes modularity and shared configurations, moving away from monolithic or duplicated setup files.

### ⚙️ Automation Scripts (`scripts/`)

* `scripts/install.sh`: **The main installation script.** This script is modular, idempotent, and handles the creation of symbolic links, installation of packages, and applying configurations. It replaces the legacy `old-dotfiles/dotfile/setup.sh`.
* `scripts/uninstall.sh`: **The main uninstallation script.** Used to cleanly revert changes made by `install.sh`.
* `scripts/*-post-install.sh`: Specific installation scripts for individual Linux distributions (e.g., `pop-os-post-install.sh`).

### 🧩 Shared Configuration Files (`system/`)

* `system/.env`: **Environment Variables.** Contains shared `export` variables (e.g., $PATH, NVM_DIR) to be sourced by multiple shell configurations (`.bashrc`, `.zshrc`).
    ```bash
    # Example content of system/.env
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    # ... other PATH or environment exports
    ```
* `system/.dotfile_config`: **Shared Configuration Variables.** Contains general project/user variables to be used by scripts (e.g., `install.sh`) or configuration files.
    ```bash
    # Example content of system/.dotfile_config
    GIT_AUTHOR_NAME="Your Name"
    GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
    GIT_AUTHOR_EMAIL="your.email@example.com"
    # ... other shared variables
    ```
* `system/aliases`: **Unified Alias File.** Consolidates and de-duplicates aliases from previous files (e.g., `.bash_aliases`, `aliases.zsh`) to be sourced by both Bash and Zsh configurations.

### 🐚 Shell Configuration

* `bash/.bashrc`: Now **cleaner** and **modular.** It removes duplicated code and aliases, includes Spanish comments, and **sources** both `system/.env` and `system/aliases`.

---

## Initial Development Objectives (Phase 1)

The first phase of development focuses on establishing a clean, unified, and automated foundation:

1.  **Unify Aliases:** Consolidate and de-duplicate aliases from legacy files (e.g., `old-dotfiles/dotfile/.bash_aliases` and `old-dotfiles/dotfile/.zsh_custom/aliases.zsh`) into the new **`system/aliases`** file.
2.  **Create Shared Environment Variables:** Create **`system/.env`** to house common `export` statements for environment variables (e.g., $NVM\_DIR, $PATH).
3.  **Create Shared Script Variables:** Create **`system/.dotfile_config`** to store shared configuration variables used by automation scripts (e.g., Git author name/email).
4.  **Improve `bash/.bashrc`:** Refactor the file to be idempotent, use Spanish comments, remove duplicated code/aliases, and source the new **`system/.env`** and **`system/aliases`** files.
5.  **Develop `scripts/install.sh`:** Create the core installation script based on the logic of the legacy `setup.sh`, ensuring it is:
    * **Modular** (uses functions).
    * **Idempotent** (can be run multiple times safely).
    * Uses variables from **`system/.dotfile_config`**.
    * Handles essential tasks (e.g., creating symbolic link for `.bashrc`).
6.  **Develop `scripts/uninstall.sh`:** Create the inverse script to cleanly revert the changes made by `install.sh`.

---

## Development Conventions

* **Language:** All comments within shell scripts must be in **Spanish**.
* **Idempotence:** All automation scripts (`install.sh`, `uninstall.sh`, etc.) **must be idempotent** (executable multiple times without negative side effects).
* **Modularity:** Shared configurations (variables, aliases) must be extracted into dedicated files in the **`system/`** directory to be used by multiple configuration files (e.g., `bash`, `zsh`).
* **Target OS:** Scripts are primarily designed to run on a **Linux-based operating system**.

## References and Inspiration

This project draws inspiration from established "dotfiles" conventions and best practices:

* [webpro/awesome-dotfiles](https://github.com/webpro/awesome-dotfiles)
* [dotfiles.github.io](https://dotfiles.github.io/)
* [voku/dotfiles](https://github.com/voku/dotfiles)
* [g6ai/dotfiles](https://github.com/g6ai/dotfiles)