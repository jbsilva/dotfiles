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
  'utility' \
  'completion' \
  'fasd' \
  'homebrew' \
  'git' \
  'tmux' \
  'gpg' \
  'osx' \
  'archive' \
  'autosuggestions' \
  'syntax-highlighting' \
  'history-substring-search' \
  'prompt'

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
#zstyle ':prezto:module:prompt' theme 'sorin'
zstyle ':prezto:module:prompt' theme 'powerlevel9k'

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
zplug "arzzen/calc.plugin.zsh"

###############################################################################
# History Search Multi Word
# Ctrl-r: bindkey "^r" history-search-multi-word
###############################################################################
zplug "zdharma/history-search-multi-word"

###############################################################################
# Enhancd - A next-generation cd command with an interactive filter
###############################################################################
zplug "b4b4r07/enhancd", use:init.sh, defer:2, hook-load:"ENHANCD_DISABLE_HOME=1"

###############################################################################
# Alias-tips - Help remembering those shell aliases and Git aliases you once defined
###############################################################################
zplug "djui/alias-tips"
#zplug "/molovo/tipz"
#zplug "MichaelAquilina/zsh-you-should-use"

###############################################################################
# Git-extra-commands - Extra git helper scripts packaged as a plugin.
###############################################################################
zplug "unixorn/git-extra-commands"

###############################################################################
# Zsh-vim-mode - Sane bindings for zsh's vi mode so it behaves more vim like
###############################################################################
zplug "sharat87/zsh-vim-mode"

###############################################################################
# Plugin-OSX - Add some common OS X related aliases and functions
###############################################################################
zplug "mwilliammyers/plugin-osx"

###############################################################################
# Zsh-titles - Automatic terminal and tmux titles based on current location and task
###############################################################################
#zplug "jreese/zsh-titles"
