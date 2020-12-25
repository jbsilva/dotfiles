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
# Zsh-titles - Automatic terminal and tmux titles based on current location and task
###############################################################################
#zplug "jreese/zsh-titles"

###############################################################################
# OS specific: Archlinux and MacOS
###############################################################################
if [[ $OSTYPE = (linux)* ]]; then
	zplug "plugins/archlinux", from:oh-my-zsh, if:"which pacman"
	# zplug "plugins/dnf",       from:oh-my-zsh, if:"which dnf"
fi

if [[ $OSTYPE = (darwin)* ]]; then
	zplug "plugins/osx",      from:oh-my-zsh
	zplug "plugins/brew",     from:oh-my-zsh, if:"which brew"
	zplug "plugins/macports", from:oh-my-zsh, if:"which port"
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
# Enhanced dir list with git features
###############################################################################
zplug "supercrabtree/k"

###############################################################################
# Auto-close and delete matching delimiters
###############################################################################
zplug "hlissner/zsh-autopair", defer:2

###############################################################################
# Docker completion
###############################################################################
zplug "felixr/docker-zsh-completion"

###############################################################################
# Jump back to parent directory
###############################################################################
zplug "tarrasch/zsh-bd"

