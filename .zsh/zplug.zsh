###############################################################################
# Let zplug manage zplug
###############################################################################
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

###############################################################################
# Prezto
###############################################################################
zplug "sorin-ionescu/prezto", use:init.zsh, hook-build:"ln -s $ZPLUG_ROOT/repos/sorin-ionescu/prezto ${ZDOTDIR:-$HOME}/.zprezto"

# Color output
zstyle ':prezto:*:*' color 'yes'

# Set the Prezto modules to load (browse modules). The order matters.
zstyle ':prezto:load' pmodule \
  'environment' \
  'terminal' \
  'editor' \
  'history' \
  'directory' \
  'spectrum' \
  'gnu-utility' \
  'utility' \
  'completion' \
  'fasd' \
  'tmux' \
  'gpg' \
  'archive' \
  'autosuggestions' \
  'syntax-highlighting' \
  'history-substring-search' \
  'docker' \
  'prompt'

# GNU Utility
# Homebrew prefixes 'g' to GNU utililies:
#     brew install coreutils binutils findutils libtool grep make gnu-sed
# Adding "gnubin" directories to the PATH may break system scripts. Use this instead
zstyle ':prezto:module:gnu-utility' prefix 'g'

# Auto-start Tmux localy
# zstyle ':prezto:module:tmux:auto-start' local 'yes'

# Auto-start Tmux in a SSH connection
# zstyle ':prezto:module:tmux:auto-start' remote 'yes'
# zstyle ':prezto:module:tmux:session' name 'julio'

# Disable hosts completion
zstyle ':prezto:module:completion:*:hosts' etc-host-ignores \
      '0.0.0.0' '127.0.0.1'

# Set the key mapping style to 'emacs' or 'vi'.
zstyle ':prezto:module:editor' key-bindings 'vi'

# Set the query found color.
zstyle ':prezto:module:history-substring-search:color' found ''

# Set the query not found color.
zstyle ':prezto:module:history-substring-search:color' not-found ''

# Set the search globbing flags.
zstyle ':prezto:module:history-substring-search' globbing-flags ''

# Theme
# For Powerlevel9k, remember to export POWERLEVEL9K_MODE='nerdfont-complete'
zstyle ':prezto:module:prompt' theme 'powerlevel10k'

# Auto-title
zstyle ':prezto:module:terminal' auto-title 'yes'

###############################################################################
# Emoji-cli
# Dependencies: jq fzf peco
# Ctrl-s: bindkey -M viins '^s' emoji::cli
###############################################################################
zplug "b4b4r07/emoji-cli"

###############################################################################
# Calculator
###############################################################################
# zplug "arzzen/calc.plugin.zsh"

###############################################################################
# History Search Multi Word
# Ctrl-r: bindkey "^r" history-search-multi-word
###############################################################################
zplug "zdharma-continuum/history-search-multi-word"

###############################################################################
# Enhancd - A next-generation cd command with an interactive filter
###############################################################################
#zplug "b4b4r07/enhancd", use:init.sh, defer:2, hook-load:"ENHANCD_DISABLE_HOME=1"

###############################################################################
# Alias-tips - Help remembering those shell aliases and Git aliases you once defined
###############################################################################
zplug "djui/alias-tips"
#zplug "/molovo/tipz"
#zplug "MichaelAquilina/zsh-you-should-use"

###############################################################################
# Git
###############################################################################
zplug "plugins/git",         from:oh-my-zsh
# zplug "plugins/git-extras",         from:oh-my-zsh

###############################################################################
# Git-extra-commands - Extra git helper scripts packaged as a plugin.
###############################################################################
zplug "unixorn/git-extra-commands"

###############################################################################
# Zsh-vim-mode - Sane bindings for zsh's vi mode so it behaves more vim like
###############################################################################
zplug "sharat87/zsh-vim-mode"

###############################################################################
# Zsh-titles - Automatic terminal and tmux titles based on current location and task
###############################################################################
#zplug "jreese/zsh-titles"

###############################################################################
# OS specific: Archlinux and MacOS
###############################################################################
if [[ $OSTYPE = (linux)* ]]; then
    if (( $+commands[pacman] )); then
        zplug "plugins/archlinux", from:oh-my-zsh, if:"which pacman"
    fi
	# zplug "plugins/dnf",       from:oh-my-zsh, if:"which dnf"
fi

if [[ $OSTYPE = (darwin)* ]]; then
	zplug "plugins/osx",      from:oh-my-zsh
    if (( $+commands[brew] )); then
	    zplug "plugins/brew",     from:oh-my-zsh, if:"which brew"
    fi
    if (( $+commands[port] )); then
	    zplug "plugins/macports", from:oh-my-zsh, if:"which port"
    fi
    zplug "mwilliammyers/plugin-osx"
fi


###############################################################################
# Directory colors
###############################################################################
zplug "seebi/dircolors-solarized", ignore:"*", as:plugin

if zplug check "seebi/dircolors-solarized"; then
  if which gdircolors &> /dev/null; then
	alias dircolors='() { $(whence -p gdircolors) }'
  fi
  if which dircolors &> /dev/null; then
    scheme="dircolors.ansi-universal"
    eval $(dircolors ~/.zplug/repos/seebi/dircolors-solarized/$scheme)
  fi
fi

###############################################################################
# Enhanced dir list with git features. Command: `k`
###############################################################################
zplug "supercrabtree/k"

###############################################################################
# Auto-close and delete matching delimiters
###############################################################################
zplug "hlissner/zsh-autopair", defer:2

###############################################################################
# Docker completion
###############################################################################
# zplug "plugins/docker",         from:oh-my-zsh, if:'[[ $commands[docker] ]]'
#  zplug "plugins/docker-compose", from:oh-my-zsh, if:'[[ $commands[docker-compose] ]]'
zplug "webyneter/docker-aliases", use:docker-aliases.plugin.zsh

###############################################################################
# asdf
###############################################################################
zplug "plugins/asdf",         from:oh-my-zsh

###############################################################################
# Poetry
###############################################################################
# zplug "plugins/poetry",         from:oh-my-zsh

###############################################################################
# Kafka completion
###############################################################################
# zplug "Dabz/kafka-zsh-completions"

###############################################################################
# Jump back to parent directory
# Quickly go back to a specific parent directory. Command: `bd dir_name`
###############################################################################
zplug "tarrasch/zsh-bd"

###############################################################################
# diff-so-fancy
###############################################################################
# zplug "z-shell/zsh-diff-so-fancy", as:command, use:"bin/"
zplug "z-shell/zsh-diff-so-fancy"

###############################################################################
# Terraform
###############################################################################
if (( $+commands[terraform] )); then
    zplug "plugins/terraform", from:oh-my-zsh, if:"which terraform"
fi
