function pthcl -d "Light interface to review and remove entries from PATH safely"
    argparse s/system h/help -- $argv
    if set -q _flag_help
        echo "Usage: pthcl [-s/--system, -h/--help]"
        echo ""
        echo "Light interface to review and remove entries from PATH safely."
        echo ""
        echo "By default, this edits the fish_user_paths variable,"
        echo "which is the recommended way to manage user-specific PATH entries in fish shell."
        echo "Use the --system flag to edit the full PATH variable if absolutely necessary."
        return 0
    end
    set -l var_name fish_user_paths
    set -l path_list $fish_user_paths
    # Change values to system PATH if requested
    if set -q _flag_system
        set var_name PATH
        set path_list $PATH
    end

    # Let user select paths to remove (no limit)
    set -l choices (printf '%s\n' $path_list | gum choose --no-limit)

    # Confirm and remove each selected path
    for choice in $choices
        if gum confirm "Remove '$choice' from \$$var_name?"
            set -l idx (contains --index -- $choice $path_list)
            if test -n "$idx"
                set -e {$var_name}[$idx]
                # Update our local copy for subsequent iterations
                set -e path_list[$idx]
            end
        end
    end
end
