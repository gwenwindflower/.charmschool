#!/bin/sh
# pane-icon.sh — resolve a tmux pane command to a Nerd Font icon
# Called by tmux via #() in window-status-format / window-status-current-format.
# Usage: pane-icon.sh <pane_current_command> [hint_cmd]
#
# When @hint_cmd is set (via tmux_hint), it takes priority over
# pane_current_command. This handles wrappers like `opo` (where tmux
# sees "op") and pager pipelines like `man` (where tmux sees "less").

cmd="$1"
hint="$2"

# @hint_cmd is the authoritative signal when set
if [ -n "$hint" ]; then
  cmd="$hint"
fi

case "$cmd" in
# Shells
fish | zsh | bash | tmux) icon="" ;;
# Tools
nvim | vim) icon="" ;;
yazi) icon="󰀶" ;;
git | lazygit) icon="" ;;
gh) icon="" ;;
man) icon="" ;;
glow | moor | less | bat | cat) icon="" ;;
ls | lsd | eza | exa) icon="󰙅" ;;
make | cmake | task) icon="" ;;
docker | lazydocker | orbstack) icon="" ;;
k9s | kubectl) icon="" ;;
htop | btm | top) icon="" ;;
# AI
claude | codex | crush | opencode) icon="󱜚" ;;
# Network
mitmproxy) icon="" ;;
ssh) icon="" ;;
# Languages
python | ipython | uv | ruff | marimo | jupyter)
  icon=""
  ;;
node | npm | pnpm) icon="" ;;
deno) icon="" ;;
bun) icon="" ;;
cargo) icon="" ;;
go) icon="" ;;
ruby | irb | pry | rails)
  icon=""
  ;;
lua | luajit) icon="" ;;
# Data
pgcli | postgresql) icon="" ;;
duckdb) icon="󰇥 " ;;
sqlite | sqlite3) icon="" ;;
dbt) icon="" ;;
# Media
cmus) icon=" " ;;
spotify_player) icon="" ;;
# Fallback
*) icon="" ;;
esac

printf ' %s ' "$icon"
