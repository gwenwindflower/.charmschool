---
name: chezmoi
description: |
  Manage dotfiles with chezmoi - a cross-platform dotfile manager using a source-state model.
  Use when: (1) Working with chezmoi (2) Managing user-level configs outside of chezmoi that would be useful to bring into chezmoi
---

# chezmoi Dotfile Management

chezmoi manages dotfiles using a **three-state model**: source (declared in `~/.local/share/chezmoi`), destination (current home directory), and target (computed desired state). Running `chezmoi apply` updates destination to match target.

## Quick Reference

```bash
chezmoi init                    # Initialize source directory
chezmoi add ~/.bashrc           # Add file to management
chezmoi edit ~/.bashrc          # Edit source file
chezmoi diff                    # Preview changes
chezmoi apply                   # Apply changes to home directory
chezmoi apply -n -v             # Dry run with verbose output
chezmoi cd                      # Enter source directory
chezmoi data                    # Show template variables
chezmoi doctor                  # Diagnose issues
chezmoi managed                 # List managed files
```

## Core Concepts

- **Attributes**: Prefixes/suffixes on source filenames control behavior (`dot_`, `private_`, `executable_`, `.tmpl`, etc.). See [attributes reference](attributes.md).
- **Target types**: Files, directories, symlinks, scripts. See [target types reference](target-types.md).
- **Special files**: `.chezmoi*` files control chezmoi behavior. See [special files reference](special-files.md).
- **Application order**: Before scripts → file updates → after scripts. See [application order reference](application-order.md).

## Handling Externally-Modified Files

**Key principle:** Only symlink files that are modified by external tools (package managers, plugin systems, app settings auto-writers). Everything else should use normal chezmoi copy workflow.

Ask: "Will something other than me edit this file?" If yes → symlink. If no → copy.

### Examples of files that need symlinks

- **Package lockfiles**: `lazy-lock.json` (updated by `:Lazy sync`), `package-lock.json`
- **Agent settings**: `~/.claude/settings.json` (edited by Claude Code itself)
- **Plugin directories**: `~/.claude/skills/` (target for skill installation)
- **Editor state**: `lazyvim.json` (updated by LazyVim framework)

### Examples of files that do NOT need symlinks

- Config you author and apply: `init.lua`, `config.fish`, `starship.toml`
- Rules/docs you write: `~/.claude/rules/*.md`
- Templates with OS logic: anything using `{{ if eq .chezmoi.os "darwin" }}`

### Pattern: Inline symlinks with nested attributes

Place `symlink_` entries at their natural target path. Source files live at repo root in `.chezmoiignore`.

```text
# Directory structure
dot_config/nvim/
├── init.lua                        # copied normally
├── lua/plugins/...                 # copied normally
├── symlink_lazy-lock.json.tmpl     # → source-managed lockfile
└── symlink_lazyvim.json.tmpl       # → source-managed state file

nvim/                               # repo root, in .chezmoiignore
├── lazy-lock.json                  # actual file (symlink target)
└── lazyvim.json                    # actual file (symlink target)
```

Each `symlink_*.tmpl` file contains a single line:

```text
{{ .chezmoi.sourceDir }}/nvim/lazy-lock.json
```

The `.chezmoiignore` prevents chezmoi from also deploying `nvim/` as `~/nvim/`:

```text
nvim/
```

This approach keeps the bulk of the config in normal chezmoi workflow while only the specific externally-modified files get symlink treatment. Attributes nest freely — `symlink_` works inside `dot_config/` or any other prefix directory.

### Anti-pattern: Symlinking entire directories

Avoid symlinking a whole directory (e.g., `~/.config/nvim → source`) just because one or two files in it are externally modified. This bypasses chezmoi's state management for the entire tree and prevents template processing on any file in that directory.

## Design Philosophy: Minimize Moving Parts

chezmoi's strength is declarative file management. Prefer static files over dynamic scripts, and copy over symlink.

**Decision hierarchy:**

1. **Copy** (default) — file at target path with `dot_` prefix. Use `.tmpl` for OS/machine branching.
2. **Symlink** — only for files modified by external tools (see above). Use `symlink_` prefix inline.
3. **Script** — only for side effects that can't be expressed as files (package installs, shell changes). Minimize script count.

**Scripts are a surface to minimize.** Each script is an imperative action that can fail, has ordering concerns, and complicates debugging. If something can be a file, make it a file. Reserve `run_once_` and `run_onchange_` for truly imperative operations like `brew bundle` or `chsh`.

**Plugin managers with file-based output** (like Fisher for Fish shell) don't need install scripts in chezmoi. If the plugin manager just puts files into a tracked directory, track the output files directly and treat the plugin manager as a manual tool the user runs occasionally.

## Templates

Templates use Go `text/template` with the expanded sprig library of functions.

## Scripts

Scripts in `.chezmoiscripts/` run during apply. Format: `run_[once_|onchange_][before_|after_]<order>-<name>.<ext>[.tmpl]`.

## Hooks

Hooks run before/after chezmoi commands (not during apply like scripts).

## External Sources

Pull from git repos/archives via `.chezmoiexternal.yaml`. Refresh with `chezmoi apply -R`.

## Debugging

```bash
chezmoi doctor                                     # Check setup
chezmoi diff                                       # Show pending changes
chezmoi cat ~/.bashrc                              # Show what would be written
chezmoi execute-template '{{ .chezmoi.os }}'       # Test template
chezmoi state delete-bucket --bucket=scriptState  # Reset run_once_ tracking
```

## References

- [Attributes](attributes.md) - Source state prefixes/suffixes
- [Target types](target-types.md) - Files, directories, symlinks, scripts
- [Special files](special-files.md) - `.chezmoi*` files and directories
- [Application order](application-order.md) - Execution flow during apply
- [Hooks](hooks.md) - Command hooks configuration
- [Templates](templates.md) - Template syntax and functions
- [Scripts](scripts.md) - Script patterns and examples
