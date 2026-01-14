# 🎨 logirl & c - Consistent, Beautiful Fish Function Output

A pair of helper functions for creating consistent, colorful output in Fish shell functions.

## Quick Start

```fish
logirl error "File not found"
logirl success "Build complete!"
echo "Updated from "(c s v1.0)" to "(c s v2.0)
```

## Why These Functions?

**Before:**

```fish
function my_func
    # Declare colors in every function 😫
    set -l normal (set_color normal)
    set -l success (set_color -o brgreen)
    set -l error (set_color red)

    echo $error"[ERROR]"$normal" Something failed"
    echo $success"OK"$normal
end
```

**After:**

```fish
function my_func
    # No declarations needed! 🎉
    logirl error "Something failed"
    logirl success_msg "OK"
end
```

## logirl - Structured Messages

For complete messages with standardized formatting.

### Basic Usage

```fish
logirl <type> "message"
```

### Message Types

| Type | Output | Use Case |
| ------ | -------- | ---------- |
| `error` | `[ERROR] message` (red, bold tag) | Error messages |
| `warning` | `[WARNING] message` (yellow, bold tag) | Warnings |
| `info` | `[INFO] message` (cyan bold tag) | Info/status |
| `success` | `[SUCCESS] message` (green, bold tag) | Success messages |
| `special` | `==> message` (magenta, bold) | Progress/steps |
| `error_msg` | `message` (red, no tag) | Plain error text |
| `success_msg` | `message` (green, no tag) | Plain success text |
| `special_msg` | `message` (magenta, no tag) | Plain special text |
| `help_header` | `message` (bold bright green) | Help headings |
| `help_cmd` | `message` (bold bright magenta) | Commands/flags |
| `help_body` | `message` (blue) | Help content |
| `dim` | `message` (dimmed) | Deprecated/old |
| `normal` | `message` (normal) | Plain text |

### Options

```fish
-h, --help         Show help
-n, --no-newline   Don't add newline
-t, --tag=TEXT     Custom tag (e.g., -t " git")
-i, --icon=ICON    Add icon before message
```

### Examples

```fish
# Standard messages
logirl error "Connection failed"
logirl success "Build complete!"
logirl special "Installing dependencies..."

# Custom tags
logirl -t " fnm" special_msg "Node.js updated"
logirl -t "[BUILD]" info "Compiling 47 files..."

# With icons
logirl -i "⚡" warning "Update available"
logirl -i "" success "All tests passed"

# No newline (for progress indicators)
logirl -n special "Processing"
printf "."
printf "."
printf " done!\n"
```

## c - Inline Colored Text

For embedding colored text within echo/printf statements.

### Basic Usage

```fish
echo "Status: "(c s OK)
echo "From "(c s v1.0)" to "(c s v2.0)
```

### Color Types

| Type | Aliases | Color | Use Case |
| ------ | --------- | ------- | ---------- |
| `s` | `success` | Bright green, bold | Success, versions, active values |
| `e` | `error` | Red | Errors, failures |
| `w` | `warn`, `warning` | Bright yellow, bold | Warnings |
| `i` | `info` | Cyan | Info, neutral values |
| `m` | `cmd`, `command` | Bright magenta, bold | Commands, flags |
| `d` | `dim`, `old`, `deprecated` | Dimmed | Old/deprecated values |
| `b` | `bold` | Bold | Emphasis |
| `n` | `normal`, `reset` | Normal | Reset colors |

### Examples

```fish
# Version updates
echo "Updated from "(c s v18.0.0)" to "(c s v20.0.0)

# Commands
echo "Run "(c m "npm install")" to install"

# Old values
echo "Removing old config: "(c d ~/.oldrc)

# Combined with logirl
logirl special_msg "Installing "(c s package-name)"..."
logirl success "Updated to "(c s v2.0.0)
```

## Combining logirl and c

The real power comes from using them together:

```fish
function deploy -d "Deploy application"
    logirl special "Starting deployment..."

    logirl info "Building for "(c s production)" environment"

    if not npm run build
        logirl error "Build failed"
        return 1
    end

    logirl success "Built in "(c s 2.4s)
    logirl special_msg "Deploying to "(c s production)" server..."

    rsync -avz ./dist/ server:/var/www/

    logirl -i "" success "Deployment complete!"
    echo "View at: "(c m "https://example.com")
end
```

## Migrating Existing Functions

### 1. Remove color declarations

```fish
# Delete these:
set -l normal (set_color normal)
set -l success (set_color -o brgreen)
set -l error (set_color red)
# etc...
```

### 2. Replace error messages

```fish
# Before:
echo (set_color red --bold)"[ERROR]"(set_color normal)" File not found"

# After:
logirl error "File not found"
```

### 3. Replace success messages

```fish
# Before:
echo (set_color -o brgreen)" "(set_color normal)"Build complete"

# After:
logirl -i "" success "Build complete"
```

### 4. Replace inline colors

```fish
# Before:
echo "Updated from "$success"v1.0"$normal" to "$success"v2.0"$normal

# After:
echo "Updated from "(c s v1.0)" to "(c s v2.0)
```

## Color Convention Reference

These conventions are centralized in `logirl.fish` and `c.fish`:

| Element | Color | Weight | Usage |
| --------- | ------- | -------- | ------- |
| Error tags | Red | Bold | `[ERROR]` |
| Error messages | Red | Normal | Error descriptions |
| Warning tags | Bright Yellow | Bold | `[WARNING]` |
| Warning messages | Bright Yellow | Normal | Warning descriptions |
| Info tags | Cyan | Bold | `[INFO]` |
| Info messages | Normal | Normal | Info descriptions |
| Success tags | Bright Green | Bold | `[SUCCESS]` |
| Success messages | Bright Green | Normal | Success descriptions |
| Special/progress | Bright Magenta | Bold | `==>`, step indicators |
| Help headers | Bright Green | Bold | Section headings |
| Help commands | Bright Magenta | Bold | Commands, flags |
| Help body | Blue | Normal | Help text content |
| Versions/values | Bright Green | Bold | Version numbers, paths |
| Commands/flags | Bright Magenta | Bold | Command names |
| Old/deprecated | Any | Dim | Removed/old values |

## Benefits

✅ **DRY** - No repeated color declarations
✅ **Consistent** - Same styling across all functions
✅ **Maintainable** - Change conventions in one place
✅ **Readable** - Semantic, self-documenting code
✅ **Discoverable** - Built-in help with `--help`
✅ **Flexible** - Custom tags, icons, inline usage

## Testing

```fish
# Test logirl
logirl --help
logirl error "Test error"
logirl success "Test success"

# Test c
c --help
echo "Status: "(c s OK)

# Test together
source ~/.config/fish/functions/logirl.fish
source ~/.config/fish/functions/c.fish
logirl special_msg "Installing "(c s package)"@"(c s 1.0.0)
```

## See Also

- `LOGIRL_EXAMPLE.md` - Detailed before/after examples
- `fnmup_refactored_example.fish` - Real-world refactoring example
- `logirl --help` - Complete message type reference
- `c --help` - Complete color type reference
