---
name: chezmoi
description: |
  Manage dotfiles with chezmoi - a cross-platform dotfile manager using a source-state model.
  Use when: (1) Working with chezmoi configuration, setup, or repo structure, (2) Managing files,
  templates, or scripts (Go template syntax, run_once_/run_onchange_ scripts, .chezmoidata),
  (3) Handling file attributes (symlinks, permissions, encryption, external sources),
  (4) Troubleshooting chezmoi operations or understanding application order.
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

- **Attributes**: Prefixes/suffixes on source filenames control behavior (`dot_`, `private_`, `executable_`, `.tmpl`, etc.). See [attributes reference](./references/attributes.md).
- **Target types**: Files, directories, symlinks, scripts. See [target types reference](./references/target-types.md).
- **Special files**: `.chezmoi*` files control chezmoi behavior. See [special files reference](./references/special-files.md).
- **Application order**: Before scripts → file updates → after scripts. See [application order reference](./references/application-order.md).

## Handling Externally-Modified Files

For tools that modify their own configs (Claude Code, VS Code), use **symlinks pointing to source**:

```bash
# 1. Move config to source (without chezmoi prefixes)
mv ~/.config/tool/settings.json ~/.local/share/chezmoi/tool-settings.json

# 2. Ignore the raw file
echo "tool-settings.json" >> ~/.local/share/chezmoi/.chezmoiignore

# 3. Create symlink template
echo '{{ .chezmoi.sourceDir }}/tool-settings.json' > \
  ~/.local/share/chezmoi/symlink_dot_config/tool/settings.json.tmpl

# 4. Apply
chezmoi apply
```

## Templates

Templates use Go `text/template` with sprig functions. See [templates reference](./references/templates.md).

## Scripts

Scripts in `.chezmoiscripts/` run during apply. Format: `run_[once_|onchange_][before_|after_]<order>-<name>.<ext>[.tmpl]`. See [scripts reference](./references/scripts.md).

## Hooks

Hooks run before/after chezmoi commands (not during apply like scripts). See [hooks reference](./references/hooks.md).

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

- [Attributes](./references/attributes.md) - Source state prefixes/suffixes
- [Target types](./references/target-types.md) - Files, directories, symlinks, scripts
- [Special files](./references/special-files.md) - `.chezmoi*` files and directories
- [Application order](./references/application-order.md) - Execution flow during apply
- [Hooks](./references/hooks.md) - Command hooks configuration
- [Templates](./references/templates.md) - Template syntax and functions
- [Scripts](./references/scripts.md) - Script patterns and examples
