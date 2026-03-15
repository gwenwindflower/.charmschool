# Enable vi mode by default
fish_vi_key_bindings

# bracket nav <-[ ]->
## this is really neat, if there's an autosuggestion,
## it accepts it one token at a time, very useful with long paths
## or commands where you need to change something towards the end
## comes in handy constantly - if the command line is empty it goes
## back/forward in your nav history
bind --user -M insert ctrl-\[ prevd-or-backward-word
bind --user -M insert ctrl-\] nextd-or-forward-word
bind --user ctrl-\[ prevd-or-backward-word
bind --user ctrl-\] nextd-or-forward-word

bind --user -M insert ctrl-alt-\[ backward-kill-word
bind --user -M insert ctrl-alt-\] kill-word-vi
bind --user ctrl-alt-\[ backward-kill-word
bind --user ctrl-alt-\] kill-word-vi

# TODO: find a way to bind up/down command history search to something
# more home-row friendly (or put home row arrows on Planck 'adjust' layer)
# not sure this is exactly the ideal binding, but i want j/k history search for sure
# bind --user -M insert alt-k history-search-backwards
# bind --user -M insert alt-j history-search-forward

# quick pretty list (l - list)
# fish has a default binding for plain 'ls' to alt-l
# this overrides it with better output and supports super as well
bind --user -M insert super-l "commandline -r 'lsd -lAg .'; commandline -f execute"
bind --user super-l "commandline -r 'lsd -lAg .'; commandline -f execute"
bind --user -M insert alt-l "commandline -r 'lsd -lAg .'; commandline -f execute"
bind --user alt-l "commandline -r 'lsd -lAg .'; commandline -f execute"

# launch yazi file explorer (f - finder/file/folder)
bind --user -M insert super-f "ff; commandline -f repaint"
bind --user super-f "ff; commandline -f repaint"
bind --user -M insert alt-f "ff; commandline -f repaint"
bind --user alt-f "ff; commandline -f repaint"
# open Mac Finder
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
bind --user -M insert super-G "commandline -r 'opo gh dash'; commandline -f execute"
bind --user super-G "commandline -r 'opo gh dash'; commandline -f execute"
bind --user -M insert alt-G "commandline -r 'opo gh dash'; commandline -f execute"
bind --user alt-G "commandline -r 'opo gh dash'; commandline -f execute"

# AI agents (c - code)
## launch claude code
bind --user -M insert ctrl-super-c claude_launch
bind --user ctrl-super-c claude_launch
bind --user -M insert ctrl-alt-c claude_launch
bind --user ctrl-alt-c claude_launch
bind --user -M insert alt-C "ee ~/.claude/"
bind --user alt-C "ee ~/.claude/"

# clearing and reloading (e - erase, r - reload)
## just reload a 'fresh' sesh with pretty output, keep output on screen
bind --user -M insert super-r "fresh -r"
bind --user super-r "fresh -r"
bind --user -M insert alt-r "fresh -r"
bind --user alt-r "fresh -r"
## just clear the screen via `fresh`
bind --user -M insert alt-e "fresh -c; commandline -f repaint"
bind --user alt-e "fresh -c; commandline -f repaint"
## clear *and* reload sesh, so fresh, so clean
bind --user -M insert ctrl-super-e "fresh; commandline -f repaint"
bind --user ctrl-super-e "fresh; commandline -f repaint"
## clear, reload, *and* navigate to home dir - a brand new start
## essentially the same as opening a new tab
## but keeps random short-lived tabs for accumulating
bind --user -M insert alt-super-e "fresh -g; commandline -f repaint"
bind --user alt-super-e "fresh -g; commandline -f repaint"

# wrapping commands
## print (p) (i use p -> echo and pp -> bat)
## this wraps anything (or nothing) on the command line
## with echo "[stuff]^", with ^ being the end location of the cursor
bind --user -M insert alt-p _wrap_echo
bind --user alt-p _wrap_echo
## secrets (s) 1Password env wrapper
bind --user -M insert ctrl-o "_wrap_op_interactive -a"
bind --user ctrl-o "_wrap_op_interactive -a"
bind --user -M insert ctrl-alt-o _wrap_op_interactive
bind --user ctrl-alt-o _wrap_op_interactive
