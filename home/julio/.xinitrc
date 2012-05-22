#!/bin/sh
# Última modificação: 27/04/2011 23:30

#############################      Monitores      #############################
/home/julio/Scripts/monitores.sh &

#############################      Wallpaper      #############################
#/home/julio/Scripts/wallpaper.sh &

#############################    Keyboard Stuff    #############################
# Scim -> escrever em japonês
#export XMODIFIERS=@im=SCIM
#export GTK_IM_MODULE="scim"
#export QT_IM_MODULE="scim"
#export XIM_MODULE="scim -d"
#
#setxkbmap -option terminate:ctrl_alt_bksp
#setxkbmap -model acer_laptop -layout us -variant intl
setxkbmap -model pc105 -layout gb -variant intl -option caps:swapescape

if [ -f ~/.Xmodmap/xmodmap_uk ]; then
    xmodmap ~/.Xmodmap/xmodmap_uk
fi

xbindkeys

#############################        Musica        #############################
/home/julio/Scripts/inicia_mpd.sh

### Corrige problema da tela cinza dos programas em Java no Awesome ###
wmname LG3D

########################## Desktop Environments / WMs #########################
#exec xterm
exec awesome
#exec pekwm
#xmonad
#xsetrot -cursor_name left_ptr
#exec startxfce4

#############################         VNC          #############################
#x11vnc -localhost -many -display :0 -auth ~/.Xauthority &>/dev/null &

#############################       Tablet         #############################
#xsetwacom set "Wacom Bamboo Pen Pen stylus" Rotate half
