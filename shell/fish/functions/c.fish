function c -d "Quick inline color wrapper for embedding colored text in strings"
    argparse h/help -- $argv
    or return

    if set -q _flag_help
        printf "%sUsage:%s c <type> <text>\n\n" (set_color --bold) (set_color normal)
        printf "Quick inline color wrapper for use within echo/printf statements.\n\n"
        printf "%sTypes:%s\n" (set_color --bold) (set_color normal)
        printf "  %ss, success%s     Bright green (success messages, versions)\n" (set_color brmagenta) (set_color normal)
        printf "  %se, error%s       Red (error messages)\n" (set_color brmagenta) (set_color normal)
        printf "  %sw, warn%s        Bright yellow (warnings)\n" (set_color brmagenta) (set_color normal)
        printf "  %si, info%s        Cyan (info messages)\n" (set_color brmagenta) (set_color normal)
        printf "  %sm, cmd%s         Bright magenta (commands/flags)\n" (set_color brmagenta) (set_color normal)
        printf "  %sd, dim, old%s    Dimmed (deprecated/old values)\n" (set_color brmagenta) (set_color normal)
        printf "  %sb, bold%s        Bold text\n" (set_color brmagenta) (set_color normal)
        printf "  %sn, normal%s      Normal/reset colors\n" (set_color brmagenta) (set_color normal)
        printf "\n%sExamples:%s\n" (set_color --bold) (set_color normal)
        printf "  echo \"Status: \"(c s OK)\n"
        printf "  echo \"Updated from \"(c s v1.0)\" to \"(c s v2.0)\n"
        printf "  echo \"Old value: \"(c d deprecated)\n"
        printf "  logirl special_msg \"Installing \"(c s package)\"...\"\n"
        return 0
    end

    if test (count $argv) -lt 2
        echo (set_color red --bold)"[ERROR]"(set_color normal)" c requires <type> and <text> arguments"
        echo "Try: c --help"
        return 1
    end

    set -l type $argv[1]
    set -l text $argv[2..-1]

    switch $type
        case s success
            echo (set_color -o brgreen)"$text"(set_color normal)

        case e error
            echo (set_color red)"$text"(set_color normal)

        case w warn warning
            echo (set_color -o bryellow)"$text"(set_color normal)

        case i info
            echo (set_color cyan)"$text"(set_color normal)

        case m cmd command
            echo (set_color -o brmagenta)"$text"(set_color normal)

        case d dim old deprecated
            echo (set_color --dim)"$text"(set_color normal)

        case b bold
            echo (set_color --bold)"$text"(set_color normal)

        case n normal reset
            echo "$text"

        case '*'
            echo (set_color red --bold)"[ERROR]"(set_color normal)" Unknown color type: $type"
            echo "Try: c --help"
            return 1
    end

    return 0
end
