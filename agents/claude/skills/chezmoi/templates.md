# chezmoi Templates Reference

Templates use Go's `text/template` syntax with `{{ }}` delimiters and [sprig](http://masterminds.github.io/sprig/) functions.

## Built-in Variables

### `.chezmoi` Object

| Variable | Example Value | Description |
| --- | --- | --- |
| `.chezmoi.os` | `"darwin"`, `"linux"` | Operating system |
| `.chezmoi.arch` | `"amd64"`, `"arm64"` | Architecture |
| `.chezmoi.hostname` | `"my-laptop"` | Machine hostname |
| `.chezmoi.homeDir` | `"/Users/user"` | Home directory |
| `.chezmoi.sourceDir` | `"~/.local/share/chezmoi"` | Source directory |
| `.chezmoi.workingTree` | `"~/.local/share/chezmoi"` | Git working tree |
| `.chezmoi.username` | `"user"` | Current username |
| `.chezmoi.uid` | `"501"` | User ID |
| `.chezmoi.gid` | `"20"` | Group ID |
| `.chezmoi.fqdnHostname` | `"my-laptop.local"` | FQDN hostname |

### Custom Data

Data from `.chezmoidata.yaml` or config file `data:` section:

```yaml
# .chezmoidata.yaml
email: user@example.com
features:
  work: true
```

Access: `{{ .email }}`, `{{ .features.work }}`

## Template Functions (sprig)

### String Functions

```
{{ "hello" | upper }}              # HELLO
{{ "HELLO" | lower }}              # hello
{{ "hello" | title }}              # Hello
{{ "  hello  " | trim }}           # hello
{{ "hello" | replace "l" "L" }}    # heLLo
{{ "a,b,c" | split "," }}          # [a b c]
{{ list "a" "b" | join "," }}      # a,b
```

### Conditionals & Logic

```
{{ if eq .chezmoi.os "darwin" }}macOS{{ end }}
{{ if ne .chezmoi.os "windows" }}not windows{{ end }}
{{ if and (eq .chezmoi.os "linux") (eq .chezmoi.arch "arm64") }}linux arm{{ end }}
{{ if or .personal .work }}has context{{ end }}
{{ default "fallback" .optional }}
{{ ternary "yes" "no" .condition }}
```

### List Operations

```
{{ range .items }}{{ . }}{{ end }}
{{ range $i, $v := .items }}{{ $i }}: {{ $v }}{{ end }}
{{ first .list }}
{{ last .list }}
{{ has "item" .list }}
{{ without .list "exclude" }}
{{ concat .list1 .list2 }}
```

### File Operations

```
{{ include "path/to/file" }}                    # Include file contents
{{ include "file" | sha256sum }}                # Hash for run_onchange_
{{ .chezmoi.sourceDir | joinPath "subdir" }}    # Build paths
```

### Environment & System

```
{{ env "HOME" }}                    # Environment variable
{{ lookPath "brew" }}               # Find executable path (empty if not found)
{{ stat "/path/to/file" }}          # File info (nil if doesn't exist)
{{ glob "*.txt" }}                  # Match files
```

## Machine-Specific Templates

### Using hostname

```
{{ if eq .chezmoi.hostname "work-laptop" -}}
# Work configuration
export HTTP_PROXY=http://proxy.work.com:8080
{{- else if eq .chezmoi.hostname "home-desktop" -}}
# Home configuration
{{- end }}
```

### Using custom data

`.chezmoidata.yaml`:

```yaml
machine:
  type: work  # or "personal"
  company: acme
```

Template:

```
{{ if eq .machine.type "work" -}}
# Work-specific settings
export COMPANY={{ .machine.company }}
{{- end }}
```

### Using OS detection

```
{{ if eq .chezmoi.os "darwin" -}}
# macOS
alias ls="gls --color=auto"
{{- else if eq .chezmoi.os "linux" -}}
# Linux
alias ls="ls --color=auto"
{{- end }}
```

## Template Debugging

```bash
# Test template rendering
chezmoi execute-template '{{ .chezmoi.os }}'

# Test template file
chezmoi execute-template < ~/.local/share/chezmoi/dot_bashrc.tmpl

# Show what a file would contain
chezmoi cat ~/.bashrc

# Show available data
chezmoi data

# Verbose diff shows template output
chezmoi diff -v
```

## Common Patterns

### Conditional blocks with proper whitespace

```
{{- if .feature_enabled }}
# Feature is enabled
export FEATURE=1
{{- end }}
```

Note: `{{-` trims whitespace before, `-}}` trims after.

### Including optional sections

```
# Core config
set -gx EDITOR nvim

{{ if stat (joinPath .chezmoi.homeDir ".work-config") -}}
# Work config exists, source it
source ~/.work-config
{{- end }}
```

### Platform-specific package lists

`.chezmoidata.yaml`:

```yaml
packages:
  common: [bat, fd, ripgrep]
  darwin: [coreutils, gnu-sed]
  linux: [build-essential]
```

Script template:

```fish
#!/usr/bin/env fish
{{ range .packages.common }}
brew install {{ . }}
{{ end }}

{{ if eq .chezmoi.os "darwin" }}
{{ range .packages.darwin }}
brew install {{ . }}
{{ end }}
{{ end }}
```

### Encrypted values

Use `chezmoi add --encrypt` for secrets:

```text
{{ onepasswordRead "op://vault/item/field" }}  # 1Password
{{ pass "path/to/secret" }}                     # pass
{{ secret "key" }}                              # chezmoi's secret manager
```

### Symlink to source directory

Common pattern for externally-modified files:

```text
{{ .chezmoi.sourceDir }}/tool-config.json
```

### Modify templates

For `modify_` scripts, access current file content:

```text
{{- $config := .chezmoi.stdin | mustFromJson -}}
{{- $config = set $config "key" "value" -}}
{{ $config | toPrettyJson }}
```

## Template Partials

Store reusable templates in `.chezmoitemplates/`:

```text
# .chezmoitemplates/header
# Managed by chezmoi - do not edit
# Host: {{ .chezmoi.hostname }}
```

Use in templates:

```text
{{ template "header" . }}
# rest of config...
```
