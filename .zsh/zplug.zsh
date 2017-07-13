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
zstyle ':prezto:module:prompt' theme 'sorin'

###############################################################################
# Emoji-cli
# To insert emoji, type ctrl-s. Dependencies: jq fzf peco
###############################################################################
zplug "b4b4r07/emoji-cli"

###############################################################################
# Calculator
###############################################################################
zplug "arzzen/calc.plugin.zsh"

#zplug "b4b4r07/enhancd"
#zplug "djui/alias-tips"
#zplug "hchbaw/auto-fu.zsh", at:pu
#zplug "hkupty/ssh-agent"
#zplug "jimmijj/zsh-syntax-highlighting"
#zplug "jreese/zsh-titles"
#zplug "mollifier/anyframe"
#zplug "zdharma/history-search-multi-word"
