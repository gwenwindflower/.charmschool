function twin -d "Create a persistent tmux window in a session, optionally running a command with a locked hint"
    argparse h/help 'cmd=' -- $argv
    or return

    # TODO: Add support for commands with args, and update flag to c/command= for clarity
    # TODO: Add pwd based session name inference, to match pmux.fish behavior
    if set -q _flag_help
        echo "Create a persistent tmux window in an existing session, optionally running a tool command with icon display name."
        logirl help_usage "twin [OPTIONS] <session>"
        logirl help_header Usage
        printf "  twin dev-project                 Empty shell window in session 'dev-project'\n"
        printf "  twin dev-project --cmd nvim      Run nvim with locked icon name in session 'dev-project'\n"
        printf "  twin dev-project --cmd lazygit   Run lazygit with locked icon name in session 'dev-project'\n"
        logirl help_header Options
        logirl help_flag h/help "Show this help message"
        logirl help_flag cmd NAME "Command to run and hint to set (always locked)"
        logirl help_header Details
        printf "  Creates a detached window via send-keys so the shell persists\n"
        printf "  after the command exits. --cmd sets both the command and the\n"
        printf "  tmux_hint (locked) for icon display. Works from outside tmux.\n"
        return 0
    end

    if test (count $argv) -ne 1
        logirl error "Requires exactly one argument: the session name"
        logirl help_usage "twin [OPTIONS] <session>"
        return 1
    end

    set -l session $argv[1]

    if not tmux has-session -t "$session" 2>/dev/null
        logirl error "Session '$session' not found."
        return 1
    end

    # Create window detached (-d), return the new pane's unique id
    # for precise hint targeting (window id would require tmux to resolve
    # to a pane, which can go wrong in detached sessions)
    set -l wid (tmux new-window -d -t "$session" -P -F "#{pane_id}")

    if test -z "$wid"
        logirl error "Failed to create window in session '$session'."
        return 1
    end

    if set -q _flag_cmd
        # Set locked hint on the new window's pane, then send the command
        tmux_hint --target $wid --lock $_flag_cmd

        if tmux send-keys -t "$wid" "$_flag_cmd" Enter
            logirl success "Running '$_flag_cmd' in new window @ session '$session'."
        else
            logirl error "Failed to send '$_flag_cmd' to window in session '$session'."
            logirl warning "Cleaning up window '$wid'..."
            if tmux kill-window -t "$wid"
                logirl success "Killed window '$wid'. Edit your command and try again."
            else
                logirl error "Window clean up for '$wid' failed. Check tmux to clean up manually."
            end
            return 1
        end
    end
end
