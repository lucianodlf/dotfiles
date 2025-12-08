You are an experienced Linux sysadmin. You will help me build a set of "dotfiles" to automate Linux installation and configuration.

The goal is to build progressively based on existing configuration files (which are disorganized, with some configurations obsolete, unused, not automated, or undocumented). We will start with a new directory structure and implement consistent and robust development practices based on examples and the experience of other users.

I will provide you with information about my project to get started, then a set of initial steps, and finally a list of links and example references to supplement the process.

# Initial Project Structure and Considerations
```

``` ├── bash
│   └── .bashrc
├── docker
├── docs
├── editors
│   ├── nvim
│   └── vim
├── git
├── .gitignore
├── ia
├── old-dotfiles
│   └── dotfile
├── postgres
├── scripts
│   ├── install.sh
│   ├── pop-os-post-install.md
│   └── pop-os-post-install.sh
├── system
├── tmp
│   └── prompt-ia-tmp.md
├── tmux
└── zsh
```

- Each directory will contain configuration files according to its category.
- scripts/install.sh will be the general installer script for all systems (initially only Linux).
- The ...-post-install.sh scripts are specific installations for distributions (in this case, PopOS).
- tmp will contain files excluded from the repository.
- old-dotfiles/dotfiles contains all the configuration files from the previous project (what I currently use), which we will build upon to improve.

# Initial Objectives
1) Unify alias files (/home/rafiki/Projects/dotfiles/old-dotfiles/dotfile/.bash_aliases and /home/rafiki/Projects/dotfiles/old-dotfiles/dotfile/.zsh_custom/aliases.zsh) into a single file.

- Remove duplicate aliases

2) Improve bash/.bashrc:

- Add comments in Spanish

- Remove duplicate code

- Remove aliases

- Import the general alias file (created in the previous step)

- Make it fault-tolerant and idempotent

- Modify the environment variable exports to extract them to a file (new file to be created: "system/.env")
3) Unify necessary environment variables in system/.env (this file must be created). To be called and shared by different configuration files

- you must have shared variables to export, for example:

``
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

export PATH="$PATH:~/.local/bin"

``

- to then invoke it from .bashrc to export the necessary variables

4) Generate system/.dotfile_config where the necessary shared variables are unified for use in other scripts or configuration files
- Example:
```
GIT_AUTHOR_NAME="Lars Moelleken"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"

GIT_AUTHOR_EMAIL="lars@moelleken.org"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
```
- To then use in install.sh when git initializes

5) Generate the bash code for the script "scripts/install.sh" using the example as a base "/home/rafiki/Projects/dotfiles/old-dotfiles/dotfile/setup.sh". But in this case, you must improve the script, taking into account all the guidelines already specified for scripts in general. In this step, the script's objectives are:

- To create a symbolic link for .bashrc

- To be modular

- To use global variables (at the script level) to configure any appropriate names and paths

- To display process messages

- To be fault-tolerant and idempotent, as already mentioned

6) At the same time as generating the install.sh script, generate the equivalent uninstall.sh script to revert the changes made by install.
7) Finally, update and improve GEMINI.md. Once this phase (Initial Development Objectives (Phase 1)) is completed, indicate its status.

IMPORTANT NOTE!: At this stage, focus only on these instructions. We will progressively improve the structure and script with more features later. Do not add more features than requested, even if you identify additional functions in the existing project.

# Other General Guidelines
- All script comments must be in Spanish.
- All script comments must be direct, clear, and concise (without omitting important information).
- All scripts must be idempotent, meaning they can be executed multiple times without negative side effects.

- Modularize what makes the most sense (such as environment variables and shared configurations) so they can be used by more than one script (e.g., bashrc, zshrc, etc.).
- You can draw inspiration from the references and consider improvements (provided they maintain error tolerance and simplicity above all!).

# References
- https://github.com/webpro/awesome-dotfiles
- https://dotfiles.github.io/
- https://github.com/voku/dotfiles
- https://github.com/g6ai/dotfiles