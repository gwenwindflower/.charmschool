set -gx BUN_INSTALL $HOME/.bun
fish_add_path $BUN_INSTALL/bin

set -gx PNPM_HOME $XDG_DATA_HOME/pnpm
fish_add_path $PNPM_HOME

set -gx DENO_HOME $XDG_DATA_HOME/deno
set -gx DENO_INSTALL_ROOT $DENO_HOME/bin
fish_add_path $DENO_HOME
fish_add_path $DENO_INSTALL_ROOT
