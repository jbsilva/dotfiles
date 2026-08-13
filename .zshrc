###############################################################################
#               Julio's ~/.zshrc file
#
#                      ( O O )
#               ====oOO==(_)==OOo=====
#
# License:
#           Copyright (c) 2011-2025, Julio Batista Silva <julio@juliobs.com>
#                       All Rights Reserved
#
#           This program is free software. It comes without any warranty, to
#           the extent permitted by applicable law. You can redistribute it
#           and/or modify it under the terms of the Do What The Fuck You Want
#           To Public License, Version 2, as published by Sam Hocevar. See
#           http://www.wtfpl.net/txt/copying for more details.
#
# Created:      12 Aug 2011
# Last Change:  27 Jan 2026
#
# Download: https://github.com/jbsilva/dotfiles
###############################################################################

###############################################################################
# Source ~/.zprofile
###############################################################################
if [[ -s "$HOME/.zprofile" ]]; then
  source "$HOME/.zprofile"
fi


###############################################################################
# Security test
###############################################################################
# Don't do anything for non-interactive shells
[[ -z "$PS1" ]] && return

# Return if zsh is called from Vim
if [[ -n $VIMRUNTIME ]]; then
  return 0
fi


###############################################################################
# FZF - Command-line fuzzy finder
#
# fzf is declared in nix-darwin/modules/packages.nix. Since fzf 0.48 the shell
# integration (Ctrl-T files, Ctrl-R history, Alt-C cd, ** completion) is emitted
# by `fzf --zsh`, so no install script or generated ~/.fzf.zsh is needed.
###############################################################################
if (( $+commands[fzf] )); then
  source <(fzf --zsh)

  # Use fd for traversal: respects .gitignore and is much faster than find.
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi

  # Preview file contents with bat, directory contents with eza.
  if (( $+commands[bat] )); then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
  fi
  if (( $+commands[eza] )); then
    export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"
  fi
elif [[ -f ~/.fzf.zsh ]]; then
  # Fallback for machines still using the old fzf install script.
  source ~/.fzf.zsh
fi


###############################################################################
# Path Functions
###############################################################################

# Use $path array and force unique values
typeset -U path PATH

# Add to beginning of PATH
function addToPathStart {
  path=("$1" $path)
}

# Add to end of PATH
function addToPathEnd {
  path+=("$1")
}


###############################################################################
#                                     Vars
# Some will be in ~/.xprofile
###############################################################################
addToPathStart /usr/local/sbin
addToPathStart $HOME/.local/bin
addToPathStart $HOME/bin

# Neovim compiled from source
if (( ! $+commands[nvim] )); then
  if [[ -d $HOME/.local/nvim/bin ]]; then
    addToPathStart $HOME/.local/nvim/bin
  fi
fi

if [[ -z "$XDG_CONFIG_HOME" ]]; then
  export XDG_CONFIG_HOME=$HOME/.config
fi

# `local` is only valid inside a function; at file scope zsh treats it as
# `typeset`, which works but leaks the name. Use a plain assignment and unset.
NVIM=nvim
export NVIM_PYTHON_LOG_FILE_PATH=~/.config/nvim/nvimlog
export VISUAL=$NVIM
export EDITOR=$NVIM
export OS="$(uname -s)"
export USER_NAME='Julio'
export USER_FULLNAME='Julio Batista Silva'
export USER_EMAIL='julio@juliobs.com'
export USER_GITHUB='jbsilva'
export USER_COPYRIGHT="Copyright (c) $(date +%Y), $USER_FULLNAME"

# Colors
export DEFAULT_FOREGROUND=006 DEFAULT_BACKGROUND=235
export DEFAULT_COLOR=$DEFAULT_FOREGROUND

# Language
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Terminal Emulator
#
# Do NOT overwrite $TERM here. Every modern terminal sets it correctly and
# ships its own terminfo (ghostty -> xterm-ghostty, kitty -> xterm-kitty,
# wezterm -> wezterm). Forcing xterm-256color throws away truecolor, undercurl
# and styled-underline support.
#
# (The previous version detected the parent process with `ps -h -o comm`, but
# BSD/macOS ps has no -h, so it kept the "COMM" header line, never matched
# kitty, and unconditionally fell through to xterm-256color.)
export term_emulator="${TERM_PROGRAM:-$(ps -o comm= -p $PPID 2>/dev/null)}"

