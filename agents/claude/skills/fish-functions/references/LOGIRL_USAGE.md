# Using logirl for Consistent Logging in Fish Functions

`logirl` is a centralized logging helper that provides consistent, colorful output with structured message formats. It eliminates manual `set_color` formatting and ensures all Fish functions follow the same visual conventions.

## Purpose

Instead of manually crafting colored output, `logirl` provides **opinionated, structured formats**:

```fish
# ❌ Manual (inconsistent, verbose)
echo (set_color red --bold)"[ERROR]"(set_color normal)" File not found"

# ✅ With logirl (consistent, clear)
logirl error "File not found"
```

**Key principle:** Each message type has ONE format. No customization flags. This creates consistency across all functions.

## Quick Start

Use the `logirl_print_test` function to see a quick reference of all message types, which also functions as an easy test to verify `logirl` is working correctly:

```fish
logirl_print_test
```

When making changes to logirl, use this to test via `fish -c "logirl_print_test"`, instead of manually running a bunch of individual bash calls in a row.

## Core Message Types

These are your primary logging tools for errors, warnings, status updates, and progress:

### error

Red text with  icon (bold):

```fish
logirl error "File not found: $filepath"
logirl error "Command failed with exit code $status"
```

**When to use:** Validation failures, missing dependencies, command errors, fatal issues.

### warning

Bright yellow with  icon (bold tag, colored message):

```fish
logirl warning "Deprecated flag used: --old-format"
logirl warning "Rate limit approaching (80% used)"
```

**When to use:** Non-fatal issues, deprecation notices, concerning but recoverable situations.

### info

Cyan with  icon (bold tag, normal message):

```fish
logirl info "Processing 42 files"
logirl info "Current directory: $PWD"
```

**When to use:** Status updates, progress information, neutral notifications.

### success

Bright green with 󰡕 icon (bold):

```fish
logirl success "Build completed successfully"
logirl success "All tests passed"
```

**When to use:** Operation completions, confirmations, successful outcomes.

### special

Bright magenta with `==>` prefix (bold prefix, colored message):

```fish
logirl special "Step 1: Installing dependencies"
logirl special "Step 2: Building project"
logirl special "Step 3: Running tests"
```

**When to use:** Multi-step operation progress, major workflow transitions, highlighted steps.

## Help Text Formatting

These types create structured, consistent help output for `--help` flags:

### help_usage

**IMPORTANT:** Always use `help_usage` for the Usage line (not `help_header` with 2 args). This avoids double spacing from consecutive `help_header` calls and provides clearer formatting.

Bold bright green "Usage:" prefix with the usage pattern:

```fish
logirl help_usage "mytool [OPTIONS] <file>"
# Output:
#
# Usage: mytool [OPTIONS] <file>
#
```

**When to use:** The Usage line that comes immediately after the one-sentence description (via plain `echo`)

### help_header

Bold bright green headers with automatic newlines above and below. Takes 1 argument:

**Section headers:**

```fish
logirl help_header "Options"
# Output:
#
# Options:
#

logirl help_header "Examples"
# Output:
#
# Examples:
#
```

**When to use:** Section dividers (Options, Examples, Commands, Arguments, etc.)

### help_cmd

Bold text for commands/subcommands + description (2 args):

```fish
logirl help_cmd "mytool" "Process input files"
# Output: mytool     Process input files
#         ^^^^^^ (bold)
```

**When to use:** Documenting subcommands or command examples.

### help_flag

Italic blue text for flags + description. Takes flag spec `short/long` or `short/long=ARG`:

**Flags without arguments:**

```fish
logirl help_flag "h/help" "Show this help message"
# Output: -h, --help              Show this help message
#         ^^^^^^^^^^ (italic, blue)

logirl help_flag "v/verbose" "Enable verbose output"
# Output: -v, --verbose           Enable verbose output
```

**Flags with arguments:**

