# These tools respect these env vars, and I prefer this to their macOS defaults
# which are in ~/Library/Application\ Support
set -gx BUN_INSTALL $HOME/.bun
fish_add_path $BUN_INSTALL/bin
set -gx PNPM_HOME $HOME/.pnpm
fish_add_path $PNPM_HOME
set -gx DENO_HOME $HOME/.deno
fish_add_path $DENO_HOME/bin

if status is-interactive
    # --use-on-cd allows automatic switching when entering a directory with a .nvmrc or .node-version file
    # This edits PATH directly, sets a bunch of env vars, and add the dir switching hook
    # Would prefer to manually fish_add_paths it to $fish_user_paths, but this is fine
    fnm env --use-on-cd --corepack-enabled --shell fish | source
end
