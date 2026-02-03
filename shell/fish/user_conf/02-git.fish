# Configured in ./git/gitconfig -> ~/.config/git/.gitconfig
# but some tools look for this env var and git does not it set it by default
# even when configured in the global git config file
set -gx GIT_PAGER delta

set -gx DFT_DISPLAY inline

# This allows forgit to be accessed as a git subcommand
fish_add_path $FORGIT_INSTALL_DIR/bin
