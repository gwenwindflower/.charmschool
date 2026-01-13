fish_config theme choose Catppuccin\ Frappe

# Null out fish greeting
set -gx fish_greeting

# Set the theme for bat
# This is also set via config now but /shrug
# might come in handy some time
set -gx BAT_THEME Catppuccin-Frappe

# Set theme for tools that use LS_COLORS (fd, tree, lsd etc)
# vivid is a little CLI that generates the arcane ls colors format from 
# human-readable themes
set -gx LS_COLORS (vivid generate catppuccin-frappe)
