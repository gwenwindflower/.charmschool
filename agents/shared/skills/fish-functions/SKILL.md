---
name: fish-functions
description: Write Fish shell functions in idiomatic fish syntax with delightful UX. Use when (1) Creating new Fish functions, (2) Refactoring or improving existing functions, (3) Adding flags, help text, or error handling, (4) Working with any `*.fish` files, (5) Converting bash/zsh scripts to Fish, (6) Debugging Fish syntax issues
allowed-tools:
  - WebFetch(domain:fishshell.com)
---

# Fish Function Development

Create and enhance Fish shell functions with excellent developer experience, colorful output, and robust error handling.

## Repository Context

- **Location:** `shell/fish/functions/`
- **Filename convention:** `function_name.fish` (filename must match function name exactly)
- **Linking:** You *do not* need to manually link functions, the entire shell/fish/functions/ directory is already symlinked to the correct location, adding functions in the dotfiles projects automatically makes them available in Fish
- **Testing:** You work in a separate bash environment, to test commands requires `fish -c "[commands]"` - given that and the potentially dangerous effects of shell commands in development, you should have the user manually test for tasks using this Skill rather than validating yourself and reporting success. If you are instructed to test yourself, you will automatically pick up new functions without needing to reload anything, because you are always calling a new subshell.

## Instructions

### Function Structure

Every function follows this structure (scale appropriately for complexity):

```fish
function funcname -d "Brief description of what this function does"
    # Parse arguments first (if using flags)
    argparse h/help 'o/option=' -- $argv
    or return

    # Handle --help early exit
    if set -q _flag_help
        # Help text here (use logirl for consistent formatting)
        return 0
    end

    # Validate dependencies
    if not type -q required_cmd
        logirl error "required_cmd not found in PATH"
        return 127
    end

    # Validate inputs
    if test (count $argv) -lt 1
        logirl error "Missing required argument"
        printf "Try: funcname --help\n"
        return 1
    end

    # Main logic here
    # Prefer guards that error helpfully and exit early for other conditions

    return 0
end
```

### Argument Parsing with argparse

Use Fish's built-in `argparse` for flag handling:

```fish
# Basic flags
argparse h/help v/verbose -- $argv
or return  # Exit if parsing fails

# Flags with required values
argparse 'w/width=' 'o/output=' -- $argv

# Access flags
if set -q _flag_verbose
    echo "Verbose mode enabled"
end
set width $_flag_width  # Get value
```

For simple positional args without flags, use `--argument-names`:

```fish
function greet -d "Greet someone" --argument-names name
    echo "Hello, $name!"
end
```

### Adding Help Text

Include comprehensive help for any function with flags or non-obvious usage.

**Required structure:** Description (plain echo) → Usage → Commands (if applicable) → Options → Examples (optional)

**Use `logirl` for consistent help formatting:**

```fish
if set -q _flag_help
    echo "Brief description of what this function does."
    logirl help_usage "funcname [OPTIONS] <required_arg>"
    logirl help_header "Options"
    logirl help_flag "h/help" "Show this help message"
    logirl help_flag "v/verbose" "Enable verbose output"
    logirl help_flag "o/output" "FILE" "Specify output file path"
    logirl help_header "Examples"
    printf "  funcname file.txt\n"
    printf "  funcname -v -o out.txt in\n"
    return 0
end
```

**Key patterns:**

- Start with plain `echo` for the one-sentence description
- **Use `help_usage` for the Usage line** (avoids double spacing from consecutive `help_header` calls)
- `help_header` takes 1 arg for section headers (Options, Examples, Commands, etc.)
- `help_flag` takes 2 args for boolean flags: `logirl help_flag "h/help" "Description"`
- `help_flag` takes 3 args for flags with values: `logirl help_flag "o/output" "FILE" "Description"`

If you need to do something beyond this with the help text, the [logirl reference guide](logirl-custom-logging-framework.md) has more examples of how to create consistent, advanced help text easily with `logirl`, as well as any other logging needs for fish scripts and functions.

### Error Handling

**Recommended:** Use `logirl` for consistent error/warning/info formatting:

```fish
# Error messages (red with  icon)
logirl error "File not found: $filepath"
logirl error "Command failed with exit code $status"

# Warnings (bright yellow with  icon)
logirl warning "Deprecated flag used"
logirl warning "Rate limit approaching"

# Info messages (cyan with  icon)
logirl info "Processing 42 files"
logirl info "Using default configuration"

# Success messages (bright green with 󰡕 icon)
logirl success "Build completed successfully"

# Progress indicators (bright magenta with ==> prefix)
logirl special "Step 1: Installing dependencies"
logirl special "Step 2: Building project"

# Exit codes
# 0   - Success
# 1   - General error (bad input, file not found, etc.)
# 2   - Usage error (wrong arguments)
# 127 - Missing dependency
```

