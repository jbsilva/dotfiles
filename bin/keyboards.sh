#!/bin/zsh

# Notebook keyboard
keyboard_id=$(
    xinput -list |
    grep "AT Translated Set 2 keyboard.*keyboard" |
    sed -e 's/^.*id=\([0-9]\+\).*/\1/' |
    head -1
)
if [ ! -z "$keyboard_id" ]; then
    setxkbmap -device $keyboard_id    \
              -layout us              \
              # -layout br              \
              -variant intl           \
              -option lv3:ralt_switch \
              #  -option compose:menu    \
              -option compose:rctlr   \
              -option caps:swapescape
fi


# Keychron K2
# See https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion-Flags
keyboard_ids=(${(@f)$(
    xinput -list |
    grep "Keychron K2.*keyboard" |
    sed -e 's/^.*id=\([0-9]\+\).*/\1/'
)})
for keyboard_id in $keyboard_ids
do
    setxkbmap -device $keyboard_id    \
              -layout us              \
              -variant intl           \
              -option lv3:ralt_switch \
              -option compose:rctrl   \
              -option caps:swapescape
done

