#!/bin/bash

# MPD
#mpd /home/julio/.mpd/mpd.conf
systemd --user &


# Mpdscribble:
pidof mpdscribble >& /dev/null
if [ $? -ne 0 ]; then
  mpdscribble &
fi
