###############################################################################
#               Julio's ~/.zshrc file
#
#                      ( O O )
#               ====oOO==(_)==OOo=====
#
# License:
#           Copyright (c) 2011-2022, Julio Batista Silva <julio@juliobs.com>
#                       All Rights Reserved
#
#           This program is free software. It comes without any warranty, to
#           the extent permitted by applicable law. You can redistribute it
#           and/or modify it under the terms of the Do What The Fuck You Want
#           To Public License, Version 2, as published by Sam Hocevar. See
#           http://sam.zoy.org/wtfpl/COPYING for more details.
#
# Created:      12 Aug 2011
# Last Change:  16 Dez 2022
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
# Run `/usr/local/opt/fzf/install` after instalation through Homebrew
###############################################################################
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


###############################################################################
# Path Functions
###############################################################################

# Add to beginning of PATH
function addToPathStart {
  case ":$PATH:" in
    *":$1:"*) :;; # already there
    *) PATH="$1:$PATH";;
  esac
}

# Add to end of PATH
function addToPathEnd {
  case ":$PATH:" in
    *":$1:"*) :;; # already there
    *) PATH="$PATH:$1";;
  esac
}

###############################################################################
#                                     Vars
# Some will be in ~/.xprofile
###############################################################################

addToPathStart /usr/local/sbin
addToPathStart $HOME/.local/bin
addToPathStart $HOME/.cargo/bin
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

fpath=(/usr/local/share/zsh-completions $fpath)

local NVIM=nvim
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
export LANG='en_GB.UTF-8'
export LC_ALL='en_GB.UTF-8'


# Terminal Emulator
export term_emulator=$(ps -h -o comm -p $PPID)

if [[ $term_emulator == *"kitty"* ]]; then
	export TERM="xterm-kitty"
else
	export TERM="xterm-256color"
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

# More functions
[[ -f "$HOME/.zsh/baixa_dir.zsh" ]] && source "$HOME/.zsh/baixa_dir.zsh"
[[ -f "$HOME/.zsh/cleand.zsh" ]] && source "$HOME/.zsh/cleand.zsh"
[[ -f "$HOME/.zsh/clone_dir.zsh" ]] && source "$HOME/.zsh/clone_dir.zsh"
[[ -f "$HOME/.zsh/my_ip.zsh" ]] && source "$HOME/.zsh/my_ip.zsh"
[[ -f "$HOME/.zsh/python_server.zsh" ]] && source "$HOME/.zsh/python_server.zsh"
[[ -f "$HOME/.zsh/rm_empty_dirs.zsh" ]] && source "$HOME/.zsh/rm_empty_dirs.zsh"
[[ -f "$HOME/.zsh/rm_empty_files.zsh" ]] && source "$HOME/.zsh/rm_empty_files.zsh"
[[ -f "$HOME/.zsh/rm_regex.zsh" ]] && source "$HOME/.zsh/rm_regex.zsh"


###############################################################################
#                                    Zplug
# Plugin manager for zsh (https://github.com/zplug/zplug)
# Do not install with homebrew
###############################################################################
# Install zplug if necessary and start it
export ZPLUG_HOME="${ZDOTDIR:-$HOME}/.zplug"
test -e $ZPLUG_HOME || git clone https://github.com/zplug/zplug $ZPLUG_HOME
export ZPLUG_LOADFILE="$HOME/.zsh/zplug.zsh"
source "${ZPLUG_HOME}/init.zsh"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load


###############################################################################
#                                 Keybindings
# bindkey -l will give you a list of existing keymap names.
# bindkey -M <keymap> will list all the bindings in a given keymap.
# zle -al lists all registered zle commands
###############################################################################
for keymap in 'emacs' 'viins' 'vicmd'; do
    # Requires zdharma/history-search-multi-word plugin
    bindkey -M $keymap '^r' history-search-multi-word
done
unset keymap

