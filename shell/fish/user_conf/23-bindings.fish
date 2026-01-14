# Enable vi mode by default
fish_vi_key_bindings

# nice consistent bracket nav
bind --user -M insert ctrl-\[ prevd-or-backward-word
bind --user -M insert ctrl-\] nextd-or-forward-word
bind --user -M visual ctrl-\[ prevd-or-backward-word
bind --user -M visual ctrl-\] nextd-or-forward-word
bind --user ctrl-\[ prevd-or-backward-word
bind --user ctrl-\] nextd-or-forward-word

# quick pretty git log
bind --user -M insert ctrl-super-g "commandline -r 'git forgit log'; commandline -f execute"
bind --user ctrl-super-g "commandline -r 'git forgit log'; commandline -f execute"

# quick pretty list
bind --user -M insert super-l "commandline -r 'lsd -lAg .'; commandline -f execute"
bind --user super-l "commandline -r 'lsd -lAg .'; commandline -f execute"

# launch lazygit
bind --user -M insert super-g "commandline -r 'lazygit'; commandline -f execute"
bind --user super-g "commandline -r 'lazygit'; commandline -f execute"

# launch yazi file explorer
bind --user -M insert super-f "ff; commandline -f repaint"
bind --user super-f "ff; commandline -f repaint"

# open claude code
bind --user -M insert ctrl-super-c claude_launch
bind --user ctrl-super-c claude_launch
# open claude code config
bind --user -M insert super-C "sd ~/.claude; commandline -f repaint"
bind --user super-C "sd ~/.claude; commandline -f repaint"

# open nvim in current directory (via v.fish function)
bind --user -M insert super-o v
bind --user super-o v
# open Mac Finder
bind --user -M insert alt-super-o "open ."
bind --user alt-super-o "open ."

# nice consistent set of clearing and reloading shortcuts
## just reload a fresh sesh with pretty output, keep output on screen
bind --user -M insert super-e "fresh -r"
bind --user -M visual super-e "fresh -r"
bind --user super-e "fresh -r"
## just clear the screen (ctrl+l -- this is fish default, but we want to use our 'fresh' function)
bind --user -M insert ctrl-e "fresh -c; commandline -f repaint"
bind --user -M visual ctrl-e "fresh -c; commandline -f repaint"
bind --user ctrl-e "fresh -c; commandline -f repaint"
## clear *and* fresh for a so fresh, so clean session (shift+super+l)
bind --user -M insert ctrl-super-e "fresh; commandline -f repaint"
bind --user -M visual ctrl-super-e "fresh; commandline -f repaint"
bind --user ctrl-super-e "fresh; commandline -f repaint"

# TODO: figure out the right command here to emulate up/down behavior
# not sure this is exactly the ideal binding, but i want j/k history search for sure
# bind --user -M insert alt-k history-search-backwards
# bind --user -M insert alt-j history-search-forward
