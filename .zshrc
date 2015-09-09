#######################################################
#               Julio's ~/.zshrc file
#
#                      ( O O )
#               ====oOO==(_)==OOo=====
#
# Licença:
#           Copyright (c) 2011 Julio B. Silva <julio@juliobs.com>
#                       All Rights Reserved
#
#           This program is free software. It comes without any warranty, to
#           the extent permitted by applicable law. You can redistribute it
#           and/or modify it under the terms of the Do What The Fuck You Want
#           To Public License, Version 2, as published by Sam Hocevar. See
#           http://sam.zoy.org/wtfpl/COPYING for more details.
#
# Created:      Fri 12 Aug 2011
# Last Change:  Sat 19 Apr 2014
#
# Download: https://github.com/jbsilva/dotfiles
#
# OS: MacBook OS X 10.9.2
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
# Variáveis
################################
VIM=/usr/local/bin/vim
export VISUAL=$VIM
export EDITOR=$VIM

################################
# Aliases
################################
alias dir='ls -1'
alias list='du -shc *'
alias listh='du -shc * | gsort -h'
alias back='cd "$OLDPWD"'
alias meuip='curl ifconfig.me'
alias g++e='g++ -O2 -lm -Wall -Wextra -Weffc++ -Wwrite-strings -Werror'   #Warnings = Error
alias g++w='g++ -O2 -lm -Wall -Wextra -Weffc++ -Wwrite-strings'           #Warnings
alias g++p='g++ -O2 -lm -Wall -Wextra -Weffc++ -Wwrite-strings -pedantic' #Warnings + Pedantic
alias g++d='g++ -O0 -ggdb3 -lm -Wall -Wextra -Weffc++ -Wwrite-strings'    #Debug
alias g++11='g++ -O2 -lm -std=c++11 -Wall -Wextra'                        #C++11
alias g++p11='g++ -O2 -lm -std=c++11 -Wall -Wextra -Weffc++ -Wwrite-strings -pedantic' #Warnings + Pedantic + C++11
alias estiliza='astyle --unpad-paren --style=allman --pad-oper --delete-empty-lines --break-blocks --convert-tabs --align-pointer=name --align-reference=name --lineend=linux --pad-header --indent-col1-comments --indent-switches --suffix=none --keep-one-line-statements'
alias brewu='brew update && brew upgrade && brew cleanup && brew cask cleanup && brew prune && brew doctor'
alias showAllOn='defaults write com.apple.finder AppleShowAllFiles 1 && killall Finder' # Show all files in Finder
alias showAllOff='defaults write com.apple.finder AppleShowAllFiles 0 && killall Finder'
alias difff='/usr/bin/diff'
alias rot13="tr '[A-Za-z]' '[N-ZA-Mn-za-m]'"
alias del_lixo="sudo find / -type f \( -name '.DS_Store' -o -name 'Thumbs.db' -o -name 'desktop.ini' \) -exec echo "{}" \; -exec rm "{}" \;"
alias d755="find . -type d -exec chmod 755 {} \;"
alias f644="find . -type f -exec chmod 644 {} \;"
################################
# FUN
################################
alias rainbow='yes "$(seq 16 231)" | while read i; do printf "\x1b[48;5;${i}m\n"; sleep .02; done'
alias fucking='sudo'
alias emacs='echo "segmentation fault"'
alias more=less
alias CAT='echo "=^.^=\n"'
