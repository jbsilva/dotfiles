###############################################################################
#               Julio's ~/.zshrc file
#
#                      ( O O )
#               ====oOO==(_)==OOo=====
#
# License:
#           Copyright (c) 2011-2016, Julio Batista Silva <julio@juliobs.com>
#                       All Rights Reserved
#
#           This program is free software. It comes without any warranty, to
#           the extent permitted by applicable law. You can redistribute it
#           and/or modify it under the terms of the Do What The Fuck You Want
#           To Public License, Version 2, as published by Sam Hocevar. See
#           http://sam.zoy.org/wtfpl/COPYING for more details.
#
# Created:      12 Aug 2011
# Last Change:  29 Jan 2016
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


###############################################################################
# Zplug - Plugin manager for zsh
# Install with homebrew
###############################################################################
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "sorin-ionescu/prezto", \
    use:init.zsh, hook-build:"ln -s $ZPLUG_HOME/repos/sorin-ionescu/prezto ~/.zprezto"

zplug "lukechilds/zsh-nvm"

zplug "junegunn/fzf-bin", from:gh-r, \
    as:command, rename-to:fzf, use:"*linux*amd64*"

zplug "stedolan/jq", from:gh-r, \
    as:command, rename-to:jq

zplug "zplug/zplug"
zplug "hkupty/ssh-agent"
zplug "jreese/zsh-titles"
zplug "modules/completion", from:prezto
zplug "modules/directory", from:prezto
zplug "modules/editor", from:prezto
zplug "modules/environment", from:prezto
zplug "modules/git", from:prezto
zplug "modules/gpg", from:prezto
zplug "modules/history", from:prezto
zplug "modules/homebrew", from:prezto
zplug "modules/node", from:prezto
zplug "modules/osx", from:prezto
zplug "modules/prompt", from:prezto
zplug "modules/ruby", from:prezto
zplug "modules/spectrum", from:prezto
zplug "modules/terminal", from:prezto
zplug "modules/tmux", from:prezto
zplug "modules/utility", from:prezto

zplug "psprint/history-search-multi-word"
zplug "psprint/zsh-select"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting"

zstyle ':prezto:module:utility:ls' color 'yes'
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting", defer:2


# Theme
zplug "jbsilva/prompt_jbs", use:prompt_jbs_setup, from:github, as:theme


# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
# To debug: zplug load --verbose
zplug load --verbose


###############################################################################
# Source Prezto
###############################################################################
#if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
#    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
#fi


###############################################################################
# FZF - Command-line fuzzy finder
# zplug "junegunn/fzf", as:command, hook-build:"./install --bin", use:"bin/{fzf-tmux,fzf}"
###############################################################################
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


###############################################################################
# Variáveis
###############################################################################
case ":$PATH:" in
  *:/usr/local/sbin:*) ;;
  *) export PATH=/usr/local/sbin:$PATH ;;
esac

if [[ -z "$XDG_CONFIG_HOME" ]]; then
    export XDG_CONFIG_HOME=$HOME/.config
fi

fpath=(/usr/local/share/zsh-completions $fpath)

local NVIM=nvim
export VISUAL=$NVIM
export EDITOR=$NVIM
export NVIM_PYTHON_LOG_FILE_PATH=~/.config/nvim/nvimlog
export OS="$(uname -s)"
export USER='Julio'
export USER_FULLNAME='Julio Batista Silva'
export USER_EMAIL='julio@juliobs.com'
export USER_GITHUB='jbsilva'
export USER_COPYRIGHT="Copyright (c) $(date +%Y), $USER_FULLNAME"

export LANG="en_US"
export LC_ALL=$LANG.UTF-8


###############################################################################
# Coisas específicas de cada SO
###############################################################################
case $(uname -s) in
    Darwin)
        export OSX_VERSION="$(sw_vers -productVersion)"
        source $HOME/.zsh/zshrc_osx
        ;;
    Linux)
        source $HOME/.zsh/zshrc_linux
        ;;
esac

###############################################################################
# Pyenv and pyenv-virtualenv
# pyenv install 2.7-dev && pyenv rehash && pyenv global 2.7-dev
###############################################################################
if (( $+commands[pyenv] )); then eval "$(pyenv init -)"; fi
if (( $+commands[pyenv-virtualenv-init] )); then eval "$(pyenv virtualenv-init -)"; fi


###############################################################################
# rbenv
###############################################################################
if (( $+commands[rbenv] )); then eval "$(rbenv init -)"; fi


###############################################################################
# Histórico
###############################################################################
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=10000
setopt sharehistory
setopt HIST_IGNORE_ALL_DUPS


