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
setxkbmap -layout de -model macbook79 -option caps:swapescape,altwin:swap_lalt_lwin,compose:rwin
if [ -f ~/.Xmodmap ]; then
    xmodmap ~/.Xmodmap
fi
xbindkeys

# Desativa Touchpad durante digitação
syndaemon -t -k -i 2 &

############################      Xresources      #############################
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# URxvt daemon
urxvtd -q -o -f &

#############################     Screen Lock     #############################
xautolock -time 10 -locker slock -nowlocker slock -detectsleep -corners 0+00 -cornerdelay 3 &

########################## Desktop Environments / WMs #########################
exec awesome

################################# Monitor ICC #################################
/usr/bin/xcalib -d :0 /usr/share/color/icc/Profiles_Mac/Displays/Color\ LCD-933C106C-08BC-09AA-F750-C2A74A119DEF.icc
