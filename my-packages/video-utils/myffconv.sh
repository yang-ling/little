#!/usr/bin/env bash

output_name="${1%.*}.mp4"
ffmpeg -i $1 -preset medium -c:v libx264 -profile:v main -crf 23 -qmin 18 -qmax 51 -maxrate 5000K -bufsize 7500K -c:a aac -strict experimental -b:a 128K -ar 44100 -ac 2 $output_name
