# Worktrunk (wt) Integration

Worktrunk is a git worktree manager installed as both a CLI tool (`wt`) and a Claude Code plugin (`worktrunk@worktrunk`). Config lives at `tools/worktrunk/config.toml` (symlinked to `~/.config/worktrunk/config.toml`).

## Plugin Hooks (automatic session tracking)

The worktrunk Claude Code plugin registers hooks that track session state via branch markers:

| Event | Marker | Meaning |
| --- | --- | --- |
| `UserPromptSubmit` | 🤖 | Claude is actively working |
| `Notification` | 💬 | Claude is waiting for user input |
| `SessionEnd` | (cleared) | Session ended |

These markers are stored in git config (`worktrunk.state.<branch>.marker`) and shared across all worktrees. They power the worktree roster in the statusline (see `.claude/docs/statusline.md`).

## User Config (`tools/worktrunk/config.toml`)

Currently contains:

- **LLM commit generation**: Uses Claude Code (Haiku) for `wt merge` commit messages
- **`post-remove` hook**: Cleans up git config entries when worktrees are removed or merged

## Useful Commands

```fish
wt list                        # show all worktrees with status
wt list --format json          # machine-readable output (used by statusline)
wt switch --create <branch>    # create worktree and switch to it
wt switch <branch>             # switch to existing worktree
wt merge <target>              # merge current branch into target, cleanup worktree
wt remove <branch>             # remove a worktree
wt config state marker set "🚧"  # manually set a status marker
```

## How Markers and Hooks Fit Together

- **Markers** (transient): managed by plugin hooks, track Claude session state per-branch
- **Statusline**: reads markers to render the pink worktree segment (see `.claude/docs/statusline.md`)

During `wt merge`, hooks run: pre-commit → pre-merge → pre-remove → post-remove → post-merge.

## Key Files

- `tools/worktrunk/config.toml` — user config (LLM commits, cleanup hooks)
- `agents/claude/settings.json` — winline statusline consumes worktrunk marker data
