# Tmux Hint & Pane Icon System

Tmux pane options drive a custom icon system for window labels. Fish functions set hints, and a POSIX shell script resolves them to Nerd Font icons in the tmux status bar.

## How It Works

The tmux status bar displays an icon per window (center section) and the active command name (left section). Both read from the same data:

1. **`@assigned_icon`** — literal icon string, bypasses all lookup (set via `tmux_hint -d`)
2. **`@hint_cmd`** — command name override, looked up in `pane-icon.sh`'s case statement
3. **`pane_current_command`** — tmux default, used when no hints are set

Priority flows top-down: assigned icon wins over hint, hint wins over pane command.

## Key Files

| File | Role |
| --- | --- |
| `shell/fish/functions/tmux_hint.fish` | Sets/clears/locks pane hint options |
| `shell/fish/functions/opo.fish` | Wraps `op run` with per-tool env files; sets locked hints |
| `shell/tmux/pane-icon.sh` | POSIX script resolving command names to Nerd Font icons |
| `shell/tmux/statusline.conf` | Tmux status bar format strings that consume hints |
| `shell/fish/functions/twin.fish` | Creates persistent tmux windows with hint support |
| `shell/fish/functions/nvim.fish` | opo wrapper (nvim, claude, gh follow same pattern) |

## tmux_hint

Fish function that manages `@hint_cmd`, `@assigned_icon`, and `@hint_locked` pane options. No-ops silently outside tmux.

```fish
tmux_hint nvim          # set hint (icon lookup uses "nvim")
tmux_hint -l nvim       # set hint with lock (bg processes can't clear it)
tmux_hint -d "󱜚"        # set literal icon (max 6 chars, no spaces)
tmux_hint -t %5 nvim    # set hint on a specific pane/window (e.g. from twin)
tmux_hint               # clear all hints (respects lock)
```

### Lock mechanism

`--lock` / `-l` stores `$fish_pid` in `@hint_locked`. When another process tries to clear:

- If the lock owner PID is still alive and isn't the caller → clear is a **no-op**
- If the lock owner is dead or is the caller → clear proceeds normally
- A new `--lock` call always **upgrades** — any process can claim the hint, but only the current owner (or a dead owner) allows clearing

This prevents background processes (like `op` authenticating for git SSH) from resetting the icon while a primary command like nvim is running.

## opo (op open)

Wraps any command with `op run` and a tool-scoped 1Password env file. Sets a **locked** hint so the icon stays stable.

```fish
opo nvim file.lua       # runs: op run --env-file=$OP_ENV_DIR/nvim.env -- nvim file.lua
```

Flow: validate command → validate env file → `tmux_hint --lock <cmd>` → `op run` → `tmux_hint` (clear on exit).

### Dedicated wrappers

Common opo commands get thin Fish wrappers for completions and ergonomics:

```fish
# shell/fish/functions/nvim.fish (claude.fish and gh.fish are identical)
function nvim
    opo nvim $argv
end
```

## twin (tmux window launcher)

Creates persistent tmux windows via `send-keys` (shell stays alive after command exits). `--cmd` sets both the command to run and the locked hint for icon display. Works from outside tmux.

```fish
twin myproject                  # empty shell window
twin --cmd nvim myproject       # run nvim with locked nvim hint
twin --cmd lazygit myproject    # run lazygit with locked lazygit hint
```

Designed for project `mux.fish` setup scripts (run from outside tmux):

```fish
set -l s cool-tool
tmux new-session -d -s $s
twin --cmd nvim $s
twin --cmd claude $s
twin --cmd lazygit $s
tmux attach -t $s
```

Each `twin` call targets the new window's pane via `tmux_hint --target`, so hints land correctly even when the script runs outside tmux.

## pane-icon.sh

POSIX shell script called by tmux via `#()` in `window-status-format`. Receives three args from the tmux format string:

```text
pane-icon.sh <pane_current_command> <hint_cmd|none> <assigned_icon|none>
```

### Process filter

Transient processes that should never claim the window icon are filtered before the icon lookup. If `pane_current_command` matches a filtered process and no hint override exists, it falls back to the shell icon (`fish`) rather than displaying an icon for a background utility.

Filtered: `op`, `ssh-agent`, `gpg-agent`, `1Password`, `git-credential-*`, `sudo`.

### Icon categories

The case statement maps command names to Nerd Font icons across these groups: shells, tools (nvim, yazi, git, etc.), AI agents, network, languages, data, and media. Unrecognized commands get a generic terminal icon.

## Adding a new icon

1. Add a case in `pane-icon.sh` with the command name(s) and Nerd Font icon
2. If the command runs through `opo`, the hint handles the rest automatically
3. If not opo-wrapped, call `tmux_hint <name>` (or `--lock` for long-running processes) from whatever launches it

## Statusline format reference

The left section of the status bar shows the hint-aware command name:

```text
#{?#{@hint_cmd},#{@hint_cmd},#{pane_current_command}}
```

The center section (window list) calls pane-icon.sh per window, passing all three data sources as args. See `shell/tmux/statusline.conf` for the full format strings.
