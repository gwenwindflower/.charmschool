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
bind --user -M insert super-l "commandline -r 'lsd -lAg .'; commandline -f execute"
bind --user super-l "commandline -r 'lsd -lAg .'; commandline -f execute"

# launch yazi file explorer (f - finder/file/folder)
bind --user -M insert super-f "ff; commandline -f repaint"
bind --user super-f "ff; commandline -f repaint"

# TUI git tools (g - git)
## launch lazygit
bind --user -M insert super-g "commandline -r 'lazygit'; commandline -f execute"
bind --user super-g "commandline -r 'lazygit'; commandline -f execute"
## quick pretty git log
bind --user -M insert ctrl-alt-g "commandline -r 'git forgit log'; commandline -f execute"
bind --user ctrl-alt-g "commandline -r 'git forgit log'; commandline -f execute"
## gh dash GitHub Dash extension for quick project management
bind --user -M insert super-G "commandline -r 'gh dash'; commandline -f execute"
bind --user super-G "commandline -r 'gh dash'; commandline -f execute"

# AI agents (c - code)
## launch claude code
bind --user -M insert ctrl-super-c claude_launch
bind --user ctrl-super-c claude_launch
bind --user -M insert alt-super-c "zex ~/.claude/"
bind --user alt-super-c "zex ~/.claude/"

# Opening stuff (o - open)
# open nvim in current directory (via v.fish function)
bind --user -M insert super-o v
bind --user super-o v
# open Mac Finder
bind --user -M insert alt-super-o "open ."
bind --user alt-super-o "open ."

# clearing and refreshing (e - erase)
## just reload a 'fresh' sesh with pretty output, keep output on screen
bind --user -M insert super-e "fresh -r"
bind --user -M visual super-e "fresh -r"
bind --user super-e "fresh -r"
## just clear the screen via `fresh`
bind --user -M insert ctrl-e "fresh -c; commandline -f repaint"
bind --user -M visual ctrl-e "fresh -c; commandline -f repaint"
bind --user ctrl-e "fresh -c; commandline -f repaint"
## clear *and* reload sesh, so fresh, so clean
bind --user -M insert ctrl-super-e "fresh; commandline -f repaint"
bind --user -M visual ctrl-super-e "fresh; commandline -f repaint"
bind --user ctrl-super-e "fresh; commandline -f repaint"

# wrapping commands
## print (p) (i use p -> echo and pp -> bat)
## this wraps anything (or nothing) on the command line
## with echo "[stuff]^", with ^ being the end location of the cursor
bind --user -M insert ctrl-p _wrap_echo
bind --user ctrl-p _wrap_echo
## secrets (s) 1Password env wrapper
bind --user -M insert ctrl-s _wrap_op_interactive
bind --user ctrl-s _wrap_op_interactive
