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
        printf "    %-20s Bold command + description (2 args)\n" help_cmd
        printf "    %-20s Italic blue flag: s/long or s/long=ARG + desc (2 or 3 args, the first arg must follow `f/flag` format)\n" help_flag

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

        # Output formatted command + description with trailing newline
        printf "%s%-18s%s %s\n" \
            (set_color --bold) \
            "$command" \
            (set_color normal) \
            "$description"
        return 0
    end

    # help_flag requires 2 args (flag_spec + description)
    # flag_spec format: "s/long" or "s/long=ARG"
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

        # Parse the flag spec
        set -l flags_split (string split '/' $flag_spec)
        if test (count $flags_split) -ne 2
            printf "%s Flag spec must be SHORT/LONG or SHORT/LONG=ARG (e.g., h/help or o/output=FILE)%s\n" \
                (set_color red --bold) \
                (set_color normal) >&2
            printf "Got: $flag_spec\n" >&2
            return 1
        end

        set -l short_flag $flags_split[1]
        set -l long_with_arg $flags_split[2]

        if test -z "$short_flag" -o -z "$long_with_arg"
            printf "%s Both short and long flag names required%s\n" \
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
            # Format: -s, --long <ARG>  Description
            # Combine long flag and <ARG> first, then pad to 18 chars total
            set -l flag_with_arg "$long_flag <$arg_name>"
            printf "%s-%-1s, --%-18s%s %s\n" \
                (set_color --italics blue) \
                "$short_flag" \
                "$flag_with_arg" \
                (set_color normal) \
                "$description"
        else
            # Format: -s, --long  Description
            printf "%s-%-1s, --%-18s%s %s\n" \
                (set_color --italics blue) \
                "$short_flag" \
                "$long_flag" \
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
