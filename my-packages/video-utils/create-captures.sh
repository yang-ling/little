#!/usr/bin/env bash

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

set -e

checkFileType() {
    filename="${1}"

    filetype=$(xdg-mime query filetype "${filename}")
    if [[ $SUPPORT_VIDEO_FILETYPES =~ (^|[[:space:]])"$filetype"($|[[:space:]]) ]]; then
        isVideo=1
    else
        isVideo=0
    fi

}

create_capture_for_one_file() {
    filename=$(basename "$1")
    echoSection ">>> Start process ${filename} <<<"

    checkFileType "${filename}"
    [[ $isVideo -eq 1 ]] || { echoWarning "${filename} is not supported video file. Supported Video Types are: ${SUPPORT_VIDEO_FILETYPES}"; \
        echo "$(pwd)/${filename} is not supported video file. Supported Video Types are: ${SUPPORT_VIDEO_FILETYPES}" >> ${log_file}; \
        return; }

    filebasename="${filename%.*}"
    capture_folder="$(pwd)/capture"
    [[ -d "${capture_folder}" ]] || { echoInfo "${capture_folder} doesn't exist. Create it!"; mkdir "${capture_folder}"; }
    [[ -d "${capture_folder}/output" ]] || { echoInfo "${capture_folder}/output doesn't exist. Create it!"; mkdir "${capture_folder}/output"; }
    ffmpeg -i $filename -r 1/10 -vf scale=-1:120 -vcodec png "$capture_folder/$filebasename-%02d.png"
    montage -title "$filebasename-captures" -geometry +4+4 "$capture_folder/$filebasename*.png" "$capture_folder/output/$filebasename-captures.png"
    echoSection ">>> End process ${filename} <<<"
}

create_capture_for_one_dir() {
    echoSection ">> Start process dir $1 <<"
    pushd "$1"
    echoInfo "Remove capture directory. $(pwd)/capture"
    rm -rf "$(pwd)/capture"
    for oneFile in *; do
        [[ "${oneFile}" == "*" ]] && { echoWarning "$1 is an empty folder."; break; }
        if [[ -d $oneFile ]]; then
            [[ $isRecursive -eq 0 ]] && { echoInfo "No Recursive. Skip ${oneFile}"; continue; }
            create_capture_for_one_dir "$oneFile"
        else
            create_capture_for_one_file "$oneFile"
        fi
    done
    popd
    echoSection ">> End process dir $1 <<"
}

SUPPORT_VIDEO_FILETYPES="video/mp4 video/quicktime application/octet-stream"

isVideo=0
isfolder=0
log_file="$(pwd)/capture.log"
isRecursive=0

usage="$(basename "$0") [options] <file name|directory name> ...\n

Options:\n
    \t-h|--help\t                           show this help text\n
    \t-r\t\t                                  Recursive\n

File name or directory name: Target file or directory.\n
If it is directory, all files under this directory will be processed.\n
If -r is specified, all sub-directories also will be processed.\n

Support file type:\n
\t${SUPPORT_VIDEO_FILETYPES}\n"

while test $# -gt 0 ; do
    case "$1" in
        -r)
            isRecursive=1
            shift 1
            ;;
        -h|--help)
            echo -e $usage
            exit 0
            ;;
        *)
            rm -rf "${log_file}"
            touch "${log_file}"
            filename="${1}"
            if [[ -f "${filename}" ]]; then
                isfolder=0
            elif [[ -d "${filename}" ]]; then
                isfolder=1
            else
                echoError "${filename} is not found!"
                exit 1
            fi

            if [[ $isfolder -eq 0 ]]; then
                create_capture_for_one_file "${filename}"
            else
                create_capture_for_one_dir "${filename}"
            fi

            shift 1

    esac
done
