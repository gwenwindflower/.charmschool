# Orbstack setup (lighter, faster Docker Desktop alternative for macOS)
# They want you to do this:
# `source ~/.orbstack/shell/init2.fish`
# which just adds ~/.orbstack/bin to PATH, thus we do this more cleanly here
# Orbstack doesn't use this env var, but it's helpful to me for consistency and convenience
set -gx ORBSTACK_HOME ~/.orbstack
fish_add_path $ORBSTACK_HOME/bin