```fish
logirl help_flag "o/output" "FILE" "Output file path"
# Output: -o, --output <FILE>     Output file path
#         ^^^^^^^^^^^^^^^^^^^ (italic, blue)

logirl help_flag "w/width" "PX" "Set output width in pixels"
# Output: -w, --width <PX>        Set output width in pixels
#         ^^^^^^^^^^^^^^^^ (italic, blue)
```

**When to use:** Documenting flags in help text

## Utility Types

### dim

Dimmed/grayed out text:

```fish
logirl dim "This feature is deprecated"
logirl dim "(disabled)"
```

**When to use:** Disabled features, old versions, de-emphasized information.

## Practical Examples

### Complete Help Text

Follows the pattern: One-sentence description (via plain echo) → Usage (via `help_usage`) → Commands section (if applicable) → Options section → Examples (if applicable)

```fish
function mytool -d "Example tool with full help text"
    argparse h/help v/verbose 'o/output=' -- $argv
    or return

    if set -q _flag_help
        echo "Process files with advanced features."
        logirl help_usage "mytool [OPTIONS] <COMMAND> /path/to/file"
        logirl help_header "Commands"
        logirl help_cmd "examine" "Process input files"
        logirl help_cmd "convert" "Convert file formats"
        logirl help_header "Options"
        logirl help_flag "h/help" "Show this help message"
        logirl help_flag "v/verbose" "Enable verbose output"
        logirl help_flag "o/output" "FILE" "Specify output file path"
        logirl help_header "Examples"
        printf "  mytool examine data.csv\n"
        printf "  mytool -v convert input.txt\n"
        return 0
    end

    # Rest of function...
end
```

### Error Handling with Context

```fish
function process_file -d "Process a file"
    if test (count $argv) -lt 1
        logirl error "Missing required argument: <file>"
        logirl info "Try `process_file --help`"
        return 1
    end

    set -l file $argv[1]
    if not test -f "$file"
        logirl error "File not found: $file"
        return 1
    end

    if not test -r "$file"
        logirl error "Permission denied: $file"
        return 1
    end

    logirl info "Processing file: $file"
    # ... do work ...
    logirl success "File processed successfully"
end
```

### Multi-Step Operation with Progress

```fish
function deploy -d "Deploy application"
    logirl special "Step 1: Running tests"
    if not npm test
        logirl error "Tests failed, aborting"
        return 1
    end

    logirl special "Step 2: Building project"
    if not npm run build
        logirl error "Build failed"
        return 1
    end

    logirl special "Step 3: Deploying to server"
    if not rsync -avz ./dist/ server:/var/www/
        logirl error "Deploy failed"
        return 1
    end

    logirl success "Deploy complete!"
end
```

### Dependency Validation

```fish
function video_convert -d "Convert video files"
    if not type -q ffmpeg
        logirl error "ffmpeg not found in PATH"
        logirl info "Install with: brew install ffmpeg"
        return 127
    end

    if not type -q ffprobe
        logirl warning "ffprobe not found, some features disabled"
    end

    logirl info "Starting video conversion"
    # ... conversion logic ...
end
```

### Interactive Confirmation

```fish
function cleanup -d "Remove temporary files"
    set -l files (fd -t f -e tmp -e temp)

    if test (count $files) -eq 0
        logirl info "No temporary files found"
        return 0
    end

    logirl warning "Found "(count $files)" temporary files"
    printf "  %s\n" $files

    read -P "Delete these files? (y/N) " -n 1 confirm
    if test "$confirm" = y
        rm $files
        logirl success "Deleted "(count $files)" files"
    else
        logirl info "Cancelled"
    end
end
```

### Verbose Mode

```fish
function backup -d "Backup files"
    argparse v/verbose -- $argv
    or return

    set -l files *.txt
    logirl special "Starting backup of "(count $files)" files"

    for file in $files
        if set -q _flag_verbose
            logirl info "Backing up: $file"
        end
        cp $file backup/$file
    end

    logirl success "Backup complete"
end
```

