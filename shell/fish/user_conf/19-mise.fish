# See notes in shell/fish/user_conf/AGENTS.md about mise auto-activation
$HOMEBREW_PREFIX/bin/mise activate fish | source
# Not used by Mise, but useful for quick access to Mise stuff quickly
set -gx MISE_INSTALLS $XDG_DATA_HOME/mise/installs/
