# Set terminal environment variables
set -x -g EDITOR nvim
set -x -g SHELL /opt/homebrew/bin/fish
set -x -g TERM xterm-256color
set -x -g XDG_CONFIG_HOME $HOME/.config
set -x -g LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/dev/catppuccin-lazygit-themes/themes-mergable/frappe/sky.yml"

# Set tooling home directory environment variables
set -x -g GO_HOME $(go env GOPATH)
set -x -g PNPM_HOME $HOME/Library/pnpm
set -x -g BUN_INSTALL $HOME/.bun
set -x -g PYENV_ROOT $HOME/.pyenv

# Homebrew environment setup
# I have one Mac Silicon and one Intel Mac so I have to check both places
if type -q brew
    eval (brew shellenv)
else if test -d /opt/homebrew/bin
    eval (/opt/homebrew/bin/brew shellenv)
else if test -d /usr/local/homebrew/bin
    eval (/usr/local/homebrew/bin/brew shellenv)
else
    echo "Brew doesn't seem to be installed"
end

# Ensure that Fisher is installed
if not functions -q fisher
    echo "Installing Fisher..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
end

# Set PATH
set -g -x PATH \
    /opt/homebrew/bin \
    $HOMEBREW_PREFIX/opt/postgresql@16/bin \
    $HOME/.local/bin \
    $GO_HOME/bin \
    $PNPM_HOME \
    $BUN_INSTALL/bin \
    $PYENV_ROOT/bin \
    $HOME/.poetry/bin \
    $HOME/.gem/ruby/2.6.0/bin \
    /Applications/SnowSQL.app/Contents/MacOS \
    /Applications/Postgres.app/Contents/Versions/latest/bin \
    $PATH

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

# Load private environment variables
source $HOME/.env.fish
