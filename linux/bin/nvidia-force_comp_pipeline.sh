#!/usr/bin/env bash
# Force NVIDIA's ForceCompositionPipeline on the current MetaMode, to stop
# screen tearing under X11.
#
# Needs bash: uses [[ ]] and ${var//pattern/replacement}.
s="$(nvidia-settings -q CurrentMetaMode -t)"
echo "$s"
if [[ "${s}" != "" ]]; then
  s="${s#*" :: "}"
  echo "$s"
  if [[ "${s}" != "NULL" ]]; then
    nvidia-settings -a CurrentMetaMode="${s//\}/, ForceCompositionPipeline=On\}}"
  fi
fi
