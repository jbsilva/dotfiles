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

################################     CopyQ     ################################
copyq&

################################ Gnome Keyring ################################
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

############################### source xprofile ###############################
[ -f /etc/xprofile ] && . /etc/xprofile
[ -f ~/.xprofile ] && . ~/.xprofile

#############################      Monitores      #############################
#/home/julio/Scripts/monitores.sh &
#xrandr --output LVDS1 --primary --auto --output HDMI1 --auto --same-as LVDS1
#xrandr --output eDP1 --mode 1366x768 --output HDMI1 --mode 1920x1080 --right-of eDP1
#xrandr --output eDP1 --off --output HDMI1 --mode 1920x1080 --primary

#############################      Wallpaper      #############################
#/home/julio/Scripts/wallpaper.sh &

#############################    Keyboard Stuff   #############################
#/home/julio/Scripts/keyboard.sh
setxkbmap br -option caps:swapescape

#############################      Touchpad       #############################
# Desativa touchpad por 0,5 segundos depois de usar o teclado
syndaemon -i 0.5 -K -t -R -d

#############################     Screen Lock     #############################
#xautolock -time 15 -locker slock -nowlocker slock -detectsleep -corners 0+00 -cornerdelay 3 &

########################## Desktop Environments / WMs #########################
#exec startxfce4
exec awesome

####### Corrige problema da tela cinza dos programas em Java no Awesome #######
#wmname LG3D

#############################         VNC          #############################
#x11vnc -localhost -many -display :0 -auth ~/.Xauthority &>/dev/null &
