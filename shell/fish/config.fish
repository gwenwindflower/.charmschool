# Set terminal environment variables
set -x -g EDITOR nvim
set -x -g SHELL /opt/homebrew/bin/fish
set -x -g TERM xterm-256color

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

# Load private environment variables
source $HOME/.env.fish

# Set the theme for bat
set -x -g BAT_THEME Catppuccin-frappe

# Set the theme for fzf
set -Ux FZF_DEFAULT_OPTS "\
--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
--color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284"

# fzf integration config
fzf_configure_bindings --directory=\cf
set fzf_directory_opts --bind 'ctrl-o:execute(nvim {} &> /dev/tty),ctrl-n:preview-down,ctrl-p:preview-up'
set fzf_fd_opts --hidden
set fzf_preview_file_cmd bat --style=numbers,changes --color always
set fzf_preview_dir_cmd eza --all --color=always
set fzf_diff_highlighter delta --paging=never --width=20

# Set the the theme for tools that use LS_COLORS (fd, tree, etc)
set -Ux LS_COLORS (vivid generate catppuccin-frappe)
