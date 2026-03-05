#!/bin/sh
# pane-icon.sh — resolve a tmux pane command to a Nerd Font icon
# Called by tmux via #() in window-status-format / window-status-current-format.
# Usage: pane-icon.sh <pane_current_command> [hint_cmd] [assigned_icon]
#
# Priority chain:
#   1. @assigned_icon — literal string set via `tmux_hint -d`, bypasses lookup
#   2. @hint_cmd  — command name override set via `tmux_hint <name>`
#   3. pane_current_command — tmux default

cmd="$1"
hint="$2"
assigned="$3"

# @assigned_icon bypasses the case statement entirely
# tmux passes "none" as a sentinel when the option is unset
if [ -n "$assigned" ] && [ "$assigned" != "none" ]; then
  printf ' %s ' "$assigned"
  exit 0
fi

# @hint_cmd overrides pane_current_command for the lookup
if [ -n "$hint" ] && [ "$hint" != "none" ]; then
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