# Only provide a sane fallback when the terminal told us nothing useful.
if [[ -z $TERM || $TERM == (dumb|unknown) ]]; then
  export TERM="xterm-256color"
fi


###############################################################################
#                                Completions
###############################################################################
# /usr/local is Intel Homebrew's prefix; Apple Silicon uses /opt/homebrew. On
# the Nix machines zsh-completions comes from nixpkgs (see the home-manager zsh
# module), so this is only for the non-Nix ones.
for _fp in /usr/local/share/zsh-completions /opt/homebrew/share/zsh-completions; do
  [[ -d $_fp ]] && fpath=($_fp $fpath)
done
unset _fp
fpath=($HOME/.zsh/completions $fpath)

# compinit is the single most expensive step in zsh startup because it stats
# every file in $fpath. Rebuild the dump at most once a day and use the cached
# dump (-C skips the security audit) the rest of the time.
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "${_zcompdump:h}"
# glob qualifiers: N = null_glob, mh-24 = modified less than 24 hours ago
if [[ -n ${_zcompdump}(#qN.mh-24) ]]; then
  compinit -C -d "$_zcompdump"
else
  compinit -d "$_zcompdump"
  # Compile the dump so subsequent shells load bytecode instead of parsing it.
  { zcompile -R -- "$_zcompdump" } &!
fi
unset _zcompdump

autoload -Uz bashcompinit && bashcompinit


###############################################################################
#                                    Rust
###############################################################################
if [[ -d $HOME/.cargo/bin ]]; then
  addToPathStart $HOME/.cargo/bin
  # . "$HOME/.cargo/env"
fi


###############################################################################
#                                    Go
###############################################################################
if [[ -d $HOME/.local/go/bin ]]; then
  addToPathStart $HOME/.local/go/bin
elif [[ -d /usr/local/go/bin ]]; then
  addToPathStart /usr/local/go/bin
fi


###############################################################################
# More Functions
###############################################################################

# Colorful messages
function iHeader()     { echo -e "\033[1m$@\033[0m";  }
function iStep()       { echo -e "  \033[1;33m➜\033[0m $@"; }
function iFinishStep() { echo -e "  \033[1;32m✔\033[0m $@"; }
function iGood()       { echo -e "    \033[1;32m✔\033[0m $@"; }
function iBad()        { echo -e "    \033[1;31m✖\033[0m $@"; }

# More functions. Every *.zsh in ~/.zsh is sourced, so dropping a new helper in
# that directory is enough -- no need to add a line here.
# Glob qualifiers: N = null_glob (no error when nothing matches), . = plain files.
for _f in "$HOME"/.zsh/*.zsh(N.); do
  case "${_f:t}" in
    # zplug loadfiles: consumed by `zplug load` below, not sourced directly.
    zplug.zsh | zplug_light.zsh) continue ;;
  esac
  source "$_f"
done
unset _f


###############################################################################
#                                   Plugins
#
# On the Nix machines, plugins are installed by home-manager
# (nix-darwin/modules/home-manager/programs/zsh.nix) and have already been
# sourced by the time this file runs. ~/.zshenv exports
# DOTFILES_PLUGINS_FROM_NIX=1 to say so.
#
# Everywhere else (Arch, WSL) fall back to zplug + Prezto as before. zplug is
# unmaintained and clones itself over the network on first run, which is
# exactly why the Nix machines no longer use it.
###############################################################################
if [[ -z $DOTFILES_PLUGINS_FROM_NIX ]]; then
  export ZPLUG_HOME="${ZDOTDIR:-$HOME}/.zplug"
  test -e $ZPLUG_HOME || git clone https://github.com/zplug/zplug $ZPLUG_HOME
  export ZPLUG_LOADFILE="$HOME/.zsh/zplug.zsh"
  source "${ZPLUG_HOME}/init.zsh"

  # Install plugins if there are plugins that have not been installed
  if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
      echo
      zplug install
    fi
  fi

  # Then, source plugins and add commands to $PATH
  zplug load
fi


###############################################################################
#                        Prezto replacements (Nix machines)
#
# Prezto came with zplug and provided a lot of small things besides the plugins
# that are now Nix packages. These are the pieces worth keeping, written out
# natively so they work with or without a framework.
###############################################################################

# --- editor: edit the current command line in $EDITOR (bound to `vv` below) ---
autoload -Uz edit-command-line
zle -N edit-command-line

# --- terminal: set the window/tab title to the running command and cwd -------
if [[ -z $DOTFILES_DISABLE_AUTO_TITLE ]]; then
  function _set_terminal_title() { print -Pn "\e]0;$1\a" }
  function _title_precmd()  { _set_terminal_title "%~" }
  function _title_preexec() { _set_terminal_title "${1%% *} | %~" }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd  _title_precmd
  add-zsh-hook preexec _title_preexec
fi

# --- archive: extract any archive with one command --------------------------
function extract() {
  if (( $# == 0 )); then
    print "Usage: extract FILE..." >&2
    return 1
  fi
  local f
  for f in "$@"; do
    if [[ ! -f $f ]]; then
      print "extract: no such file: $f" >&2
      continue
    fi
    case $f in
      *.tar.bz2|*.tbz2) tar xjf   "$f" ;;
      *.tar.gz|*.tgz)   tar xzf   "$f" ;;
      *.tar.xz|*.txz)   tar xJf   "$f" ;;
      *.tar.zst)        tar --zstd -xf "$f" ;;
      *.tar)            tar xf    "$f" ;;
      *.bz2)            bunzip2   "$f" ;;
      *.gz)             gunzip    "$f" ;;
      *.xz)             unxz      "$f" ;;
      *.zip)            unzip     "$f" ;;
      *.7z)             7z x      "$f" ;;
      *.rar)            unrar x   "$f" ;;
      *.Z)              uncompress "$f" ;;
      *) print "extract: unknown archive type: $f" >&2 ;;
    esac
  done
}
alias x=extract

# --- zsh-bd: jump back to a named parent directory, e.g. `bd src` -----------
function bd() {
  if (( $# == 0 )); then
    cd ..
    return
  fi
  local target="${PWD%/${1}/*}/${1}"
  if [[ -d $target && $target != $PWD ]]; then
    cd "$target"
  else
    print "bd: no parent directory named '$1'" >&2
    return 1
  fi
}

# --- utility: pbcopy/pbpaste on Linux, which macOS provides natively --------
if [[ $OS == Linux ]] && (( ! $+commands[pbcopy] )); then
  if (( $+commands[wl-copy] )); then
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
  elif (( $+commands[xclip] )); then
    alias pbcopy='xclip -selection clipboard -in'
    alias pbpaste='xclip -selection clipboard -out'
  fi
fi

# --- dircolors-solarized: replaced by vivid, a maintained LS_COLORS generator
if (( $+commands[vivid] )); then
  export LS_COLORS="$(vivid generate one-dark 2>/dev/null)"
elif (( $+commands[dircolors] )); then
  eval "$(dircolors -b)"
fi


###############################################################################
#                                 Keybindings
# bindkey -l will give you a list of existing keymap names.
# bindkey -M <keymap> will list all the bindings in a given keymap.
# zle -al lists all registered zle commands
###############################################################################
# Bind only widgets that actually exist: binding a missing widget makes zsh
# print an error on every shell start, and which plugins are present differs
# between the Nix machines and the zplug ones.
function _bindkey_if_widget() {
  local widget="$1" key="$2" keymap
  (( $+widgets[$widget] )) || return 0
  for keymap in "${@:3}"; do
    bindkey -M "$keymap" "$key" "$widget"
  done
}

# Ctrl-R: multi-word history search (zsh-history-search-multi-word).
_bindkey_if_widget history-search-multi-word '^r' emacs viins vicmd

# Ctrl-S: emoji picker (emoji-cli). Note that some terminals swallow Ctrl-S as
# XOFF flow control; `stty -ixon` frees it up.
_bindkey_if_widget emoji::cli '^s' viins

# Press vv to edit the command line in $EDITOR (zsh's own edit-command-line,
# autoloaded above; used to come from Prezto's editor module).
_bindkey_if_widget edit-command-line 'vv' vicmd


###############################################################################
# Options
###############################################################################
setopt autocd            # Allow changing directories without `cd`
setopt pushd_ignore_dups # Dont push copies of the same dir on stack.
setopt pushd_minus       # Reference stack entries with "-".
setopt extended_glob


###############################################################################
# History
###############################################################################
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=10000
setopt append_history         # Dont overwrite history
setopt extended_history       # Also record time and duration of commands.
setopt share_history          # Share history between multiple shells
setopt hist_expire_dups_first # Clear duplicates when trimming internal hist.
setopt hist_find_no_dups      # Dont display duplicates during searches.
setopt hist_ignore_dups       # Ignore consecutive duplicates.
setopt hist_ignore_all_dups   # Remember only one unique copy of the command.
setopt hist_reduce_blanks     # Remove superfluous blanks.
setopt hist_save_no_dups      # Omit older commands in favor of newer ones.


###############################################################################
# OS specific stuff
###############################################################################
case $OS in
Darwin)
  export MACOS_VERSION="$(sw_vers -productVersion)"
  [[ -f "$HOME/.zsh/zshrc_macos" ]] && source "$HOME/.zsh/zshrc_macos"
  ;;
Linux)
  [[ -f "$HOME/.zsh/zshrc_linux" ]] && source "$HOME/.zsh/zshrc_linux"
  ;;
esac


###############################################################################
# Aliases
###############################################################################
# alias sudo='sudo '
alias please='sudo $(fc -ln -1)' # Last command with sudo

alias list='du -shc *'
alias listh='du -shc * | sort -h'

alias back='cd "$OLDPWD"'
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias ......='cd ../../../../../'

alias dir='ls -1'           # Show one entry per line
alias lah='ls -alh'         # Show all human-readable
alias ld='ls -ld'           # Show info about the directory
alias lla='ls -lAFh'        # Show hidden all files
alias ll='ls -lF'           # Show long file information
alias la='ls -AF'           # Show hidden files
alias lx='ls -lXB'          # Sort by extension
alias lk='ls -lSr'          # Sort by size, biggest last
alias lc='ls -ltcr'         # Sort by and show change time, most recent last
alias lu='ls -ltur'         # Sort by and show access time, most recent last
alias lt='ls -ltr'          # Sort by date, most recent last
alias lr='ls -lR'           # Recursive ls
alias lsr='find . -mindepth 2 -maxdepth 2 -type d -exec ls -ld "{}" \;' # ls dirs with depth 2

alias cls="clear"

# Set editor preference to nvim if available.
if which nvim &>/dev/null; then
  alias vim='() { $(whence -p nvim) $@ }'
else
  alias vim='() { $(whence -p vim) $@ }'
fi

alias difff='/usr/bin/diff'
alias rot13="tr '[A-Za-z]' '[N-ZA-Mn-za-m]'"
alias d755="find . -mindepth 1 -type d -not \( -name '#recycle' -prune \) -not \( -name '@eaDir' -prune \) -exec chmod 755 {} \;"
alias d750="find . -mindepth 1 -type d -not \( -name '#recycle' -prune \) -not \( -name '@eaDir' -prune \) -exec chmod 750 {} \;"
alias f644="find . -type d -not \( -name '#recycle' -prune \) -not \( -name '@eaDir' -prune \) -o -type f -exec chmod 644 {} \;"
alias f640="find . -type d -not \( -name '#recycle' -prune \) -not \( -name '@eaDir' -prune \) -o -type f -exec chmod 640 {} \;"
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'
alias sha1='openssl sha1'
alias sha256='shasum -a 256'
alias wget='wget -c' # Resume wget by default

alias ack='ack --ignore-dir=".mypy_cache"'

alias unzipall="unzip '*.zip'"

alias gst='git status'
alias git-remove-untracked='git fetch --prune && git branch -r | awk "{print \$1}" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk "{print \$1}" | xargs git branch -d'
alias git-remove-merged='git branch --merged master | grep -E -v "(^\*|master|main|dev|develop|testing)" | xargs git branch -d'
alias git-remove-remote-merged-to-master-keep='git fetch --prune origin && git branch -r --merged | grep -E -v "(^\*|master|main|dev|develop|testing)" | sed "s/origin\///" | xargs -n 1 git push --delete origin'
alias git-remove-remote-merged-to-master='git fetch --prune origin && git branch -r --merged | grep -E -v "(^\*|master|main)" | sed "s/origin\///" | xargs -n 1 git push --delete origin'

# Supercrabtree/k (unmaintained since 2019) -- superseded by eza below.
# Kept behind a guard so the aliases still work if the zplug plugin is present.
if (( $+functions[k] )); then
  # _k: original k
  #  k: human readable, without Git (faster)
  # kk: human readable, with Git
  eval "$(echo "_k() {"; declare -f k | tail -n +2)"
  alias kk="_k --human --group-directories-first"
  alias k="_k --human --group-directories-first --no-vcs"
fi

# eza: actively maintained ls replacement. Overrides k/kk when available.
# `tree` and `lt` are deliberately left alone (lt is `ls -ltr` above).
if (( $+commands[eza] )); then
  alias k='eza --long --header --group-directories-first --git'
  alias kk='eza --long --header --group-directories-first --git --all'
  alias ltree='eza --tree --level=3'
fi

# Paste clipboard in new vim file
# On Linux, pbcopy/pbpaste are aliased to wl-copy/xclip further up.
alias paste2vim='pbpaste | nvim -'

# Open AuTHentication (OATH) one-time password
alias otp='oathtool --totp -b'
alias otp8='oathtool --totp=SHA1 -b -d 8 -s 60'
alias otp8hex='oathtool --totp -s 60 -v -d8'

# Backup
alias bkp='rsync --recursive --links --times --compress-level=0 --info=flist2,name,progress --human-readable'
alias bkpd='rsync --recursive --links --times --compress-level=0 --info=flist2,name,progress --human-readable --delete'

# Renamers
alias recc='rename -X -c --rews --camelcase --nows'
alias qmvv='qmv --format=dc --options=spaces,width=40,autowidth'
alias qmvo='qmv --format=destination-only'
alias qmvor='qmv -R --format=destination-only'
alias exif_move="exiftool -P -i '#recycle' -i '@eaDir' -i 'SYMLINKS' -i 'HIDDEN' -d '%Y/%m' '-Directory<\${CreateDate}' '-Directory<\${DateTimeOriginal}' ."
alias exif_rename="exiftool -P -i '#recycle' -i '@eaDir' -i 'SYMLINKS' -i 'HIDDEN' -d '%Y%m%d_%H%M%S' '-filename<%f-\${ImageSize}%-03c.%le' '-filename<\${CreateDate}%-03c.%le' '-filename<\${DateTimeOriginal}%-03c.%le' ."
alias exif_copyright="exiftool -G1 -Artist -Copyright -IPTC:By-line -IPTC:CopyrightNotice -IPTC:Credit -XMP-dc:Creator -XMP-dc:Rights -XMP-iptcCore:CreatorWorkEmail -XMP-iptcCore:CreatorWorkURL -XMP-plus:CopyrightOwnerName -XMP-plus:CopyrightStatus -XMP-plus:ImageCreatorName -XMP-plus:LicensorName -XMP-xmpRights:Marked -XMP-xmpRights:Owner -XMP-xmpRights:UsageTerms"

# Docker
alias dnorestart='docker update --restart=no $* $(docker ps -q)'
alias dprune='docker system prune --volumes'
alias dpsa='docker ps -a'
alias dupgrade="docker images | awk '{print $1}' | grep -v 'none' | grep -iv 'repo' | xargs -n1 docker pull"

# Kitty terminal
alias icat='kitty +kitten icat'
alias kssh='kitty +kitten ssh'
alias kkssh='TERM="xterm-256color" ssh'

# Clipboard
# Prezto already defined the pbcopy and pbpaste aliases
alias clipboard='if [ -p /dev/stdin ]; then pbcopy &> /dev/null; fi; pbpaste'

# Split files
alias split_80_20='gawk '"'"'BEGIN {srand()} {f = FILENAME (rand() <= 0.8 ? ".80" : ".20"); print > f}'"'"''
alias split_70_30='gawk '"'"'BEGIN {srand()} {f = FILENAME (rand() <= 0.7 ? ".70" : ".30"); print > f}'"'"''

# See open ports. `ss` is Linux-only; macOS needs lsof.
if (( $+commands[ss] )); then
  alias open_ports='sudo ss -tulpn | grep LISTEN'
else
  alias open_ports='sudo lsof -nP -iTCP -sTCP:LISTEN'
fi


###############################################################################
#                                     FUN
###############################################################################
alias rainbow='yes "$(seq 16 231)" | while read i; do printf "\x1b[48;5;${i}m\n"; sleep .02; done'
alias fucking='sudo'
alias emacs='echo "segmentation fault"'
alias more='less'
alias CAT='echo "=^.^=\n"'


###############################################################################
#                                Powerlevel10k
###############################################################################
# case $(tty) in
#   (/dev/tty[1-9]) [[ -f ~/.p10k_console.zsh ]] && source ~/.p10k_console.zsh;;
#               (*) [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh;;
#           esac


###############################################################################
#                                Starship
###############################################################################
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi


###############################################################################
#                                Zoxide
# Smarter cd that learns your habits. `z foo` jumps, `zi` picks interactively.
# Loaded after compinit so its completions register correctly.
###############################################################################
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi


###############################################################################
#                                Carapace
# Multi-shell completion engine covering hundreds of CLIs that ship none.
###############################################################################
if (( $+commands[carapace] )); then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  zstyle ':completion:*' format $'\e[2m%d\e[0m'
  source <(carapace _carapace zsh)
fi


###############################################################################
#                                Zellij
###############################################################################
if [[ -z "$ZELLIJ" &&
  -z "$EMACS" &&
  -z "$VIM" &&
  -z "$INSIDE_EMACS" &&
  -n "$SSH_TTY" &&
  "$TERM_PROGRAM" != "vscode" &&
  "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" ]]; then
  zellij attach -c
fi


###############################################################################
#                                asdf
###############################################################################
# if (( $+commands[asdf] )); then
#   export ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"
#   addToPathStart ${ASDF_DATA_DIR}/shims

#   if [[ ! -f "$HOME/.zsh/completions/_asdf" ]]; then
#     asdf completion zsh > "$HOME/.zsh/completions/_asdf"
#   fi
# fi


###############################################################################
#                                Pixi
###############################################################################
if [[ -d $HOME/.pixi/bin ]]; then
  addToPathStart $HOME/.pixi/bin
fi

if (( $+commands[pixi] )); then
  eval "$(pixi completion --shell zsh)"
fi


###############################################################################
#                               uv and uvx
###############################################################################
if (( $+commands[uv] )); then
  eval "$(uv generate-shell-completion zsh)"
fi

if (( $+commands[uvx] )); then
  eval "$(uvx --generate-shell-completion zsh)"
fi


###############################################################################
#                                .NET
# curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 3.1
# curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 8.0
###############################################################################
if [[ -d "$HOME/.dotnet" ]]; then
  export DOTNET_ROOT=$HOME/.dotnet
  addToPathEnd $DOTNET_ROOT
  addToPathEnd $DOTNET_ROOT/tools
fi


###############################################################################
#                                gnome-keyring
# Wait for systemd --user dbus session and unlock keyring
###############################################################################
# if (( $+commands[gnome-keyring-daemon] )); then
#   eval $(echo -n db | gnome-keyring-daemon --unlock 2> /dev/null)
# fi


###############################################################################
#                                NVM
###############################################################################
if [[ -d "$HOME/.config/nvm" ]]; then
  export NVM_DIR="$HOME/.config/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi


###############################################################################
#                                WSL
###############################################################################

# Open Windows browser. Install wslu first: `sudo apt install wslu`
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
  export BROWSER=wslview
fi


###############################################################################
#                                LM Studio
###############################################################################
# Added by LM Studio CLI (lms)
if [[ -d "$HOME/.lmstudio/bin" ]]; then
  export LM_STUDIO_PATH="$HOME/.lmstudio/bin"
  addToPathEnd $LM_STUDIO_PATH
fi
# End of LM Studio CLI section


###############################################################################
#                                VS Code
###############################################################################
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  if (( $+commands[code-insiders] )); then
    . "$(code-insiders --locate-shell-integration-path zsh)"
  else
    . "$(code --locate-shell-integration-path zsh)"
  fi
fi


###############################################################################
#                          AWS CLI completions
###############################################################################
if (( $+commands[aws_completer] )); then
  complete -C aws_completer aws
fi

###############################################################################
#                               Pants completions
###############################################################################
if (( $+commands[pants] )); then
  if [[ ! -f "$HOME/.zsh/completions/_pants" ]]; then
    pants complete --shell=zsh > "$HOME/.zsh/completions/_pants"
  fi
fi


###############################################################################
#                               Claude
###############################################################################
claude-session() {
  local file=$(ls -t ~/.claude/projects/**/*.jsonl | head -1)
  echo "Session ID: $(basename $file .jsonl)"
  tail -5 "$file" | jq '.message.content[0].text // .message.content // empty' 2>/dev/null
}


###############################################################################
#                               Tmux
# Remember to symlink:
# ln -sf ~/dotfiles/.tmux/.tmux.conf "$XDG_CONFIG_HOME/tmux/tmux.conf"
# ln -sf ~/dotfiles/.tmux/.tmux.conf.local "$XDG_CONFIG_HOME/tmux/tmux.conf.local"
###############################################################################


###############################################################################
#                                Nexus Tools
###############################################################################
if [[ -d "$HOME/.nexus-tools" ]]; then
  export NEXUS_TOOLS_PATH="$HOME/.nexus-tools"
  addToPathEnd $NEXUS_TOOLS_PATH
fi
