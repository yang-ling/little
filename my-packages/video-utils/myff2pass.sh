#!/usr/bin/env bash

# $1: mp4 file name
extension="${1##*.}"

[[ "$extension" == "mp4" ]] || { echo "Only support mp4."; exit 1; }

basename="${1%.*}"

ffmpeg -y -i $basename.mp4 -c:v libx264 -preset medium -b:v 555k -pass 1 -an -f mp4 /dev/null && ffmpeg -i $basename.mp4 -c:v libx264 -preset medium -b:v 555k -pass 2 -c:a aac -b:a 128k $basename-output.mp4
