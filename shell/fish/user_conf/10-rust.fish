# Rust environment setup
# Rust installer does this automatically via installer script,
# by adding ~/.config/fish/conf.d/rustup.fish
# or having you `source $HOME/.cargo/env` in your config
# All those do is conditionally add $HOME/.cargo/bin to PATH if needed.
# I prefer to have control over when it executes, so I do it here

# For convenience
set -gx CARGO_HOME $HOME/.cargo
fish_add_path $CARGO_HOME/bin
