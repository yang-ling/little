#!/usr/bin/env bash

set -e

echoHeader()
{
    # Blue, underline
    echo -e "\033[0;34;4m${1}\033[0m"
}
echoSection()
{
    # White background and black font
    echo -e "\033[47;30m${1}\033[0m"
}
echoInfo()
{
    # Green
    echo -e "\033[0;32m${1}\033[0m"
}
echoWarning()
{
    # Yellow
    echo -e "\033[0;33m${1}\033[0m"
}
echoError()
{
    # Red
    echo -e "\033[0;31m${1}\033[0m"
}

checkFileType() {
    filename="${1}"

    filetype=$(xdg-mime query filetype "${filename}")
    if [[ $SUPPRT_IMG_FILETYPES =~ (^|[[:space:]])"$filetype"($|[[:space:]]) ]]; then
        isImage=1
        isVideo=0
    elif [[ $SUPPRT_VIDEO_FILETYPES =~ (^|[[:space:]])"$filetype"($|[[:space:]]) ]]; then
        isImage=0
        isVideo=1
    else
        isImage=0
        isVideo=0
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
    echoSection ">>> Start process ${filename} <<<"

    checkFileType "${filename}"
    [[ $isImage -eq 0 ]] && [[ $isVideo -eq 0 ]] && {  echoWarning "${filename} renaming failed: Only support ${SUPPRT_IMG_FILETYPES} and ${SUPPRT_VIDEO_FILETYPES}, but got ${filetype}"; return;  }

    extension="${filename##*.}"

    if [[ $isImage -eq 1 ]]; then
        basefilename=$(exiftool -DateTimeOriginal "${filename}" | tr -s ' ' | cut -d ' ' -f 4,5 --output-delimiter=_ | tr ':' '-')
        if [[ -z "${basefilename}" ]]; then
            basefilename=$(exiftool -ModifyDate "${filename}" | tr -s ' ' | cut -d ' ' -f 4,5 --output-delimiter=_ | tr ':' '-')
        fi

    elif [[ $isVideo -eq 1 ]]; then
        basefilename=$(exiftool -MediaCreateDate "${filename}" | tr -s ' ' | cut -d ' ' -f 5,6 --output-delimiter=_ | tr ':' '-')
    else
        echoError "Error! You are not supposed to be here!"
        exit 1;
    fi
    if [[ -z "${basefilename}" ]]; then
        set +e
        exiv2 "${filename}" > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echoWarning "${filename} image EXIF cannot be found. Use file creation time instead."
            basefilename=$(date -r "${filename}" +%F-%H%M%S%z)
            echo "${filename} image EXIF cannot be found. Use file creation time instead. New name is $(pwd)/${basefilename}.${extension}" >> "${log_file}"
        else
            echoError "${filename} image creation date cannot be found but has EXIF. You need check this file."
            echo "$(pwd)/${filename} image creation date cannot be found. You need check this file." >> "${log_file}"
            exit 1
        fi
        set -e
    fi
    newname="${basefilename}.${extension}"

    [[ "${filename}" == "${newname}" ]] && { echoWarning "${filename} and ${newname} are the same file. Skip."; return; }

    if [[ -f "${newname}" ]]; then
        isSameFile "${filename}" "${newname}"
        if [[ isSame -eq 1 ]]; then
            echoWarning "${filename} and ${newname} are the same file. Skip."
            return
        fi
        generateSequence "${newname}"
    fi

    echoInfo "Renaming ${filename} --> ${newname}"
    mv -iv "${filename}" "${newname}"
    echoInfo "Renaming is successful!"
    echoSection ">>> End process ${filename} <<<"
}

rename_files_in_dir() {
    echoSection ">> Start process dir $1 <<"
    pushd "$1"
    for oneFile in *; do
        [[ "${oneFile}" == "*" ]] && { echoWarning "$1 is an empty folder."; break; }
        if [[ -d $oneFile ]]; then
            rename_files_in_dir "$oneFile"
        else
            rename_one_file "$oneFile"
        fi
    done
    popd
    echoSection ">> End process dir $1 <<"
}

echoHeader "> Start process... <"

isfolder=0
isImage=0
isVideo=0

SUPPRT_IMG_FILETYPES="image/png image/jpeg"
SUPPRT_VIDEO_FILETYPES="video/mp4 video/quicktime"
log_file="$(pwd)/rename.log"
rm -rf "${log_file}"
touch "${log_file}"

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

echoHeader "> End process <"