**Always pair error messages with appropriate return codes:**

```fish
if not test -f "$file"
    logirl error "File not found: $file"
    return 1
end
```

Write errors to stderr for pipeable functions:

```fish
echo "Error message" >&2
```

For detailed logging patterns, see the [guide to our custom fish function logging helper, logirl](logirl-custom-logging-framework.md).

If you need an error handling pattern not covered here, look at the [error handling best practices guide](error-handling-best-practices.md).

### Dependency Checks

Validate required commands exist before using them:

```fish
if not type -q ffmpeg
    logirl error "ffmpeg not found in PATH"
    logirl info "Install with: brew install ffmpeg"
    return 127
end

# For interactive features
if not type -q gum
    logirl error "gum not found in PATH"
    logirl info "Install with: brew install gum"
    return 127
end
```

### Variable Scoping

Use appropriate scopes:

```fish
set -l local_var "value"      # Local to function (default, preferred)
set -g global_var "value"     # Global (persistent in session)
set -gx EXPORTED_VAR "value"  # Global and exported to child processes
set -U universal_var "value"  # Persists across sessions (use sparingly)
```

### Conditionals and Tests

Use Fish syntax, not bash:

```fish
# Check if variable is set
if set -q MY_VAR
    echo "MY_VAR is set to $MY_VAR"
end

# Check if variable is empty
if test -z "$MY_VAR"
    echo "MY_VAR is empty or unset"
end

# File tests
if test -f "$filepath"      # File exists
if test -d "$dirpath"       # Directory exists
if test -r "$path"          # Readable
if test -w "$path"          # Writable
if test -x "$path"          # Executable

# String comparison
if test "$var" = "value"    # Equal (single =)
if test "$var" != "value"   # Not equal

# Numeric comparison
if test $count -gt 0        # Greater than
if test $count -eq 0        # Equal
if test $count -lt 10       # Less than

# Compound conditions
if test -f "$file"; and test -r "$file"
    echo "File exists and is readable"
end

if test -z "$var"; or test "$var" = "default"
    echo "Using default"
end
```

### Command Success/Failure

Check command exit status:

```fish
# Using $status (check immediately after command)
some_command
if test $status -ne 0
    echo "Command failed"
    return 1
end

# Using and/or chaining
some_command; and echo "Success"; or echo "Failed"

# Capture output and check status
set -l output (some_command 2>&1)
if test $status -eq 0
    echo "Got: $output"
end
```

### Colorful Output

**IMPORTANT:** Use the `logirl` helper for consistent formatting whenever possible, if you need special formatting outside of what `logirl` provides, fallback to using `set_color` directly.

The `set_color` builtin provides a range of colors and modifiers:

```fish
# Basic colors
set_color red
set_color green
set_color blue
set_color yellow
set_color cyan
set_color magenta

# Modifiers
set_color --bold red        # Bold red
set_color --dim white       # Dimmed
set_color --italics blue    # Italics (terminal support varies)
set_color --underline       # Underlined

# Bright variants
set_color brred             # Bright red
set_color brgreen           # Bright green
set_color brblack           # Gray (useful for "disabled" text)

# Reset
set_color normal

# Inline color usage
echo "Status: "$(set_color green)"OK"$(set_color normal)
echo $(set_color --bold cyan)"==> "$(set_color normal)"Doing something..."
```

**IMPORTANT:** Always reset colors with `(set_color normal)` after using `set_color` to avoid color bleed in the terminal.

#### Preferred Color Conventions

**NOTE**: these are all handled automatically by `logirl`.

If bold or italics are not specified, use normal weight.

##### Help Text

- Body: Normal
- Headings: Green
- Commands: Bold (normal color)
- Flags: Blue Italics

##### Errors/Warnings

- Warning tags: Bright Yellow, Bold
- Warning messages: Bright Yellow
- Error tags: Red, Bold
- Error messages: Red

##### Logging/Info

- Info tags: Cyan, Bold
- Info messages: Normal
- Success tags: Bright Green, Bold
- Success messages: Bright Green
- Special steps/progress: Bright Magenta, Bold
- Special step messages: Bright Magenta

### Progress and Status

Show progress for longer operations:

