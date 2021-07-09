#!/bin/sh
s="$(nvidia-settings -q CurrentMetaMode -t)"
echo "$s"
if [[ "${s}" != "" ]]; then
  s="${s#*" :: "}"
  echo "$s"
  if [[ "${s}" != "NULL" ]]; then
    nvidia-settings -a CurrentMetaMode="${s//\}/, ForceCompositionPipeline=On\}}"
  fi
fi

