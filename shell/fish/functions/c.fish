function c -d "Quick inline color wrapper for embedding colored text in strings"
    argparse h/help b/bold d/dim -- $argv
    or return

    if set -q _flag_help
        printf "%sUsage:%s c [-b|--bold] [-d|--dim] <type> <text>\n\n" (set_color --bold) (set_color normal)
        printf "Quick inline color wrapper for use within echo/printf statements.\n\n"
        printf "%sFlags:%s\n" (set_color --bold) (set_color normal)
        printf "  %s-b, --bold%s       Make text bold/bright (combines with any type)\n" (set_color brmagenta) (set_color normal)
        printf "  %s-d, --dim%s        Make text dimmed (combines with any type)\n" (set_color brmagenta) (set_color normal)
        printf "\n%sTypes:%s\n" (set_color --bold) (set_color normal)
        printf "  %ss, success%s     Bright green (success messages, versions)\n" (set_color brmagenta) (set_color normal)
        printf "  %se, error%s       Red (error messages)\n" (set_color brmagenta) (set_color normal)
        printf "  %sw, warn%s        Bright yellow (warnings)\n" (set_color brmagenta) (set_color normal)
        printf "  %si, info%s        Cyan (info messages)\n" (set_color brmagenta) (set_color normal)
        printf "  %sm, cmd%s         Bright magenta (commands/flags)\n" (set_color brmagenta) (set_color normal)
        printf "  %sn, normal%s      Normal/reset colors\n" (set_color brmagenta) (set_color normal)
        printf "\n%sExamples:%s\n" (set_color --bold) (set_color normal)
        printf "  echo \"Status: \"(c s OK)\n"
        printf "  echo \"Updated from \"(c s v1.0)\" to \"(c s v2.0)\n"
        printf "  echo \"Old value: \"(c -d s deprecated)\n"
        printf "  echo \"Bold error: \"(c -b e \"Critical issue\")\n"
        printf "  echo \"Dim warning: \"(c --dim w \"Minor issue\")\n"
        printf "  echo \"Bold + dim: \"(c -b -d i \"Fading notice\")\n"
        printf "  logirl special_msg \"Installing \"(c s package)\"...\"\n"
        return 0
    end

    if test (count $argv) -lt 2
        logirl error "c requires <type> and <text> arguments"
        logirl help_body -n "Try: "
        logirl help_cmd "c --help"
        return 1
    end

    set -l type $argv[1]
    set -l text $argv[2..-1]

    # Determine styling flags for set_color
    set -l bold_flag
    if set -q _flag_bold
        set bold_flag -o
    end

    set -l dim_flag
    if set -q _flag_dim
        set dim_flag --dim
    end

    switch $type
        case s success
            echo (set_color $bold_flag $dim_flag brgreen)"$text"(set_color normal)

        case e error
            echo (set_color $bold_flag $dim_flag red)"$text"(set_color normal)

        case w warn warning
            echo (set_color $bold_flag $dim_flag bryellow)"$text"(set_color normal)

        case i info
            echo (set_color $bold_flag $dim_flag cyan)"$text"(set_color normal)

        case m cmd command
            echo (set_color $bold_flag $dim_flag brmagenta)"$text"(set_color normal)

        case n normal reset
            if set -q _flag_bold; or set -q _flag_dim
                echo (set_color normal)(set_color $bold_flag $dim_flag)"$text"(set_color normal)
            else
                echo (set_color normal)"$text"(set_color normal)
            end

        case '*'
            echo (set_color red --bold)"[ERROR]"(set_color normal)" Unknown color type: $type"
            echo "Try: c --help"
            return 1
    end

    return 0
end
