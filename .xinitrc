#!/bin/sh
# Última modificação: 07/Jun/2013

#if [ -d /etc/X11/xinit/xinitrc.d ]; then 
#  for f in /etc/X11/xinit/xinitrc.d/*; do 
#    [ -x "$f" ] && . "$f" 
#  done 
#  unset f 
#fi

########################## Roda systemd como usuário ##########################
#systemd --user &

#############################      Monitores      #############################
#/home/julio/Scripts/monitores.sh &
#xrandr --output LVDS1 --primary --auto --output HDMI1 --auto --same-as LVDS1
#############################      Wallpaper      #############################
#/home/julio/Scripts/wallpaper.sh &

#############################    Keyboard Stuff   #############################
#/home/julio/Scripts/keyboard.sh
setxkbmap br -option caps:swapescape

#############################     Screen Lock     #############################
#xautolock -time 15 -locker slock -nowlocker slock -detectsleep -corners 0+00 -cornerdelay 3 &

###################################### QT #####################################
#export QT_QPA_PLATFORMTHEME="qt5ct"

########################## Desktop Environments / WMs #########################
exec awesome

####### Corrige problema da tela cinza dos programas em Java no Awesome #######
#wmname LG3D

#############################         VNC          #############################
#x11vnc -localhost -many -display :0 -auth ~/.Xauthority &>/dev/null &
