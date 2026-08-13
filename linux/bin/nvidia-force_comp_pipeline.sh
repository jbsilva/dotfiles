#!/usr/bin/env bash
# Force NVIDIA's ForceCompositionPipeline on the current MetaMode, to stop
# screen tearing under X11.
#
# This needs bash, not sh: it uses [[ ]] and ${var//pattern/replacement}, both
# of which are bash extensions. The shebang used to say /bin/sh, which works
# only where /bin/sh happens to be bash -- on Debian/Ubuntu it is dash and the
# script fails outright.
s="$(nvidia-settings -q CurrentMetaMode -t)"
echo "$s"
if [[ "${s}" != "" ]]; then
  s="${s#*" :: "}"
  echo "$s"
  if [[ "${s}" != "NULL" ]]; then
    nvidia-settings -a CurrentMetaMode="${s//\}/, ForceCompositionPipeline=On\}}"
  fi
fi

