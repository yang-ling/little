#!/usr/bin/env bash

set -ex
VIDEO_FOLDER=$1
CAPTURE_FOLDER=$1

cd "$VIDEO_FOLDER"
for file in *.mp4
do
    filename=$(basename "$file")
    filebasename="${filename%.*}"
    ffmpeg -i $filename -r 1/10 -vf scale=-1:120 -vcodec png "$CAPTURE_FOLDER/$filebasename-%02d.png"
    montage -title "$filebasename-captures" -geometry +4+4 "$CAPTURE_FOLDER/$filebasename*.png" "$CAPTURE_FOLDER/output/$filebasename-captures.png"
done
