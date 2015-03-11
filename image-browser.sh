#!/usr/bin/env bash

function echoError()
{
    # Red
    echo -e "\033[0;31m${1}\033[0m"
}

usage="$(basename "$0") [options] image_dir

options:
    -h|--help                       Show this help text
    -E thumbnail height             Default value: 256
    -y thumbnail width              Default value: 256
    -W Thumbnail list pane width    Default value: 1960"

options=$(getopt -o E:y:W -- "$@")

[ $? -eq 0 ] || {
    echoError "Incorrect options provided"
    echo "$usage"
    exit 1
}

eval set -- "$options"

thumbnailHeight=256
thumbnailWidth=256
paneWidth=1960
dirname=''

# getopt will check wrong options so here we needn't manually check that.
while test $# -gt 0; do
  case "$1" in
      -E)
          thumbnailHeight=$2
          shift 2
          ;;
      -y)
          thumbnailWidth=$2
          shift 2
          ;;
      -W)
          paneWidth=$2
          shift 2
          ;;
      -h|--help)
          echo "$usage"
          exit 0
          ;;
      --)
          dirname=$2
          shift 2;
          ;;
  esac
done

if [ -z "$dirname" ]; then
    echoError "No directory name specified"
    echo "$usage"
    exit 1
fi

if [[ ! -d "$dirname" ]]; then
    echoError "No such directory!"
    exit 1
fi

feh -t -r -Sfilename -E $thumbnailHeight -y $thumbnailWidth -W $paneWidth -A "gwenview %F" $dirname
