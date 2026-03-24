# Claude Code Statusline (winline)

The Claude Code statusline is **winline**, a standalone Bun-compiled binary distributed from its own repo. It reads session context JSON from stdin and renders a Catppuccin Frappe-themed powerline statusline to stdout.

winline is configured in `agents/claude/settings.json` under `statusLine`, pointing to the `winline` binary (installed to `~/.local/bin`). A reference TOML config lives at `~/.claude/statusline.toml`.

## Segments

| Segment | Color | Data source | Notes |
| --- | --- | --- | --- |
| model | mauve | stdin context | Active Claude model name |
| directory | peach | stdin context | Workspace root basename |
| git | yellow | `git branch`, `git status --porcelain` | Status indicators: `! + ✘ ?`; optional `colorized_status` |
| worktrees | pink | `git config --get-regexp worktrunk.state.*.marker` | Count of sessions waiting on input; hidden when 0 |
| languages | green | `starship module <name>` | Starship passthrough, parallel per module |
| context | blue/maroon | stdin context | Block bar + percentage, color shifts at warn threshold |

## Worktrunk integration

The worktrees segment reads `worktrunk.state.*.marker` keys from git config (set by worktrunk plugin hooks — see `.claude/docs/worktrunk.md`). It shows a count badge of sessions waiting on input. The `wt` binary is never called directly; without worktrunk the segment stays hidden.

## Key files in this repo

- `agents/claude/settings.json` — Claude Code config with `statusLine.command: "winline"`
- `agents/claude/statusline.toml` — reference TOML config (copy to `~/.claude/statusline.toml`)
- `tools/worktrunk/config.toml` — worktrunk user config with `post-remove` cleanup hook

## What moved out

The statusline implementation (`statusline.ts`) was extracted from this repo into its own standalone project (winline). The old in-repo Deno script is no longer the source of truth — winline is a Bun-compiled binary with its own TOML config system, caching layer, and CLI flags (`--print`, `--capture`, `--explain`). See the winline repo for development and architecture details.
