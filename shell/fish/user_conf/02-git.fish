# Configured in ./git/gitconfig -> ~/.config/git/.gitconfig
# but some tools look for this env var and git does not it set it by default
# even when configured in the global git config file
set -gx GIT_PAGER delta

set -gx DFT_DISPLAY inline

# forgit
if test -f $HOMEBREW_PREFIX/share/forgit/forgit.plugin.fish
    source $HOMEBREW_PREFIX/share/forgit/forgit.plugin.fish
end
# forgit's shell aliases clash with the extremely comprehensive
# git fish plugin, which is quite helpful, so instead of these
# we have git subcommand aliases set in gitconfig like `git fga`, `git fgct`, etc.
# I then have my own abbreviations for those commands in the `gfg` namespace
# `gfga`, `gfgct`, etc
set -gx FORGIT_NO_ALIASES 1
set -gx FORGIT_GLO_FORMAT "%C(green)%h %C(reset)%d %s %C(magenta)%cr%C(reset)"
# ctrl-d to drop stashes from the forgit stash show fzf viewer
set -gx FORGIT_STASH_FZF_OPTS '--bind="ctrl-d:reload(git stash drop $(cut -d: -f1 <<<{}) 1>/dev/null && git stash list)"'
# This allows forgit to be accessed as a git subcommand
fish_add_path $FORGIT_INSTALL_DIR/bin