# Requires b4b4r07/emoji-cli plugin
bindkey -M viins '^s' emoji::cli


###############################################################################
#                          Pyenv and pyenv-virtualenv
# pyenv install 2.7 && pyenv install 3.8.12 && pyenv rehash && pyenv global 2.7 3.8.12
###############################################################################
if (( $+commands[pyenv] )); then eval "$(pyenv init --path)"; eval "$(pyenv init -)"; fi
if (( $+commands[pyenv-virtualenv-init] )); then eval "$(pyenv virtualenv-init -)"; fi


###############################################################################
#                                    Conda
###############################################################################
export CONDA_AUTO_ACTIVATE_BASE=false
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOME/.pyenv/versions/mambaforge/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/.pyenv/versions/mambaforge/etc/profile.d/conda.sh" ]; then
        . "$HOME/.pyenv/versions/mambaforge/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/.pyenv/versions/mambaforge/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "$HOME/.pyenv/versions/mambaforge/etc/profile.d/mamba.sh" ]; then
    . "$HOME/.pyenv/versions/mambaforge/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<


###############################################################################
#                                    rbenv
###############################################################################
if (( $+commands[rbenv] )); then eval "$(rbenv init -)"; fi


###############################################################################
#                             Ruby Version Manager
###############################################################################
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
addToPathEnd $HOME/.rvm/bin

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

###############################################################################
#                                     jenv
###############################################################################
#export PATH="$HOME/.jenv/bin:$PATH"
if (( $+commands[jenv] )); then eval "$(jenv init -)"; fi


###############################################################################
#                            Node Version Manager
###############################################################################
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


###############################################################################
#                                   Perl
###############################################################################
PATH="$HOME/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;


###############################################################################
# Options
###############################################################################
setopt autocd                   # Allow changing directories without `cd`
setopt pushd_ignore_dups        # Dont push copies of the same dir on stack.
setopt pushd_minus              # Reference stack entries with "-".
setopt extended_glob


###############################################################################
# History
###############################################################################
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=10000
setopt append_history           # Dont overwrite history
setopt extended_history         # Also record time and duration of commands.
setopt share_history            # Share history between multiple shells
setopt hist_expire_dups_first   # Clear duplicates when trimming internal hist.
setopt hist_find_no_dups        # Dont display duplicates during searches.
setopt hist_ignore_dups         # Ignore consecutive duplicates.
setopt hist_ignore_all_dups     # Remember only one unique copy of the command.
setopt hist_reduce_blanks       # Remove superfluous blanks.
setopt hist_save_no_dups        # Omit older commands in favor of newer ones.


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
alias please='sudo $(fc -ln -1)'        # Last command with sudo

alias list='du -shc *'
alias listh='du -shc * | sort -h'

alias back='cd "$OLDPWD"'
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

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

alias vim='nvim'

# Download mp3 from Youtube
if (( $+commands[youtube-dl] )); then
    alias ytmp3="youtube-dl --extract-audio --audio-format mp3"
fi

# Set editor preference to nvim if available.
if which nvim &>/dev/null; then
	alias vim='() { $(whence -p nvim) $@ }'
else
	alias vim='() { $(whence -p vim) $@ }'
fi

# alias pip2_upgrade="pip2 install --upgrade pip && pip2 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip2 install --upgrade"
#alias pip3_upgrade="pip3 install --upgrade pip && pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install --upgrade"
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
alias wget='wget -c'        # Resume wget by default

alias ack='ack --ignore-dir=".mypy_cache"'

alias unzipall="unzip '*.zip'"

alias gst='git status'
alias git-remove-untracked='git fetch --prune && git branch -r | awk "{print \$1}" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk "{print \$1}" | xargs git branch -d'
alias git-remove-merged='git branch --merged master | grep -E -v "(^\*|master|main|dev)" | xargs git branch -d'

