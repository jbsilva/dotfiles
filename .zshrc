#######################################################
#               Julio's ~/.zshrc file
#
#                      ( O O )
#               ====oOO==(_)==OOo=====
#
# Licença:
#           Copyright (c) 2011 Julio Batista Silva <julio@juliobs.com>
#                       All Rights Reserved
#
#           This program is free software. It comes without any warranty, to
#           the extent permitted by applicable law. You can redistribute it
#           and/or modify it under the terms of the Do What The Fuck You Want
#           To Public License, Version 2, as published by Sam Hocevar. See
#           http://sam.zoy.org/wtfpl/COPYING for more details.
#
# Created:      Fri 12 Aug 2011
# Last Change:  Wed 09 Sep 2015
#
# Download: https://github.com/jbsilva/dotfiles
#
# OS: MacBook OS X 10.11
#######################################################


################################
# Teste de segurança
################################
# Don't do anything for non-interactive shells
[[ -z "$PS1" ]] && return


################################
# Source Prezto.
################################
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi


################################
# Variáveis
################################
local VIM=/usr/local/bin/vim
export VISUAL=$VIM
export EDITOR=$VIM
export OS="$(uname -s)"
export USER='Julio'
export USER_FULLNAME='Julio Batista Silva'
export USER_EMAIL='julio@juliobs.com'
export USER_GITHUB='jbsilva'
export USER_COPYRIGHT='Copyright (c) 2015, Julio Batista Silva'

################################
# Coisas específicas de cada SO
################################
case $(uname -s) in
    Darwin)
        export OSX_VERSION="$(sw_vers -productVersion)"
#        source $HOME/.zsh/osx.zshrc
        ;;
    Linux)
#        source $HOME/.zsh/linux.zshrc
        ;;
esac


################################
# rbenv
################################
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi


################################
# Histórico
################################
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=10000
setopt sharehistory
setopt HIST_IGNORE_ALL_DUPS


################################
# Aliases
################################
alias dir='ls -1'
alias list='du -shc *'
alias listh='du -shc * | gsort -h'
alias back='cd "$OLDPWD"'
alias ...='cd ../../../'
alias ....='cd ../../../../'

alias meuip='curl ifconfig.me'
alias my_ip="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"

alias brewu='brew update && brew upgrade && brew cleanup && brew cask cleanup && brew prune && brew doctor'
alias pip_upgrade="pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install --upgrade"
alias difff='/usr/bin/diff'
alias rot13="tr '[A-Za-z]' '[N-ZA-Mn-za-m]'"
alias d755="find . -type d -exec chmod 755 {} \;"
alias f644="find . -type f -exec chmod 644 {} \;"
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'
alias sha1='openssl sha1'
alias wget='wget -c'    # Resume wget by default

alias showAllOn='defaults write com.apple.finder AppleShowAllFiles 1 && killall Finder'  # Show all files in Finder
alias showAllOff='defaults write com.apple.finder AppleShowAllFiles 0 && killall Finder'
alias paste2vim='pbpaste | vim -'             # Paste clipboard in new vim file

alias g++e='g++ -O2 -lm -Wall -Wextra -Weffc++ -Wwrite-strings -Werror'    # Warnings = Error
alias g++w='g++ -O2 -lm -Wall -Wextra -Weffc++ -Wwrite-strings'            # Warnings
alias g++p='g++ -O2 -lm -Wall -Wextra -Weffc++ -Wwrite-strings -pedantic'  # Warnings + Pedantic
alias g++d='g++ -O0 -ggdb3 -lm -Wall -Wextra -Weffc++ -Wwrite-strings'     # Debug
alias g++11='g++ -O2 -lm -std=c++11 -Wall -Wextra'                         # C++11
alias g++p11='g++ -O2 -lm -std=c++11 -Wall -Wextra -Weffc++ -Wwrite-strings -pedantic'  # Warnings + Pedantic + C++11
alias estiliza='astyle --unpad-paren --style=allman --pad-oper --delete-empty-lines --break-blocks --convert-tabs --align-pointer=name --align-reference=name --lineend=linux --pad-header --indent-col1-comments --indent-switches --suffix=none --keep-one-line-statements'


################################
# Functions
################################

# Python server
function python_server()
{
    local port="${1:-8000}"
    open "http://localhost:${port}/"
    python -m SimpleHTTPServer "$port"
}

# Cleanup
function cleand()
{
    if [[ "$(uname)" == "Darwin" ]]; then
        dot_clean -m --keep=mostrecent "$1"
    fi
    
    find "$1" -type f \( -name '.DS_Store' -o -name 'Thumbs.db' -o -name 'desktop.ini' \) -exec echo "{}" \; -exec rm "{}" \;
}

# Clone directories
function dir_clone()
{
    cleand "$1"
    rsync -aruv --delete "$1" "$2"
}

# Remove empty directories. GNU find
function rm_empty_dirs()
{
    find "$1" -type d -empty -delete
    #find "$1" -depth -type d -empty -print0 | xargs -0 rmdir
}

# Downloads directories recursively. Mirror remote
function baixa_dir()
{
    UserAgent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36'

    wget -e robots=off \
    --user-agent="${UserAgent}" \
    --cut-dirs=3 \
    --no-parent \
    --recursive \
    --relative \
    --level=5 \
    --no-host-directories \
    #--no-directories \
    --no-check-certificate \
    --reject="index.html*" \
    "$1"
}
################################
# FUN
################################
alias rainbow='yes "$(seq 16 231)" | while read i; do printf "\x1b[48;5;${i}m\n"; sleep .02; done'
alias fucking='sudo'
alias emacs='echo "segmentation fault"'
alias more=less
alias CAT='echo "=^.^=\n"'
