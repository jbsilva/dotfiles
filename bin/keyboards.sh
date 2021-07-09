#!/bin/sh

# Notebook keyboard
keyboard_id=$(
    xinput -list |
    grep "AT Translated Set 2 keyboard.*keyboard" |
    sed -e 's/^.*id=\([0-9]\+\).*/\1/' |
    head -1
)
if [ ! -z "$keyboard_id" ]; then
    setxkbmap -device $keyboard_id    \
              -layout br              \
              -option lv3:ralt_switch \
              -option compose:menu    \
              -option caps:swapescape
fi

# Keychron K2
keyboard_id=$(
    xinput -list |
    grep "Keychron K2.*keyboard" |
    sed -e 's/^.*id=\([0-9]\+\).*/\1/' |
    head -1
)
if [ ! -z "$keyboard_id" ]; then
    setxkbmap -device $keyboard_id    \
              -layout us              \
              -variant intl           \
              -option lv3:ralt_switch \
              -option compose:rctrl   \
              -option caps:swapescape
fi
