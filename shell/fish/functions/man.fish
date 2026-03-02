function man -d "man with tmux status hint"
    tmux_hint man
    command man $argv
    tmux_hint
end
