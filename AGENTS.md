# AGENTS.md — Coding Agent Guidelines (Charm School)

macOS dotfiles repo managed by **rotz** (Rust). Primary shell is **Fish**; rotz install hooks run in Fish (not bash/zsh), primarily through a custom `dot` function (see shell/fish/functions/dot.fish or dot --help for usage).

**Goal**: repeatable, idempotent setup managing install commands and symlinks to take a fresh machine to highly customized developer environment in one step.

## Scope & Assumptions

- **Target OS:** macOS only (Intel + Apple Silicon, user is still on Intel, we will drop Intel support when they move to Apple Silicon).
- Prefer **rotz-managed** changes (links + installs) over ad-hoc manual steps. The initial bootstrap.sh should be the only manual step outside of the rotz process.
- Do not add secrets, tokens, private keys, or licensed fonts.

## How This Repo Works (rotz model)

- Any directory containing a `dot.yaml` is a rotz **dot** (installable unit).
- `dot.yaml` commonly uses:
  - `installs` — commands executed on install
  - `links` — symlinks to create (`source: target`)
  - `depends` — dependencies (and/or `installs.depends` depending on dot patterns)
- **Inheritance:** `defaults.yaml` sets defaults for subdirectories.
  - Subdirectories inherit only when they set a key to `null`.
  - Common pattern: `tools/defaults.yaml` provides `brew install {{file_name name}}` (dots use handlebars helpers for templating).
- Project-level rotz config: `config.yaml`
  - Dotfiles location is **non-standard**: `$HOME/.charmschool`
  - Project-level config `shell_command` (in `config.yaml`) runs installs via **Fish** (via `fish -c [command]`), so bash syntax will fail.

References:

- rotz docs: <https://volllly.github.io/rotz/docs>
- fish docs: <https://fishshell.com/docs/current/index.html>
- LazyVim docs: <https://www.lazyvim.org/>

## Repo Map (high level)

- `bootstrap.sh` — fresh machine bootstrap (Rust → rotz → Homebrew → Fish). Must be **idempotent**.
- `agents/` — configs for coding agents/CLIs.
- `apps/` — Homebrew casks (GUI apps), typically via `defaults.yaml`.
- `tools/` — Homebrew formulae (CLI/TUI tools), typically via `defaults.yaml`.
- `shell/` — Fish, kitty, starship prompt.
- `editor/` — Neovim (LazyVim), plugins, snippets.
- `lang/` — language tooling (transitioning toward `mise`).
- `git/` — git tooling/config.

## Essential Commands (prefer safe wrappers)

Prefer Fish wrapper functions when available (more safety/help/flags).

- Symlink dots:
  - `dot -l [path...]`  (preferred)  
  - `rotz link [path...]`
  - `rotz link --force` only when you intentionally want repo links to win
- Install hooks:
  - `dot -i [path...]`  (preferred)
  - `rotz install [path...]`
- Link + install:
  - `dot [path...]` (preferred)
- Bootstrap:
  - `sh bootstrap.sh`
    - **Do not run on production machines.** Intended for fresh/VM testing (future CI).

Notes on paths:

- `[path]` is a relative path (no trailing slash), e.g. `editor/nvim`, although the `dot` function will strip trailing slashes if provided.
- rotz: no path ⇒ “all”, do not call this unless explicitly intended as it will run for a very long time.
- wrapper `dot`: no path requires `-a/--all` (safer), supports `-d/--dry-run`

## Style & Conventions

- YAML: **2 spaces**
- Lua: **2 spaces**
- Prefer existing formatters/linters/LSP installed via Mason, Claude Code plugins provide access to these.
- Shell:
  - General-purpose scripts: POSIX `sh` (when portability matters).
  - User-facing / interactive: **Fish** (the repo assumes Fish is set up).
  - Coding agent CLIs: **Bash** (current standard for widest compatibility).
  - Agent tool scripts: **Deno** (high security, expressive, and portable - can be run as lambdas via Val Town).
- Fish functions:
  - Stored in `shell/fish/functions/`
  - Filename must match function name (`foo.fish` defines `foo`)
  - Include a description + a useful `--help` flag
- Keep configs small and **comment rationale** (friendly tone; beginner-accessible).
- Avoid hard-coded personal paths or machine-specific assumptions unless documented.
- If Mac-specific, say so in comments.
- Lean into Unix-like standards where possible (e.g., use `$HOME`, `$XDG_CONFIG_HOME`, etc where possible, avoid hardcoding usernames)

### Fish vs bash/zsh reminders (common footguns)

In rotz install commands (Fish):

- Use `test`, not `[[ ... ]]`
- Use `type -q cmd`, not `command -v cmd`
- Assign with `set`, not `VAR=value`
- Avoid universal variable scope (`set -U`/`set -Ux`) unless certain it's the best idiomatic solution. Fish is moving away from universal variables (e.g., the theming system moved to global scope in recent releases). Prefer global (`set -gx`) or local scope for most use cases.

