#!/usr/bin/bash

# This script can add label to an image.

[[ $# -eq 2 ]] || [[ $# -eq 3 ]] || { echo "Must give 2 or 3 parameters."; exit 1; }

# $1: path/to/input/image
# $2: path/to/output/image
# $3: Label content

# Modify this
CAPTION_CONTENT="GitLab\nCjk Shanghai"
[[ -n $3 ]] && CAPTION_CONTENT=$3

width=`identify -format %w $1`
height=`identify -format %h $1`
height=$((${height}/2))
convert -background '#0008' -fill white -gravity center -font Creepster -size ${width}x${height} caption:"$CAPTION_CONTENT" $1 +swap -gravity center -composite $2

