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

process_one_dir() {
    targetDir=""
    echoSection ">> Start process ${1} <<"
    pushd "${1}"
    for oneFile in *; do
        if [[ "${oneFile}" != "*" ]]; then
            if [[ -d "$oneFile" ]]; then
                process_one_dir "${oneFile}"
            else
                continue
            fi
        else
            targetDir="$(pwd)"
            echoInfo "${targetDir} is an empty folder."
            echo "${targetDir} is an empty folder." >> "${LOG_FILE}"
        fi
    done
    popd
    set +e
    if [[ $isDryRun -eq 0 ]] && [[ -n "${targetDir}" ]]; then
        rmdir "${targetDir}"
        if [[ $? -eq 0 ]]; then
            echoInfo "${targetDir} is deleted."
            echo "${targetDir} is deleted." >> "${LOG_FILE}"
        else
            echoError "${targetDir} is not empty!"
            echo "Error!: ${targetDir} is not empty!" >> "${LOG_FILE}"
        fi
    fi
    set -e
    targetDir=""
    echoSection ">> End process ${1} <<"
}

isRecursive=0
isDryRun=0

usage="$(basename "$0") [options] <directory name> ...\n
Check and delete empty directories

Options:\n
    \t-n|--dry-run\t                        dry run.
    \t-h|--help\t                           show this help text\n

Directory name: Target directory.\n
All sub-directories under this directory will be processed.\n"

options=$(getopt -o hn --long "help,dry-run" -- "$@")

[ $? -eq 0 ] || {
    echo "Incorrect options provided"
    echo $usage
    exit 1
}

eval set -- "$options"

echoHeader "> Start process... <"

LOG_FILE="$(pwd)/empty.log"
rm -rf "${LOG_FILE}"

while test $# -gt 0 ; do
    case "$1" in
        -n|--dry-run)
            isDryRun=1
            shift 1
            ;;
        -h|--help)
            echo -e $usage
            exit 0
            ;;
        --)
            dirname="${2}"
            [[ -d "${dirname}" ]] || { echoError "${dirname} doesn't exist!"; exit 1; }

            process_one_dir "${dirname}"
            shift 2
            ;;

        *)
            dirname="${1}"
            [[ -d "${dirname}" ]] || { echoError "${dirname} doesn't exist!"; exit 1; }

            process_one_dir "${dirname}"
            shift 1

    esac
done

echoHeader "> End process <"