## Editor Notes (Neovim + LazyVim)

- Plugins: `editor/nvim/lua/plugins/*.lua`
- Keymaps: `editor/nvim/lua/config/keymaps.lua`
- Snippets: `editor/nvim/snippets/` (VSCode JSON format)
- When editing configs:
  - Check LazyVim defaults to avoid redundant config (project is available locally at `~/.local/share/nvim/lazy/LazyVim` and made available as an accessible additional working directory in Claude Code).
  - After changes: open `nvim`, ensure no startup errors; consider `:checkhealth`.

## Common Workflows

### Add a new CLI tool (Homebrew formula)

- Create `tools/<toolname>/dot.yaml` with `installs: null` (to inherit defaults).
- Add config files there (and `links:` if needed).
- Install: `dot -i tools/<toolname>` (or `rotz install tools/<toolname>`).
- Then link configs if needed: `dot -l tools/<toolname>` (command will create new subdirectories as needed).

### Add a new GUI app (Homebrew cask)

- Create `apps/<appname>/dot.yaml` with `installs: null`.
- Install: `dot -i apps/<appname>`.

### Add/update a Fish function

- Add `shell/fish/functions/<name>.fish` (function name matches filename).
- Link: `dot -l shell/fish` (or relevant path).
- Reload Fish config if needed: `source ~/.config/fish/config.fish`.

### Modify Neovim plugins

- Edit/create `editor/nvim/lua/plugins/<name>.lua` (LazyVim plugin spec style).
- Restart `nvim` or run `:Lazy sync`.

## Safety / “Require Approval” Changes

Treat these as **high-impact** and do not perform without explicit user intent:

- Running `bootstrap.sh`
- Running `dot -a` / `rotz install` broadly (installs system packages)
- Using `sudo`
- Modifying `config.yaml` (changes rotz behavior globally)
- Deleting dots/directories or removing `dot.yaml` files
- Changing git identity (`user.name`, `user.email`)
- Installing/changing language runtimes via `mise` (unless clearly requested)

Hard rules:

- Never commit secrets/tokens/keys.
- Never delete `dot.yaml` without a clear reason (breaks rotz structure).
- Preserve symlink model: edit files in-repo, not their linked targets.

## Troubleshooting (fast checks)

- rotz install fails:
  - Confirm the command is valid **Fish** syntax.
  - Confirm Homebrew exists: `which brew`
  - Ensure dependencies implied by `defaults.yaml`/`dot.yaml` are present
- Symlink conflicts:
  - Prefer resolving conflicts explicitly; use `rotz link --force` only intentionally
- Fish function not found:
  - Filename == function name
  - Link exists under `~/.config/fish/functions/`
  - Reload fish config
- Neovim issues:
  - `:checkhealth`
  - Validate plugin specs align with LazyVim conventions
  - Ensure CLI deps (e.g., `fzf`, `rg`) are installed

## Git Commit Style & PR Guidelines

- Commit messages: imperative, concise (<72 chars), one logical change when practical. Use conventional style if possible (e.g., `feat(claude): add LSP plugins`). Some specific preferences for conventional commit tags:
  - use `nvim` for editor changes, not `editor` (e.g., 'feat(nvim): ...')
  - use `fish` for shell changes, not `shell` (e.g., 'fix(fish): ...')
    - adding new fish functions should be considered a `feat`, config changes such as setting new environment variables should be considered a `chore` or `fix` depending on the nature of the change
  - use `kitty` for terminal changes, not `terminal` (e.g., 'chore(kitty): ...')
  - use `mux` for both tmux or zellij changes (e.g., 'fix(mux): ...')
  - use `prompt` for starship prompt changes (e.g., 'feat(prompt): ...')
  - use the specific agentic coding tool for changes to agent configs (e.g., 'feat(claude): ...', 'fix(copilot): ...')
    - Claude Code changes should just be tagged `claude` not `claude code`
  - `tools` and `apps` can be used for their respective subdirectories, as long as the name of the specific tool is in the commit message (e.g., 'chore(tools): configure ripgrep', 'feat(apps): add zen web browser')
    - adding new tools or apps should be considered a `feat`
    - config changes to existing tools/apps should be considered a `chore` or `fix` depending on the nature of the change
- PRs: summary + rationale + manual verification steps + macOS version tested.
- Include screenshots for visual/theme changes (terminal/editor).

## Roadmap (non-blocking)

- Add GitHub Actions CI/CD workflow to test fresh macOS installs in a VM.
- Migrate language tooling management from multiple language-specific tools to mise.
- Consider migrating from rotz → chezmoi over time (we will probably do this in a parallel repo as the `rotz` history will not be very useful for a totally different framework).
