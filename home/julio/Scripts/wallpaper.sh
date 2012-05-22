#!/bin/sh

DIRETORIO=/media/externo/Imagens/Wallpapers/varios/Panoramic_Wallpapers_1920x1080

sleep 6

while true; do
	find $DIRETORIO -type f -name '*.jpg' -print0 |
		shuf -n1 -z | xargs -0 feh --bg-scale
	sleep 10m
done
