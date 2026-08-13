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
# Last Change:  13 Aug 2026
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

# pixi installs itself outside any package manager. Added here rather than
# further down because the completion cache below has to see it on $PATH.
if [[ -d $HOME/.pixi/bin ]]; then
  addToPathStart $HOME/.pixi/bin
fi

# Neovim compiled from source
if (( ! $+commands[nvim] )); then
  if [[ -d $HOME/.local/nvim/bin ]]; then
    addToPathStart $HOME/.local/nvim/bin
  fi
fi

if [[ -z "$XDG_CONFIG_HOME" ]]; then
  export XDG_CONFIG_HOME=$HOME/.config
fi

# Neovim exports $NVIM itself, set to its RPC socket, and that is how tools
# detect "running inside a :terminal". So do not use NVIM as a scratch variable
# here -- it made every shell look like a nested Neovim.
export NVIM_PYTHON_LOG_FILE_PATH=~/.config/nvim/nvimlog
export VISUAL=nvim
export EDITOR=nvim

# zsh sets $OSTYPE natively, so the common cases need no `uname` fork.
case $OSTYPE in
  darwin*) export OS=Darwin ;;
  linux*) export OS=Linux ;;
  *) export OS="$(uname -s)" ;;
esac

export USER_NAME='Julio'
export USER_FULLNAME='Julio Batista Silva'
export USER_EMAIL='julio@juliobs.com'
export USER_GITHUB='jbsilva'
# strftime from zsh/datetime rather than a `date` fork.
zmodload zsh/datetime
strftime -s _year '%Y' $EPOCHSECONDS
export USER_COPYRIGHT="Copyright (c) $_year, $USER_FULLNAME"
unset _year

# Colors
export DEFAULT_FOREGROUND=006 DEFAULT_BACKGROUND=235
export DEFAULT_COLOR=$DEFAULT_FOREGROUND

# Language
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Terminal Emulator
#
# Leave $TERM alone. Terminals set it themselves and ship matching terminfo
# (ghostty -> xterm-ghostty, wezterm -> wezterm); overwriting it costs
# truecolor and undercurl support.
#
# $term_emulator used to be derived here from $TERM_PROGRAM, falling back to a
# `ps` on the parent pid. Nothing ever read it, and the fallback forked on every
# shell that was not started by a terminal that sets $TERM_PROGRAM. Use
# $TERM_PROGRAM directly if it is ever needed again.

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

# --- tool-generated completions ----------------------------------------------
#
# `eval "$(some-tool completion zsh)"` is the documented way to install these,
# but it makes every shell fork the tool and then *parse* the generated
# function. Parsing is the expensive half: 143 ms for pixi and 87 ms for uv,
# measured with `zsh -i -x` and PS4 timestamps.
#
# Written into a directory on $fpath instead, so compinit autoloads each one
# the first time that command is completed and startup pays nothing. The file
# is only regenerated when the tool's binary is newer than it.
_zcompcache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
[[ -d $_zcompcache ]] || mkdir -p "$_zcompcache"
fpath=("$_zcompcache" $fpath)

# Set when a completion is (re)written, so compinit below rebuilds its dump
# instead of reusing a cached one that predates the new file.
_zcomp_fresh=0
function _gen_completion() {
  local name=$1 bin=$2
  shift 2
  local out="$_zcompcache/_$name"
  (( $+commands[$bin] )) || return 0
  [[ -s $out && $out -nt $commands[$bin] ]] && return 0
  if "$@" >| "$out" 2>/dev/null; then
    _zcomp_fresh=1
  else
    rm -f "$out"
  fi
}

_gen_completion uv uv uv generate-shell-completion zsh
_gen_completion uvx uvx uvx --generate-shell-completion zsh
_gen_completion pixi pixi pixi completion --shell zsh

unfunction _gen_completion
unset _zcompcache

