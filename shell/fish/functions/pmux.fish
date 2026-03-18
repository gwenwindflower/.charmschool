function pmux -d "Generate my preferred dev setup in tmux for a given project directory"
    # TODO: Figure out tmux_hint icon logic (currently not working)
    argparse h/help e/no-nvim g/no-lazygit n/name= a/agent= t/terminals= -- $argv
    or return

    if set -q _flag_help
        echo "Generate a tmux dev session for a project directory."
        logirl help_usage "pmux [OPTIONS] [DIRECTORY]"
        logirl help_header "Default Layout"
        printf "  1: nvim\n"
        printf "  2: AI agent (claude)\n"
        printf "  3: lazygit\n"
        printf "  4: terminal\n"
        logirl help_header Options
        logirl help_flag h/help "Show this help"
        logirl help_flag a/agent <agent >"AI agent to launch (default: claude)"
        logirl help_flag t/terminals N "Extra terminal windows (default: 1)"
        logirl help_flag x/no-nvim "Skip the nvim window"
        logirl help_flag g/no-lazygit "Skip the lazygit window"
        logirl help_flag n/name NAME "Session name (default: directory name)"
        logirl help_header Examples
        printf "  pmux ~/projects/myapp\n"
        printf "  pmux -a goose -t 2 ~/projects/myapp\n"
        printf "  pmux -x -g .  # just agent + terminals\n"
        return 0
    end

    if not type -q tmux
        logirl error "tmux not found in PATH"
        logirl info "Install with: brew install tmux"
        return 127
    end

    # Resolve target directory (defaults to CWD)
    set -l target_dir $PWD
    if test (count $argv) -ge 1
        set target_dir $argv[1]
    end

    if not test -d "$target_dir"
        logirl error "Directory not found: $target_dir"
        return 1
    end

    if not git -C "$target_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1
        logirl error "Not a git repository: $target_dir"
        return 1
    end

    if test "$target_dir" != "$PWD"
        if type -q z
            # @fish-lsp-disable-next-line
            z $target_dir
        else
            cd "$target_dir"
        end
    end

    # Session name defaults to the project directory name
    set -l session_name (string replace -ra '[^a-zA-Z0-9_-]' '_' (path basename "$target_dir"))
    if set -q _flag_name
        set session_name (string replace -ra '[^a-zA-Z0-9_-]' '_' "$_flag_name")
    end

    set -l agent claude
    if set -q _flag_agent
        set agent $_flag_agent
    end

    set -l extra_terminals 1
    if set -q _flag_terminals
        if not string match -qr '^\d+$' "$_flag_terminals"
            logirl error "The -t/--terminals flag requires a non-negative integer"
            return 1
        end
        if test $_flag_terminals -gt 8
            logirl warning "That's a lot of terminals! Are you sure? (limit is 8)"
            return 1
        end
        set extra_terminals $_flag_terminals
    end

    set -l launch_nvim true
    set -l launch_lazygit true
    if set -q _flag_no_nvim
        set launch_nvim false
    end
    if set -q _flag_no_lazygit
        set launch_lazygit false
    end

    # Attach to an existing session if one already exists for this project
    if tmux has-session -t "$session_name" 2>/dev/null
        logirl warning "Session '$session_name' already exists, attaching..."
        if set -q TMUX
            tmux switch-client -t "$session_name"
        else
            tmux attach-session -t "$session_name"
            logirl success "Left session '$session_name'. Have a great day!"
        end
        return 0
    end

    logirl special "Creating session '$session_name' in $target_dir"
    set -l config_summary "Configured with coding agent '$agent'"
    if test $extra_terminals -gt 0
        set config_summary $config_summary " $extra_terminals extra terminal(s),"
    end
    if $launch_nvim
        set config_summary $config_summary " nvim,"
    end
    if $launch_lazygit
        set config_summary $config_summary " lazygit,"
    end
    set config_summary $config_summary " happy coding!"
    logirl info $config_summary
    sleep 2s
    _pmux_launch_session "$session_name" "$target_dir" "$agent" "$extra_terminals" "$launch_nvim" "$launch_lazygit"

    if test $status -ne 0
        logirl error "Failed to create session '$session_name'"
        return 1
    end

    if set -q TMUX
        tmux switch-client -t "$session_name"
    else
        tmux attach-session -t "$session_name"
        logirl success "Ending session '$session_name'...have a great day!"
    end
end

function _pmux_launch_session -d "Internal: create the pmux tmux session and window layout"
    set -l session $argv[1]
    set -l dir $argv[2]
    set -l agent $argv[3]
    set -l extra_terminals $argv[4]
    set -l launch_nvim $argv[5]
    set -l launch_lazygit $argv[6]

    set -l first_created false

    # Window 1: nvim
    if test "$launch_nvim" = true
        tmux new-session -d -s "$session" -c "$dir" "opo nvim"
        set first_created true
    end

    # Window 2: AI agent
    if test "$first_created" = false
        tmux new-session -d -s "$session" -c "$dir" "opo $agent"
        set first_created true
    else
        tmux new-window -t "$session" -c "$dir" "opo $agent"
    end

    # Window 3: lazygit
    if test "$launch_lazygit" = true
        tmux new-window -t "$session" -c "$dir" "tmux_hint -l lazygit; lazygit; tmux_hint"
    end

    # Window 4+: extra terminals
    set -l terminal_count 0
    while test $terminal_count -lt $extra_terminals
        tmux new-window -t "$session" -c "$dir"
        set terminal_count (math $terminal_count + 1)
    end

    tmux select-window -t "$session":1
end
