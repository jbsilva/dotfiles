#!/usr/bin/env zsh
# Rotate a video by rewriting its rotation metadata.
#
# This is lossless: the streams are copied and only the display matrix changes,
# so players rotate on playback. Use rotate_video_reencode when the consumer
# ignores metadata and the pixels themselves must be rotated.

# Rotate via metadata only (fast, lossless, no quality change)
function rotate_video()
{
    local usage="$(
	cat <<-EOF
	Rotate a video losslessly by setting its rotation metadata.

	Usage:
	    rotate_video INPUT OUTPUT [DEGREES]

	DEGREES defaults to 90. Use 90, 180 or 270.

	Examples:
	    rotate_video in.mp4 out.mp4
	    rotate_video in.mp4 out.mp4 270
	EOF
    )"

    if (( $# < 2 )); then
        print "$usage" >&2
        return 1
    fi

    if (( ! $+commands[ffmpeg] )); then
        print "rotate_video: ffmpeg not found" >&2
        return 1
    fi

    local input="$1" output="$2" degrees="${3:-90}"

    if [[ ! -f $input ]]; then
        print "rotate_video: no such file: $input" >&2
        return 1
    fi

    ffmpeg -i "$input" -metadata:s:v rotate="$degrees" -codec copy "$output"
}

# Rotate by actually re-encoding the pixels (slower, lossy, universally honored)
function rotate_video_reencode()
{
    if (( $# < 2 )); then
        print "Usage: rotate_video_reencode INPUT OUTPUT [90|180|270]" >&2
        return 1
    fi

    if (( ! $+commands[ffmpeg] )); then
        print "rotate_video_reencode: ffmpeg not found" >&2
        return 1
    fi

    local input="$1" output="$2" degrees="${3:-90}"
    local filter

    # transpose=1 -> 90° clockwise, 2 -> 90° counter-clockwise
    case $degrees in
        90)  filter="transpose=1" ;;
        180) filter="transpose=1,transpose=1" ;;
        270) filter="transpose=2" ;;
        *)   print "rotate_video_reencode: DEGREES must be 90, 180 or 270" >&2; return 1 ;;
    esac

    ffmpeg -i "$input" -vf "$filter" "$output"
}
