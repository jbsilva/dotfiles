#ffmpeg -i $1 -vf "transpose=1" $2
#ffmpeg -i $1 -metadata:s:v rotate="90" -codec copy $2
ffmpeg -i $1 rotate="90" -codec copy $2
