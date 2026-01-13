function y2j -d "Convert between YAML and JSON format (or vice versa!)"
    argparse h/help i/invert f/force -- $argv
    or return

    set -l input_file $argv[1]
    set -l output_file $argv[2] # Optional
    # Established for later use
    set -l input_type
    set -l output_type
    set -l yq_args

    if set -q _flag_help
        set_color green
        echo "Convert a YAML file to JSON format, or vice versa."
        printf "%sRequires the %s%s%s%s command-line tool.%s%s\n\n" (set_color --italic blue) (set_color --bold brmagenta) yq (set_color normal) (set_color --italic blue) (set_color normal) (set_color green)
        echo "Usage: y2j <input file> [output file name]"
        echo "Options:"
        echo "-h, --help    Show this help message"
        echo "-i, --invert  Convert JSON to YAML instead of YAML to JSON"
        set_color normal
        return 0
    end

    # None of this can happen if they don't have yq!
    if not type -q yq
        set_color --bold red
        echo "[ERROR] Missing dependency: yq"
        set_color normal
        echo "Please install yq to use this function."
        return 127
    end
    # Error handling for args
    if test (count $argv) -eq 0
        set_color --bold red
        echo "[ERROR] Missing required args: input file"
        set_color normal
        set_color green
        echo "Usage: y2j <input file> [output file name]"
        set_color normal
        return 1
    end
    if test (count $argv) -gt 2
        set_color --bold red
        echo "[ERROR] Too many args: maximum is 2, got $(count $argv)"
        set_color normal
        set_color green
        echo "Usage: y2j <input file> [output file name]"
        set_color normal
        return 1
    end
    if not test -f $input_file
        set_color --bold red
        echo "[ERROR] Input file not found: $input_file"
        set_color normal
        return 124
    end

    if set -q _flag_invert
        set input_type json
        set output_type yaml
    else
        set input_type yaml
        set output_type json
    end

    # Set up output and command to run (y -> j or j -> y)
    if set -q _flag_invert
        if test -z "$output_file"
            set output_file (string replace -r '\.json$' '.yml' "$input_file")
        end
        set yq_args -p=json -o=yaml
    else
        if test -z "$output_file"
            set output_file (string replace -r '\.ya?ml$' '.json' "$input_file")
        end
        set yq_args -o=json
    end

    # Double check if we're forcing overwriting
    if test -e "$output_file"; and not set -q _flag_force
        set_color --bold red
        echo "[ERROR] Already exists: $output_file, use -f/--force to overwrite"
        set_color normal
        return 1
    end

    # Convert!
    yq eval $yq_args $input_file >$output_file
    if test $status -eq 0
        set_color green
        echo "[SUCCESS] Converted $input_file to $output_file"
        set_color normal
    else
        set_color --bold red
        echo "[ERROR] Conversion error: yq could not convert $input_file to $output_file"
        set_color normal
        return 1
    end
end