```fish
# Step indicators
logirl special "Step 1: Downloading..."
logirl special "Step 2: Processing..."

# With icons (nerd fonts)
logirl special " Installing dependencies..."
logirl special "󰙨 Running tests..."
logirl special " Build complete!"
logirl special " Something failed"

# Progress dots
printf "Processing"
for i in (seq 1 5)
    sleep 0.5
    printf "."
end
printf " done!\n"
```

### Interactive Prompts

**Recommended:** Use `gum` for polished interactive components. Falls back to `read` if gum unavailable.

```fish
# Confirmation with gum (preferred)
if gum confirm "Delete files?"
    rm *.tmp
    logirl success "Files deleted"
else
    logirl info "Cancelled"
end

# User input with gum
set name (gum input --placeholder "Enter name")
set description (gum write --placeholder "Enter description (ctrl+d when done)")

# Choose from options
set option (gum choose "Option 1" "Option 2" "Option 3")

# Fallback with read (no dependencies)
read -P "Continue? (y/N) " -n 1 response
if test "$response" = y; or test "$response" = Y
    echo "Continuing..."
end

# Password input with read
read -P "Password: " -s password
```

Gum can do more than just handle input, if you need something beyond the above, check the [gum guide](charm-gum-shell-script-helper-cli.md) before writing custom input handling.

### String Manipulation

Use Fish's `string` builtin:

```fish
# Replace
string replace "old" "new" -- $var
string replace -r 'pattern' 'replacement' -- $var  # Regex

# Split and join
string split "/" -- $path
string join "," -- $list

# Match
if string match -q "*.fish" -- $filename
    echo "It's a fish file"
end

# Trim whitespace
string trim -- $var

# Extract parts
set basename (string replace -r '.*/' '' -- $filepath)
set extension (string replace -r '.*\.' '' -- $filename)
```

### Loops and Iteration

```fish
# For loop
for file in *.fish
    echo "Processing $file"
end

for i in (seq 1 10)
    echo "Number $i"
end

# While loop
while read -l line
    echo "Line: $line"
end < file.txt

# Iterate with index
set -l items a b c
for i in (seq (count $items))
    echo "$i: $items[$i]"
end
```

### Private/Helper Functions

Prefix with underscore for internal helpers:

```fish
function _myhelper -d "Internal helper (not user-facing)"
    # Implementation
end

function myfunc -d "Public function"
    _myhelper arg1 arg2
end
```

Helper functions can live in the same file or separate files.

## Common Patterns

### Wrapper with Defaults

```fish
function mygrep -d "Ripgrep with my preferred defaults"
    rg --smart-case --hidden --glob '!.git' $argv
end
```

### Directory Navigation

```fish
function proj -d "Jump to project directory"
    z ~/Projects/$argv[1] # prefer zoxide to cd
end
```

### fzf Integration

```fish
function ffile -d "Find and open file with fzf"
    set -l file (fd --type f | fzf --preview 'bat --color=always {}')
    if test -n "$file"
        $EDITOR $file
    end
end
```

### Confirmation Before Dangerous Action

```fish
function cleanup -d "Remove temp files with confirmation"
    # Check for gum
    if not type -q gum
        logirl error "gum not found in PATH"
        logirl info "Install with: brew install gum"
        return 127
    end

    set -l files (fd -t f -e tmp -e temp)
    if test (count $files) -eq 0
        logirl info "No temp files found"
        return 0
    end

    logirl warning "Found "(count $files)" temp files"
    printf "  %s\n" $files

    if not gum confirm "Delete these files?"
        logirl info "Cancelled"
        return 0
    end

    rm $files
    logirl success "Deleted "(count $files)" files"
end
```

## Examples

### Simple Function (No Flags)

```fish
function wthr -d "Get weather for a location (default: Chicago)"
    set -l location (string join "+" $argv)
    if test -z "$location"
        set location chicago
    end
    curl -s "wttr.in/$location"
end
```

### Function with Flags and Validation

