#!/usr/bin/env bash

[[ -f output.mp4 ]] && { echo "output.mp4 exists!"; exit 1; }

FILENAME="filelist.txt"

rm -rf $FILENAME

content=""

while test $# -gt 0; do
  content="${content}file ${1}\n"
  shift 1
done

echo -e "${content}" > $FILENAME

ffmpeg -f concat -i $FILENAME -c copy output.mp4
