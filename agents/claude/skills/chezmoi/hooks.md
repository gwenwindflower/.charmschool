# chezmoi Hooks

Hooks are commands executed before and after chezmoi commands. They differ from scripts in important ways.

## Hooks vs Scripts

| Aspect | Hooks | Scripts |
| --- | --- | --- |
| Configured in | `chezmoi.yaml` | Source directory (`.chezmoiscripts/`) |
| Run when | Before/after chezmoi commands | During `chezmoi apply` |
| With `--dry-run` | **Always run** | Skipped |
| Use case | Git sync, notifications | Package installation, setup |

## Available Hook Events

### Command Hooks

Every chezmoi command supports hooks:

- `add.pre` / `add.post`
- `apply.pre` / `apply.post`
- `archive.pre` / `archive.post`
- `diff.pre` / `diff.post`
- `init.pre` / `init.post`
- `update.pre` / `update.post`
- ... (any chezmoi command)

### Special Events

| Event | When |
| --- | --- |
| `read-source-state.pre` | Before reading source directory |
| `read-source-state.post` | After reading source directory |
| `git-auto-commit.pre` | Before auto-commit |
| `git-auto-commit.post` | After auto-commit |
| `git-auto-push.pre` | Before auto-push |
| `git-auto-push.post` | After auto-push |

## Configuration

Hooks are configured in `~/.config/chezmoi/chezmoi.yaml`.

### Basic Command Hook

```yaml
hooks:
  apply:
    pre:
      command: "echo"
      args: ["Starting apply..."]
    post:
      command: "echo"
      args: ["Apply complete!"]
```

### Script-Based Hook

```yaml
hooks:
  apply:
    pre:
      script: "pre-apply.fish"
```

Script is resolved relative to source directory. Extension determines interpreter.

### Git Auto-Sync Pattern

Common pattern: pull before reading, push after apply.

```yaml
hooks:
  read-source-state:
    pre:
      command: "git"
      args: ["-C", "{{ .chezmoi.sourceDir }}", "pull", "--quiet", "--rebase"]
  apply:
    post:
      command: "git"
      args: ["-C", "{{ .chezmoi.sourceDir }}", "push", "--quiet"]
```

## Environment Variables

chezmoi sets these environment variables when hooks run:

| Variable | Description |
| --- | --- |
| `CHEZMOI` | Always `1` |
| `CHEZMOI_COMMAND` | The command being run (e.g., `apply`) |
| `CHEZMOI_COMMAND_DIR` | Directory where chezmoi was invoked |
| `CHEZMOI_ARGS` | Full arguments including executable path |

## Hook Requirements

Hooks should be:

1. **Fast** - They run on every command invocation
2. **Idempotent** - Safe to run multiple times
3. **Quiet** - Minimal output (use `--quiet` flags)
4. **Non-blocking** - Don't prompt for input

## Examples

### Notify on Apply

```yaml
hooks:
  apply:
    post:
      command: "terminal-notifier"
      args: ["-title", "chezmoi", "-message", "Dotfiles applied"]
```

### Validate Before Apply

```yaml
hooks:
  apply:
    pre:
      command: "chezmoi"
      args: ["verify"]
```

### Log to File

```yaml
hooks:
  apply:
    post:
      command: "sh"
      args: ["-c", "echo \"Applied at $(date)\" >> ~/.chezmoi.log"]
```

### Conditional Git Pull

```yaml
hooks:
  read-source-state:
    pre:
      command: "sh"
      args: ["-c", "cd {{ .chezmoi.sourceDir }} && git fetch --quiet && git pull --quiet --ff-only || true"]
```

The `|| true` ensures hook doesn't fail if offline or merge conflicts exist.

## Debugging Hooks

```bash
# Hooks run even with dry-run
chezmoi apply -n -v

# Check config is valid
chezmoi doctor

# View current config
chezmoi cat-config
```

## Common Pitfalls

### Blocking Input

```yaml
# BAD: May prompt for password
hooks:
  apply:
    pre:
      command: "git"
      args: ["-C", "{{ .chezmoi.sourceDir }}", "pull"]
```

Use `--quiet` and ensure SSH keys or credential caching.

### Slow Hooks

```yaml
# BAD: Runs on every command
hooks:
  read-source-state:
    pre:
      command: "brew"
      args: ["update"]
```

Keep hooks fast. Use scripts for slow operations.

### Exit Codes

Hook failure (non-zero exit) stops chezmoi. Use `|| true` for optional operations:

```yaml
hooks:
  apply:
    post:
      command: "sh"
      args: ["-c", "notify-send 'Applied' || true"]
```
