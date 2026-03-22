---
paths:
  - "**/*.fish"
  - "**/*.fish.tmpl"
---

# Fish Shell Conventions

Fish shell syntax and style guidelines.

## Fish vs bash/zsh (Common Footguns)

When writing Fish scripts:

| bash/zsh | Fish |
| --- | --- |
| `[[ ... ]]` | `test ...` or `[ ... ]` |
| `command -v cmd` | `type -q cmd` |
| `VAR=value` | `set VAR value` |
| `export VAR=value` | `set -gx VAR value` |
| `&&` / `\|\|` | `; and` / `; or` |
| `function foo() { }` | `function foo; end` |

## Variable Scope

Prefer **global** or **local** scope over universal, never add a universal variable unless specifically instructed to:

```fish
# Good: Global scope
set -gx EDITOR nvim

# Good: Local scope (in functions)
set -l temp_var "value"

# Avoid always: Universal scope (persists across sessions)
set -U some_var "value"  # DO NOT DO THIS
```

Fish is moving away from universal variables. The theming system moved to global scope in recent releases.

## Function Style

Filename must match function name:

```fish
# In: functions/my_function.fish
function my_function -d "Brief description"
    # Add --help flag
    if contains -- --help $argv
        echo "Usage: my_function [options]"
        echo "Options:"
        echo "  --help    Show this help"
        return 0
    end

    # Function body
end
```

## Idiomatic Patterns

### Command Checks

```fish
# Good
if type -q command_name
    # Command exists
end

# Avoid
if command -v command_name >/dev/null 2>&1
    # bash pattern
end
```

### Path Manipulation

```fish
# Good: Fish path handling
set -gx PATH $HOME/.local/bin $PATH

# Also good: fish_add_path (preferred)
fish_add_path $HOME/.local/bin
```

### Conditionals

```fish
# Good: Fish test syntax
if test -f $file; and test -r $file
    # File exists and is readable
end

# Also good: [ ] syntax
if [ -f $file ] && [ -r $file ]
    # Same
end

# Avoid: bash [[  ]]
```

## Error Handling

```fish
# Check command success
if not some_command
    echo "Error: command failed" >&2
    return 1
end

# Or use ; and / ; or
some_command; or return 1
```

## Comments

- Explain **rationale**, not obvious actions
- Note macOS-specific behavior
- Beginner-accessible tone
- Use `#` for comments (same as bash)

## Style

- **Indentation:** 2 spaces (no tabs)
- **Line length:** Soft limit 100 chars
- **Descriptive names:** `set -l matching_files_list` not `set -l files`
