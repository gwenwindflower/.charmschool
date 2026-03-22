# chezmoi Target Types

chezmoi manages four primary target types. Each has specific source-state representations and behaviors.

## Files

Regular files are the most common target type.

### Standard Files

Source file → target file with optional attributes.

```text
dot_bashrc        → ~/.bashrc
dot_bashrc.tmpl   → ~/.bashrc (templated)
```

Attributes: `encrypted_`, `private_`, `readonly_`, `executable_`, `empty_`

**Empty files**: By default, files with empty content after template execution are **removed** from destination. Use `empty_` prefix to preserve empty files.

### Create Files (`create_`)

Create file only if it doesn't exist in destination. Never overwrites.

```text
create_dot_bashrc → ~/.bashrc (only if missing)
```

Use for files users may customize - chezmoi won't clobber their changes.

### Modify Scripts (`modify_`)

Script that patches existing files. Receives current file content via stdin, outputs new content to stdout.

```text
modify_dot_bashrc → patches ~/.bashrc
```

Example modify script:

```bash
#!/bin/bash
# Add line if not present
if ! grep -q "export EDITOR=nvim" /dev/stdin; then
    cat
    echo "export EDITOR=nvim"
else
    cat
fi
```

### Modify Templates

Scripts containing `chezmoi:modify-template` are processed as templates. Access current content via `.chezmoi.stdin`.

```text
modify_dot_config/tool/config.json.tmpl
```

Example using `setValueAtPath` for JSON:

```text
{{- $config := .chezmoi.stdin | mustFromJson -}}
{{- $config = set $config "editor" "nvim" -}}
{{ $config | toPrettyJson }}
```

### Remove Files (`remove_`)

Remove file or symlink from destination if it exists.

```text
remove_dot_old_config → removes ~/.old_config
```

## Directories

Directories are represented as regular directories in source state.

### Standard Directories

```text
dot_config/       → ~/.config/
private_dot_ssh/  → ~/.ssh/ (mode 700)
```

Attributes: `encrypted_`, `private_`, `readonly_`

### Exact Directories (`exact_`)

Remove any entries in destination not explicitly in source state.

```text
exact_dot_config/fish/ → ~/.config/fish/ (unmanaged files removed)
```

**Warning**: `exact_` removes files not in source. Use carefully.

### External Directories (`external_`)

Ignore parent attributes for child entries. Used with `.chezmoiexternal.yaml`.

```text
external_dot_oh-my-zsh/ → ~/.oh-my-zsh/
```

### Remove Empty Directories (`remove_`)

Remove directory if it exists and is empty.

```text
remove_dot_old_dir/ → removes ~/.old_dir/ if empty
```

## Symlinks

Symlinks are specified with `symlink_` prefix. File content is the symlink target.

### Basic Symlink

```text
# Source: symlink_dot_gitconfig
# Content: /path/to/actual/gitconfig
# Result: ~/.gitconfig → /path/to/actual/gitconfig
```

### Templated Symlink

```text
# Source: symlink_dot_config/nvim.tmpl
# Content: {{ .chezmoi.sourceDir }}/nvim-config
# Result: ~/.config/nvim → <source-dir>/nvim-config
```

### Symlink to Source Directory

Common pattern for files modified by external tools:

```bash
# Create symlink pointing into source directory
echo '{{ .chezmoi.sourceDir }}/tool-config.json' > symlink_dot_config/tool/config.json.tmpl
```

### Empty Symlinks

Symlinks with empty or whitespace-only targets are **removed** from destination.

## Scripts

Scripts are executed during `chezmoi apply`. They don't create files - they run commands.

### Basic Script (`run_`)

Runs on every `chezmoi apply`.

```text
run_99-notify.fish → executes every apply
```

### Run Once (`run_once_`)

Runs only once per machine. Tracked by content SHA256 hash.

```text
run_once_00-bootstrap.fish → runs once, tracked by content
```

If script content changes, it runs again.

### Run On Change (`run_onchange_`)

Runs when script content changes. Tracked by content + filename hash.

```text
run_onchange_50-fisher.fish.tmpl → runs when content changes
```

Common pattern - embed hash of watched file:

```fish
#!/usr/bin/env fish
# fish_plugins hash: {{ include "dot_config/fish/fish_plugins" | sha256sum }}
fisher update
```

### Before/After Timing

Control when scripts run relative to file updates:

```text
run_before_10-prep.fish   → before file updates
run_after_90-cleanup.fish → after file updates
```

Default (no `before_`/`after_`): runs in alphabetical order with file updates.

### Script Execution Order

Scripts sort alphabetically by target name (after stripping attributes):

```text
run_once_before_00-first.fish  → target: 00-first.fish
run_once_before_10-second.fish → target: 10-second.fish
run_after_99-last.fish         → target: 99-last.fish
```

### Templated Scripts

Add `.tmpl` suffix to access template data:

```text
run_once_10-install.fish.tmpl
```

```fish
#!/usr/bin/env fish
{{ range .packages.tools }}
brew install {{ . }}
{{ end }}
```

### Script Interpreter

chezmoi uses the file extension to determine interpreter:

| Extension | Interpreter |
| --- | --- |
| `.sh` | `/bin/sh` |
| `.bash` | `bash` |
| `.fish` | `fish` |
| `.py` | `python3` |
| `.rb` | `ruby` |
| `.ps1` | `powershell` |

Or use explicit shebang: `#!/usr/bin/env fish`
