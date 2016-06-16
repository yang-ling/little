#!/usr/bin/env bash

set -e

rename_one_file() {
    filename=$1
    echo ">>> Start process $filename <<<"

    filetype=$(xdg-mime query filetype $filename)

    [[ $SUPPRT_FILETYPES =~ (^|[[:space:]])"$filetype"($|[[:space:]]) ]] || { echo "$filename renaming failed: Only support png and jpg files, but got $filetype"; return; }

    extension="${filename##*.}"

    basefilename=$(identify -verbose $filename | grep "date:modify:" | tr -d [:space:] | cut -d ':' -f 3,4,5 | cut -d '+' -f 1,2 --output-delimiter="TZ" | sed "s/:/-/g")
    newname="$basefilename.$extension"

    echo "Renaming $filename --> $newname"
    mv -iv $filename $newname
    echo "Renaming is successful!"
    echo ">>> End process $filename <<<"
}

rename_files_in_dir() {
    echo ">> Start process dir $1 <<"
    pushd $1
    for oneFile in *; do
        if [ -d $oneFile ]; then
            rename_files_in_dir $oneFile
        else
            rename_one_file $oneFile
        fi
    done
    popd
    echo ">> End process dir $1 <<"
}

isfolder=0
SUPPRT_FILETYPES="image/png image/jpeg"

echo "> Start process... <"

if [ -f $1 ]; then
 isfolder=0
 elif [ -d $1 ]; then
     isfolder=1
 else
     echo "$1 is not found!"
     exit 1
fi

if [ $isfolder -eq 0 ]; then
    rename_one_file $1
else
    rename_files_in_dir $1
fi

echo "> End process <"