# compinit is the single most expensive step in zsh startup because it stats
# every file in $fpath. Rebuild the dump at most once a day and use the cached
# dump (-C skips the security audit) the rest of the time.
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "${_zcompdump:h}"
# glob qualifiers: N = null_glob, mh-24 = modified less than 24 hours ago
if (( ! _zcomp_fresh )) && [[ -n ${_zcompdump}(#qN.mh-24) ]]; then
  compinit -C -d "$_zcompdump"
else
  compinit -d "$_zcompdump"
  # Compile the dump so subsequent shells load bytecode instead of parsing it.
  { zcompile -R -- "$_zcompdump" } &!
fi
unset _zcompdump _zcomp_fresh


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
  source "$_f"
done
unset _f


###############################################################################
#                                   Plugins
#
# There is no plugin manager. On the Nix machines home-manager has already
# sourced everything by the time this file runs (~/.zshenv exports
# DOTFILES_PLUGINS_FROM_NIX=1). Everywhere else the plugins come from the
# system package manager and are sourced from wherever it put them.
#
# Install them with the native package manager:
#   Arch      pacman -S zsh-autosuggestions zsh-syntax-highlighting \
#                       zsh-history-substring-search zsh-completions
#   Debian    apt install zsh-autosuggestions zsh-syntax-highlighting
#   Synology  opkg install zsh-autosuggestions zsh-syntax-highlighting  (Entware)
#
# Anything not found is simply skipped, so a machine with none of them still
# gets a working shell.
###############################################################################
if [[ -z $DOTFILES_PLUGINS_FROM_NIX ]]; then
  # Source the first candidate that exists. Order matters: syntax highlighting
  # wraps ZLE widgets and must come after anything else that does.
  function _load_plugin() {
    local candidate
    for candidate in "$@"; do
      if [[ -r $candidate ]]; then
        source "$candidate"
        return 0
      fi
    done
    return 1
  }

  # Prefixes to search, covering Arch, Debian/Ubuntu, Homebrew (Intel and Apple
  # Silicon), Entware on Synology, and a manual ~/.local install.
  _plug_dirs=(
    /usr/share/zsh/plugins
    /usr/share/zsh/vendor-completions
    /usr/share
    /opt/share            # Entware
    /opt/homebrew/share
    /usr/local/share
    "$HOME/.local/share/zsh/plugins"
  )

  for _p in $_plug_dirs; do
    _load_plugin \
      "$_p/zsh-autosuggestions/zsh-autosuggestions.zsh" && break
  done

  for _p in $_plug_dirs; do
    _load_plugin \
      "$_p/zsh-history-substring-search/zsh-history-substring-search.zsh" && break
  done

  # Last, for the reason above.
  for _p in $_plug_dirs; do
    _load_plugin \
      "$_p/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" && break
  done

  unset _p _plug_dirs
  unfunction _load_plugin

  # history-substring-search binds nothing by itself.
  if (( $+widgets[history-substring-search-up] )); then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down
  fi
fi


###############################################################################
#                              Shell conveniences
#
# Small things a framework would normally provide, written out natively so they
# work on every machine.
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
# Uses ouch where available; falls back to the case statement below on
# machines with only the base utilities, such as the NAS.
function extract() {
  if (( $# == 0 )); then
    print "Usage: extract FILE..." >&2
    return 1
  fi
  if (( $+commands[ouch] )); then
    ouch decompress "$@"
    return
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

# --- LS_COLORS: one palette, read by both GNU ls and eza ---------------------
# vivid generates it from a named theme; `vivid themes` lists the alternatives.
# dircolors is the fallback where vivid is not installed.
if (( $+commands[vivid] )); then
  export LS_COLORS="$(vivid generate one-dark 2>/dev/null)"
elif (( $+commands[dircolors] )); then
  eval "$(dircolors -b)"
fi

# ls defaults to no colour and has to be asked for it. Recent GNU and BSD ls
# both take --color; older BSD and busybox (the NAS) only honour CLICOLOR.
# Only GNU ls reads LS_COLORS -- BSD falls back to its own palette via LSCOLORS.
if ls --color=auto /dev/null >/dev/null 2>&1; then
  alias ls='ls --color=auto'
else
  export CLICOLOR=1
fi

# `auto` means colour only when stdout is a terminal, so pipes stay clean.
if echo | grep --color=auto '' >/dev/null 2>&1; then
  alias grep='grep --color=auto'
  alias egrep='egrep --color=auto'
  alias fgrep='fgrep --color=auto'
fi


###############################################################################
#                            Completion behaviour
#
# Set after LS_COLORS above, because the completion list borrows its colours.
###############################################################################

# --- matching: case-insensitive, then partial-word, then substring -----------
#
# Tried in order; zsh only moves to the next rule if the previous finds nothing.
#   m:{a-zA-Z-_}={A-Za-z_-}  case-insensitive, and - and _ interchangeable:
#                            `cd ~/dev` completes ~/Dev, `foo-bar` matches
#                            `foo_bar`
#   r:|=*                    partial word: `usr/lo/b` -> `usr/local/bin`
#   l:|=* r:|=*              substring: `mkdir` matches `_mkdir`
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z-_}={A-Za-z_-}' \
  'r:|=*' \
  'l:|=* r:|=*'

# Globbing is separate from completion and case-sensitive by default, so
# `ls ~/dev/*` would still miss ~/Dev. Comment out for case-sensitive globs.
unsetopt CASE_GLOB

# --- options ----------------------------------------------------------------
setopt COMPLETE_IN_WORD   # complete from both ends of the word, not just the end
setopt ALWAYS_TO_END      # after completing, put the cursor at the end
setopt AUTO_MENU          # a second <TAB> starts cycling through the matches
setopt AUTO_LIST          # list choices when the completion is ambiguous
setopt AUTO_PARAM_SLASH   # completed directory gets a trailing slash
setopt PATH_DIRS          # search $PATH even for commands containing a slash
unsetopt MENU_COMPLETE    # do not silently insert the first match
unsetopt FLOW_CONTROL     # free up ^S/^Q, which XOFF/XON would otherwise eat

# --- presentation -----------------------------------------------------------
zstyle ':completion:*' menu select                      # arrow-key selectable menu
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}   # colour matches like ls
zstyle ':completion:*' group-name ''                    # group by type...
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages'     format ' %F{purple}-- %d --%f'
zstyle ':completion:*:warnings'     format ' %F{red}-- no matches --%f'
zstyle ':completion:*:corrections'  format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:options' description yes

# --- cache: makes completion for big commands noticeably faster -------------
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# --- per-command tweaks -----------------------------------------------------
# cd: offer local directories first, then the directory stack.
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
# Do not offer the current directory as a completion for `cd ../`.
zstyle ':completion:*:cd:*' ignore-parents parent pwd
# kill/ps: complete on this user's processes, with the command line visible.
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
# man: split the sections instead of one flat list.
zstyle ':completion:*:manuals' separate-sections true
# Internal helpers are noise.
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

###############################################################################
#                                  fzf-tab
#
# Replaces the completion menu with an fzf picker. It sits on top of zsh's own
# completers, so everything above still applies -- the candidate list is built
# by zsh with the matcher-list, fzf only chooses among it. `ls linux/Compose`
# still finds XCompose.
#
# Must load after compinit and before zsh-syntax-highlighting. $DOTFILES_FZF_TAB
# is exported from ~/.zshenv on the Nix machines; elsewhere it is looked up in
# the usual package-manager prefixes.
###############################################################################
() {
  local candidate
  for candidate in \
    "$DOTFILES_FZF_TAB" \
    /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh \
    /opt/homebrew/share/fzf-tab/fzf-tab.plugin.zsh \
    /usr/share/fzf-tab/fzf-tab.plugin.zsh \
    "$HOME/.local/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"
  do
    [[ -n $candidate && -r $candidate ]] && { source "$candidate"; break }
  done
}

if (( $+functions[fzf-tab-complete] )); then
  # Keep the picker small and out of the way.
  zstyle ':fzf-tab:*' fzf-flags --height=45% --layout=reverse --border
  # Accept the current match with Enter; Space keeps filtering.
  zstyle ':fzf-tab:*' continuous-trigger '/'
  # Preview: directory listing for cd, file contents elsewhere.
  if (( $+commands[eza] )); then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'
  fi
  if (( $+commands[bat] )); then
    zstyle ':fzf-tab:complete:*:*' fzf-preview \
      '[[ -d $realpath ]] && ls -1 "$realpath" || bat --color=always --style=plain --line-range=:100 "$realpath" 2>/dev/null'
  fi
  # fzf-tab draws the list itself, so zsh should not also open its own menu.
  zstyle ':completion:*' menu no
fi


###############################################################################
#                                 Keybindings
# bindkey -l will give you a list of existing keymap names.
# bindkey -M <keymap> will list all the bindings in a given keymap.
# zle -al lists all registered zle commands
###############################################################################
# --- navigation keys ---------------------------------------------------------
# vi mode leaves Home/End/Delete/Insert unbound in some terminals. Take the
# sequences from terminfo where the terminal reports them, and fall back to the
# common xterm ones, then bind in every keymap.
zmodload zsh/terminfo
typeset -A _keys
_keys=(
  Home     "${terminfo[khome]:-^[[H}"
  End      "${terminfo[kend]:-^[[F}"
  Delete   "${terminfo[kdch1]:-^[[3~}"
  Insert   "${terminfo[kich1]:-^[[2~}"
  PageUp   "${terminfo[kpp]:-^[[5~}"
  PageDown "${terminfo[knp]:-^[[6~}"
  Backward "${terminfo[kcub1]:-^[[D}"
  Forward  "${terminfo[kcuf1]:-^[[C}"
)
for _keymap in emacs viins vicmd; do
  bindkey -M $_keymap "$_keys[Home]"     beginning-of-line
  bindkey -M $_keymap "$_keys[End]"      end-of-line
  bindkey -M $_keymap "$_keys[Delete]"   delete-char
  bindkey -M $_keymap "$_keys[Insert]"   overwrite-mode
  bindkey -M $_keymap "$_keys[PageUp]"   up-line-or-history
  bindkey -M $_keymap "$_keys[PageDown]" down-line-or-history
  bindkey -M $_keymap "$_keys[Backward]" backward-char
  bindkey -M $_keymap "$_keys[Forward]"  forward-char
done
unset _keymap _keys

# --- url-quote-magic: quote URLs as they are typed ---------------------------
# Without it, the ?, & and * in a pasted URL are treated as glob characters.
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# --- Alt-S: prepend sudo to the current line ---------------------------------
function prepend-sudo() {
  [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER" && (( CURSOR += 5 ))
}
zle -N prepend-sudo
bindkey -M emacs '\es' prepend-sudo
bindkey -M viins '\es' prepend-sudo
bindkey -M vicmd '\es' prepend-sudo

# Bind only widgets that exist: which plugins are present varies by machine,
# and binding a missing widget errors on every shell start.
function _bindkey_if_widget() {
  local widget="$1" key="$2" keymap
  (( $+widgets[$widget] )) || return 0
  for keymap in "${@:3}"; do
    bindkey -M "$keymap" "$key" "$widget"
  done
}

# Ctrl-R: multi-word history search. Skipped when Atuin is installed, since
# Atuin claims Ctrl-R further down.
if (( ! $+commands[atuin] )); then
  _bindkey_if_widget history-search-multi-word '^r' emacs viins vicmd
fi

# Press vv to edit the command line in $EDITOR.
_bindkey_if_widget edit-command-line 'vv' vicmd


###############################################################################
# Options
###############################################################################
# --- directories ---
setopt autocd            # Allow changing directories without `cd`
setopt auto_pushd        # `cd` pushes onto the stack, so `cd -` and `d` work
setopt pushd_ignore_dups # Dont push copies of the same dir on stack.
setopt pushd_minus       # Reference stack entries with "-".
setopt pushd_silent      # No stack dump after every cd
setopt pushd_to_home     # Bare `pushd` goes home, like bare `cd`
setopt cdable_vars       # `cd myvar` when myvar holds a path
setopt extended_glob

# `d` lists the stack; 1-9 jump to an entry.
alias d='dirs -v'
for _i in {1..9}; do alias "$_i"="cd -$_i"; done
unset _i

# --- interactive niceties ---
setopt interactive_comments # Allow `# comment` on the command line
setopt combining_chars      # Draw accented characters as one glyph
setopt rc_quotes            # 'Henry''s' instead of 'Henry'\''s'
unsetopt mail_warning

# --- job control ---
setopt long_list_jobs   # `jobs` in the long format
setopt auto_resume      # Resume a suspended job instead of starting a new one
unsetopt hup            # Background jobs survive the shell exiting
unsetopt check_jobs     # No "you have running jobs" nag on exit


###############################################################################
# History
###############################################################################
HISTFILE=~/.zsh_history
# HISTSIZE is the in-memory list, SAVEHIST is how much of it reaches HISTFILE,
# so SAVEHIST can never exceed HISTSIZE. These were 5000/10000, which silently
# capped the file at 5000 -- half of what SAVEHIST asked for.
HISTSIZE=20000
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
setopt hist_ignore_space      # A leading space keeps a command out of history.
setopt hist_verify            # Show `!!` expansions instead of running them.


###############################################################################
# OS specific stuff
###############################################################################
#
# $DOTFILES_PLATFORM is set to one of: macos, synology, wsl, linux.
# Scripts and prompts can branch on it instead of re-detecting.
#
case $OS in
Darwin)
  export DOTFILES_PLATFORM=macos
  # $MACOS_VERSION was exported here from `sw_vers -productVersion`, ~6 ms of
  # every shell start, and nothing read it. Run sw_vers directly when needed.
  [[ -f "$HOME/.zsh/zshrc_macos" ]] && source "$HOME/.zsh/zshrc_macos"
  ;;
Linux)
  # Synology DSM: /etc/synoinfo.conf is present on every DSM install and on
  # nothing else. Checked before WSL: DSM is never WSL.
  if [[ -f /etc/synoinfo.conf ]]; then
    export DOTFILES_PLATFORM=synology
    [[ -f "$HOME/.zsh/zshrc_synology" ]] && source "$HOME/.zsh/zshrc_synology"
  # WSL sets $WSL_DISTRO_NAME; the osrelease check covers older builds.
  elif [[ -n $WSL_DISTRO_NAME ]] || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
    export DOTFILES_PLATFORM=wsl
    [[ -f "$HOME/.zsh/zshrc_wsl" ]] && source "$HOME/.zsh/zshrc_wsl"
  else
    export DOTFILES_PLATFORM=linux
  fi
  # The generic Linux file loads on every Linux, including WSL and DSM.
  [[ -f "$HOME/.zsh/zshrc_linux" ]] && source "$HOME/.zsh/zshrc_linux"
  ;;
*)
  export DOTFILES_PLATFORM=unknown
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

# noglob: type unquoted globs without zsh expanding them first,
# e.g. `find . -name *.txt` or `scp host:*.log .`
alias find='noglob find'
alias locate='noglob locate'
alias rsync='noglob rsync'
alias scp='noglob scp'
alias sftp='noglob sftp'

alias unzipall="unzip '*.zip'"

alias gst='git status'
alias git-remove-untracked='git fetch --prune && git branch -r | awk "{print \$1}" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk "{print \$1}" | xargs git branch -d'
alias git-remove-merged='git branch --merged master | grep -E -v "(^\*|master|main|dev|develop|testing)" | xargs git branch -d'
alias git-remove-remote-merged-to-master-keep='git fetch --prune origin && git branch -r --merged | grep -E -v "(^\*|master|main|dev|develop|testing)" | sed "s/origin\///" | xargs -n 1 git push --delete origin'
alias git-remove-remote-merged-to-master='git fetch --prune origin && git branch -r --merged | grep -E -v "(^\*|master|main)" | sed "s/origin\///" | xargs -n 1 git push --delete origin'

# eza provides k/kk. `lt` stays `ls -ltr` from above.
if (( $+commands[eza] )); then
  alias k='eza --long --header --group-directories-first --git'
  alias kk='eza --long --header --group-directories-first --git --all'
  alias ltree='eza --tree --level=3'
  # eza respects .gitignore and colours by file type.
  (( ! $+commands[tree] )) && alias tree='eza --tree'
fi

# btop under the old name, out of muscle memory.
if (( $+commands[btop] )) && (( ! $+commands[htop] )); then
  alias htop='btop'
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

###############################################################################
# Docker
#
# Inspiration: https://github.com/webyneter/docker-aliases
###############################################################################

# --- Images ---
alias di='docker images'
alias dbu='docker build'
alias drmi='docker rmi'
alias drmi_all='docker rmi $* $(docker images -a -q)'
alias drmi_dang='docker rmi $* $(docker images -q -f "dangling=true")'
alias dhi='docker history $*'

# Layers of an image, largest first.
dhi_neat() {
  docker history "${1}" \
    --format "{{ .Size }}\t{{ .CreatedBy }}" \
    ${2:-} |
    sort --key=1 --human-numeric-sort --reverse
}

# --- Containers ---
alias dps='docker ps'
alias dpsa='docker ps -a'
alias drit='docker run -it'
alias deit='docker exec -it'
alias dlog='docker logs'
alias dip='docker inspect --format "{{ .NetworkSettings.IPAddress }}" $*'
alias dstop_all='docker stop $* $(docker ps -q -f "status=running")'
alias drm='docker rm'
alias drm_stopped='docker rm $* $(docker ps -q -f "status=exited")'
alias drmv_stopped='docker rm -v $* $(docker ps -q -f "status=exited")'
alias drm_all='docker rm $* $(docker ps -a -q)'
alias drmv_all='docker rm -v $* $(docker ps -a -q)'

# --- Volumes ---
alias dvls='docker volume ls $*'
alias dvrm_all='docker volume rm $(docker volume ls -q)'
alias dvrm_dang='docker volume rm $(docker volume ls -q -f "dangling=true")'

# --- Housekeeping ---
alias dnorestart='docker update --restart=no $* $(docker ps -q)'
alias dprune='docker system prune --volumes'
alias dupgrade="docker images | awk '{print $1}' | grep -v 'none' | grep -iv 'repo' | xargs -n1 docker pull"

# --- Compose ---
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f --tail=100'
alias dcr='docker compose restart'

###############################################################################
# Terminal images
#
# Ghostty replaced kitty, so `kitty +kitten icat` is gone. Ghostty speaks the
# same graphics protocol, and timg/chafa render images over it.
###############################################################################
if (( $+commands[timg] )); then
  alias icat='timg'
elif (( $+commands[chafa] )); then
  alias icat='chafa'
fi

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
#                                Atuin
# SQLite-backed shell history: records exit code, duration, cwd and session,
# and gives Ctrl-R a fuzzy search over all of it.
#
# Configured declaratively on the Nix machines, see
# nix-darwin/modules/home-manager/programs/atuin.nix
#
# Initialised here rather than by home-manager so it runs after the keybindings
# section and therefore claims Ctrl-R, and so non-Nix machines pick it up too.
#
# --disable-up-arrow keeps Up bound to zsh-history-substring-search, which
# matches on the prefix already typed. Ctrl-R is the full search.
###############################################################################
if (( $+commands[atuin] )); then
  eval "$(atuin init zsh --disable-up-arrow)"
fi


###############################################################################
#                                Carapace
#
# Deliberately not enabled globally. `carapace _carapace zsh` compdefs itself
# onto ~400 commands, and it matches prefixes internally rather than consulting
# zsh's matcher-list, so those commands lose the case-insensitive, partial-word
# and substring matching configured in the completion section above --
# `ls linux/Compose<TAB>` no longer finds XCompose. Prefix-only is the best it
# offers; CARAPACE_MATCH=CASE_INSENSITIVE recovers case but not substring.
#
# Almost everything worth completing already ships a zsh function (_ls, _git,
# _docker, _gh, _just, _cargo ...), which the matcher-list does apply to.
#
# For a tool that genuinely has no completion, enable it for that command only:
#   source <(carapace some-tool zsh)
###############################################################################


###############################################################################
#                                Zellij
#
# Auto-attach on incoming SSH, so reconnecting to a box (the NAS in particular)
# lands back in the same session with everything still running.
#
# The session is named after the host, so `zellij ls` from anywhere is readable
# and two different servers never collide.
#
# Deliberately NOT `exec zellij`: if zellij is broken or the terminfo is wrong,
# exec would kill the login shell and lock you out of a headless box over SSH.
# Falling through to a normal shell is the safe failure mode.
#
# Escape hatches:
#   DOTFILES_NO_ZELLIJ=1 ssh host    skip it for one connection
#   ssh host -t 'zsh -l'             same, if the variable cannot be passed
###############################################################################
if (( $+commands[zellij] )) &&
  [[ -z "$ZELLIJ" &&
    -z "$DOTFILES_NO_ZELLIJ" &&
    -z "$EMACS" &&
    -z "$VIM" &&
    -z "$INSIDE_EMACS" &&
    -n "$SSH_TTY" &&
    -o interactive &&
    "$TERM_PROGRAM" != "vscode" &&
    "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" ]]; then
  zellij attach --create "${HOST%%.*}"
fi


###############################################################################
#                            pixi, uv and uvx
#
# $PATH is set in the Vars section; their completions are cached onto $fpath by
# the Completions section, which is why nothing is needed here.
###############################################################################


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
#                       Toolchain versions: mise, else nvm
#
# mise (https://mise.jdx.dev) manages node, python and go versions from a
# single .tool-versions/mise.toml, activated per directory. nvm loads only when
# mise is absent: running both leaves two tools fighting over the node on $PATH.
#
#   mise use --global node@lts      # then ~/.config/nvm can go
###############################################################################
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
elif [[ -d "$HOME/.config/nvm" ]]; then
  export NVM_DIR="$HOME/.config/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
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
#                               Claude
###############################################################################
claude-session() {
  local file=$(ls -t ~/.claude/projects/**/*.jsonl | head -1)
  echo "Session ID: $(basename $file .jsonl)"
  tail -5 "$file" | jq '.message.content[0].text // .message.content // empty' 2>/dev/null
}


###############################################################################
#                                Nexus Tools
###############################################################################
if [[ -d "$HOME/.nexus-tools" ]]; then
  export NEXUS_TOOLS_PATH="$HOME/.nexus-tools"
  addToPathEnd $NEXUS_TOOLS_PATH
fi
