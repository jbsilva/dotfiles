for f in *.JPG; do convert $f -resize 1024x768 -strip 768/$f; done
for f in *.JPG; do convert $f -resize 1024x768\> -strip 768/$f; done
for f in *.jpg; do convert $f -gravity center -extent 1240x1754 A4/$f; done

#O -strip remove coisas como o exif da imagem
