#!/bin/sh
# This script can convert an input video file
# into the format which can be played by HTC
# Desire, roughly with 800x480 resolution,
# h.264 baseline video codec and aac audio codec
# created by laputa at 2/28/2011
VERSION=0.1
AUTHOR=laputa

#Global constant
screen_width=800
screen_height=480

usage()
{
    cat <<EOF
Transcode media files for HTC Desire
    Usage: transcode [-b bitrate] [-r framerate] [-p] [-2] [-v] -i inputfile [extra ffmpeg flags]
    OPTIONS:
    -b bitrate
        specifies the bitrate of the output file, 400kbps by default
    -r framerate
        specifies the framerate of the output file, 13 by default
    -p
        if specified, keep the original aspect ratio and pad the video
        to fit the htc screen. Or strech to 800x480
    -2
        use 2 pass encoding
    -v
        verbose output
    -h
        print this help information
EOF
}

calc_output()
{
    if [[ ! -f "$1" ]]
    then
	echo "file $1 dose not exists"
	exit 1
    fi
    INPUT_WIDTH=$(ffmpeg -i "$1" 2>&1 | grep "Stream.*Video:" | sed 's/^.* \([0-9]*\)x\([0-9]*\).*$/\1/')
    INPUT_HEIGHT=$(ffmpeg -i "$1" 2>&1 | grep "Stream.*Video:" | sed 's/^.* \([0-9]*\)x\([0-9]*\).*$/\2/')
    if (( $INPUT_WIDTH <= $screen_width && $INPUT_HEIGHT <= $screen_height ))
    then
        OUTPUT_WIDTH=$INPUT_WIDTH
        OUTPUT_HEIGHT=$INPUT_HEIGHT
    elif (( $INPUT_WIDTH * $screen_height < $INPUT_HEIGHT * $screen_width ))
    then
	OUTPUT_HEIGHT=$screen_height
	let "OUTPUT_WIDTH = $INPUT_WIDTH * $OUTPUT_HEIGHT / $INPUT_HEIGHT"
	let "OUTPUT_WIDTH = $OUTPUT_WIDTH - $OUTPUT_WIDTH % 4"
	let "PADLEFT = ( $screen_width - $OUTPUT_WIDTH ) / 2"
    else
	OUTPUT_WIDTH=$screen_width
	let "OUTPUT_HEIGHT = $INPUT_HEIGHT * $OUTPUT_WIDTH / $INPUT_WIDTH"
	let "OUTPUT_HEIGHT = $OUTPUT_HEIGHT - $OUTPUT_HEIGHT % 4"
	let "PADTOP = ( screen_height - OUTPUT_HEIGHT ) / 2"
    fi
}

while [[ $# -ne 0 ]]
do
    case "$1" in
	-b)
	    BITRATE=$2
	    shift 2
	    ;;
	-r)
	    FRAMERATE=$2
	    shift 2
	    ;;
	-p)
	    PADDING=1
	    shift
	    ;;
	-2)
	    PASS2=1
	    shift
	    ;;
	-v)
	    VERBOSE=1
	    shift
	    ;;
	-h)
	    usage
	    exit
	    ;;
	-i)
	    INPUTFILE="$2"
	    shift 2
	    ;;
	*)
	    EXTRA_FFMPEG="$EXTRA_FFMPEG $1"
	    shift
	    ;;
    esac
done

BITRATE=${BITRATE:-400k}
FRAMERATE=${FRAMERATE:-15}
AUDIO_BITRATE=${AUDIO_BITRATE:-128k}
FFMPEG=$(which ffmpeg)


PASS1_PROF="-vpre slow_firstpass -vpre baseline"
PASS2_PROF="-vpre slow -vpre baseline"
AUDIO_PARAM="-acodec libfaac -ab $AUDIO_BITRATE -ac 2"

calc_output "$INPUTFILE"
if [[ $PADLEFT ]]
then
    VIDEO_PARAM="-s ${OUTPUT_WIDTH}x$OUTPUT_HEIGHT -vf pad=$screen_width:$screen_height:$PADLEFT:0 -vcodec libx264 -b $BITRATE -r $FRAMERATE -sameq"
elif [[ $PADTOP ]]
then
    VIDEO_PARAM="-s ${OUTPUT_WIDTH}x$OUTPUT_HEIGHT -vf pad=$screen_width:$screen_height:0:$PADTOP -vcodec libx264 -b $BITRATE -r $FRAMERATE -sameq"
else
    VIDEO_PARAM="-s ${OUTPUT_WIDTH}x$OUTPUT_HEIGHT -vcodec libx264 -b $BITRATE -r $FRAMERATE -sameq"
fi
OUTPUTFILE=${INPUTFILE%%.*}-htc.mp4
[[ $VERBOSE ]] && echo "transcode from $INPUTFILE to $OUTPUTFILE"
if [[ $PASS2 ]]
then
    $FFMPEG -i "$INPUTFILE" $VIDEO_PARAM $PASS1_PROF \
	-an -pass 1 -f rawvideo -y $EXTRA_FFMPEG /dev/null && \
	$FFMPEG -y -i "$INPUTFILE" $VIDEO_PARAM $PASS2_PROF \
	$AUDIO_PARAM -pass 2 $EXTRA_FFMPEG "$OUTPUTFILE"
else
    [[ $VERBOSE ]] && \
	echo "using command:" && \
	echo "ffmpeg -y -i $INPUTFILE $VIDEO_PARAM $PASS2_PROF $EXTRA_FFMPEG $OUTPUTFILE"
    $FFMPEG -y -i "$INPUTFILE" $VIDEO_PARAM $PASS2_PROF $AUDIO_PARAM $EXTRA_FFMPEG "$OUTPUTFILE"
fi
