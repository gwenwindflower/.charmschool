# chezmoi Special Files and Directories

Special files and directories in the source directory control chezmoi behavior. They all begin with `.chezmoi`.

## Special Files

### `.chezmoi.$FORMAT.tmpl`

Config template processed during `chezmoi init`. Creates/updates `~/.config/chezmoi/chezmoi.yaml`.

**Formats**: `.yaml`, `.toml`, `.json`

**Processed before**: All other special files

**Use for**: Interactive setup prompts, machine-specific configuration

Example `.chezmoi.yaml.tmpl`:

```yaml
{{- $email := promptString "email" -}}
{{- $name := promptString "name" -}}
data:
  email: {{ $email | quote }}
  name: {{ $name | quote }}
```

### `.chezmoidata.$FORMAT`

Static data available to all templates via `.` accessor.

**Formats**: `.yaml`, `.toml`, `.json`

**Use for**: Template variables, package lists, feature flags

Example `.chezmoidata.yaml`:

```yaml
packages:
  cli: [bat, fd, ripgrep]
  gui: [firefox, slack]
email: user@example.com
features:
  work: false
  personal: true
```

Access in templates: `{{ .packages.cli }}`, `{{ .email }}`, `{{ .features.work }}`

### `.chezmoiignore`

Patterns for files/directories to ignore (not manage).

**Syntax**: Gitignore-style patterns, supports templates

**Use for**: Machine-specific exclusions, OS-specific files

Example:

```text
# Always ignore
README.md
LICENSE

# Template-based ignoring
{{ if ne .chezmoi.os "darwin" }}
.config/macos-only/
{{ end }}

{{ if ne .chezmoi.os "linux" }}
.config/linux-only/
{{ end }}

# Ignore by hostname
{{ if ne .chezmoi.hostname "work-laptop" }}
.config/work/
{{ end }}
```

### `.chezmoiremove`

Files to remove from destination during apply.

**Syntax**: One path per line, relative to home directory

**Use for**: Cleaning up deprecated dotfiles

Example:

```text
.old_bashrc
.config/deprecated-tool
```

### `.chezmoiexternal.$FORMAT`

External sources (git repos, archives) to include.

**Formats**: `.yaml`, `.toml`, `.json`

**Use for**: Third-party configs, oh-my-zsh, spaceship prompt, etc.

Example `.chezmoiexternal.yaml`:

```yaml
".oh-my-zsh":
  type: archive
  url: https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz
  stripComponents: 1
  refreshPeriod: 168h  # 1 week

".config/nvim":
  type: git-repo
  url: https://github.com/user/nvim-config.git
  refreshPeriod: 168h
  clone:
    args: ["--depth", "1"]

".local/bin/fzf":
  type: file
  url: https://github.com/junegunn/fzf/releases/download/0.44.0/fzf-0.44.0-{{ .chezmoi.os }}_{{ .chezmoi.arch }}.tar.gz
  executable: true
```

**Types**: `archive`, `archive-file`, `file`, `git-repo`

Refresh with: `chezmoi apply -R` or `chezmoi apply --refresh-externals`

### `.chezmoiversion`

Minimum chezmoi version requirement.

**Processed before**: Any operations applied

**Use for**: Ensuring compatible chezmoi version

Example:

```text
2.40.0
```

### `.chezmoiroot`

Changes the root of the source state.

**Processed first**: Before anything else

**Use for**: Nested source directories in monorepos

Example (if source files are in `home/` subdirectory):

```text
home
```

## Special Directories

### `.chezmoidata/`

Alternative location for data files. Files here are merged into template data.

**Use for**: Organizing large data sets, separating concerns

Structure:

```text
.chezmoidata/
├── packages.yaml
├── hosts.yaml
└── features.yaml
```

All files merged into template data.

### `.chezmoitemplates/`

Reusable template partials.

**Use for**: Shared template snippets, DRY template code

Example `.chezmoitemplates/header`:

```text
# Managed by chezmoi
# Machine: {{ .chezmoi.hostname }}
# Last updated: {{ now | date "2006-01-02" }}
```

Use in templates:

```text
{{ template "header" . }}
# Rest of config...
```

### `.chezmoiexternals/`

Alternative location for external source definitions.

**Use for**: Organizing many external sources

Structure:

```text
.chezmoiexternals/
├── oh-my-zsh.yaml
├── nvim.yaml
└── fzf.yaml
```

Each file follows `.chezmoiexternal.yaml` format.

### `.chezmoiscripts/`

Scripts executed during `chezmoi apply`.

**See**: [./scripts.md](./scripts.md) for full documentation.

Common patterns:

```text
.chezmoiscripts/
├── run_once_before_00-install-homebrew.fish
├── run_once_10-install-packages.fish.tmpl
├── run_onchange_after_50-fisher.fish.tmpl
└── run_after_99-notify.fish
```

## Processing Order

1. `.chezmoiroot` - Set source root
2. `.chezmoiversion` - Check version
3. `.chezmoi.$FORMAT.tmpl` - Create/update config
4. `.chezmoidata.$FORMAT` / `.chezmoidata/` - Load template data
5. `.chezmoiexternal.$FORMAT` / `.chezmoiexternals/` - Load external sources
6. `.chezmoiignore` - Determine ignored files
7. `.chezmoiremove` - Determine files to remove
8. `.chezmoitemplates/` - Load template partials
9. Source files/directories/symlinks/scripts - Process entries
