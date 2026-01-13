# This file allows setting flags before any plugins are loaded
# Because plugins are sourced alphabetically from conf.d
# *before* config.fish - any plugin-specific config has to be here

# I prefer to use forgit as a git subcommand
# and define aliases in gitconfig
set -gx FORGIT_NO_ALIASES 1

set -gx FORGIT_GLO_FORMAT "%C(green)%h %C(reset)%d %s %C(magenta)%cr%C(reset)"
