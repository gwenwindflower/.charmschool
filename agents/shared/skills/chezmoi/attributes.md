# chezmoi Source State Attributes

Source state attributes control how chezmoi transforms source files into target files. Attributes are specified as **prefixes** and **suffixes** on filenames in the source directory.

## Prefix Order

**Prefix order matters.** chezmoi parses prefixes in a specific order. The canonical order for files:

```text
remove_ | create_ | modify_ | run_ [once_ | onchange_] [before_ | after_]
  → encrypted_ → private_ → readonly_ → empty_ → executable_ → dot_ → literal_
```

For directories:

```text
remove_ | exact_ | external_
  → encrypted_ → private_ → readonly_ → dot_ → literal_
```

For symlinks:

```text
symlink_ → dot_ → literal_
```

## Complete Prefix Reference

### File/Directory Attributes

| Prefix | Applies To | Effect |
| --- | --- | --- |
| `dot_` | files, dirs, symlinks | Rename to leading `.` (`dot_bashrc` → `.bashrc`) |
| `private_` | files, dirs | Remove group/world permissions (chmod go-rwx) |
| `readonly_` | files, dirs | Remove write permissions (chmod a-w) |
| `executable_` | files only | Add execute permission (chmod +x) |
| `empty_` | files only | Preserve file even if empty (default: empty files removed) |
| `encrypted_` | files, dirs | Encrypt in source state (strips `.age`/`.asc` suffix) |
| `exact_` | dirs only | Remove entries not in source state |
| `external_` | dirs only | Ignore attributes in child entries |
| `literal_` | all | Stop parsing prefixes (use for literal `dot_` etc.) |

### File Creation/Modification

| Prefix | Effect |
| --- | --- |
| `create_` | Create file only if it doesn't exist (don't overwrite) |
| `modify_` | Script that modifies existing file (receives current via stdin) |
| `remove_` | Remove file/symlink, or empty directory |

### Script Attributes

| Prefix | Effect |
| --- | --- |
| `run_` | Execute as script during apply |
| `once_` | Run only once (tracked by content hash) |
| `onchange_` | Run when content changes (tracked by content + filename hash) |
| `before_` | Run before file updates |
| `after_` | Run after file updates |

## Suffix Reference

| Suffix | Effect |
| --- | --- |
| `.tmpl` | Process as Go template |
| `.literal` | Stop parsing suffixes |
| `.age` | Stripped from encrypted files (age encryption) |
| `.asc` | Stripped from encrypted files (GPG encryption) |

## Examples

### Basic File Attributes

```text
dot_bashrc                    → ~/.bashrc
dot_bashrc.tmpl               → ~/.bashrc (templated)
private_dot_ssh/              → ~/.ssh/ (mode 700)
executable_dot_local/bin/foo  → ~/.local/bin/foo (executable)
readonly_dot_config/settings  → ~/.config/settings (read-only)
empty_dot_gitkeep             → ~/.gitkeep (preserved even if empty)
```

### Combined Attributes

```text
private_executable_dot_script → ~/.script (private + executable)
encrypted_dot_secrets.yaml    → ~/.secrets.yaml (decrypted on apply)
```

### Directory Attributes

```text
exact_dot_config/fish/        → ~/.config/fish/ (removes unmanaged files)
private_dot_gnupg/            → ~/.gnupg/ (mode 700)
external_dot_oh-my-zsh/       → ~/.oh-my-zsh/ (children ignore parent attrs)
```

### Script Names

```text
run_once_before_00-install.fish       → Run once, before updates, first
run_onchange_after_50-sync.fish.tmpl  → Run on change, after updates, templated
run_99-notify.fish                    → Run every apply, last
```

### Symlinks

```text
symlink_dot_gitconfig         → ~/.gitconfig (symlink, target = file content)
symlink_dot_config/nvim.tmpl  → ~/.config/nvim (symlink, templated target)
```

### Create vs Modify

```text
create_dot_bashrc             → Create ~/.bashrc only if missing
modify_dot_bashrc             → Script that patches ~/.bashrc
```

### Literal Prefix

```text
literal_dot_dot_file          → ~/.dot_file (literal `dot_` in name)
```

## Attribute Stripping for Ordering

During apply, chezmoi sorts entries alphabetically by **target name** (after stripping attributes). Examples:

| Source Name | Target Name | Sort Position |
| --- | --- | --- |
| `dot_bashrc` | `.bashrc` | Before `alpha` |
| `create_dot_config` | `.config` | Before `alpha` |
| `run_before_10-foo.fish` | `10-foo.fish` | Early in scripts |

Directories are always processed before their contents.
