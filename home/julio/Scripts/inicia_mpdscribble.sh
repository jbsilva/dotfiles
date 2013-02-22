#!/bin/bash
pidof mpdscribble >& /dev/null
if [ $? -ne 0 ]; then
  mpdscribble &
fi
