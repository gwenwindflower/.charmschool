function giffer -d "Convert a video to GIF using ffmpeg (palette method); preserves aspect"
    # Dependency
    if not type -q ffmpeg
        echo "giffer: ffmpeg not found in PATH" 1>&2
        return 127
    end

    # Parse flags (minimal surface)
    argparse -n giffer \
        h/help \
        'w/width=' \
        'f/fps=' \
        'l/loop=' \
        q/quiet -- $argv
    or return 2

    if set -q _flag_help
        echo "Usage: giffer [options] input_video"
        echo "Options:"
        echo "  -w, --width PX     Output width (default: 480; height auto to preserve aspect)"
        echo "  -f, --fps N        Frames per second (default: 12)"
        echo "  -l, --loop N       0=infinite (default), 1=play once"
        echo "  -q, --quiet        Less ffmpeg output"
        return 0
    end

    # Positional: input file
    if test (count $argv) -ne 1
        echo "giffer: missing input_video" 1>&2
        echo "Try: giffer --help" 1>&2
        return 2
    end
    set -l in "$argv[1]"
    if not test -f "$in"
        echo "giffer: input not found: $in" 1>&2
        return 1
    end

    # Defaults
    set -l width 480
    set -l fps 12
    set -l loop 0
    set -l loglevel warning

    if set -q _flag_width
        set width $_flag_width
    end
    if set -q _flag_fps
        set fps $_flag_fps
    end
    if set -q _flag_loop
        set loop $_flag_loop
    end
    if set -q _flag_quiet
        set loglevel error
    end

    # Paths
    set -l fname (basename -- "$in")
    set -l base (string replace -r '\.[^.]+$' '' -- "$fname")
    set -l pdir palette_out
    mkdir -p "$pdir"
    set -l palette "$pdir/$base.palette.png"
    set -l outgif (printf "%s_%dw_%dfps.gif" "$base" $width $fps)

    # Filters (aspect preserved via height=-1)
    set -l gen_filters "fps=$fps,scale=$width:-1:flags=lanczos,palettegen=stats_mode=full"
    set -l use_filters "fps=$fps,scale=$width:-1:flags=lanczos,paletteuse=dither=bayer:bayer_scale=5"

    # Pass 1: palette
    ffmpeg -hide_banner -loglevel $loglevel -y \
        -i "$in" \
        -vf "$gen_filters" \
        "$palette"
    if test $status -eq 1
        echo "Failed to generate palette"
    end

    # Pass 2: generate gif
    ffmpeg -hide_banner -loglevel $loglevel -y \
        -i "$in" \
        -i "$palette" \
        -lavfi "$use_filters" \
        -an -loop $loop \
        "$outgif"
    if test $status -eq 1
        echo "Failed to generate gif from palette" 1>&2
    end

    # Cleanup
    rip $pdir

    if not set -q _flag_quiet
        echo "Wrote: $outgif"
    end
end
