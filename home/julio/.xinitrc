#!/bin/sh
# Última modificação: 26/12/2012 22:30

if [ -d /etc/X11/xinit/xinitrc.d ]; then 
  for f in /etc/X11/xinit/xinitrc.d/*; do 
    [ -x "$f" ] && . "$f" 
  done 
  unset f 
fi


########################## Roda systemd como usuário ##########################
systemd --user &

#############################      Monitores      #############################
#/home/julio/Scripts/monitores.sh &

#############################      Wallpaper      #############################
#/home/julio/Scripts/wallpaper.sh &

#############################    Keyboard Stuff    ############################
setxkbmap br -option caps:swapescape
#setxkbmap -model acer_laptop -layout us -variant intl -option caps:swapescape
#setxkbmap -model pc105 -layout gb -variant intl -option caps:swapescape
#if [ -f ~/.Xmodmap/xmodmap_uk ]; then
#    xmodmap ~/.Xmodmap/xmodmap_uk
#fi

xbindkeys

#############################        Musica        ############################
/home/julio/Scripts/inicia_mpd.sh

########################## Desktop Environments / WMs #########################
exec awesome

####### Corrige problema da tela cinza dos programas em Java no Awesome #######
wmname LG3D

#############################         VNC          ############################
#x11vnc -localhost -many -display :0 -auth ~/.Xauthority &>/dev/null &
