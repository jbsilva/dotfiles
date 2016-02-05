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
# Teste de segurança
###############################################################################
# Don't do anything for non-interactive shells
[[ -z "$PS1" ]] && return


###############################################################################
# Source Prezto.
###############################################################################
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi


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

local NVIM=nvim
export VISUAL=$NVIM
export EDITOR=$NVIM
export OS="$(uname -s)"
export USER='Julio'
export USER_FULLNAME='Julio Batista Silva'
export USER_EMAIL='julio@juliobs.com'
export USER_GITHUB='jbsilva'
export USER_COPYRIGHT="Copyright (c) $(date +%Y), $USER_FULLNAME"

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
# rbenv
###############################################################################
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi


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

WWWDUMP='lynx -dump -nolist -width=300 -accept_all_cookies -display_charset=UTF-8'
alias meuip="curl -s -m 1 ifconfig.me || curl -s -m 1 icanhazip.com || $WWWDUMP http://www.getip.com | sed -n 's/^Current IP: //p'"

alias pip_upgrade="pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install --upgrade"
alias pip3_upgrade="pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install --upgrade"
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
alias estiliza='astyle --unpad-paren --style=allman --pad-oper --delete-empty-lines --break-blocks --convert-tabs --align-pointer=name --align-reference=name --lineend=linux --pad-header --indent-col1-comments --indent-switches --suffix=none --keep-one-line-statements'


###############################################################################
# Functions
###############################################################################
source $HOME/.zsh/baixa_dir.zsh
source $HOME/.zsh/cleand.zsh
source $HOME/.zsh/clone_dir.zsh
source $HOME/.zsh/my_ip.zsh
source $HOME/.zsh/rm_empty_dirs.zsh

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
