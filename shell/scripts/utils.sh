#         ___
#        /\_ \    __
#    __  \//\ \  /\_\     __      ____     __    ____
#  /'__`\  \ \ \ \/\ \  /'__`\   /',__\  /'__`\ /',__\
# /\ \L\.\_ \_\ \_\ \ \/\ \L\.\_/\__, `\/\  __//\__, `\
# \ \__/.\_\/\____\\ \_\ \__/.\_\/\____/\ \____\/\____/
#  \/__/\/_/\/____/ \/_/\/__/\/_/\/___/  \/____/\/___/

# shell and editor
alias vi="nvim"
alias vim="nvim"
alias ss="z ~/dev/charm-school/ && nvim zshrc"
alias oo="z ~/.oh-my-zsh/ && nvim"
alias rr="exec $SHELL"
alias e="clear"
alias er="clear && exec $SHELL"
alias s="z"

# rotz dotfile tool
alias di="rotz install"
alias dl="rotz link"
alias dli="rotz link && rotz install"

# git tools
alias gdto="git difftool"
alias gdtoc="git difftool --cached"
alias gz="lazygit"
alias gho="gh repo view -w"
alias ghd="gh dash"
alias gdc="forgit::diff --cached"
alias gcmm="meteor"

# dbt and data
alias dbtc="${HOMEBREW_PREFIX}/bin/dbt"
alias dbtp="vi ~/.dbt/profiles.yml"
alias db="dbtc build"
alias dbs="dbtc build -s"
alias dt="dbtc test"
alias dts="dbtc test -s"
alias dr="dbtc run"
alias drs="dbtc run -s"
alias dp="dbtc parse"
alias dbx="databricks"

# media and misc
alias af="als"
alias bri="brew update && brew upgrade && brew install"
alias bu="brew update && brew upgrade"
alias cat="bat"
alias cc="cookiecutter"
alias kb="cd ~/qmk_firmware/keyboards/splitkb/kyria/keymaps/gwenwindflower && vi"
alias ddb="duckdb"
alias ki="kitty +kitten icat"
alias wthr="curl wttr.in/chicago"
alias moon="pyphoon"
alias moonl="pyphoon-lolcat"
alias pu="cmus-remote --pause"
alias spotify="spotify_player"
alias pg="pgcli"
alias yt="youtube"
alias ytdl="youtube-dl"
alias gdl="gallery-dl"
alias ppl="web_search perplexity"
alias t="task"
alias mm="macchina"

# python
alias p="python3"
alias python="python3"
alias venv="uv venv .venv"
alias va="source .venv/bin/activate"
alias da="deactivate"
alias venva="venv && va"
alias pi="uv pip"
alias pir="uv pip install -r"
alias pirr="uv pip install -r requirements.txt"
alias pc="uv pip compile requirements.in -o requirements.txt"
alias pcd="uv pip compile dev-requirements.in -o dev-requirements.txt"
alias psy="uv pip sync requirements.txt"
alias psyd="uv pip sync requirements.txt dev-requirements.txt"
alias pcy="pc && psy"
alias pcyd="pc && pcd && psyd"
alias piup="uv pip install --upgrade pip"
alias vpi="venva && piup && pirr"
alias vpci="venva && piup && pc && pirr"
alias pdot="uv pip install -e ."
alias pcydd="pcyd && pdot"
alias pyt="pytest"

# go
alias gorm="go run main.go"
alias gord="go run ."
alias gotv="go test -v"

# eza
alias l="eza -l"
alias ls="eza"
alias ll="eza -l"
alias la="eza -a"
alias lla="eza -la"
alias lg="eza -laG --git"
alias lt="eza --tree"

# frontend
alias ni="pnpm i"
alias nu="pnpm up"
alias nd="pnpm dev"
alias nb="pnpm build"
alias bi="bun install"
alias bd="bun dev"
alias ad="astro dev"

#    ___                         __
#  /'___\                       /\ \__  __
# /\ \__/  __  __    ___     ___\ \ ,_\/\_\    ___     ___     ____
# \ \ ,__\/\ \/\ \ /' _ `\  /'___\ \ \/\/\ \  / __`\ /' _ `\  /',__\
#  \ \ \_/\ \ \_\ \/\ \/\ \/\ \__/\ \ \_\ \ \/\ \L\ \/\ \/\ \/\__, `\
#   \ \_\  \ \____/\ \_\ \_\ \____\\ \__\\ \_\ \____/\ \_\ \_\/\____/
#    \/_/   \/___/  \/_/\/_/\/____/ \/__/ \/_/\/___/  \/_/\/_/\/___/

# function to make a directory in a python package project with __init__.py
function pd() {
	mkdir $1 && touch $1/__init__.py
}

# functions for wrapping dbt codegen
source ~/scripts/dbt_scaffolding.sh

# functions for wrapping gh CLI copilot commands
source ~/scripts/gh_copilot.sh

# open yazi and exit to directory navigated to
function ff() {
	tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# function to get code suggestions from Gemma
function mc() {
	local file_name=$1
	mods -m gemma "How would you improve the code in this file?" <$file_name | glow
}

# function to get a code explanation from Gemma
function mp() {
	mods -m gemma "Can you explain this code?" <<<"$(pbpaste)" | glow
}

# function to copy a enviornment variable to the clipboard
function cpenv() {
	printenv $1 | pbcopy
}

# function to time zsh startup
function timezsh() {
	shell=${1-$SHELL}
	for i in $(seq 1 10); do
		/usr/bin/time $shell -i -c exit
	done
}

function go_cover() {
	go test -coverprofile=coverage.out
	go tool cover -html=coverage.out
}

# Query a dbt saved query
# Takes one argument, the name of the saved query
function dsq() {
	dbt parse && dbt sl query --limit=10 --saved-query $1
}
# Query a dbt metric
# Takes 3 arguments, the name of the metric, the group-by, and the filter
# It assumes you want to order by the group-by
function dsm() {
	if [ -z "$3" ]; then
		dbt parse && dbt sl query --metrics $1 --group-by $2 --order-by $2
	else
		dbt parse && dbt sl query --metrics $1 --group-by $2 --order-by $2 --where $3
	fi
}

function v() {
	if [[ -z $1 ]]; then
		nvim
	else
		z $1 && nvim
	fi
}
