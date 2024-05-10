# Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
#                                             WELCOME TO
#          ,,                                                                 ,,                           ,,
#        `7MM                                                               `7MM                         `7MM
#          MM                                                                 MM                           MM
#  ,p6"bo  MMpMMMb.   ,6"Yb.  `7Mb,od8 `7MMpMMMb.pMMMb.      ,pP"Ybd  ,p6"bo  MMpMMMb.  ,pW"Wq.   ,pW"Wq.  MM
# 6M'  OO  MM    MM  8)   MM    MM' "'   MM    MM    MM      8I   `" 6M'  OO  MM    MM 6W'   `Wb 6W'   `Wb MM
# 8M       MM    MM   ,pm9MM    MM       MM    MM    MM      `YMMMa. 8M       MM    MM 8M     M8 8M     M8 MM
# YM.    , MM    MM  8M   MM    MM       MM    MM    MM      L.   I8 YM.    , MM    MM YA.   ,A9 YA.   ,A9 MM
#  YMbmd'.JMML  JMML.`Moo9^Yo..JMML.   .JMML  JMML  JMML.    M9mmmP'  YMbmd'.JMML  JMML.`Ybmd9'   `Ybmd9'.JMML.

# *•.¸♡ *•.¸♡*•.¸♡*•.¸♡*•.¸♡*•.¸♡*•.¸♡ extra special zsh config ♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*
# The `.zshrc` file is a configuration file for the Z shell (Zsh) that is
# sourced for each new interactive shell session. It is used to define aliases,
# functions, options, and other interactive shell behavior. The `.zshrc` file
# is where you typically customize your shell prompt, set up command line
# completions, define key bindings, and add other interactive features to your
# shell. It is executed every time you start a new interactive shell session,
# such as opening a new terminal window or running `zsh` from the command line.
# The `.zshrc` file is the main configuration file for interactive Zsh usage.
# *•.¸♡ *•.¸♡*•.¸♡*•.¸♡*•.¸♡*•.¸♡*•.¸♡ extra special zsh config ♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*♡¸.•*

# Toolfor profiling zsh startup
zmodload zsh/zprof

# load z move
autoload -U zmv

#        ___
#       /\_ \                     __
#  _____\//\ \    __  __     __  /\_\     ___      ____
# /\ '__`\\ \ \  /\ \/\ \  /'_ `\\/\ \  /' _ `\   /',__\
# \ \ \L\ \\_\ \_\ \ \_\ \/\ \L\ \\ \ \ /\ \/\ \ /\__, `\
#  \ \ ,__//\____\\ \____/\ \____ \\ \_\\ \_\ \_\\/\____/
#   \ \ \/ \/____/ \/___/  \/___L\ \\/_/ \/_/\/_/ \/___/
#    \ \_\                   /\____/
#     \/_/                   \_/__/
#

# OMZ plugins
plugins=(
	aliases
	brew
	bun
	colored-man-pages
	gh
	git
	golang
	nvm
	pip
	python
	sudo
)

# Lazy load nvm
zstyle ':omz:plugins:nvm' lazy yes
zstyle ':omz:plugins:nvm' lazy-cmd bun eslint prettier typescript
# if there is an .nvmrc file in the current directory,
# autoload that node version with nvm when a node-related command is run
zstyle ':omz:plugins:nvm' autoload yes
# we can do this silently as the node env is displayed nicely in starship prompt
zstyle ':omz:plugins:nvm' silent-autoload yes

# Initialize oh-my-zsh
source "${ZSH}/oh-my-zsh.sh"

# Enable custom zsh plugins
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$(brew --prefix)/share/forgit/forgit.plugin.zsh"

#                                   /\_ \           /\ \__  __
#   ___     ___     ___ ___    _____\//\ \       __ \ \ ,_\/\_\     ___     ___      ____
#  /'___\  / __`\ /' __` __`\ /\ '__`\\ \ \    /'__`\\ \ \/\/\ \   / __`\ /' _ `\   /',__\
# /\ \__/ /\ \L\ \/\ \/\ \/\ \\ \ \L\ \\_\ \_ /\  __/ \ \ \_\ \ \ /\ \L\ \/\ \/\ \ /\__, `\
# \ \____\\ \____/\ \_\ \_\ \_\\ \ ,__//\____\\ \____\ \ \__\\ \_\\ \____/\ \_\ \_\\/\____/
#  \/____/ \/___/  \/_/\/_/\/_/ \ \ \/ \/____/ \/____/  \/__/ \/_/ \/___/  \/_/\/_/ \/___/
#                                \ \_\
#                                 \/_/
# Completions
# Load homebrew completions
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
if [ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]; then source "${HOME}/google-cloud-sdk/completion.zsh.inc"; fi
# Load oh-my-zsh completions
FPATH="${ZSH_COMP}:${FPATH}"
# Initialize completions
autoload -Uz compinit && compinit
# clean up stale zcompdump files
zcompdump_clean() {
	local dump="${HOME}/.zcompdump"
	[[ "$dump" -nt "$dump.zwc" ]] || rm -f "$dump.zwc"
}
zcompdump_clean
# Initialize zcompdump
compinit -d "${HOME}/.zcompdump"
#  __                    ___
# /\ \__                /\_ \
# \ \ ,_\    ___     ___\//\ \      ____
#  \ \ \/   / __`\  / __`\\ \ \    /',__\
#   \ \ \_ /\ \L\ \/\ \L\ \\_\ \_ /\__, `\
#    \ \__\\ \____/\ \____//\____\\/\____/
#     \/__/ \/___/  \/___/ \/____/ \/___/
#

# Atuin magical shell history
eval "$(atuin init zsh)"

# Starship prompt
eval "$(starship init zsh)"

# Zoxide, a Rust replacement for z, which is a replacement for cd
eval "$(zoxide init zsh)"

# pyenv for managing python versions
eval "$(pyenv init -)"

# fzf
eval "$(fzf --zsh)"

#   __     __
# /\ \__ /\ \
# \ \ ,_\\ \ \___       __     ___ ___       __     ____
#  \ \ \/ \ \  _ `\   /'__`\ /' __` __`\   /'__`\  /',__\
#   \ \ \_ \ \ \ \ \ /\  __/ /\ \/\ \/\ \ /\  __/ /\__, `\
#    \ \__\ \ \_\ \_\\ \____\\ \_\ \_\ \_\\ \____\\/\____/
#     \/__/  \/_/\/_/ \/____/ \/_/\/_/\/_/ \/____/ \/___/
# Theming for tools
# Color theme for `bat` which I always forget to use
# so I alias it to `cat` in the aliases section
export BAT_THEME="Catppuccin-frappe"

# Color theme for `fzf` also Catppuccin Frappe
export FZF_DEFAULT_OPTS=" \
--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#f4b8e4 \
--color=fg:#c6d0f5,header:#f4b8e4,info:#ca9ee6,pointer:#f2d5cf \
--color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#f4b8e4"

# bun completions
[ -s "/Users/winnie/.bun/_bun" ] && source "/Users/winnie/.bun/_bun"

# Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
