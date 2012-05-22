#######################################################
#               Julio's ~/.bashrc file
#
#                      ( O O )
#               ====oOO==(_)==OOo=====
#
# Licença:
#           Copyright (c) 2008-2011 Julio B. Silva <julio@juliobs.com>
#                       All Rights Reserved
#
#           This program is free software. It comes without any warranty, to
#           the extent permitted by applicable law. You can redistribute it
#           and/or modify it under the terms of the Do What The Fuck You Want
#           To Public License, Version 2, as published by Sam Hocevar. See
#           http://sam.zoy.org/wtfpl/COPYING for more details.
#
# Created:      2008
# Last Change:  Sat 13 Aug 2011 15:00
#
# Download: https://github.com/jbsilva/dotfiles
# Distro: Arch Linux
#######################################################

# Check for an interactive session
    [ -z "$PS1" ] && return

################################
# Definições
################################
    export VISUAL=/usr/bin/vim
    export EDITOR=/usr/bin/vim
    export PROMPT_DIRTRIM=3
    export PYTHONSTARTUP="/home/julio/.pyrc"
    export PATH="/home/julio/django_trunk/django/bin:$PATH"
    PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

    # Faz o Chromium o browser padrão
    if [ -n "$DISPLAY" ]
    then
        export BROWSER=/usr/bin/chromium
    fi

################################
# Aliases
################################
    # Pastas
    alias CPP='cd /media/externo/Documentos/Programacao/Cpp'
    alias documentos='cd /media/externo/Documentos'
    alias imagens='cd /media/externo/Imagens'
    alias musicas='cd /media/externo/Musicas'
    alias prints='cd /media/externo/Imagens/Prints'
    alias videos='cd /media/externo/Videos'

    # Permite usar o sudo com os aliases
    alias sudo='sudo '
    alias ls='ls --color=auto'
    alias dir='ls -1'
    alias grep='grep --color=auto'
    alias list='du -shc *'
    alias listh='du -shc * | sort -h'
    alias pac='sudo pacman -S'

    # ou back='cd -' para mostrar caminho
    alias back='cd "$OLDPWD"'
    alias calendario='zenity --calendar'
    alias sx='startx &'
    alias xterm='uxterm'
    alias meuip='curl ifconfig.me'
    alias chrometor='chromium --proxy-server="socks://localhost:9050" & exit'      # Usa chrome com Tor
    alias awesomev='xinit /usr/bin/awesome -- :1 &'
    alias awesomen='Xephyr -ac -screen 800x600 -br -reset -terminate -title Awesome_Xephyr :2 &'
    alias houaiss='wine /home/julio/.wine/drive_c/Program\ Files\ \(x86\)/Houaiss3/Houaiss3.exe & exit'
    alias regua='echo .........1.........2.........3.........4.........5.........6.........7.........8'
    alias uzbl='uzbl-tabbed'

    alias telas='xrandr --output LVDS1 --auto --output HDMI1 --auto --right-of LVDS1'

#############################
# PS1 e PS2
#############################

    # Para usar com o GIT
    parse_git_branch()
    {
      git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }
    #PS1="\w\$(parse_git_branch) $ "

    # julio@julio-acer ~  $ em verde
    #PS1='\[\e[0;32m\]\u@\h\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[m\] \[\e[1;32m\]\$ \[\e[m\] '
    PS1="\[\e[0;32m\]\u@\h\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[m\]\[\e[1;32m\]\$(parse_git_branch) \$ \[\e[m\] "
    #PS1="\u@\h:\W #\! \A \`if [ \$? == 0 ]; then echo \:\); else echo \:\(; fi\` "

    # '>' em vermelho
    PS2="\[\e[0;31m\]>\[\e[0;0m\] "

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

############################
# Funções
############################

    # Uso:  lembreme <tempo> <texto>
    # e.g.: lembreme 15m "omg, a pizza"
    #   lembreme "1d 5h 3m 2s" "1dia 5horas 3minutos 2segundos"
    function lembreme()
    {
        sleep $1 && zenity --info --text "$2" &
    }

    # Clock - Um relógio que roda no terminal.
    clock ()
    {
        while true
        do
            clear;
            echo "===========";
            date +"%r";
            echo "===========";
            sleep 1;
        done
    }

    # Descompactador
    extract ()
    {
        if [ -f $1 ]
        then
           case $1 in
               *.tar.bz2) tar xjf $1   ;;
               *.tar.gz)  tar xzf $1   ;;
               *.bz2)     bunzip2 $1   ;;
               *.rar)     unrar x $1   ;;
               *.gz)      gunzip $1    ;;
               *.tar)     tar xf $1    ;;
               *.tbz2)    tar xjf $1   ;;
               *.tgz)     tar xzf $1   ;;
               *.zip)     unzip $1     ;;
               *.ZIP)     unzip $1     ;;
               *.Z)       uncompress $1;;
               *)         echo "'$1' impossível extrair" ;;
           esac
        else
            echo "'$1' não é um arquivo válido"
        fi
    }

    # compress archive.tar folder
    compress ()
    {
        if [ -d $2 ]
        then
            case $1 in
                *.tar.bz2)   tar vcjf $1 $2;;
                *.tar.gz)    tar vczf $1 $2;;
                *.bz2)       bunzip2 $1 $2;;
                *.gz)        gzip $1 $2;;
                *.tar)       tar vcf $1 $2;;
                *.tbz2)      tar vcjf $1 $2;;
                *.tgz)       tar vczf $1 $2;;
                *.zip)       zip -r $1 $2;;
                *.rar)      rar a -r $1 $2;;
                *.Z)         compress $1 $2;;
                *.7z)        7z a -t7z $1 $2;;
                *)           echo "Não foi possível comprimir $2.";;
           esac
       else
           echo "$2 não é um arquivo válido."
       fi
    }

    # Tradutor - `babylon palavra lingua`
    babylon()
    {
        if [ $1 == "--help" ]
        then
            echo "pt  -> Português"
            echo "de  -> Alemão"
            echo "zhs -> Chinês (S)"
            echo "zht -> Chinês (T)"
            echo "es  -> Espanhol"
            echo "fr  -> Francês"
            echo "he  -> Hebráico"
            echo "nl  -> Holandês"
            echo "en  -> Inglês (US)"
            echo "it  -> Italiano"
            echo "ja  -> Japonês"
        else
            if [ -n "$2" ]
            then
                LANG="$2"
            else
                LANG='pt'
            fi
            elinks -dump -no-numbering "http://bis.babylon.com/?rt=ol&tid=pop&mr=1&term=$1&tl=$LANG"
        fi
    }

    # Logo
    logo ()
    {
        echo -en "\033[1;36m"
        echo "       /\                     _     _ _                   "
        echo "      /  \      __ _ _ __ ___| |__ | (_)_ __  _   ___  __ "
        echo "     /'   \    / _\` | '__/ __| '_ \| | | '_ \| | | \ \/ / "
        echo "    /_- ~ -\  | (_| | | | (__| | | | | | | | | |_| |>  <  "
        echo "   /        \  \__,_|_|  \___|_| |_|_|_|_| |_|\__,_/_/\_\ "
        echo "  /  _- - _ '\                                            "
        echo " /_-'      '-_\                                           "
        echo -en "\033[0m\n"
    }