###############################################################################
# Aliases
###############################################################################
alias dir='ls -1'
alias lsa='ls -alh'
alias list='du -shc *'
alias back='cd "$OLDPWD"'
alias ...='cd ../../../'
alias ....='cd ../../../../'

# Needs lynx
if (( $+commands[lynx] )); then
    WWWDUMP='lynx -dump -nolist -width=300 -accept_all_cookies -display_charset=UTF-8'
    alias meuip="curl -s -m 8 eth0.me || curl -s -m 5 ifconfig.me || curl -s -m 5 icanhazip.com || $WWWDUMP http://www.getip.com | sed -n 's/^Current IP: //p'"
else
    alias meuip="curl -s -m 8 eth0.me || curl -s -m 5 ifconfig.me || curl -s -m 5 icanhazip.com"
fi


alias pip2_upgrade="pip2 install --upgrade pip && pip2 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip2 install --upgrade"
alias pip3_upgrade="pip3 install --upgrade pip && pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install --upgrade"
alias difff='/usr/bin/diff'
alias rot13="tr '[A-Za-z]' '[N-ZA-Mn-za-m]'"
alias d755="find . -type d -exec chmod 755 {} \;"
alias f644="find . -type f -exec chmod 644 {} \;"
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'
alias sha1='openssl sha1'
alias sha256='shasum -a 256'
alias wget='wget -c'    # Resume wget by default

alias showAllOn='defaults write com.apple.finder AppleShowAllFiles 1 && killall Finder'  # Show all files in Finder
alias showAllOff='defaults write com.apple.finder AppleShowAllFiles 0 && killall Finder'
alias hide_Desktop='defaults write com.apple.finder CreateDesktop -bool FALSE; killall Finder'
alias show_Desktop='defaults write com.apple.finder CreateDesktop TRUE; killall Finder'

alias unzipall="unzip '*.zip'"

alias paste2vim='pbpaste | vim -'             # Paste clipboard in new vim file

alias g++e='g++ -O2 -lm -Wall -Wextra -Weffc++ -Wwrite-strings -Werror'    # Warnings = Error
alias g++w='g++ -O2 -lm -Wall -Wextra -Weffc++ -Wwrite-strings'            # Warnings
alias g++p='g++ -O2 -lm -Wall -Wextra -Weffc++ -Wwrite-strings -pedantic'  # Warnings + Pedantic
alias g++d='g++ -O0 -ggdb3 -lm -Wall -Wextra -Weffc++ -Wwrite-strings'     # Debug
alias g++11='g++ -O2 -lm -std=c++11 -Wall -Wextra'                         # C++11
alias g++p11='g++ -O2 -lm -std=c++11 -Wall -Wextra -Weffc++ -Wwrite-strings -pedantic'  # Warnings + Pedantic + C++11
alias estiliza='astyle --unpad-paren --style=allman --pad-oper --pad-comma --delete-empty-lines --break-blocks --convert-tabs --align-pointer=name --align-reference=name --lineend=linux --pad-header --indent-col1-comments --indent-switches --suffix=none --keep-one-line-statements'
alias estiliza_objc='astyle --unpad-paren --style=attach --pad-oper --pad-comma --delete-empty-lines --break-blocks --convert-tabs --align-pointer=name --align-reference=name --lineend=linux --pad-header --indent-switches --suffix=none --keep-one-line-statements --pad-method-prefix --unpad-return-type --unpad-param-type --align-method-colon --pad-method-colon=none'

alias recc='rename -X -c --rews --camelcase --nows'
alias qmvv='qmv --format=dc --options=spaces,width=40,autowidth'
alias qmvo='qmv --format=destination-only'
alias qmvor='qmv -R --format=destination-only'


###############################################################################
# Functions
###############################################################################
source $HOME/.zsh/baixa_dir.zsh
source $HOME/.zsh/cleand.zsh
source $HOME/.zsh/clone_dir.zsh
source $HOME/.zsh/my_ip.zsh
source $HOME/.zsh/rm_empty_dirs.zsh
source $HOME/.zsh/rm_empty_files.zsh
source $HOME/.zsh/rm_regex.zsh

# OS X only
if [[ "$OSTYPE" == darwin* ]]; then
    source $HOME/.zsh/getuti.zsh
fi

# Python server
function python_server()
{
    local port="${1:-8000}"
    open "http://localhost:${port}/"
    python -m SimpleHTTPServer "$port"
}

###############################################################################
# FUN
###############################################################################
alias rainbow='yes "$(seq 16 231)" | while read i; do printf "\x1b[48;5;${i}m\n"; sleep .02; done'
alias fucking='sudo'
alias emacs='echo "segmentation fault"'
alias more=less
alias CAT='echo "=^.^=\n"'
