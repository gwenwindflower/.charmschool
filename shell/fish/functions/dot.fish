function dot -d "Link and install dotfiles with rotz"
    argparse h/help a/all l/link i/install d/dry-run -- $argv
    or return

    set -l dotfiles_root ~/.charmschool
    set -l target_dots
    set -l rotz_commands

    if set -q _flag_help
        printf "Usage: dot [OPTIONS] [FILES...]\n\n"
        printf "Link and install dotfiles with rotz.\n\n"
        printf "Options:\n"
        printf "  -h, --help      Show this help message and exit\n"
        printf "  -a, --all       Link and install all dotfiles\n"
        printf "  -l, --link      Link specified dotfiles\n"
        printf "  -i, --install   Install specified dotfiles\n"
        printf "  -d, --dry-run   Show commands that would be executed without running them\n"
        printf "\nExamples:\n"
        printf "  dot -a              Link and install all dotfiles\n"
        printf "  dot tools/fzf       Link and install a specific dot\n"
        printf "  dot -l tools/fzf    Link a specific dot\n"
        printf "  dot -i lang/python  Install all dots under lang/python/\n"
        printf "  dot -d -a           Show what commands would run for all dotfiles\n"
        return 0
    end

    if set -q _flag_all; and test (count $argv) -gt 0
        printf "%s[ERROR]%s: Cannot use -a/--all with specific dots.\n" (set_color red --bold) (set_color normal)
        return 1
    end

    if set -q _flag_all
        set target_dots # empty => all
    else if test (count $argv) -gt 0
        # Expand each argument to matching dot directories
        for arg in $argv
            if test (string match -r '/$' $arg)
                set arg (string sub -e -1 $arg)
            end
            # Check if it's an exact dot (has dot.yaml)
            if test -f "$dotfiles_root/$arg/dot.yaml"
                set -a target_dots $arg
            else
                # Try to find subdirectories with dot.yaml files
                set -l matches (find "$dotfiles_root/$arg" -name "dot.yaml" -type f 2>/dev/null | sort)
                if test (count $matches) -gt 0
                    for match in $matches
                        # Extract relative path from dotfiles_root, removing /dot.yaml suffix
                        set -l rel_path (string replace "$dotfiles_root/" "" (dirname $match))
                        set -a target_dots $rel_path
                    end
                else
                    printf "%s[ERROR]%s: No dots found matching '%s'\n" (set_color red --bold) (set_color normal) $arg
                    return 1
                end
            end
        end
    else
        printf "No dotfiles specified, if you want to run all, you must use the -a/--all option.\n"
        return 1
    end

    if set -q _flag_link; and set -q _flag_install
        printf "%s[WARNING]%s: you don't need to specify both -l/--link and -i/--install, this is default behavior.\n\n" (set_color yellow --bold) (set_color normal)
        set rotz_commands link install
    else if set -q _flag_link
        set rotz_commands link
    else if set -q _flag_install
        set rotz_commands install
    else
        set rotz_commands link install
    end

    if set -q _flag_dry_run
        printf "%sDRY-RUN MODE%s - these are the commands that would be executed...\n\n" (set_color cyan --bold) (set_color normal)
    end

    if test (count $target_dots) -eq 0
        # run all
        for cmd in $rotz_commands
            if set -q _flag_dry_run
                printf "%s[DRY-RUN]%s: %srotz %s%s\n" (set_color cyan --bold) (set_color normal) (set_color magenta) $cmd (set_color normal)
            else
                rotz $cmd
            end
        end
    else
        # run specific dots
        for dot in $target_dots
            for cmd in $rotz_commands
                if set -q _flag_dry_run
                    printf "%s[DRY-RUN]%s: %srotz %s %s%s\n" (set_color cyan --bold) (set_color normal) (set_color magenta) $cmd $dot (set_color normal)
                else
                    rotz $cmd $dot
                end
            end
        end
    end
end
