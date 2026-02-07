function yj -d "Convert between YAML and JSON format (or vice versa!)"
    argparse h/help i/invert f/force s/safe 'r/rename=' -- $argv
    or return

    # Handle --help early
    if set -q _flag_help
        echo "Convert a YAML file to JSON format, or vice versa. Requires the yq command-line tool."
        logirl help_usage "y2j [OPTIONS] <input_file> [output_file]"
        logirl help_header Arguments
        logirl help_cmd input_file "File to convert"
        logirl help_cmd output_file "Optional output path (auto-generated if not provided)"
        logirl help_header Options
        logirl help_flag h/help "Show this help message"
        logirl help_flag i/invert "Convert JSON to YAML instead of YAML to JSON"
        logirl help_flag f/force "Overwrite output file if it already exists"
        logirl help_flag s/safe "Add '.new' suffix to output instead of overwriting"
        logirl help_flag r/rename=FILENAME "Specify custom output filename"
        return 0
    end

    # Validate yq dependency
    if not type -q yq
        logirl error "yq not found in PATH"
        logirl info "Install with: brew install yq"
        return 127
    end

    # Validate arguments
    if test (count $argv) -eq 0
        logirl error "Missing required argument: input_file"
        printf "Try: y2j --help\n"
        return 1
    end

    if test (count $argv) -gt 2
        logirl error "Too many arguments: expected 1-2, got "(count $argv)
        printf "Try: y2j --help\n"
        return 1
    end

    # Check for conflicting flags
    if set -q _flag_rename; and test (count $argv) -gt 1
        logirl error "Cannot use --rename with explicit output_file argument"
        printf "Try: y2j --help\n"
        return 1
    end

    if set -q _flag_safe; and set -q _flag_force
        logirl warning "Both --safe and --force specified; --safe takes precedence"
    end

    set -l input_file $argv[1]
    set -l output_file $argv[2] # May be empty

    # Validate input file exists
    if not test -f "$input_file"
        logirl error "Input file not found: $input_file"
        return 1
    end

    # Determine conversion direction and yq arguments
    set -l input_type
    set -l output_type
    set -l yq_args

    if set -q _flag_invert
        set input_type json
        set output_type yaml
        set yq_args -p=json -o=yaml
    else
        set input_type yaml
        set output_type json
        set yq_args -o=json
    end

    # Determine output filename
    if set -q _flag_rename
        # Use custom name from --rename flag
        set output_file $_flag_rename
    else if test -z "$output_file"
        # Auto-generate output filename based on input
        if set -q _flag_invert
            # JSON -> YAML
            set output_file (string replace -r '\\.json$' '.yml' "$input_file")
            # Handle case where input didn't have .json extension
            if test "$output_file" = "$input_file"
                set output_file "$input_file.yml"
            end
        else
            # YAML -> JSON
            set output_file (string replace -r '\\.ya?ml$' '.json' "$input_file")
            # Handle case where input didn't have .yaml/.yml extension
            if test "$output_file" = "$input_file"
                set output_file "$input_file.json"
            end
        end
    end

    # Apply --safe suffix if requested
    if set -q _flag_safe
        set output_file "$output_file.new"
    end

    # Check for output file conflicts
    if test -e "$output_file"
        if set -q _flag_safe
            logirl error "Safe output file already exists: $output_file"
            logirl info "Remove the existing file or use --force to overwrite"
            return 1
        else if not set -q _flag_force
            logirl error "Output file already exists: $output_file"
            logirl info "Use --force to overwrite or --safe to create .new file"
            return 1
        end
    end

    # Perform conversion
    logirl info "Converting $input_type → $output_type"
    if not yq eval $yq_args "$input_file" >"$output_file" 2>/dev/null
        logirl error "Conversion failed"
        logirl info "Check if input file is valid $input_type"
        # Clean up failed output file
        test -f "$output_file"; and rm "$output_file"
        return 1
    end

    logirl success "Created: $output_file"
    return 0
end
