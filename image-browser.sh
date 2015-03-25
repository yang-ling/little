#!/usr/bin/env bash

function echoError()
{
    # Red
    echo -e >&2 "\033[0;31m${1}\033[0m"
}

match()
{
    re=$2
    if [[ ! $1 =~ $re ]]; then
        return 1
    fi
    return 0
}

isNumber()
{
    re='^[0-9]+([.][0-9]+)?$'
    match $1 $re
    return $?
}

isInteger()
{
    re='^[0-9]+$'
    match $1 $re
    return $?
}

command -v feh > /dev/null 2>&1 || { echo >&2 "ERROR: feh not found!"; exit 1; }

usage="$(basename "$0") [options] image_dir

options:
    -h|--help                       Show this help text
    -E thumbnail height             Default value: 256
    -y thumbnail width              Default value: 256
    -W Thumbnail list pane width    Default value: 1920
    -r Ratio value                  Default value: 1"

options=$(getopt -o E:y:W:r:h -- "$@")

[ $? -eq 0 ] || {
    echoError "Incorrect options provided"
    echo "$usage"
    exit 1
}

eval set -- "$options"

theRatio=1
thumbnailHeight=256
thumbnailWidth=256
paneWidth=1960
dirname=''

# getopt will check wrong options so here we needn't manually check that.
while test $# -gt 0; do
  case "$1" in
      -E)
          isInteger $2
          [[ $? -eq 0 ]] || { echoError "-E only accept positive integer!"; echo "$usage"; exit 1; }
          thumbnailHeight=$2
          shift 2
          ;;
      -y)
          isInteger $2
          [[ $? -eq 0 ]] || { echoError "-y only accept positive integer!"; echo "$usage"; exit 1; }
          thumbnailWidth=$2
          shift 2
          ;;
      -W)
          isInteger $2
          [[ $? -eq 0 ]] || { echoError "-W only accept positive integer!"; echo "$usage"; exit 1; }
          paneWidth=$2
          shift 2
          ;;
      -r)
          isNumber $2
          [[ $? -eq 0 ]] || { echoError "-r only accept positive number!"; echo "$usage"; exit 1; }
          theRatio=$2
          shift 2
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
          if [[ $# -eq 1 ]]; then
              shift 1
          else
              shift 2;
          fi
          ;;
      *)
          echoError "Invalid parameter! $1"
          echo "$usage"
          exit 1
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

thumbnailHeight=`bc <<< "$thumbnailHeight * $theRatio"`
thumbnailWidth=`bc <<< "$thumbnailWidth * $theRatio"`

feh -t -r -Sfilename -E $thumbnailHeight -y $thumbnailWidth -W $paneWidth -A "gwenview %F" $dirname
