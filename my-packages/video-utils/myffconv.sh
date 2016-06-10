#!/usr/bin/env bash

output_name="${1%.*}.mp4"
ffmpeg -i $1 -vcodec libx264 -acodec libmp3lame -b:a 128K $output_name
