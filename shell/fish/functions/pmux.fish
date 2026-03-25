function pmux -d "Generate my preferred dev setup in tmux for a given project directory"
    argparse h/help -- $argv
    or return

    if set -q _flag_help
        echo "Launch a new tmux session with a predefined set of windows for development tools."
        logirl help_usage "pmux [OPTIONS]"
        logirl help_header Usage
        printf "  pmux                           Launch a new tmux session with predefined windows\n"
        logirl help_header Options
        logirl help_flag h/help "Show this help message"
        return 0
    end

    if set -q TMUX
        logirl error "You're already in a tmux session, pmux is for launching new dev sessions from outside tmux."
        logirl info "Use $(set_color brmagenta)twin$(set_color normal) to launch dev tool windows both inside and outside tmux sessions."
    end
    if not type -q tmux
        logirl error "tmux not found in PATH"
        logirl info "Install with: $(set_color brmagenta)brew install tmux$(set_color normal)"
        return 127
    end

    set -l session_name (string replace -ra '[^a-zA-Z0-9_-]' '_' (path basename $PWD))
    if tmux new-session -d -s $session_name
        logirl success "Started session $session_name"
        twin --cmd nvim $session_name
        twin --cmd opc $session_name
        twin --cmd lazygit $session_name
        tmux attach -t $session_name
    else
        logirl error "Failed to start tmux session '$session_name'."
        return 1
    end
end