# Supercrabtree/k
# _k: original k
#  k: human readable, without Git (faster)
# kk: human readable, with Git
eval "$(echo "_k() {"; declare -f k | tail -n +2)"
alias kk="_k --human --group-directories-first"
alias k="_k --human --group-directories-first --no-vcs"

# Paste clipboard in new vim file
alias paste2vim='pbpaste | nvim -'

# Open AuTHentication (OATH) one-time password
alias otp='oathtool --totp -b'

# Backup
alias bkp='rsync --recursive --links --times --compress-level=0 --info=flist2,name,progress --human-readable'
alias bkpd='rsync --recursive --links --times --compress-level=0 --info=flist2,name,progress --human-readable --delete'

# C/C++/Objective-C
alias g++e='g++ -O2 -lm -Wall -Wextra -Weffc++ -Wwrite-strings -Werror'    # Warnings = Error
alias g++w='g++ -O2 -lm -Wall -Wextra -Weffc++ -Wwrite-strings'            # Warnings
alias g++p='g++ -O2 -lm -Wall -Wextra -Weffc++ -Wwrite-strings -pedantic'  # Warnings + Pedantic
alias g++d='g++ -O0 -ggdb3 -lm -Wall -Wextra -Weffc++ -Wwrite-strings'     # Debug
alias g++11='g++ -O2 -lm -std=c++11 -Wall -Wextra'                         # C++11
alias g++p11='g++ -O2 -lm -std=c++11 -Wall -Wextra -Weffc++ -Wwrite-strings -pedantic'  # Warnings + Pedantic + C++11
alias estiliza='astyle --unpad-paren --style=allman --pad-oper --pad-comma --delete-empty-lines --break-blocks --convert-tabs --align-pointer=name --align-reference=name --lineend=linux --pad-header --indent-col1-comments --indent-switches --suffix=none --keep-one-line-statements'
alias estiliza_objc='astyle --unpad-paren --style=attach --pad-oper --pad-comma --delete-empty-lines --break-blocks --convert-tabs --align-pointer=name --align-reference=name --lineend=linux --pad-header --indent-switches --suffix=none --keep-one-line-statements --pad-method-prefix --unpad-return-type --unpad-param-type --align-method-colon --pad-method-colon=none'

# Python
alias ap8='autopep8 --in-place --aggressive --aggressive'

# Renamers
alias recc='rename -X -c --rews --camelcase --nows'
alias qmvv='qmv --format=dc --options=spaces,width=40,autowidth'
alias qmvo='qmv --format=destination-only'
alias qmvor='qmv -R --format=destination-only'
alias exif_move="exiftool -P -i '#recycle' -i '@eaDir' -i 'SYMLINKS' -i 'HIDDEN' -d '%Y/%m' '-Directory<\${CreateDate}' '-Directory<\${DateTimeOriginal}' ."
alias exif_rename="exiftool -P -i '#recycle' -i '@eaDir' -i 'SYMLINKS' -i 'HIDDEN' -d '%Y%m%d_%H%M%S' '-filename<%f-\${ImageSize}%-03c.%le' '-filename<\${CreateDate}%-03c.%le' '-filename<\${DateTimeOriginal}%-03c.%le' ."

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

# See open ports
alias open_ports='sudo ss -tulpn | grep LISTEN'

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
case $(tty) in 
  (/dev/tty[1-9]) [[ -f ~/.p10k_console.zsh ]] && source ~/.p10k_console.zsh;;
              (*) [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh;; 
          esac


###############################################################################
#                                   Neofetch
###############################################################################
#if [[ $term_emulator == *"kitty"* ]]; then
#    # kitty
#    neofetch --backend 'kitty'
#elif [[  $term_emulator == *"tmux"*  ]] || [[ $term_emulator == "login" ]]; then
#    # tmux
#    neofetch --backend 'w3m' --ascii_distro 'arch_small' 
#else
#    # xterm and rxvt
#    neofetch --backend 'w3m' --xoffset 20 --yoffset 20 --gap 0
#fi

