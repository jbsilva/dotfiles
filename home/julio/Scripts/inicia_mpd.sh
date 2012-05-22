#!/bin/bash

# MPD
mpd /home/julio/.mpd/mpd.conf

# Mpdscribble:
pidof mpdscribble >& /dev/null
if [ $? -ne 0 ]; then
  mpdscribble &
fi
