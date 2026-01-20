# Core environment variables that should be available to all processes

# rather than have the default universal fish_user_paths variable,
# we instantiate it as an exported global variable here
# this allows us to use fish's smart `fish_add_path` function to
# keep the path tidy (it avoids duplicates, prepends additions automatically,
# and prepends the entire variable onto the system PATH automatically as well)
# CONVERSELY - if this is used with the standard universal variable
# then mistakes, old paths, unused things, etc can accumulate over time and cause confusion
# it's less maintenance and easier to reason about if you just construct it as a global per session
if test fish_user_paths
    fish_add_path $HOME/.local/bin
else
    set -gx fish_user_paths $HOME/.local/bin
end

set -gx EDITOR nvim
set -gx SHELL /usr/local/bin/fish
set -gx TEMP /tmp
set -gx TERM xterm-256color

# set a handy env var for DRY, flexible pointer to dev projects home dir
set -gx PROJECTS $HOME/dev

# moor gives us nice 'smart' search/filter in pager
# bat will also use it as pager for paged output
# nb: bat's auto-paging is pretty simple actually
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

# set XDG config directory to ~/.config, for various tools
# this is my personal preference, it's more Unix-y, cleaner, more convenient
set -gx XDG_CONFIG_HOME $HOME/.config

# a lot of tools use this location for macOS-specific configuration
# it is technically correct! because of this, it is what the `dirs` Rust crate returns
# for the macOS config dir - so Rust-based tools particularly often expect this
# but really any builder who is more...stringent (one might say pedantic) about
# the 'correct' place for tool/app configs on macOS will use this by default
# my preference is to leave GUI app configs here, but reconfigure terminal-based tools
# to the above $XDG_CONFIG_HOME location (~/.config) if i can
# this mirrors my dotfiles' semantic distinction between 'apps' and 'tools' (GUI vs terminal)
set -gx MACOS_CONFIG_HOME $HOME/Library/Application Support

# one of those tools mentioned above is Simon Willison's tool `llm`
set -gx LLM_USER_PATH $XDG_CONFIG_HOME/llm

# Configured in ./git/gitconfig -> ~/.config/git/.gitconfig
# but some tools look for this env var and git does not it set it by default
# even when configured in the global git config file
set -gx GIT_PAGER delta

# Makes sure our Homebrew-installed mise gets activated in fish shells via
# vendor conf.d rather than calling `mise activate` in fish config directly
set -gx MISE_FISH_AUTO_ACTIVATE 1

# Temporary to get Claude Code's new LSP tools working
set -gx ENABLE_LSP_TOOL 1
# tldr client (tlrc) config file location 
# defaults to be in $MACOS_CONFIG_HOME, but per the comments on that env var,
# we can redirect with this env var
set -gx TLRC_CONFIG $HOME/.config/tlrc/tlrc.toml

# This allows forgit to be accessed as a git subcommand
fish_add_path $FORGIT_INSTALL_DIR/bin

set -gx DFT_DISPLAY inline

# Private environment variables
if test -f ~/.env
    source ~/.env
end
