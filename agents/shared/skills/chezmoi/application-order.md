# chezmoi Application Order

Understanding the execution order is critical for writing correct chezmoi configurations, especially scripts.

## High-Level Flow

```text
1. Read source state (source directory + config + data)
2. Read destination state (current home directory)
3. Compute target state (what destination should become)
4. Run `run_before_` scripts (alphabetically)
5. Apply updates (directories, files, symlinks, externals - alphabetically)
6. Run `run_after_` scripts (alphabetically)
```

## Detailed Execution Order

### Phase 1: State Reading

1. **Load `.chezmoiroot`** - Determine source root (if present)
2. **Check `.chezmoiversion`** - Verify chezmoi version meets requirements
3. **Process `.chezmoi.$FORMAT.tmpl`** - Create/update config file (during `init`)
4. **Load config file** - `~/.config/chezmoi/chezmoi.yaml`
5. **Load `.chezmoidata.$FORMAT`** and `.chezmoidata/` - Template data
6. **Load `.chezmoiexternal.$FORMAT`** and `.chezmoiexternals/` - External sources
7. **Process `.chezmoiignore`** - Determine ignored entries
8. **Process `.chezmoiremove`** - Determine entries to remove
9. **Load `.chezmoitemplates/`** - Template partials
10. **Read source entries** - Files, directories, symlinks, scripts

### Phase 2: Destination Reading

- Read current state of all managed paths in home directory
- This happens once, before any changes

### Phase 3: Target State Computation

- Combine source state + config + templates
- Determine what each target should become
- Identify differences from destination

### Phase 4: Before Scripts

Run all `run_before_` scripts in alphabetical order by target name:

```text
run_once_before_00-homebrew.fish  → target: 00-homebrew.fish
run_once_before_10-packages.fish  → target: 10-packages.fish
run_before_20-prep.fish           → target: 20-prep.fish
```

**Critical constraint**: `run_before_` scripts must NOT modify files that chezmoi manages. chezmoi reads destination state once before scripts run and assumes it doesn't change.

### Phase 5: Apply Updates

Updates happen in **alphabetical order by target name** (after stripping attributes).

**Directories are processed before their contents.**

Order example:

| Source | Target | Order |
| --- | --- | --- |
| `dot_bashrc` | `.bashrc` | 1 (`.` sorts first) |
| `dot_config/` | `.config/` | 2 |
| `dot_config/fish/` | `.config/fish/` | 3 |
| `dot_config/fish/config.fish` | `.config/fish/config.fish` | 4 |
| `alpha` | `alpha` | 5 |
| `beta` | `beta` | 6 |

**Externals** (from `.chezmoiexternal.yaml`) are applied during this phase, in alphabetical order with other entries.

### Phase 6: After Scripts

Run all `run_after_` scripts in alphabetical order by target name:

```text
run_onchange_after_50-fisher.fish  → target: 50-fisher.fish
run_after_90-cleanup.fish          → target: 90-cleanup.fish
run_after_99-notify.fish           → target: 99-notify.fish
```

**Safe to depend on**: Files and externals are fully applied. `run_after_` scripts can safely use managed files and external sources.

## Script Execution Within Phases

Scripts without `before_` or `after_` prefixes run in alphabetical order during the apply phase, interleaved with file updates.

```text
run_once_50-middle.fish  → runs at position 50 during apply
```

This is rarely needed - prefer explicit `before_` or `after_` timing.

## Practical Implications

### Safe Patterns

```fish
# run_once_before_00-homebrew.fish
# Safe: installs a tool, doesn't modify managed files
if not type -q brew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
end
```

```fish
# run_onchange_after_50-fisher.fish.tmpl
# Safe: depends on fish_plugins file which is already applied
# fish_plugins hash: {{ include "dot_config/fish/fish_plugins" | sha256sum }}
fisher update
```

### Unsafe Patterns

```fish
# BAD: run_before_ modifying a managed file
# run_once_before_10-bad.fish
echo "extra line" >> ~/.bashrc  # DON'T DO THIS
```

chezmoi already read `.bashrc` - this change will be overwritten or cause conflicts.

### External Dependencies

```fish
# run_onchange_after_80-nvim-plugins.fish
# Safe: external ~/.config/nvim is applied before this runs
nvim --headless "+Lazy! sync" +qa
```

```fish
# BAD: run_before_ depending on external
# run_before_10-bad.fish
~/.oh-my-zsh/tools/install.sh  # May not exist yet!
```

## Alphabetical Ordering Details

Sorting uses target names after stripping all attributes:

| Source | Stripped Target | Sort Key |
| --- | --- | --- |
| `run_once_before_00-a.fish` | `00-a.fish` | `00-a.fish` |
| `run_once_before_10-b.fish` | `10-b.fish` | `10-b.fish` |
| `create_dot_bashrc` | `.bashrc` | `.bashrc` |
| `private_dot_ssh/` | `.ssh/` | `.ssh/` |

**Numeric prefixes** (`00-`, `10-`, etc.) are the standard way to control script order.

## Hooks vs Scripts

**Hooks** (configured in `chezmoi.yaml`) run before/after **commands**, not during apply:

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

Hooks run even with `--dry-run`. Scripts only run during actual apply.

## Debugging Order

```bash
# See what would run in order
chezmoi apply -n -v

# Verbose apply shows execution order
chezmoi apply -v
```
