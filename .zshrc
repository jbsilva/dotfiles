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
# Last Change:  Sat 13 Oct 2014
#
# Download: https://github.com/jbsilva/dotfiles
#
# OS: Arch Linux on MacBook Air
#######################################################

################################
# Teste de segurança
################################
# Don't do anything for non-interactive shells
[[ -z "$PS1" ]] && return

################################
# Source Prezto
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
VIM=/usr/bin/vim
export VISUAL=$VIM
export EDITOR=$VIM

################################
# Aliases
################################
alias dir='ls -1'
alias list='du -shc *'
alias listh='du -shc * | sort -h'
alias back='cd "$OLDPWD"'
alias meuip='curl ifconfig.me'
alias g++e='g++ -O2 -lm -Wall -Wextra -Weffc++ -Wwrite-strings -Werror'   #Warnings = Error
alias g++w='g++ -O2 -lm -Wall -Wextra -Weffc++ -Wwrite-strings'           #Warnings
alias g++p='g++ -O2 -lm -Wall -Wextra -Weffc++ -Wwrite-strings -pedantic' #Warnings + Pedantic
alias g++d='g++ -O0 -ggdb3 -lm -Wall -Wextra -Weffc++ -Wwrite-strings'    #Debug
alias g++11='g++ -O2 -lm -std=c++11 -Wall -Wextra'                        #C++11
alias pac='sudo pacman -S'

################################
# FUN
################################
alias rainbow='yes "$(seq 16 231)" | while read i; do printf "\x1b[48;5;${i}m\n"; sleep .02; done'
alias fucking='sudo'
alias emacs='echo "segmentation fault"'
alias more=less
alias CAT='echo "=^.^=\n"'
