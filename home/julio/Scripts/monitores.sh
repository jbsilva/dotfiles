#!/bin/bash

INTERNAL_OUTPUT="LVDS1"
EXTERNAL_OUTPUT="HDMI1"
#EXTERNAL_OUTPUT="VGA1"

# EXTERNAL_LOCATION: left, right, above, below, same-as
EXTERNAL_LOCATION="right"
 
case "$EXTERNAL_LOCATION" in
       left|LEFT)
               EXTERNAL_LOCATION="--left-of $INTERNAL_OUTPUT"
               ;;
       right|RIGHT)
               EXTERNAL_LOCATION="--right-of $INTERNAL_OUTPUT"
               ;;
       top|TOP|above|ABOVE)
               EXTERNAL_LOCATION="--above $INTERNAL_OUTPUT"
               ;;
       bottom|BOTTOM|below|BELOW)
               EXTERNAL_LOCATION="--below $INTERNAL_OUTPUT"
               ;;
       *)
               EXTERNAL_LOCATION="--same-as $INTERNAL_OUTPUT"
               ;;
esac
 
xrandr | grep $EXTERNAL_OUTPUT | grep " connected "
if [ $? -eq 0 ]; then
    xrandr --output $INTERNAL_OUTPUT --off --output $EXTERNAL_OUTPUT --auto $EXTERNAL_LOCATION
else
    xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --off
fi

echo "sucesso!"
#END

# Tela do notebook com versão miniatura da TV (1920x1080)
#xrandr --fb 1920x1080 --output LVDS1 --scale 1.405x1.406 --output HDMI1 --auto

# TV com versão ampliada do notebook (1366x768)
#xrandr --fb 1366x768 --output LVDS1 --auto --output HDMI1 --auto --scale 0.711x0.711
