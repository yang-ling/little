#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage()
{
    usage="$(basename "$0") [options]
    options:
    \t-h|--help\tshow this help text
    \t-c|--clipboard\tCopy screenshot to clipboard
    \t-a|--active\tTake screenshot of active window
    \t-f|--full\tTake screenshot of full desktop
    \t-s|--selection\tTake screenshot of selection.(Default)
    \t--sleep N\tSleep N seconds before take screenshot. Default is 3 seconds.
    "

    echo -e "$usage"
}


options=$(getopt -o hcafs --long "help,clipboard,active,full,selection,sleep:" -- "$@")

[ $? -eq 0 ] || {
    echo "Incorrect options provided"
    usage
    exit 1
}

eval set -- "$options"
SCREENSHOT_TYPE_CLIPBOARD="clipboard"
SCREENSHOT_TYPE_ACTIVE="active"
SCREENSHOT_TYPE_FULL="full"
SCREENSHOT_TYPE_SELECTION="selection"

screenshot_type="$SCREENSHOT_TYPE_SELECTION"
sleep_value=3

while test $# -gt 0; do
    case "$1" in
        -c|--clipboard)
            screenshot_type="$SCREENSHOT_TYPE_CLIPBOARD"
            shift 1
            ;;
        -a|--active)
            screenshot_type="$SCREENSHOT_TYPE_ACTIVE"
            shift 1
            ;;
        -f|--full)
            screenshot_type="$SCREENSHOT_TYPE_FULL"
            shift 1
            ;;
        -f|--full)
            screenshot_type="$SCREENSHOT_TYPE_FULL"
            shift 1
            ;;
        -s|--selection)
            screenshot_type="$SCREENSHOT_TYPE_SELECTION"
            shift 1
            ;;
        --sleep)
            sleep_value=$2
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift 1
            ;;
        *)
            # In most cases, 'getopt' will check incorrect options for us, but if
            # incorrect options appears after '--', 'getopt' cannot detect that,
            # so we need this case branch to catch such error.
            # For example: print.sh -- filename.pdf -z
            # -z is an incorrect option but 'getopt' cannot detect it.
            echo "Incorrect options provided: $1"
            usage
            exit 1
            ;;
    esac
done

PIC_DIR=~/Pictures/temp
[[ -d "$PIC_DIR" ]] || { mkdir -p "$PIC_DIR"; }
screenshot_file_name="$PIC_DIR/Screenshot_$(date +%F-%H%M%S%z).png"

echo "Sleep $sleep_value second(s) and then take screenshot..."
sleep $sleep_value
echo "Start taking screenshot!"
case "$screenshot_type" in
    $SCREENSHOT_TYPE_SELECTION)
        maim -s | convert - \( +clone -background black -shadow 80x3+5+5 \) +swap -background none -layers merge +repage $screenshot_file_name
        ;;
    $SCREENSHOT_TYPE_FULL)
        maim | convert - \( +clone -background black -shadow 80x3+5+5 \) +swap -background none -layers merge +repage $screenshot_file_name
        ;;
    $SCREENSHOT_TYPE_ACTIVE)
        maim -i $(xdotool getactivewindow) | convert - \( +clone -background black -shadow 80x3+5+5 \) +swap -background none -layers merge +repage $screenshot_file_name
        ;;
    $SCREENSHOT_TYPE_CLIPBOARD)
        maim -s | xclip -selection clipboard -t image/png
        ;;
    *)
        echo "$screenshot_type Didn't match anything"
esac
if [[ ! "$SCREENSHOT_TYPE_CLIPBOARD" == "$screenshot_type" ]]; then
    echo "$screenshot_file_name" | xclip -selection clipboard
    echo "Done! Your screenshot file is $screenshot_file_name and file path is in your clipboard!"
else
    echo "Done! Your screenshot is in your clipboard now!"
fi
