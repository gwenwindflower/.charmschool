# Core environment variables that should be available to all processes

# rather than have the default universal fish_user_paths variable,
# we instantiate it as an exported global variable here
# this allows us to use fish's smart `fish_add_path` function to
# keep the path tidy (it avoids duplicates, prepends additions automatically,
# and prepends the entire variable onto the system PATH automatically as well)
# CONVERSELY - if this is used with the standard universal variable
# then mistakes, old paths, unused things, etc can accumulate over time and cause confusion
# it's less maintenance and easier to reason about if you just construct it as a global per session
set -e fish_user_paths
set -gx fish_user_paths $HOME/.local/bin
fish_add_path -g $HOME/.local/bin

set -gx EDITOR nvim
set -gx SHELL /usr/local/bin/fish
set -gx TEMP /tmp
set -gx TERM xterm-256color

# set a handy env var for DRY, flexible pointer to dev projects home dir
set -gx PROJECTS $HOME/dev
set -gx OBSIDIAN_HOME $HOME/Library/Mobile\ Documents/iCloud~md~obsidian/Documents
set -gx OBSIDIAN_DEFAULT_VAULT $OBSIDIAN_HOME/girlOS

# TODO: move this into agent docs or context

# moor gives us nice 'smart' search/filter in pager
# bat will also use it as pager for paged output
# *NB*: bat's auto-paging is pretty simple actually
# it just always sends to pager (if --paging=auto, the default, or 'always'), 
# but for less it also sends the 'quit-if-one-screen' option (among others)
# so it appears to only page for larger output when 'auto' is set
# we have to manually set that for moor, but
# this means that bat's --paging=[auto|always] options 
# don't work essentially, removing this from moor = 'always',
# adding it = 'auto'
# we *can* turn off paging all together from bat with --paging=never though
# moor will add a duplicate row of line numbers for bat input,
# and we don't need line numbers for stuff like man pages, so we turn them off
# lastly, moor's status bar is weirdly ugly because it needs to be
# compatible with even the most basic terminals, so we turn it off
# both can be toggled with <- (line numbers) and = (status bar) if needed
set -gx PAGER /usr/local/bin/moor
set -gx MOOR "\
--quit-if-one-screen \
--wrap \
--no-linenumbers \
--no-statusbar \
--style=catppuccin-frappe \
--statusbar=bold \
"
# this lets use the nice bat > moor combo
# for man pages as well, which keeps lovely
# Catppuccin Frappe themeing consistent
# and good search :)
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# set XDG config directory to *nix-y standards, for various tools
# this is my personal preference, versus the below re Application Support
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_STATE_HOME $HOME/.local/state
set -gx XDG_CACHE_HOME $HOME/.cache

set -gx TMUX_PLUGIN_MANAGER_PATH $HOME/.config/tmux/plugins
# a lot of tools use this location for macOS-specific configuration
# it is technically correct! because of this, it is what the `dirs` Rust crate returns
# for the macOS config dir - so Rust-based tools particularly often expect this
# but really any builder who is more...stringent (one might say pedantic) about
# the 'correct' place for tool/app configs on macOS will use this by default
# my preference is to leave GUI app configs here, but reconfigure terminal-based tools
# to the above $XDG_CONFIG_HOME location (~/.config) if i can
# this mirrors my dotfiles' semantic distinction between 'apps' and 'tools' (GUI vs terminal)
set -gx MACOS_CONFIG_HOME $HOME/Library/Application Support

# tldr client (tlrc) config file location 
# defaults to be in $MACOS_CONFIG_HOME, but per the comments on that env var,
# we can redirect with this env var
set -gx TLRC_CONFIG $HOME/.config/tlrc/tlrc.toml

set -gx OBSIDIAN_HOME $HOME/Library/Mobile\ Documents/iCloud~md~obsidian/Documents
# Private environment variables
if test -f ~/.env
    source ~/.env
end
