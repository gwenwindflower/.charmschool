---
name: rotz-dotfiles
description: |
  Use when working with a rotz-based dotfiles repository. This includes: (1) Managing tools or apps
  (adding, configuring, or removing), (2) Modifying rotz configuration files (dot.yaml, defaults.yaml,
  config.yaml), (3) Updating tool configurations managed by rotz (mise.toml, config.fish, etc.),
  (4) Restructuring the dotfiles hierarchy, (5) Planning architectural changes to the dotfiles project.
---

# Rotz Dotfiles Management

Context for working with `rotz`, a Rust-based dotfiles management tool, and rotz-based dotfiles projects.

## Rotz System Critical Context

**Project location:** `~/.charmschool` (not default `~/.dotfiles`)

**Fish shell focused:** `config.yaml` sets `shell_command` to `fish -c`, so install commands use Fish syntax

**Rotz structure:**

- Any directory with `dot.yaml` = installable "dot"
- `dot.yaml` keys: `installs` (commands), `links` (symlinks), `depends` (dependencies)
- `defaults.yaml` provides inherited defaults (dots inherit by setting keys to `null`)
- Handlebars templating: `{{file_name name}}`, etc.

**Repository structure:**

- `agents/` - coding agent/CLI configs
- `apps/` - Homebrew casks (GUI apps)
- `tools/` - Homebrew formulae (CLI/TUI)
- `shell/` - Fish, kitty, starship
- `editor/` - Neovim (LazyVim)
- `lang/` - language tooling (transitioning to mise)
- `git/` - git tooling/config

## dot.yaml Patterns

```yaml
# Simple (inherit from defaults.yaml)
installs: null  # Gets "brew install <name>" from defaults
links:
  config: ~/.config/tool/config

# Custom install
installs:
  - brew install custom-tool
  - custom-tool --setup
links:
  config.toml: ~/.config/custom/config.toml
depends:
  - ../other-tool
```

## Adding New Tools

1. **Determine location:** `apps/`, `tools/`, `lang/`, etc. (or propose new grouping)
2. **Create dot.yaml:**
   - Use `installs: null` to inherit from defaults.yaml when possible
   - Explicit install commands for special handling
   - Declare dependencies (`depends`)
   - Set up config symlinks (`links`)
3. **Study similar tools** for consistency
4. **Consider integration** (e.g., fzf + fish functions)

## Configuration Guidelines

**Standards:**

- Modern tools preferred (Rust/Go-based when advantageous)
- Optimize for fast shell startup (lazy-load heavy tools)
- XDG compliant (use `~/.config/` over `~/.*`)
- Project-aware configs (mise auto-loading versions)
- Never expose credentials (use env vars)
- Comment non-obvious choices (beginner-friendly)
- Note macOS-specific configs

**Code quality:**

- Fish idioms in install commands (avoid bashisms)
- Idempotent install commands
- Error handling in scripts
- Clear dependencies, avoid tight coupling

**Evaluation criteria for new tools:**

- Necessity, maintenance/adoption, integration, simplification potential, performance impact, complexity cost

## Restructuring

- Analyze current state thoroughly first
- Maintain logical grouping (clean hierarchy preferred)
- Update all dot references when moving directories
- Update/preserve defaults.yaml to reflect patterns
- Explain rationale for changes

## Essential Commands

Prefer `dot` wrapper (safer, more features):

- **Link:** `dot -l [path...]` or `rotz link [path...]`
- **Install:** `dot -i [path...]` or `rotz install [path...]`
- **Both:** `dot [path...]`
- **Force link:** `rotz link --force` (use cautiously)
- **Bootstrap:** `sh bootstrap.sh` (fresh machines only)

**Path notes:**

- Paths are relative, no trailing slash (e.g., `editor/nvim`)
- `dot` strips trailing slashes if provided
- No path = all (use `dot -a` / `--all`, or very cautiously with rotz)
- `dot` supports `-d/--dry-run`

## Fish vs bash/zsh (Footguns)

In rotz install commands (Fish syntax):

| Bash/zsh | Fish |
| --- | --- |
| `[[ ... ]]` | `test ...` |
| `command -v cmd` | `type -q cmd` |
| `VAR=value` | `set VAR value` |
| `export VAR=value` | `set -gx VAR value` |

**Avoid `set -U` (universal scope):** Fish moving away from this. Prefer global (`set -gx`) or local scope.

## Style Conventions

- **YAML/Lua:** 2 spaces
- **Shell choice:**
  - General scripts: POSIX `sh`
  - User-facing/interactive: Fish
  - Coding agent CLIs: Bash
  - Agent tool scripts: Deno
- **Fish functions:**
  - Location: `shell/fish/functions/`
  - Filename = function name (`foo.fish` defines `foo`)
  - Include `-d "description"` and `--help`
- **Comments:** Explain rationale, beginner-accessible
- **Theming:** Catppuccin Frappe when possible

## Tool-Specific Notes

**mise:** Check [docs](https://mise.jdx.dev/) (rapidly evolving). Use for tasks, environments, versions. Optimize for fast startup.

**uv:** Primary Python package manager. Set up pyproject.toml, integrate with mise.

**fish:** Idiomatic functions/abbrs. Prefer global scope over universal. Optimize config.fish startup.

**fzf:** Advanced options, keybindings. Integrate with ripgrep, fd. Fish-specific functions, preview optimization.

**ripgrep:** Configure .ripgreprc defaults, custom type definitions. Integrate with fzf.