## Best Practices

### ✅ Do

**Use semantic message types:**

```fish
logirl error "..."      # For failures that stop execution
logirl warning "..."    # For issues that don't stop execution
logirl info "..."       # For neutral status updates
logirl success "..."    # For successful completions
logirl special "..."    # For progress/workflow steps
```

**Provide context in messages:**

```fish
logirl error "File not found: $filepath"  # ✅ Specific
logirl error "File not found"             # ❌ Vague
```

**Structure help text consistently:**

```fish
# Always: plain echo description → help_usage → commands (if applicable) → options
if set -q _flag_help
    echo "Tool that does xyz..."
    logirl help_usage "toolname [OPTIONS] <args>"
    logirl help_header "Commands"
    logirl help_cmd "cmd_one" "..."
    logirl help_cmd "cmd_two" "..."
    logirl help_header "Options"
    logirl help_flag "h/help" "..."
    logirl help_flag "v/verbose" "..."
    return 0
end
```

**Return appropriate exit codes:**

```fish
logirl error "Something failed"
return 1    # ✅ Always pair errors with returns
```

### ❌ Don't

**Don't manually format messages that logirl handles:**

```fish
# ❌ Manual
echo (set_color red --bold)"[ERROR]"(set_color normal)" Message"

# ✅ Use logirl
logirl error "Message"
```

**Don't forget error handling:**

```fish
# ❌ No return code
logirl error "Failed"
# Function continues...

# ✅ Exit on error
logirl error "Failed"
return 1
```

Reference `./ERROR_HANDLING.md` for guidance on more complex error handling scenarios.

**Don't mix logging styles unless printing normal text:**

```fish
# ❌ Inconsistent
logirl error "Error one"
echo (set_color yellow)"Warning"(set_color normal)

# ✅ Consistent
logirl error "Error one"
logirl warning "Warning message"
```

## Color Reference

| Type | Colors | Icon/Prefix | Notes |
| ------ | -------- | ------------- | ----- |
| `error` | Red, bold |  | - |
| `warning` | Bright yellow (tag: bold) |  | - |
| `info` | Cyan (tag: bold) |  | - |
| `success` | Bright green, bold | 󰡕 | - |
| `special` | Bright magenta (prefix: bold) | ==> | - |
| `help_usage` | Bright green, bold | Usage: | Auto newlines, 1 arg (usage pattern) |
| `help_header` | Bright green, bold | - | Auto newlines above/below, 1 arg only |
| `help_cmd` | Bold | - | For commands/subcommands |
| `help_flag` | Italic blue | - | Format: `s/long` or `s/long=ARG` |
| `normal` | Default terminal colors | - | - |
| `dim` | Dimmed | - | - |

## Migration from Manual Formatting

If refactoring existing functions:

```fish
# Before
echo (set_color red --bold)"[ERROR]"(set_color normal)" File not found"
echo (set_color cyan --bold)"[INFO]"(set_color normal)" Processing..."
echo (set_color green --bold)" "(set_color normal)" Done!"

# After
logirl error "File not found"
logirl info "Processing..."
logirl success "Done!"
```

This maintains consistent styling and makes the code more readable and maintainable.

## Summary

`logirl` provides **12 message types** organized into 3 categories:

1. **Core messages** (5): `error`, `warning`, `info`, `success`, `special`
2. **Help text** (5): `help_usage`, `help_header`, `help_cmd`, `help_flag`
3. **Utility** (2): `normal`, `dim`

Each type has exactly ONE format. No customization. This creates consistency across all Fish functions and makes the codebase more maintainable.

## Developing

When making updates to the `logirl` function itself, remember to take care of the rest of the ecosystem:

1. Use the `logirl_print_test` function to verify all message types render correctly
2. Update the test function as needed when adding new types or options
3. Update this document and any references in the fish-function-development Skill to reflect changes
