#!/bin/bash

### Set keyboard ###
setxkbmap -model acer_laptop -layout us -variant intl -option caps:swapescape
#setxkbmap -model pc105 -layout gb -variant intl -option caps:swapescape

### Xmodmap: adiciona teclas como ç ###
if [ -f ~/.Xmodmap/xmodmap_uk ]; then
    xmodmap ~/.Xmodmap/xmodmap_uk
fi

### xbindkeys: Atalhos de teclado ###
xbindkeys
