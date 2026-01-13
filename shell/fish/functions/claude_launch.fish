function claude_launch -d "Launch Claude Code then clean up afterwards, for use with keybindings"
    printf "$(set_color --bold magenta) Launching Claude Code...$(set_color normal)\n"
    command claude
    commandline -f repaint
end
