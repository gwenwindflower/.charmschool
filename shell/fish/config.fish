# Set terminal environment variables
## Set default editor to nvim
set -x -g EDITOR nvim
## Set default shell to fish
set -x -g SHELL /opt/homebrew/bin/fish
## Set default terminal to xterm-256color for better color support
set -x -g TERM xterm-256color
## Set XDG config directory to ~/.config, for various tools
set -x -g XDG_CONFIG_HOME $HOME/.config
## Set lazygit config file
set -x -g LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/dev/catppuccin-lazygit-themes/themes-mergable/frappe/mauve.yml"

# Set tooling home directory environment variables
set -x -g GO_HOME $(go env GOPATH)
set -x -g PNPM_HOME $HOME/Library/pnpm
set -x -g BUN_INSTALL $HOME/.bun
set -x -g PYENV_ROOT $HOME/.pyenv

# Set PATH
set -x -g PATH \
    /opt/homebrew/bin \
    $HOMEBREW_PREFIX/opt/postgresql@16/bin \
    $HOME/.local/bin \
    $GO_HOME/bin \
    $PNPM_HOME \
    $BUN_INSTALL/bin \
    $PYENV_ROOT/bin \
    $HOME/.poetry/bin \
    $PATH

# Setup Homebrew environment
eval (brew shellenv)

# Initialize Starship and Zoxide
starship init fish | source
zoxide init fish | source

# Initialize forgit
[ -f $HOMEBREW_PREFIX/share/forgit/forgit.plugin.fish ]; and source $HOMEBREW_PREFIX/share/forgit/forgit.plugin.fish

# Load cargo and rust environment
source $HOME/.cargo/env.fish

# Load my fish aliases
source $HOME/.config/fish/aliases.fish

# Configure tools
source $HOME/.config/fish/tool_config.fish

# Load Google Cloud SDK
source $HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc

# Load private environment variables
source $HOME/.env.fish

# Ensure that Fisher is installed
if not functions -q fisher
    echo "Installing Fisher..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
end

# Enable vi mode by default
fish_vi_key_bindings

fish_add_path /Users/winnie/.spicetify
