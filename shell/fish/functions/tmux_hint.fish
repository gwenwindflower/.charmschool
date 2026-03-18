function tmux_hint -d "Set or clear the tmux pane command hint for icon/status display"
    argparse h/help 'd/direct=' l/lock -- $argv
    or return

    if set -q _flag_help
        echo "Override the command name shown in tmux status bar and window icons."
        logirl help_usage "tmux_hint [OPTIONS] [NAME]"
        logirl help_header Usage
        printf "  tmux_hint <name>        Set hint (e.g. tmux_hint man)\n"
        printf "  tmux_hint -l <name>     Set hint with lock (survives bg clears)\n"
        printf "  tmux_hint -d <str>      Set a literal icon/label (max 6 chars, no spaces)\n"
        printf "  tmux_hint               Clear all hints (respects lock)\n"
        logirl help_header Options
        logirl help_flag h/help "Show this help message"
        logirl help_flag l/lock "Lock the hint to this shell's PID; other processes can't clear it"
        logirl help_flag d/direct STR "Literal string for the icon slot (devicon, emoji, or short label)"
        logirl help_header Details
        printf "  Sets @hint_cmd and/or @assigned_icon pane options, which\n"
        printf "  pane-icon.sh and status-left read for display.\n"
        printf "  --lock prevents background processes from clearing the hint.\n"
        printf "  The lock is released when the owning shell exits or clears.\n"
        printf "  A new --lock call always upgrades the lock to the new owner.\n"
        printf "  Silently no-ops when not inside tmux.\n"
        return 0
    end

    # Quietly no-op if not in tmux
    # so this can be called by other commands without being noisy
    if not set -q TMUX
        return 0
    end

    # Validate --direct: max 6 chars, no spaces
    if set -q _flag_direct
        if string match -q '* *' -- "$_flag_direct"
            logirl error "Direct hint cannot contain spaces"
            return 2
        end
        if test (string length -- "$_flag_direct") -gt 6
            logirl error "Direct hint must be 6 characters or fewer"
            return 2
        end
    end

    set -l pane_id (tmux display-message -p '#{pane_id}')
    if test -z "$pane_id"
        logirl warning "Could not determine tmux pane ID, hint skipped"
        return 1
    end

    # No args and no flags → clear everything (if lock allows)
    if not set -q _flag_direct; and not set -q _flag_lock; and test (count $argv) -eq 0
        # Check if a lock is held by a living process that isn't us
        set -l owner (tmux show-option -p -t $pane_id -qv @hint_locked 2>/dev/null)
        if test -n "$owner"; and test "$owner" != "$fish_pid"
            # Owner still alive? No-op to protect the hint.
            if kill -0 $owner 2>/dev/null
                return 0
            end
        end
        tmux set-option -p -t $pane_id -u @hint_cmd 2>/dev/null
        tmux set-option -p -t $pane_id -u @assigned_icon 2>/dev/null
        tmux set-option -p -t $pane_id -u @hint_locked 2>/dev/null
        return 0
    end

    # Set @hint_cmd if a name was provided
    if test (count $argv) -ge 1
        if not tmux set-option -p -t $pane_id @hint_cmd $argv[1]
            logirl warning "Failed to set tmux @hint_cmd"
            return 1
        end
    end

    # Set @assigned_icon if --direct was provided
    if set -q _flag_direct
        if not tmux set-option -p -t $pane_id @assigned_icon "$_flag_direct"
            logirl warning "Failed to set tmux @assigned_icon"
            return 1
        end
    end

    # Set lock if requested — always upgrades to new owner
    if set -q _flag_lock
        tmux set-option -p -t $pane_id @hint_locked $fish_pid 2>/dev/null
    end
end
