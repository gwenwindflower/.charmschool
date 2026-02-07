function logirl -d "Centralized logging helper with consistent color conventions"
    argparse h/help -- $argv
    or return

    if set -q _flag_help
        echo "Centralized logging with consistent, structured output formats."
        echo ""
        printf "%sUsage:%s logirl <type> [args...]\n\n" \
            (set_color --bold green) \
            (set_color normal)

        printf "%sMessage Types:%s\n\n" \
            (set_color --bold green) \
            (set_color normal)

        printf "  %sCore Messages:%s\n" (set_color --underline) (set_color normal)
        printf "    %-20s Red with  icon\n" error
        printf "    %-20s Yellow with  icon\n" warning
        printf "    %-20s Cyan with  icon\n" info
        printf "    %-20s Green with 󰡕 icon\n" success
        printf "    %-20s Magenta with ==> prefix\n" special

        printf "\n  %sHelp Text:%s\n" (set_color --underline) (set_color normal)
        printf "    %-20s Green 'Usage:' + body text with newline above, no newline below (1 arg)\n" help_usage
        printf "    %-20s Green title: + description with newlines above/below (2 args)\n" help_header
        printf "    %-20s Bold command + description, indented (2 args)\n" help_cmd
        printf "    %-20s Italic blue flag + desc, indented (s/long, s/long=ARG, long, or long=ARG)\n" help_flag

        printf "\n  %sUtility:%s\n" (set_color --underline) (set_color normal)
        printf "    %-20s Dimmed text\n" dim

        printf "\n%sOptions:%s\n\n" \
            (set_color --bold green) \
            (set_color normal)
        printf "  %s-h, --help%s         Show this help message\n" \
            (set_color --italics blue) \
            (set_color normal)
        return 0
    end

    # Validate argument count
    if test (count $argv) -lt 1
        printf "%s Missing required <type> argument%s\n" \
            (set_color red --bold) \
            (set_color normal) >&2
        printf "Try: logirl --help\n" >&2
        return 1
    end

    set -l msg_type $argv[1]

    # help_cmd requires 2 args (command + description)
    if test "$msg_type" = help_cmd
        if test (count $argv) -lt 3
            printf "%s help_cmd requires <command> and <description>%s\n" \
                (set_color red --bold) \
                (set_color normal) >&2
            printf "Try: logirl --help\n" >&2
            return 1
        end
        set -l command $argv[2]
        set -l description $argv[3..-1]

        # Output indented formatted command + description
        printf "  %s%-18s%s %s\n" \
            (set_color --bold) \
            "$command" \
            (set_color normal) \
            "$description"
        return 0
    end

    # help_flag requires 2 args (flag_spec + description)
    # flag_spec formats:
    #   "s/long"       → -s, --long          (short + long)
    #   "s/long=ARG"   → -s, --long <ARG>    (short + long with value)
    #   "long"         → --long              (long-only)
    #   "long=ARG"     → --long <ARG>        (long-only with value)
    if test "$msg_type" = help_flag
        if test (count $argv) -lt 3
            printf "%s help_flag requires <flag_spec> and <description>%s\n" \
                (set_color red --bold) \
                (set_color normal) >&2
            printf "Try: logirl --help\n" >&2
            return 1
        end
        set -l flag_spec $argv[2]
        set -l description $argv[3..-1]

        # Determine if this is short/long or long-only by checking for /
        set -l flags_split (string split '/' $flag_spec)
        set -l is_long_only false
        set -l short_flag ""
        set -l long_with_arg ""

        if test (count $flags_split) -eq 2
            # short/long format
            set short_flag $flags_split[1]
            set long_with_arg $flags_split[2]

            if test -z "$short_flag" -o -z "$long_with_arg"
                printf "%s Both short and long flag names required in s/long format%s\n" \
                    (set_color red --bold) \
                    (set_color normal) >&2
                printf "Got: $flag_spec\n" >&2
                return 1
            end
        else if test (count $flags_split) -eq 1
            # long-only format (no / found)
            set is_long_only true
            set long_with_arg $flag_spec
        else
            printf "%s Invalid flag spec format (expected s/long or long)%s\n" \
                (set_color red --bold) \
                (set_color normal) >&2
            printf "Got: $flag_spec\n" >&2
            return 1
        end

        # Check if there's an argument specification (=ARG)
        set -l arg_split (string split '=' $long_with_arg)
        set -l long_flag $arg_split[1]
        set -l arg_name ""

        if test (count $arg_split) -eq 2
            set arg_name $arg_split[2]
            if test -z "$arg_name"
                printf "%s Argument name cannot be empty after =%s\n" \
                    (set_color red --bold) \
                    (set_color normal) >&2
                printf "Got: $flag_spec\n" >&2
                return 1
            end
        end

        # Build the formatted output
        # Short+long:  "  -s, --long             Description"
        # Long-only:   "      --long             Description"
        # The 6 chars of "  -s, " align with "      " for long-only
        set -l flag_col
        if test -n "$arg_name"
            set flag_col "$long_flag <$arg_name>"
        else
            set flag_col "$long_flag"
        end

        if test "$is_long_only" = true
            # Long-only: 6 spaces to align past "  -x, " then --flag
            printf "  %s    --%-18s%s %s\n" \
                (set_color --italics blue) \
                "$flag_col" \
                (set_color normal) \
                "$description"
        else
            # Short + long
            printf "  %s-%-1s, --%-18s%s %s\n" \
                (set_color --italics blue) \
                "$short_flag" \
                "$flag_col" \
                (set_color normal) \
                "$description"
        end
        return 0
    end

    # help_usage, help_header, help_cmd, and help_flag have special arg handling with early returns
    # All other types need at least message text
    if test "$msg_type" != help_usage -a "$msg_type" != help_header -a "$msg_type" != help_cmd -a "$msg_type" != help_flag
        if test (count $argv) -lt 2
            printf "%s Type '%s' requires <message> argument%s\n" \
                (set_color red --bold) \
                "$msg_type" \
                (set_color normal) >&2
            printf "Try: logirl --help\n" >&2
            return 1
        end
    end

    set -l message $argv[2..-1]

    # Process message type
    switch $msg_type
        # Help text types
        case help_usage
            # Takes just the body text (what comes after "Usage:")
            # Single trailing newline to avoid double spacing with subsequent sections
            if test (count $argv) -lt 2
                printf "%s help_usage requires <body> argument%s\n" \
                    (set_color red --bold) \
                    (set_color normal) >&2
                printf "Try: logirl --help\n" >&2
                return 1
            end
            printf "\n%sUsage:%s %s\n" \
                (set_color --bold green) \
                (set_color normal) \
                "$message"
            return 0

        case help_header
            # Requires 2 args: title and optional body
            if test (count $argv) -eq 2
                # Title only (no body) - common for section headers like "Options:"
                printf "\n%s%s:%s\n\n" \
                    (set_color --bold green) \
                    "$message" \
                    (set_color normal)
            else if test (count $argv) -ge 3
                # Title + body (like "Usage: mytool [OPTIONS]")
                set -l title $argv[2]
                set -l body $argv[3..-1]
                printf "\n%s%s:%s %s\n\n" \
                    (set_color --bold green) \
                    "$title" \
                    (set_color normal) \
                    "$body"
            else
                printf "help_header requires <title> and optionally <body>"
                return 1
            end
            return 0

            # Core message types
        case error
            printf "%s [ERROR]%s%s %s%s%s\n" \
                (set_color brred --bold) \
                (set_color normal) \
                (set_color red) \
                "$message" \
                (set_color normal) >&2

        case warning
            printf "%s [WARN] %s%s%s\n" \
                (set_color bryellow --bold) \
                (set_color normal)(set_color yellow) \
                "$message" \
                (set_color normal)

        case info
            printf "%s [INFO]%s %s\n" \
                (set_color cyan --bold) (set_color normal) \
                "$message"

        case success
            printf "%s󰡕 [SUCCESS] %s%s%s%s\n" \
                (set_color brgreen --bold) \
                (set_color normal)(set_color green) \
                "$message" \
                (set_color normal)

        case special
            printf "%s==> %s%s\n" \
                (set_color magenta) \
                "$message" \
                (set_color normal)

            # Utility types
        case normal
            printf "%s\n" "$message"

        case dim
            printf "%s%s%s\n" \
                (set_color --dim) \
                "$message" \
                (set_color normal)

        case '*'
            printf "%sUnknown message type: $msg_type%s\n" \
                (set_color red --bold) \
                (set_color normal)
            printf "Try: logirl --help\n" >&2
            return 1
    end

    return 0
end
