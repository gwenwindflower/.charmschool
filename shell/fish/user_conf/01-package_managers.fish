# Sets $HOMEBREW_PREFIX
brew shellenv fish | source
# Turn off Homebrew hints
set -gx HOMEBREW_NO_ENV_HINTS 1
# Useful for quick access to Mise stuff directly
set -gx MISE_INSTALLS $XDG_DATA_HOME/mise/installs/
