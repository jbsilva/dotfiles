#!/bin/sh
# Última modificação: 07/Jun/2013

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

#############################    Keyboard Stuff   #############################
setxkbmap -layout de -model macbook79 -option caps:swapescape
if [ -f ~/.Xmodmap ]; then
    xmodmap ~/.Xmodmap
fi
xbindkeys

############################      Xresources      #############################
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# URxvt daemon
urxvtd -q -o -f &

#############################     Screen Lock     #############################
xautolock -time 15 -locker slock -nowlocker slock -detectsleep -corners 0+00 -cornerdelay 3 &

########################## Desktop Environments / WMs #########################
exec awesome
