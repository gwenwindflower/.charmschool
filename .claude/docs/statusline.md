# Claude Code Statusline

Custom Deno script (`agents/claude/statusline.ts`) that renders a Catppuccin Frappe-themed powerline statusline in Claude Code sessions. Configured in `agents/claude/settings.json` under `statusLine`.

## Segments (left to right)

| Segment | Color | Data source | Shows |
| --- | --- | --- | --- |
| Model | mauve | stdin context JSON | First word of `model.display_name` (Haiku/Sonnet/Opus) |
| Directory | peach | stdin context JSON | `workspace.project_dir` basename |
| Git | yellow | `git branch`, `git status`, worktrunk JSON | Branch, working tree indicators (!+?), remote ahead/behind (from wt) |
| Worktrees | pink | `wt list --format json`, git config | Roster of other worktrees with identity + session markers |
| Languages | green | File detection + version commands | Icons + versions for detected languages (Python, Node, Deno, etc.) |
| Context % | blue/maroon | stdin context JSON | Token usage as percentage of context window (maroon when >80%) |

## Worktrunk Integration

The statusline pulls data from three sources in parallel (all with 400ms timeouts for graceful fallback):

- **`wt list --format json`** — worktree list, git state, remote ahead/behind
- **`git config --get-regexp 'worktrunk\.state\..*\.marker'`** — session markers set automatically by the worktrunk plugin hooks (see `.claude/docs/worktrunk.md`)
- **`git config --get-regexp 'wt-icon\.'`** — custom identity emojis

### Worktree roster (pink segment)

Only appears when >1 worktree exists. Each non-current worktree renders as `<identity><status>`:

- **Identity**: custom emoji from `git config wt-icon.<branch>`, or last 5 chars of branch name
- **Status**: 🤖 (Claude working) or 💬 (waiting for input), appended automatically by the worktrunk plugin

Set identity emojis with the `wt-icon` fish function:

```fish
wt-icon 🧪           # set icon for current branch
wt-icon -b feat 🌙   # set icon for a specific branch
wt-icon -r            # remove icon from current branch
```

Icons are stored in `.git/config` (shared across worktrees) and cleaned up automatically on worktree removal via a `post-remove` hook in the worktrunk user config (`tools/worktrunk/config.toml`).

## Architecture

- Reads Claude Code session context from stdin (JSON with model, workspace, cost, context_window)
- Runs subprocesses via `Deno.Command` with a minimal env (PATH + version manager vars)
- All independent data fetches run in parallel (`Promise.all`)
- If `wt` is not installed or times out, the statusline renders identically to pre-integration behavior

## Key files

- `agents/claude/statusline.ts` — the script itself
- `agents/claude/settings.json` — Claude Code config including `statusLine` command
- `tools/worktrunk/config.toml` — worktrunk user config with `post-remove` cleanup hook
- `shell/fish/functions/wt-icon.fish` — fish function for setting worktree identity emojis
