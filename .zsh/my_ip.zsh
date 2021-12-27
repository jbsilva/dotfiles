#!/usr/bin/env zsh
if (( $+commands[lynx] )); then
    WWWDUMP='lynx -dump -nolist -width=300 -accept_all_cookies -display_charset=UTF-8'
    alias meuip="curl -s -m 8 eth0.me || curl -s -m 5 ifconfig.me || curl -s -m 5 icanhazip.com || $WWWDUMP http://www.getip.com | sed -n 's/^Current IP: //p'"
else
    alias meuip="curl -s -m 8 eth0.me || curl -s -m 5 ifconfig.me || curl -s -m 5 icanhazip.com"
fi

