function logirl -d "Centralized logging helper with consistent color conventions"
    argparse h/help n/no-newline t/tag= i/icon= f/flag= -- $argv
    or return

    if set -q _flag_help
        printf "%sUsage:%s logirl [OPTIONS] <type> <message>\n\n" (set_color --bold) (set_color normal)
        printf "Centralized logging with consistent color conventions.\n\n"
        printf "%sOptions:%s\n" (set_color --bold) (set_color normal)
        printf "  %s-h, --help%s         Show this help\n" (set_color brmagenta) (set_color normal)
        printf "  %s-n, --no-newline%s   Don't add newline after message\n" (set_color brmagenta) (set_color normal)
        # if text with - or -- is passed in, fish will try to parse this as a flag argument to logirl
        #   so we need special logic for flags
        printf "  %s-t, --tag=TEXT%s     Add a custom tag (e.g., [CUSTOM])\n" (set_color brmagenta) (set_color normal)
        printf "  %s-i, --icon=ICON%s    Add an icon before the message\n" (set_color brmagenta) (set_color normal)
        printf "  %s-f, --flag=S/LONG%s  Format flag pair (e.g., -f h/help → -h, --help)\n" (set_color brmagenta) (set_color normal)
        printf "\n%sMessage Types:%s\n" (set_color --bold) (set_color normal)
        printf "  %sHelp Text:%s\n" (set_color --underline) (set_color normal)
        printf "    help_body          Blue text for help content\n"
        printf "    help_header        Bold bright green for help headings\n"
        printf "    help_cmd           Bold bright magenta for commands/flags\n"
        printf "\n  %sErrors & Warnings:%s\n" (set_color --underline) (set_color normal)
        printf "    error              Red text with  tag\n"
        printf "    error_tag          Just the  tag (bold red)\n"
        printf "    error_msg          Red text without tag\n"
        printf "    warning            Bright yellow with  tag\n"
        printf "    warning_tag        Just the  tag (bold)\n"
        printf "    warning_msg        Bright yellow text without tag\n"
        printf "\n  %sLogging & Status:%s\n" (set_color --underline) (set_color normal)
        printf "    info               Cyan with  tag\n"
        printf "    info_tag           Just the  tag (bold cyan)\n"
        printf "    info_msg           Normal text without tag\n"
        printf "    success            Bright green with 󰡕 tag\n"
        printf "    success_tag        Just the tag (bold bright green)\n"
        printf "    success_msg        Bright green text without tag\n"
        printf "    special            Bold bright magenta with ==> prefix\n"
        printf "    special_tag        Just the ==> prefix\n"
        printf "    special_msg        Bright magenta text without prefix\n"
        printf "\n  %sUtility:%s\n" (set_color --underline) (set_color normal)
        printf "    normal             Reset to normal colors\n"
        printf "    dim                Dimmed text (for disabled/old items)\n"
        printf "\n%sExamples:%s\n" (set_color --bold) (set_color normal)
        printf "  logirl error \"File not found\"\n"
        printf "  logirl special \"Installing packages...\"\n"
        printf "  logirl success_msg \"Done!\"\n"
        printf "  logirl -t \"[CUSTOM]\" info_msg \"Something happened\"\n"
        printf "  logirl -i \"󰄬\" success \"Build complete\"\n"
        printf "  logirl -f h/help help_cmd       # Outputs: -h, --help\n"
        printf "  logirl -f v/version help_cmd    # Outputs: -v, --version\n"
        return 0
    end

    # When using --flag, we only need type argument (message is generated from flag)
    # Otherwise, we need both type and message
    if set -q _flag_flag
        if test (count $argv) -lt 1
            echo (set_color red --bold)""(set_color normal)" logirl with --flag requires <type> argument"
            echo "Try: logirl --help"
            return 1
        end
    else
        if test (count $argv) -lt 2
            echo (set_color red --bold)""(set_color normal)" logirl requires <type> and <message> arguments"
            echo "Try: logirl --help"
            return 1
        end
    end

    set -l msg_type $argv[1]
    set -l message $argv[2..-1]

    # Handle -f/--flag option for formatting flag pairs
    if set -q _flag_flag
        # Split on '/' to get short and long flag names
        set -l flags_split (string split '/' $_flag_flag)

        # Validate format: should have exactly 2 parts (short/long)
        if test (count $flags_split) -ne 2
            echo (set_color red --bold)""(set_color normal)" --flag requires format: SHORT/LONG (e.g., h/help)"
            echo "Got: $_flag_flag"
            return 1
        end

        set -l short_flag $flags_split[1]
        set -l long_flag $flags_split[2]

        # Validate both parts are non-empty
        if test -z "$short_flag" -o -z "$long_flag"
            echo (set_color red --bold)""(set_color normal)" --flag requires non-empty short and long names"
            echo "Got: $_flag_flag"
            return 1
        end

        # Format as "-short, --long"
        set message "-$short_flag, --$long_flag"
    end

    # Build the output line
    set -l output ""

    # Add custom icon if provided
    if set -q _flag_icon
        set output "$_flag_icon "
    end

    # Process message type
    switch $msg_type
        # Help text types
        case help_body
            set output "$output"(set_color normal)"$message"(set_color normal)

        case help_header
            set output "$output"(set_color --bold brgreen)"$message"(set_color normal)

        case help_cmd
            set output "$output"(set_color --bold brmagenta)"$message"(set_color normal)

            # Error types
        case error
            if set -q _flag_tag
                set output "$output"(set_color red --bold)"$_flag_tag $message"(set_color normal)
            else
                set output "$output"(set_color red --bold)" $message"(set_color normal)
            end

        case error_tag
            if set -q _flag_tag
                set output "$output"(set_color red --bold)"$_flag_tag"(set_color normal)
            else
                set output "$output"(set_color red --bold)""(set_color normal)
            end

        case error_msg
            set output "$output"(set_color red)"$message"(set_color normal)

            # Warning types
        case warning
            if set -q _flag_tag
                set output "$output"(set_color bryellow --bold)"$_flag_tag"(set_color normal)" "(set_color bryellow)"$message"(set_color normal)
            else
                set output "$output"(set_color bryellow --bold)""(set_color normal)" "(set_color bryellow)"$message"(set_color normal)
            end

        case warning_tag
            if set -q _flag_tag
                set output "$output"(set_color bryellow --bold)"$_flag_tag"(set_color normal)
            else
                set output "$output"(set_color bryellow --bold)""(set_color normal)
            end

        case warning_msg
            set output "$output"(set_color bryellow)"$message"(set_color normal)

            # Info types
        case info
            if set -q _flag_tag
                set output "$output"(set_color cyan --bold)"$_flag_tag"(set_color normal)(set_color cyan)" $message"(set_color normal)
            else
                set output "$output"(set_color cyan --bold)""(set_color normal)" $message"
            end

        case info_tag
            if set -q _flag_tag
                set output "$output"(set_color cyan --bold)"$_flag_tag"(set_color normal)
            else
                set output "$output"(set_color cyan --bold)""(set_color normal)
            end

        case info_msg
            set output "$output""$message"

            # Success types
        case success
            if set -q _flag_tag
                set output "$output"(set_color brgreen --bold)"$_flag_tag $message"(set_color normal)
            else
                set output "$output"(set_color brgreen --bold)"󰡕 $message"(set_color normal)
            end

        case success_tag
            if set -q _flag_tag
                set output "$output"(set_color brgreen --bold)"$_flag_tag"(set_color normal)
            else
                set output "$output"(set_color brgreen --bold)"󰡕"(set_color normal)
            end

        case success_msg
            set output "$output"(set_color brgreen)"$message"(set_color normal)

            # Special/progress types
        case special
            if set -q _flag_tag
                set output "$output"(set_color brmagenta --bold)"$_flag_tag"(set_color normal)" "(set_color brmagenta)"$message"(set_color normal)
            else
                set output "$output"(set_color brmagenta --bold)"==>"(set_color normal)" "(set_color brmagenta)"$message"(set_color normal)
            end

        case special_tag
            if set -q _flag_tag
                set output "$output"(set_color brmagenta --bold)"$_flag_tag"(set_color normal)
            else
                set output "$output"(set_color brmagenta --bold)"==>"(set_color normal)
            end

        case special_msg
            set output "$output"(set_color brmagenta)"$message"(set_color normal)

            # Utility types
        case normal
            set output "$output""$message"

        case dim
            set output "$output"(set_color --dim)"$message"(set_color normal)

        case '*'
            echo (set_color red --bold)""(set_color normal)" Unknown message type: $msg_type"
            echo "Try: logirl --help"
            return 1
    end

    # Output the message
    if set -q _flag_no_newline
        printf "%s" "$output"
    else
        printf "%s\n" "$output"
    end

    return 0
end
