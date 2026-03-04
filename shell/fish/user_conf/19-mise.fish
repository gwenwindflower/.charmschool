# We re-add Homebrew's primary bin dir with 'move' here to bring it to the front
# of $fish_user_paths just before we add `mise`
# which needs to come first (and thus be added last)
# we do this some Homebrew install of tools that get duplicated (primarily by mason.nvim)
# are first in the path, as they are easier to manage
# e.g. mason installs 'deno' because it contains its own language server,
# but Homebrew's deno is easier to manage and upgrade
# this way we're never wondering why a Homebrew tool is showing an unexpected version
fish_add_path -g -m $HOMEBREW_PREFIX/bin
# See notes in shell/fish/user_conf/AGENTS.md about mise auto-activation
$HOMEBREW_PREFIX/bin/mise activate fish | source
# Not used by Mise, but useful for quick access to Mise stuff quickly
set -gx MISE_INSTALLS $XDG_DATA_HOME/mise/installs/
