#!/bin/sh
# Última modificação: 23/07/2012 20:35

if [ -d /etc/X11/xinit/xinitrc.d ]; then 
  for f in /etc/X11/xinit/xinitrc.d/*; do 
    [ -x "$f" ] && . "$f" 
  done 
  unset f 
fi

#############################      Monitores      #############################
#/home/julio/Scripts/monitores.sh &

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
#setxkbmap -model acer_laptop -layout us -variant intl -option caps:swapescape
#setxkbmap -model pc105 -layout gb -variant intl -option caps:swapescape
setxkbmap br -option caps:swapescape

#if [ -f ~/.Xmodmap/xmodmap_uk ]; then
#    xmodmap ~/.Xmodmap/xmodmap_uk
#fi

xbindkeys

#############################        Musica        #############################
/home/julio/Scripts/inicia_mpd.sh

########################## Desktop Environments / WMs #########################
exec awesome
#exec startxfce4

### Corrige problema da tela cinza dos programas em Java no Awesome ###
wmname LG3D

#############################         VNC          #############################
#x11vnc -localhost -many -display :0 -auth ~/.Xauthority &>/dev/null &

#############################       Tablet         #############################
#xsetwacom set "Wacom Bamboo Pen Pen stylus" Rotate half
