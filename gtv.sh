#!/bin/sh
# gtv.sh
# generate test video for mobile devidecs
# now including QCIF/QVGA/CIF/VGA/D1-PAL

# create at Wed Jan 25 13:51:30 CST 2012

Version=0.1

INPUT_WIDTH=0
INPUT_HEIGHT=0
INPUT_FILENAME=""
# output video width and height of different formats
#                   QCIF QVGA CIF VGA D1-PAL
OUTPUT_RES_ARRAY=( "QCIF" "QVGA" "CIF" "VGA" "D1" )
OUTPUT_WIDTH_ARRAY=(   176    320    352   640   720 )
OUTPUT_HEIGHT_ARRAY=(  144    240    288   480   576 )
OUTPUT_BITRATE_ARRAY=( 200k   400k   400k  800k  1000k)
OUTPUT_RES_LASTNUM=4
OUTPUT_EXT="mp4"

AUDIO_CHANNEL=2
AUDIO_BITRATE=192k

FFMPEG=

usage()
{
    cat <<EOF
Transcode video files for testing on mobile devices
    Usage: gtv [-p] [-2] [-v] -i inputfile [extra ffmpeg flags]
    OPTIONS:
    -i inputfile
        input filename
    -o
        output file name prefix, will be automaticly extended to
        mp4.
    -2
        use 2 pass encoding
    -v
        verbose output
    -h
        print this help information
EOF
    exit 1
}

error_exit()
{
    echo "error" $1
    exit 1
}

log()
{
    [[ $VERBOSE ]] && echo "$@"
}

check_env()
{
    FFMPEG=$(which ffmpeg)
    if [[ -z $FFMPEG ]]
    then
	error_exit "no ffmpeg binary found"
    fi
}

parse_input()
{
    if [[ ! -f "$1" ]]
    then
	error_exit "file $1 does not exists"
    fi
    
    INPUT_WIDTH=$(ffmpeg -i "$1" 2>&1 | grep "Stream.*Video:" | sed 's/^.* \([0-9]*\)x\([0-9]*\).*$/\1/')
    INPUT_HEIGHT=$(ffmpeg -i "$1" 2>&1 | grep "Stream.*Video:" | sed 's/^.* \([0-9]*\)x\([0-9]*\).*$/\2/')

    log "input video resolution: ${INPUT_WIDTH}x${INPUT_HEIGHT}"

}

# calculator video padding
# can only be called after parse_input
# input params: out_width, out_width
calc_padding()
{
    local out_width=$1
    local out_height=$2

    if (( ${INPUT_WIDTH} <= ${out_width} && $INPUT_HEIGHT <= ${out_height} ))
    then
        OUTPUT_WIDTH=$INPUT_WIDTH
        OUTPUT_HEIGHT=$INPUT_HEIGHT
	
	log "no padding needed for output"

    elif (( ${INPUT_WIDTH} * ${out_height} < ${INPUT_HEIGHT} * ${out_width} ))
    then
	OUTPUT_HEIGHT=$out_height
	let "OUTPUT_WIDTH = INPUT_WIDTH * OUTPUT_HEIGHT / INPUT_HEIGHT"
	let "OUTPUT_WIDTH = OUTPUT_WIDTH - OUTPUT_WIDTH % 4"
	let "PADLEFT = ( out_width - OUTPUT_WIDTH ) / 2"
	let "PADTOP = -1"

	log "padding left/right for \"$PADLEFT\""

    else
	OUTPUT_WIDTH=$out_width
	let "OUTPUT_HEIGHT = INPUT_HEIGHT * OUTPUT_WIDTH / INPUT_WIDTH"
	let "OUTPUT_HEIGHT = OUTPUT_HEIGHT - OUTPUT_HEIGHT % 4"
	let "PADTOP = ( out_height - OUTPUT_HEIGHT ) / 2"
	let "PADLEFT = -1"

	log "padding top/bottom for \"$PADLEFT\""
    fi
}

set_params_for()
{
    local resname=${OUTPUT_RES_ARRAY[$1]}
    local width=${OUTPUT_WIDTH_ARRAY[$1]}
    local height=${OUTPUT_HEIGHT_ARRAY[$1]}
    local bitrate=${OUTPUT_BITRATE_ARRAY[$1]}

    calc_padding $width $height

    log "set parameters for \"$resname\""

    if (( PADLEFT > 0 ))
    then
	VIDEO_PARAM="-s ${OUTPUT_WIDTH}x${OUTPUT_HEIGHT} -vf pad=$width:$height:$PADLEFT:0"
    elif (( $PADTOP > 0 ))
    then
	VIDEO_PARAM="-s ${OUTPUT_WIDTH}x${OUTPUT_HEIGHT} -vf pad=$width:$height:0:$PADTOP"
    else
	VIDEO_PARAM="-s ${OUTPUT_WIDTH}x${OUTPUT_HEIGHT}"
    fi
    
    VIDEO_PARAM="$VIDEO_PARAM -vcodec libx264 -vpre ipod320 -b:v $bitrate"
    AUDIO_PARAM="-acodec libfaac -b:a ${AUDIO_BITRATE} -ac ${AUDIO_CHANNEL}"

    if [[ $OUTPUT_FILE_PREFIX ]]
    then
	OUTPUT_FILENAME=${OUTPUT_FILE_PREFIX}
    else
	OUTPUT_FILENAME=${INPUT_FILENAME%.*}
    fi
    OUTPUT_FILENAME=${OUTPUT_FILENAME}_${resname}_${width}x${height}.${OUTPUT_EXT}

    log "output file name: ${OUTPUT_FILENAME}"
    log "output video parameters: ${VIDEO_PARAM}"
    log "output audio parameters: ${AUDIO_PARAM}"
}
    
generate_video()
{
    if [[ $PASS2 ]]
    then
	log "first pass transcoding..."

	PASS2_OPTIONS="-pass 2"
	$FFMPEG -y -i "$INPUT_FILENAME" $VIDEO_PARAM -an -pass 1 -f rawvideo \
	    /dev/null
    fi
    $FFMPEG -y -i "$INPUT_FILENAME" $VIDEO_PARAM $AUDIO_PARAM $PASS2_OPTIONS \
	$EXTRA_FFMPEG "$OUTPUT_FILENAME"
}

generate_all_format()
{
    check_env
    parse_input ${INPUT_FILENAME}
    for i in $(seq 0 $OUTPUT_RES_LASTNUM)
    do
	set_params_for $i
	generate_video
    done
}

while [[ $# -ne 0 ]]
do
    case "$1" in
	-i)
	    INPUT_FILENAME="$2"
	    shift 2
	    ;;
	-o)
	    OUTPUT_FILE_PREFIX="$2"
	    shift 2
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
	    shift
	    ;;
	*)
	    EXTRA_FFMPEG="$EXTRA_FFMPEG $1"
	    shift
	    ;;
    esac
done

generate_all_format
