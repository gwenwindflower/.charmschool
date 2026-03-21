# Enable vi mode by default
fish_vi_key_bindings

# bracket nav <-[ ]->
## this is really neat, if there's an autosuggestion,
## it accepts it one token at a time, very useful with long paths
## or commands where you need to change something towards the end
## comes in handy constantly - if the command line is empty it goes
## back/forward in your nav history
bind --user -M insert alt-h prevd-or-backward-word
bind --user -M insert alt-l nextd-or-forward-word
bind --user alt-h prevd-or-backward-word
bind --user alt-l nextd-or-forward-word

bind --user -M insert alt-H backward-kill-word
bind --user -M insert alt-L kill-word-vi
bind --user alt-H backward-kill-word
bind --user alt-L kill-word-vi

# TODO: find a way to bind up/down command history search to something
# more home-row friendly (or put home row arrows on Planck 'adjust' layer)
# not sure this is exactly the ideal binding, but i want j/k history search for sure
# bind --user -M insert alt-k history-search-backwards
# bind --user -M insert alt-j history-search-forward

# launch yazi file explorer (f - finder/file/folder)
bind --user -M insert super-f "ff; commandline -f repaint"
bind --user super-f "ff; commandline -f repaint"
bind --user -M insert alt-f "ff; commandline -f repaint"
bind --user alt-f "ff; commandline -f repaint"
# open Mac Finder
bind --user -M insert super-F "open ."
bind --user super-F "open ."
bind --user -M insert alt-F "open ."
bind --user alt-F "open ."

# TUI git tools (g - git)
## launch lazygit
bind --user -M insert super-g "commandline -r 'lazygit'; commandline -f execute"
bind --user super-g "commandline -r 'lazygit'; commandline -f execute"
bind --user -M insert alt-g "commandline -r 'lazygit'; commandline -f execute"
bind --user alt-g "commandline -r 'lazygit'; commandline -f execute"
## quick pretty git log
bind --user -M insert ctrl-alt-g "commandline -r 'git forgit log'; commandline -f execute"
bind --user ctrl-alt-g "commandline -r 'git forgit log'; commandline -f execute"
## gh dash GitHub Dash extension for quick project management
bind --user -M insert super-G "commandline -r 'gh dash'; commandline -f execute"
bind --user super-G "commandline -r 'gh dash'; commandline -f execute"
bind --user -M insert alt-G "commandline -r 'gh dash'; commandline -f execute"
bind --user alt-G "commandline -r 'gh dash'; commandline -f execute"

# clearing and reloading (e - erase, r - reload)
## just reload a 'fresh' sesh with pretty output, keep output on screen
bind --user -M insert super-r "fresh -r"
bind --user super-r "fresh -r"
bind --user -M insert alt-r "fresh -r"
bind --user alt-r "fresh -r"
## just clear the screen
## i usually use Kitty for this, but it can't operate inside tmux
## so this the tmux-friendly quick clear
bind --user -M insert super-e "fresh -c"
bind --user super-e "fresh -c"
bind --user -M insert alt-e "fresh -c"
bind --user alt-e "fresh -c"
## alt-e is fish's default to open the command line in $EDITOR
## so we remap that to alt-o
bind --user -M insert alt-o edit_command_buffer
bind --user -M visual alt-o edit_command_buffer
bind --user alt-o edit_command_buffer
bind --user -M insert super-R "fresh; commandline -f repaint"
bind --user super-R "fresh; commandline -f repaint"
bind --user -M insert alt-R "fresh; commandline -f repaint"
bind --user alt-R "fresh; commandline -f repaint"
## clear, reload, *and* navigate to home dir - a brand new start
## essentially the same as opening a new tab
## but keeps random short-lived tabs for accumulating
bind --user -M insert ctrl-super-r "fresh -g; commandline -f repaint"
bind --user ctrl-super-r "fresh -g; commandline -f repaint"
bind --user -M insert ctrl-alt-r "fresh -g; commandline -f repaint"
bind --user ctrl-alt-r "fresh -g; commandline -f repaint"

# print, list, pager
bind --user -M insert super-p "commandline -r 'lsd -lAg .'; commandline -f execute"
bind --user super-p "commandline -r 'lsd -lAg .'; commandline -f execute"
bind --user -M insert alt-p "commandline -r 'lsd -lAg .'; commandline -f execute"
bind --user alt-p "commandline -r 'lsd -lAg .'; commandline -f execute"
# wrapping commands
## this wraps anything (or nothing) on the command line
## with echo "[stuff]^", with ^ being the end location of the cursor
bind --user -M insert alt-P _wrap_echo
bind --user alt-P _wrap_echo
bind --user -M insert super-P _wrap_echo
bind --user super-P _wrap_echo
## 1Password (op -> o) env wrapper
bind --user -M insert ctrl-o "_wrap_op_interactive -a"
bind --user ctrl-o "_wrap_op_interactive -a"
bind --user -M insert ctrl-alt-o _wrap_op_interactive
bind --user ctrl-alt-o _wrap_op_interactive
