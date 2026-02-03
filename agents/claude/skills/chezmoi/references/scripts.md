# chezmoi Scripts Reference

Scripts in `.chezmoiscripts/` automate setup tasks during `chezmoi apply`.

## Script Naming

Format: `run_[once_|onchange_][before_|after_]<order>-<description>.<interpreter>[.tmpl]`

| Component | Options | Purpose |
|-----------|---------|---------|
| Frequency | `run_`, `run_once_`, `run_onchange_` | How often to run |
| Timing | `before_`, `after_` (optional) | When to run relative to file updates |
| Order | `00-99` | Alphabetical ordering (lower = earlier) |
| Description | `install-packages` | Human-readable name |
| Interpreter | `.fish`, `.sh`, `.py` | Script language |
| Template | `.tmpl` (optional) | Enable Go templating |

## Examples by Type

### run_once_ (Bootstrap)

Runs once per machine, tracked by content SHA256:

```fish
#!/usr/bin/env fish
# .chezmoiscripts/run_once_before_00-install-homebrew.fish

if not type -q brew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
end
```

### run_once_ with Template (Package Installation)

```fish
#!/usr/bin/env fish
# .chezmoiscripts/run_once_10-install-packages.fish.tmpl

echo "Installing CLI tools..."

{{ range .packages.tools }}
if not type -q {{ . }}
    echo "Installing {{ . }}..."
    brew install {{ . }}
end
{{ end }}
```

### run_onchange_ (Config-Triggered)

Embed a hash of the config file to re-run when it changes:

```fish
#!/usr/bin/env fish
# .chezmoiscripts/run_onchange_after_30-fisher.fish.tmpl
# fish_plugins hash: {{ include "dot_config/fish/fish_plugins" | sha256sum }}

if type -q fisher
    fisher update
else
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
    fisher update
end
```

### run_onchange_ (Plugin Manager)

```fish
#!/usr/bin/env fish
# .chezmoiscripts/run_onchange_after_50-yazi-plugins.fish.tmpl
# package.toml hash: {{ include "dot_config/yazi/package.toml" | sha256sum }}

if type -q ya
    ya pkg install
end
```

### run_ (Every Apply)

Rarely needed; runs on every `chezmoi apply`:

```fish
#!/usr/bin/env fish
# .chezmoiscripts/run_after_99-notify.fish

echo "Dotfiles updated at "(date)
```

## Fish Script Patterns

### Idempotent Command Check

```fish
if not type -q bat
    brew install bat
end
```

### Idempotent Directory Creation

```fish
if not test -d ~/.config/nvim
    mkdir -p ~/.config/nvim
end
```

### Conditional by OS

```fish
#!/usr/bin/env fish
# .chezmoiscripts/run_once_10-install.fish.tmpl

{{ if eq .chezmoi.os "darwin" -}}
# macOS
brew install coreutils
{{- else if eq .chezmoi.os "linux" -}}
# Linux
sudo apt-get install -y build-essential
{{- end }}
```

### Error Handling

```fish
#!/usr/bin/env fish

function install_tool
    set tool $argv[1]
    if not type -q $tool
        echo "Installing $tool..."
        if not brew install $tool
            echo "Failed to install $tool" >&2
            return 1
        end
    end
end

install_tool bat
install_tool fd
install_tool ripgrep
```

## Script Best Practices

1. **Always be idempotent** - Safe to run multiple times
2. **Check before acting** - Use `type -q`, `test -f`, `test -d`
3. **Use numeric prefixes** - Ensure correct ordering (`00-`, `10-`, `20-`)
4. **Include shebangs** - `#!/usr/bin/env fish` for portability
5. **Template when needed** - `.tmpl` suffix enables data access
6. **Document dependencies** - Comment what must run first
7. **Keep scripts focused** - One purpose per script

## Resetting Script State

```bash
# Reset all run_once_ scripts (will re-run on next apply)
chezmoi state delete-bucket --bucket=scriptState

# Reset all run_onchange_ scripts
chezmoi state delete-bucket --bucket=entryState

# View script state
chezmoi state dump
```

## Debugging Scripts

```bash
# Dry run - shows what would run
chezmoi apply -n -v

# Run with verbose output
chezmoi apply -v

# Run specific script manually
fish ~/.local/share/chezmoi/.chezmoiscripts/run_once_10-install.fish

# Check template output
chezmoi cat ~/.local/share/chezmoi/.chezmoiscripts/run_once_10-install.fish.tmpl
```
