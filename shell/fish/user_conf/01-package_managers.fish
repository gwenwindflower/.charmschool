# Sets $HOMEBREW_PREFIX, anything installed by Homebrew
# in subsequent files should be referenced via $HOMEBREW_PREFIX,
# not an absolute path,
# for the sake of DRYness, as this is different across machines
/usr/local/bin/brew shellenv fish | source
# Turn off Homebrew hints
set -gx HOMEBREW_NO_ENV_HINTS 1
