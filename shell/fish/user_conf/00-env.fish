# Core environment variables that should be available to all processes

#  PATH
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

#  Homebrew
# Sets $HOMEBREW_PREFIX, required for almost everything following
# because it differes between machines
# which is why we set it here instead of its own config file
brew shellenv fish | source
set -gx HOMEBREW_NO_ENV_HINTS 1

#  Terminal and Shell
set -gx SHELL $HOMEBREW_PREFIX/bin/fish

#  GPG
set -gx GPG_TTY (tty)

#  SSH
# If we don't set SSH_AUTH_SOCK then we have to set it in gitconfig
# if we want to sign commits with op ssh keys
# that path will break on linux devcontainers (no GUI app, different filesystem structure)
# so, instead of any hardcoding, we set it in an env var *only* on macOS
# letting it be set dynamically by ssh agent forwarding when ssh-ing into VMs
if uname | grep -q Darwin
    set -gx SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
end

#   XDG
# setting these explicitly makes it easier to switch between macOS and Linux VMs
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_STATE_HOME $HOME/.local/state
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_CONFIG_HOME $HOME/.config
# I prefer the above for user config
# as opposed to the more 'technically correct' but buried location:
# `~/Library/Application Support`
# Most GUI tools will be there though, and some command line tools insist on it
# so we set an 'unofficial' env var for it to make it easy to reference
set -gx MACOS_CONFIG_HOME $HOME/Library/Application Support
# For tools and runtimes that look for $TEMP instead of $TMPDIR
set -gx TEMP $TMPDIR

#   pager, docs, man
# This is a nice cascade that lets us get bat
# syntax highlighting as much as possible,
# we use moor to page through longer content
# processed by bat, by setting BAT_PAGER
# then send everything to bat as our global PAGER default
## First, we set moor
## --quit-if-one-screen: preserves bat's 'auto-paging' (see user_conf README)
## --no-linenumbers: bat already shows line numbers, press left to see moor's lines if needed
## --style to keep our theme (uses Chroma themes)
set -gx MOOR "\
--quit-if-one-screen \
--wrap \
--no-linenumbers \
--style=catppuccin-frappe \
"
## Then, tell bat to use moor instead of less
set -gx PAGER $HOMEBREW_PREFIX/bin/moor
## Finally, set global default pager to bat
## so short content just pretty bat output
## and long content gets the bat->moor combo to add nice search
set -gx PAGER $HOMEBREW_PREFIX/bin/bat
# we can use the nice bat->moor combo for man pages as well
# which keeps our nice theming and search consistent
# esoteric 'col' command because man pages are an old construct
# just says 'do requisite typesetting -> feed into bat's man mode'
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
# tldr client (tlrc) config file location 
# defaults to be in $MACOS_CONFIG_HOME, but we prefer XDG_CONFIG_HOME for terminal tools
set -gx TLRC_CONFIG $XDG_CONFIG_HOME/tlrc/tlrc.toml

#  tmux
# this can be inconsistent if not set explicitly,
# if this doesn't exist, tpm will default to ~/.tmux/plugins,
# so in my effort to avoid package managers polluting my home directory
# with .<tool> config directories we set it here so even on new machines it will be correct
set -gx TMUX_PLUGIN_MANAGER_PATH $XDG_CONFIG_HOME/tmux/plugins
set -gx TMUX_PLUGIN_MANAGER_INSTALL $HOMEBREW_PREFIX/opt/tpm/share/tpm

set -gx OP_ENV_DIR $XDG_CONFIG_HOME/op/environments

#  Project Bookmarks
## handy env vars for pointing commands to commonly used dirs
## this way if I restructure my projects I don't have to rewrite code
## just update these DRY env vars
set -gx PROJECTS $HOME/dev
set -gx PROJECTS_AGENTS $HOME/dev/01_agent-workbench
set -gx PROJECTS_SCRIPTS $HOME/dev/02_spellbook
set -gx PROJECTS_SANDBOX $HOME/dev/03_sandboxes
set -gx PROJECTS_FORKS $HOME/dev/04_forks
set -gx PROJECTS_UTILS $HOME/dev/05_utils
set -gx PROJECTS_ARCHIVE $HOME/dev/zzz/
set -gx PROJECTS_GRAVEYARD $HOME/dev/zzz-rip
