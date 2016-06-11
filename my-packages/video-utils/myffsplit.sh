#!/usr/bin/env bash

options=$(getopt -o i:s:t:o: -- "$@")

[ $? -eq 0 ] || {
    echo "Incorrect options provided"
    exit 1
}

eval set -- "$options"

input=""
output=""
start_time=""
to_time=""

while test $# -gt 0; do
    case "$1" in
        -i)
            input=$2
            [[ -z "$input" ]] && { echo "Input cannot be empty."; exit 1; }
            shift 2
            ;;
        -s)
            start_time=$2
            [[ -z "$start_time" ]] && { echo "Start time cannot be empty."; exit 1; }
            shift 2
            ;;
        -t)
            to_time=$2
            [[ -z "$to_time" ]] && { echo "To time cannot be empty."; exit 1; }
            shift 2
            ;;
        -o)
            output=$2
            [[ -z "$output" ]] && { echo "Output cannot be empty."; exit 1; }
            shift 2
            ;;
        --)
            shift 1
            ;;
        *)
            echo "Didn't match anything"
            exit 1
            ;;
    esac
done

[[ "${input##*.}" == "mp4" ]] || { echo "Only support mp4."; exit 1; }
[[ "${output##*.}" == "mp4" ]] || { echo "Only support mp4."; exit 1; }
[[ -z "$start_time" ]] && [[ -z "$to_time" ]] && { echo "Start time and To time cannot be empty at the same time."; exit 1; }

if [ -z "$start_time" ]; then
    ffmpeg -i $input -vcodec copy -acodec copy -to $to_time $output
elif [ -z "$to_time" ]; then
    ffmpeg -i $input -vcodec copy -acodec copy -ss $start_time $output
else
    ffmpeg -i $input -vcodec copy -acodec copy -ss $start_time -to $to_time $output
fi