```fish
function imgopt -d "Optimize images with optional resize"
    argparse h/help 'w/width=' q/quality= -- $argv
    or return

    if set -q _flag_help
        echo "Optimize and optionally resize images."
        logirl help_usage "imgopt [OPTIONS] <image>"
        logirl help_header "Options"
        logirl help_flag "h/help" "Show this help"
        logirl help_flag "w/width" "PX" "Resize to width (preserves aspect)"
        logirl help_flag "q/quality" "N" "Quality 1-100 (default: 80)"
        return 0
    end

    if not type -q magick
        logirl error "ImageMagick not found"
        logirl info "Install: brew install imagemagick"
        return 127
    end

    if test (count $argv) -lt 1
        logirl error "No image specified"
        printf "Try: imgopt --help\n"
        return 1
    end

    set -l input $argv[1]
    if not test -f "$input"
        logirl error "File not found: $input"
        return 1
    end

    set -l quality 80
    if set -q _flag_quality
        set quality $_flag_quality
    end

    set -l resize_arg ""
    if set -q _flag_width
        set resize_arg "-resize $_flag_width"
    end

    set -l output (string replace -r '\.[^.]+$' '_optimized.jpg' -- $input)

    logirl info "Optimizing $input..."
    magick $input $resize_arg -quality $quality $output

    if test $status -eq 0
        logirl success "Created: $output"
    else
        logirl error "Optimization failed"
        return 1
    end
end
```

### Multi-Step Function with Progress

```fish
function deploy -d "Deploy the current project"
    argparse h/help d/dry-run -- $argv
    or return

    if set -q _flag_help
        echo "Deploy the current project."
        logirl help_usage "deploy [OPTIONS]"
        logirl help_header "Options"
        logirl help_flag "h/help" "Show help"
        logirl help_flag "d/dry-run" "Show what would happen"
        return 0
    end

    if set -q _flag_dry_run
        logirl warning "DRY-RUN mode enabled"
    end

    logirl special "Step 1: Running tests"
    if not set -q _flag_dry_run
        if not npm test
            logirl error "Tests failed, aborting deploy"
            return 1
        end
    end

    logirl special "Step 2: Building project"
    if not set -q _flag_dry_run
        npm run build
    end

    logirl special "Step 3: Deploying to server"
    if not set -q _flag_dry_run
        rsync -avz ./dist/ server:/var/www/
    end

    logirl success "Deploy complete!"
end
```

## Guidelines

### Do

- Include `-d "description"` on every function
- Add `--help` for any function with flags or non-obvious usage (follow the canonical structure: description → usage → commands → options)
- **Use `logirl` for all structured messages** (`error`, `warning`, `info`, `success`, `special`)
- **Use semantic message types**: `error` for failures, `warning` for non-fatal issues, `info` for status, `success` for completions, `special` for progress steps
- **Always pair error messages with return codes** (never `logirl error` without `return 1`)
- Validate inputs and dependencies before processing
- Use meaningful exit codes (0=success, 1=error, 2=misuse, 127=missing dep)
- Write errors to stderr with `>&2` for pipeable functions (when not using `logirl`, which handles this)
- Use `set -l` for local variables to avoid pollution
- Prefer `test` over `[[ ]]` (Fish syntax)
- Prefer `type -q cmd` over `command -v cmd` (Fish idiom)
- Use `string` builtins for text manipulation

### Do Not

- Use bash/zsh syntax (`[[ ]]`, `$(...)` without string, `VAR=value`)
- Forget `or return` after argparse
- Hard-code paths with usernames (use `$HOME`, `~`, or env vars)
- Create functions without testing in an actual Fish subshell (`fish -c "[command]" is your friend when using this skill`) - you cannot access Fish directly yourself, you have to run commands in a subshell from bash
- **Manually format messages that `logirl` handles** — always use `logirl error/warning/info/success/special` instead of `set_color` + `echo` for structured messages
- Forget to reset colors with `(set_color normal)` when using `set_color` for custom output not covered by `logirl`
- Use `echo -e` (use `printf` for escape sequences)
- Mix logging styles (use `logirl` consistently for all error/warning/info/success messages)

### Fish vs Bash Quick Reference

| Bash | Fish |
| --- | --- |
| `[[ ... ]]` | `test ...` |
| `$(command)` | `(command)` |
| `VAR=value` | `set VAR value` |
| `export VAR=value` | `set -gx VAR value` |
| `command -v cmd` | `type -q cmd` |
| `$((1+2))` | `math 1+2` |
| `${var:-default}` | `set -q var; or set var default` |
| `"${arr[@]}"` | `$arr` |
| `${#var}` | `string length $var` |
| `source file` | `source file` or `. file` |

## Testing

After creating or modifying a function:

1. Reload Fish: `source ~/.config/fish/config.fish` or `fresh -r` in a Fish subshell
2. Test the function with various inputs
3. Test `--help` output
4. Test error cases (missing args, bad input, missing deps)
5. Verify colors display correctly

## External Resources

If you can't find a solution within the skill and reference guides, WebFetch the [fish shell docs](https://fishshell.com/docs/current/index.html).
