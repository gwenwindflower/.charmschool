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

# Sets $HOMEBREW_PREFIX, anything installed by Homebrew
# in subsequent files should be referenced via $HOMEBREW_PREFIX,
# not an absolute path,
# for the sake of DRYness, as this is different across machines
brew shellenv fish | source
# Turn off Homebrew hints
set -gx HOMEBREW_NO_ENV_HINTS 1

set -gx SHELL $HOMEBREW_PREFIX/bin/fish
set -gx TEMP /tmp
set -gx TERM xterm-256color
set -gx SSH_AUTH_SOCK $HOME/.1password/agent.sock

# handy env vars for DRY, flexible pointers
# to notes and dev projects
set -gx PROJECTS $HOME/dev
set -gx OBSIDIAN_HOME "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
set -gx OBSIDIAN_DEFAULT_VAULT $OBSIDIAN_HOME/girlOS

set -gx PAGER $HOMEBREW_PREFIX/bin/moor
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

# this can be inconsistent if not set explicitly,
# if this doesn't exist, tpm will default to ~/.tmux/plugins,
# so in my effort to avoid package managers polluting my home directory
# with .<tool> config directories we set it here so even on new machines it will be correct
set -gx TMUX_PLUGIN_MANAGER_PATH $XDG_CONFIG_HOME/tmux/plugins
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
# defaults to be in $MACOS_CONFIG_HOME, but we prefer XDG_CONFIG_HOME for terminal tools
set -gx TLRC_CONFIG $XDG_CONFIG_HOME/tlrc/tlrc.toml

set -gx OP_ENV_DIR $XDG_CONFIG_HOME/op/environments
