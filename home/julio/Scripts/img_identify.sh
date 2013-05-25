#!/bin/bash
# Troca a extensão .jpg pela extensão do formato correto das imagens em CWD
# Dependência: imagemagick

for f in *.jpg
do
    type=`identify $f | awk '{print $2}'`
    f="${f%.*}"
    case $type in
        GIF) mv "$f.jpg" "$f.gif";;
        PNG) mv "$f.jpg" "$f.png";;
        JPEG);;
        *) mv "$f.jpg" "$f.outro";;
    esac
done
