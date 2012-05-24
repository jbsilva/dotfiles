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
# Last Change:  Sat 13 Aug 2011 15:00
#
# Download: https://github.com/jbsilva/dotfiles
#
# Distro: Arch Linux
#######################################################

################################
# Teste de segurança
################################
    # Don't do anything for non-interactive shells
    [[ -z "$PS1" ]] && return

################################
# Oh My Zsh
################################
    # Path to your oh-my-zsh configuration.
    ZSH=$HOME/.oh-my-zsh

    # Set name of the theme to load.
    # Look in ~/.oh-my-zsh/themes/
    # Optionally, if you set this to "random", it'll load a random theme each
    # time that oh-my-zsh is loaded.
    ZSH_THEME="fishy"

    # Set to this to use case-sensitive completion
    # CASE_SENSITIVE="true"

    # Comment this out to disable weekly auto-update checks
    # DISABLE_AUTO_UPDATE="true"

    # Uncomment following line if you want to disable colors in ls
    # DISABLE_LS_COLORS="true"

    # Uncomment following line if you want to disable autosetting terminal title.
    # DISABLE_AUTO_TITLE="true"

    # Uncomment following line if you want disable red dots displayed while waiting for completion
    # DISABLE_COMPLETION_WAITING_DOTS="true"

    # Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
    # Example format: plugins=(rails git textmate ruby lighthouse)
    plugins=(git)

    source $ZSH/oh-my-zsh.sh

################################
# Auto Completar
################################
    zstyle ':completion:*' completer _complete _ignored _approximate
    zstyle :compinstall filename '${HOME}/.zshrc'
    autoload -Uz compinit

################################
# Histórico
################################
    HISTFILE=~/.zsh_history
    HISTSIZE=5000
    SAVEHIST=10000
    setopt sharehistory                             # Compartilha entre sessões
    setopt HIST_IGNORE_ALL_DUPS

################################
# Variáveis
################################

    #export PROMPT='(%*) %n@%m %{$fg[$user_color]%}%3c%{$reset_color%}%(!.#.>) '
    export PROMPT='(%*) %n@%m %{$fg[$user_color]%}%3c%{$reset_color%}%(!.#.>) '
    export VISUAL=/usr/bin/vim
    export EDITOR=/usr/bin/vim
    export PYTHONSTARTUP="/home/julio/.pyrc"
    export PATH="$HOME/.rvm/bin:$PATH"

    [[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

    if [ -n "$DISPLAY" ]
    then
        export BROWSER=/usr/bin/chromium
    fi

    #LANG=en.US.UTF-8
    #LC_ALL=en_US.UTF-8

################################
# Aliases
################################
    # Pastas
    alias CPP='cd /media/externo/Documentos/Programacao/Cpp'
    alias PYTHON='cd /media/externo/Documentos/Programacao/Python'
    alias documentos='cd /media/externo/Documentos'
    alias imagens='cd /media/externo/Imagens'
    alias musicas='cd /media/externo/Musicas'
    alias prints='cd /media/externo/Imagens/Prints'
    alias filmes='cd /media/externo/Downloads/Torrents/seeding/Filmes'

    # Permite usar o sudo com os aliases.
    # Comente aliases com nocorrect na frente em ~/.oh-my-zsh/lib/correction.zsh
    # O problema é ter o correct no zsh funcionando em mkdir, touch, etc...
    alias sudo='nocorrect sudo '
    alias -s txt=vim    #associa .txt ao vim
    alias -s pdf=okular #associa .pdf o okular
    alias ls='ls --color=auto'
    alias dir='ls -1'
    alias grep='grep --color=auto'
    alias list='du -shc *'
    alias listh='du -shc * | sort -h'
    alias pac='sudo pacman -S'
    alias back='cd "$OLDPWD"'                                                       # ou back='cd -' para mostrar caminho
    alias calendario='zenity --calendar'
    alias sx='startx &'
    alias xterm='uxterm'
    alias meuip='curl ifconfig.me'
    alias chrometor='chromium --proxy-server="socks://localhost:9050" & exit'      # Usa chrome com Tor
    alias awesomev='xinit /usr/bin/awesome -- :1 &'
    alias awesomen='Xephyr -ac -screen 800x600 -br -reset -terminate -title Awesome_Xephyr :2 &'
    alias houaiss='wine /home/julio/.wine/drive_c/Program\ Files\ \(x86\)/Houaiss3/Houaiss3.exe & disown'
    alias regua='echo .........1.........2.........3.........4.........5.........6.........7.........8'
    alias uzbl='uzbl-tabbed'
    alias monitores='/home/julio/Scripts/monitores.sh'
    
    alias rainbow='yes "$(seq 16 231)" | while read i; do printf "\x1b[48;5;${i}m\n"; sleep .02; done'

################################
# Edita comando no $EDITOR (vim)
################################
autoload edit-comand-line
zle -N edit-command-line
bindkey '^X^e' edit-command-line

################################
# Colore man pages
################################
    export LESS_TERMCAP_mb=$'\e[01;34m'
    export LESS_TERMCAP_md=$'\e[01;34m'
    export LESS_TERMCAP_me=$'\e[0m'
    export LESS_TERMCAP_se=$'\e[0m'
    export LESS_TERMCAP_so=$'\e[01;44;33m'
    export LESS_TERMCAP_ue=$'\e[0m'
    export LESS_TERMCAP_us=$'\e[38;05;111m;'
