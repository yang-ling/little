#!/usr/bin/env bash

set -e

isfolder=0
isImage=0

SUPPRT_FILETYPES="image/png image/jpeg"

checkFileType() {
    filename="${1}"

    filetype=$(xdg-mime query filetype "${filename}")
    if [[ $SUPPRT_FILETYPES =~ (^|[[:space:]])"$filetype"($|[[:space:]]) ]]; then
        isImage=1
    else
        isImage=0
    fi

}

isSameFile() {
    firstfile="$1"
    secondfile="$2"
    firstmd5=$(md5sum "${firstfile}" | tr -s ' ' | cut -d ' ' -f 1)
    secondmd5=$(md5sum "${secondfile}" | tr -s ' ' | cut -d ' ' -f 1)
    if [[ "${firstmd5}" == "${secondmd5}" ]]; then
        isSame=1
    else
        isSame=0
    fi
}

generateSequence() {
    newname="$1"
    seq=0
    while [[ -f "${newname}" ]] ; do
        seq=$((seq+1))
        newname="${basefilename}-${seq}.${extension}"
    done
}

rename_one_file() {
    filename="$1"
    echo ">>> Start process ${filename} <<<"

    checkFileType "${filename}"
    [[ isImage -eq 0 ]] && {  echo "${filename} renaming failed: Only support png and jpg files, but got ${filetype}"; return;  }

    extension="${filename##*.}"

    basefilename=$(date -r "${filename}" +%F-%H%M%S%z)
    newname="${basefilename}.${extension}"

    [[ "${filename}" == "${newname}" ]] && { echo "${filename} and ${newname} are the same file. Skip."; return; }

    if [[ -f "${newname}" ]]; then
        isSameFile "${filename}" "${newname}"
        if [[ isSame -eq 1 ]]; then
            echo "${filename} and ${newname} are the same file. Skip."
            return
        fi
        generateSequence "${newname}"
    fi

    echo "Renaming ${filename} --> ${newname}"
    mv -iv "${filename}" "${newname}"
    echo "Renaming is successful!"
    echo ">>> End process ${filename} <<<"
}

rename_files_in_dir() {
    echo ">> Start process dir $1 <<"
    pushd "$1"
    for oneFile in *; do
        if [[ -d $oneFile ]]; then
            rename_files_in_dir "$oneFile"
        else
            rename_one_file "$oneFile"
        fi
    done
    popd
    echo ">> End process dir $1 <<"
}

echo "> Start process... <"

filename="${1}"

if [[ -f "${filename}" ]]; then
 isfolder=0
 elif [[ -d "${filename}" ]]; then
     isfolder=1
 else
     echo "${filename} is not found!"
     exit 1
fi

if [[ $isfolder -eq 0 ]]; then
    rename_one_file "${filename}"
else
    rename_files_in_dir "${filename}"
fi

echo "> End process <"
