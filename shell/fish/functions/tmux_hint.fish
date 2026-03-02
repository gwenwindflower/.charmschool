function tmux_hint -d "Set or clear the tmux pane command hint for icon/status display"
    argparse h/help -- $argv
    or return

    if set -q _flag_help
        echo "Override the command name shown in tmux status bar and window icons."
        logirl help_usage "tmux_hint [NAME]"
        logirl help_header "Usage"
        printf "  tmux_hint <name>    Set hint (e.g. tmux_hint man)\n"
        printf "  tmux_hint           Clear hint (revert to pane_current_command)\n"
        logirl help_header "Details"
        printf "  Sets the @hint_cmd pane option, which pane-icon.sh and\n"
        printf "  status-left read as the authoritative command name.\n"
        printf "  Silently no-ops when not inside tmux.\n"
        return 0
    end

    # Cosmetic feature — silently skip when not in tmux
    if not set -q TMUX
        return 0
    end

    set -l pane_id (tmux display-message -p '#{pane_id}')
    if test -z "$pane_id"
        logirl warning "Could not determine tmux pane ID, hint skipped"
        return 1
    end

    if test (count $argv) -ge 1
        if not tmux set-option -p -t $pane_id @hint_cmd $argv[1]
            logirl warning "Failed to set tmux @hint_cmd"
            return 1
        end
    else
        if not tmux set-option -p -t $pane_id -u @hint_cmd
            logirl warning "Failed to unset tmux @hint_cmd"
            return 1
        end
    end
end
