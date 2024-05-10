# Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"
# *•.¸♡ *•.¸♡*•.¸♡*•.¸♡*•.¸♡*•.¸♡*•.¸♡ extra special zsh config ♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*
# The `.zprofile` file is a configuration file for the Z shell (Zsh) that is
# sourced during login. It is similar to the `.profile` file in Bash. The
# `.zprofile` file is used to set environment variables, define aliases, and
# execute commands that should run when you log in to the shell. Other related
# Zsh configuration files include `.zshrc`, which is sourced for each new
# interactive shell session, and `.zlogin`, which is sourced after `.zshrc`
# during login. The `.zprofile` file is typically used for setting up the
# initial environment, while `.zshrc` is used for interactive shell
# configuration and `.zlogin` for additional login-specific setup.
# *•.¸♡ *•.¸♡*•.¸♡*•.¸♡*•.¸♡*•.¸♡*•.¸♡ extra special zsh config ♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*

# Homebrew environment setup
# I have one Mac Silicon and one Intel Mac so I have to check both places
if command -v brew >/dev/null 2>&1; then
	eval "$(brew shellenv)"
elif [[ -d "/opt/homebrew/bin" ]]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -d "/usr/local/homebrew/bin" ]]; then
	eval "$(/usr/local/homebrew/bin/brew shellenv)"
else
	echo "Brew doesn't seem to be installed"
fi
#                  __     __
#                 /\ \__ /\ \
#  _____      __  \ \ ,_\\ \ \___
# /\ '__`\  /'__`\ \ \ \/ \ \  _ `\
# \ \ \L\ \/\ \L\.\_\ \ \_ \ \ \ \ \
#  \ \ ,__/\ \__/.\_\\ \__\ \ \_\ \_\
#   \ \ \/  \/__/\/_/ \/__/  \/_/\/_/
#    \ \_\
#     \/_/
## Constructing PATH

# We use a case statement to check if the path is already in the PATH
# If it is, we don't add it again. This is to prevent duplicates,
# which can cause build up sometimes.
function check_path() {
	case ":$PATH:" in
	*":$1:"*) ;;
	*) export PATH="$1:$PATH" ;;
	esac
}

# Dedupe PATH function
function dedupe_path() {
	typeset -U PATH
}

# Cargo and Rust env vars have their own script
source "${HOME}/.cargo/env"

# Postgres
check_path "${HOMEBREW_PREFIX}/opt/postgresql@16/bin"

# Poetry path
check_path "${HOME}/.poetry/bin"

# Various things like Pipx
check_path "${HOME}/.local/bin"

# Ruby Gems path
check_path "${HOME}/.gem/ruby/2.6.0/bin"

# Go path
GO_HOME="$(go env GOPATH)"
export GO_HOME
check_path "$GO_HOME/bin"

## pnpm path
export PNPM_HOME="/Users/winnie/Library/pnpm"
check_path "$PNPM_HOME"

# bun path
export BUN_INSTALL="${HOME}/.bun"
check_path "$BUN_INSTALL/bin"

# These make these GUI apps available from the terminal
# Snowflake CLI
check_path "/Applications/SnowSQL.app/Contents/MacOS"
# Postgres.app
check_path "/Applications/Postgres.app/Contents/Versions/latest/bin:"

# GCloud (it sets the PATH with these setup scripts so we don't do it explicity)
if [[ -f "${HOME}/google-cloud-sdk/path.zsh.inc" ]]; then source "${HOME}/google-cloud-sdk/path.zsh.inc"; fi

# pyenv
export PYENV_ROOT="${HOME}/.pyenv"
check_path "${PYENV_ROOT}/bin"

# dedupe PATH in case some sneaky duplicates have crept in
dedupe_path

export GRAVEYARD="${HOME}/.Trash" # Set rm-improved (`rip`) graveyard to MacOS Trash# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
