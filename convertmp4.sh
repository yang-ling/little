#!/usr/bin/bash

# $1: input file name
# $2: video bit rate
function convertmp4()
{
    #TODO check if ouput file exists
    #TODO make scale varialbe
    #TODO make parameters to options
    #TODO make all options optional
    [[ $# -eq 2 ]] || { echo -e "2 arguments are reqired:\n\t1st: Input video file\n\t2nd: Bit rate"; return 1; }
    [[ -f $1 ]] || { echo "$1 is not a file"; return 1; }
    ffmpeg -y -i $1 -c:v libx264 -preset slow -b:v $2 -vf scale=-1:720 -pass 1 -an -f mp4 /dev/null && \
        ffmpeg -i $1 -c:v libx264 -preset slow -b:v $2 -vf scale=-1:720 -pass 2 -c:a libmp3lame -b:a 256k $1.mp4
}
