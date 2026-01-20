# This file allows setting flags before any plugins are loaded
# Because plugins are sourced alphabetically from conf.d
# *before* config.fish - any plugin-specific config has to be here

# forgit's shell aliases clash with the extremely comprehensive
# git fish plugin, which is quite helpful, so instead of these
# we have git subcommand aliases set in gitconfig like `git fga`, `git fgct`, etc.
# I then have my own abbreviations for those commands in the `gfg` namespace
# `gfga`, `gfgct`, etc
set -gx FORGIT_NO_ALIASES 1

set -gx FORGIT_GLO_FORMAT "%C(green)%h %C(reset)%d %s %C(magenta)%cr%C(reset)"
