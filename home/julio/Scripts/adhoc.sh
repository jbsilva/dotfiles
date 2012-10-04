#!/bin/bash

iwconfig wlan0 mode Ad-Hoc
ifconfig wlan0 192.168.0.2 up
iwconfig wlan0 key 1234ABCDEF
iwconfig wlan0 essid rede
route add default gw 192.168.0.1
sh -c "echo 'nameserver 8.8.8.8' >> /etc/resolv.conf"

#END
