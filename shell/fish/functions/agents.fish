function agents -d "Pick coding agents to launch in tmux windows"
    argparse h/help -- $argv
    or return

    if set -q _flag_help
        echo "Pick one or more coding agents to launch in tmux windows."
        logirl help_usage agent
        logirl help_header Behavior
        printf "  If inside a tmux session, new windows are opened for each agent.\n"
        printf "  If outside tmux, a new session named <dir>_<MM-DD-HH-mm> is created\n"
        printf "  with the agent windows plus a shell window, then attached.\n"
        logirl help_header Agents
        printf "  Claude Code, Goose, OpenCode, Crush, GitHub Copilot, OpenAI Codex\n"
        logirl help_header Options
        logirl help_flag h/help "Show this help"
        return 0
    end

    if not type -q tmux
        logirl error "tmux not found in PATH"
        logirl info "Install with: brew install tmux"
        return 127
    end

    if not type -q gum
        logirl error "gum not found in PATH"
        logirl info "Install with: brew install gum"
        return 127
    end

    set -l agent_options "Claude Code" Goose OpenCode Crush "GitHub Copilot" "OpenAI Codex"
    set -l choices (gum filter --limit 3 --header "Select agents (Tab to multi-select, Enter to confirm)" $agent_options)

    if test $status -ne 0; or test (count $choices) -eq 0
        logirl info "No agents selected"
        return 0
    end

    # Map display names to shell commands
    set -l cmds
    for choice in $choices
        switch $choice
            case "Claude Code"
                set -a cmds claude
            case Goose
                set -a cmds goose
            case OpenCode
                set -a cmds opencode
            case Crush
                set -a cmds crush
            case "GitHub Copilot"
                set -a cmds copilot
            case "OpenAI Codex"
                set -a cmds codex
            case "*"
                logirl error "Unknown agent: $choice"
                return 1
        end
    end

    if set -q TMUX
        for cmd in $cmds
            tmux new-window $cmd
        end
        logirl success "Launched "(count $choices)" agent window(s)"
    else
        set -l dir_name (string replace -ra '[^a-zA-Z0-9_-]' '' (path basename $PWD))
        if test -z "$dir_name"
            set dir_name agents
        end
        set -l timestamp (date +%m-%d-%H-%M)
        set -l session "$dir_name"_"$timestamp"

        tmux new-session -d -s $session $cmds[1]

        if test (count $choices) -gt 1
            for cmd in $cmds[2..-1]
                tmux new-window -t $session $cmd
            end
        end

        tmux new-window -t $session -n shell
        tmux attach-session -t $session
    end
end
