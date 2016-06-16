#!/usr/bin/env bash

set -e

filename=$1

[[ -f $filename ]] || { echo "$filename is not found!"; exit 1; }

SUPPRT_FILETYPES="image/png image/jpeg"

filetype=$(xdg-mime query filetype $filename)

[[ $SUPPRT_FILETYPES =~ (^|[[:space:]])"$filetype"($|[[:space:]]) ]] || { echo "$filename renaming failed: Only support png and jpg files, but got $filetype"; exit 1; }

extension="${filename##*.}"

basefilename=$(identify -verbose $filename | grep "date:modify:" | tr -d [:space:] | cut -d ':' -f 3,4,5 | cut -d '+' -f 1,2 --output-delimiter="TZ" | sed "s/:/-/g")
newname="$basefilename.$extension"

echo "Renaming $filename --> $newname"
mv -iv $filename $newname
echo "Renaming is successful!"
