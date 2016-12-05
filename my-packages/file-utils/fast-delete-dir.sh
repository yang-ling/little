#!/usr/bin/env bash

function echoHeader {
    # Blue, underline
    echo -e "\033[0;34;4m${1}\033[0m"
}

echoSection()
{
    echo -e "\033[47;30m${1}\033[0m"
}
echoInfo()
{
    # Green
    echo -e "\033[0;32m${1}\033[0m"
}
echoError()
{
    # Red
    echo -e "\033[0;31m${1}\033[0m"
}

usage="$(basename "$0") [options] directory_path

options:
    -h|--help   show this help text
    -k|--keep   Keep the root directory, only delete its content."

dirname=''
is_keep=0

options=$(getopt -o hk --long "help,keep" -- "$@")

[ $? -eq 0 ] || {
    echo "Incorrect options provided"
    echo "$usage"
    exit 1
}

eval set -- "$options"

while test $# -gt 0; do
    case "$1" in
        -k|--keep)
            is_keep=1
            shift 1
            ;;
        -h|--help)
            echo "$usage"
            exit 0
            ;;
        --)
            dirname=$2
            # In this case branch, the $2 may be empty and parameter could be only one, which means only `--'
            # If so and if we do shift 2, the $# will always be 1, thus cause infinite loop.
            # So we need check parameter number here and do proper shift.
            # In other case branches, the $2 will never be empty because we use `getopt' and it can check it for us.
            # So we needn't do such check in other case branches.
            if [[ $# -eq 1 ]]; then
                shift 1
            else
                shift 2
            fi
            ;;
        *)
            # In most cases, `getopt' will check incorrect options for us, but if
            # incorrect options appears after `--', `getopt' cannot detect that,
            # so we need this case branch to catch such error.
            echo "Incorrect options provided: $1"
            echo "$usage"
            exit 1
            ;;
    esac
done

if [ -z "$dirname" ]; then
    echo "No directory specified."
    echo "$usage"
    exit 1
fi

if [ ! -d "$dirname" ]; then
    echo "$dirname is not a directory!"
    echo "$usage"
    exit 1
fi

echoHeader "Process Start!"

# Remove trailing slash
dirname=$(echo "$dirname" | sed 's@/$@@')

echoInfo "Create temp directory."
tempdir=$(mktemp -d)
echoInfo "Temp directory is $tempdir"

set -e

rsync -a --delete --progress -h "$tempdir/" "$dirname/"
if [[ $is_keep -eq 0 ]]; then
    rmdir "$dirname"
fi

set +e

echoHeader "Process End!"
