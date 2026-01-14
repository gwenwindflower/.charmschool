---
name: fish-func
description: Write Fish shell functions with delightful UX. Use for new functions, refactoring, or adding --help/colors/errors. Triggers: fish function, shell function, .fish file.
---

# Fish Function Development

Create and enhance Fish shell functions with excellent developer experience, colorful output, and robust error handling.

For information not included in this skill, [search the official Fish documentation](https://fishshell.com/docs/current/index.html)

## When to Use This Skill

- Creating new Fish functions
- Adding flags, help text, or error handling to existing functions
- Refactoring bash/zsh scripts to Fish
- Improving function UX with colors, progress indicators, or validation
- Debugging Fish syntax issues

## Repository Context

- **Location:** `shell/fish/functions/`
- **Filename convention:** `function_name.fish` (filename must match function name exactly)
- **Linking:** You *do not* need to manually link functions, the entire shell/fish/functions/ directory is already symlinked to the correct location, adding functions in the dotfiles projects automatically makes them available in Fish
- **Reload:** `source ~/.config/fish/config.fish` or use `fresh -r` (for your bash environment that would require `fish -c "fresh -r"`)

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
        # Help text here
        return 0
    end

    # Validate dependencies
    if not type -q required_cmd
        echo (set_color red --bold)"[ERROR]"(set_color normal)" required_cmd not found in PATH"
        return 127
    end

    # Validate inputs
    if test (count $argv) -lt 1
        echo (set_color red --bold)"[ERROR]"(set_color normal)" Missing required argument"
        echo "Try: funcname --help"
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

Include comprehensive help for any function with flags or non-obvious usage:

```fish
if set -q _flag_help
    printf "%sUsage:%s funcname [OPTIONS] <required_arg>\n\n" (set_color --bold) (set_color normal)
    printf "Brief description of the function.\n\n"
    printf "%sOptions:%s\n" (set_color --bold) (set_color normal)
    printf "  %s-h, --help%s      Show this help message\n" (set_color brmagenta) (set_color normal)
    printf "  %s-v, --verbose%s   Enable verbose output\n" (set_color brmagenta) (set_color normal)
    printf "  %s-o, --output%s    Output file path\n" (set_color brmagenta) (set_color normal)
    printf "\n%sExamples:%s\n" (set_color --bold) (set_color normal)
    printf "  funcname file.txt           Process a file\n"
    printf "  funcname -v -o out.txt in   Verbose with output file\n"
    return 0
end
```

### Error Handling

Use consistent error formatting with colors and appropriate exit codes:

```fish
# Standard error format
echo (set_color red --bold)"[ERROR]"(set_color normal)" Description of what went wrong"

# Warning format
echo (set_color yellow --bold)"[WARNING]"(set_color normal)" Something concerning but not fatal"

# Info/progress format
echo (set_color cyan --bold)"[INFO]"(set_color normal)" Status update or information"

# Exit codes
# 0   - Success
# 1   - General error (bad input, file not found, etc.)
# 2   - Usage error (wrong arguments)
# 127 - Missing dependency
```

Write errors to stderr for pipeable functions:

```fish
echo "Error message" 1>&2
```

### Dependency Checks

Validate required commands exist before using them:

```fish
if not type -q ffmpeg
    echo (set_color red --bold)"[ERROR]"(set_color normal)" ffmpeg not found in PATH"
    echo "Install with: brew install ffmpeg"
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

Use `set_color` for vibrant, readable output:

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
echo "Status: "(set_color green)"OK"(set_color normal)
echo (set_color --bold cyan)"==> "(set_color normal)"Doing something..."
```

#### Preferred Color Conventions

If bold or italics are not specified, use normal weight.

##### Help Text

- Body: Blue
- Headings: Green
- Commands/flags: Bright Magenta, Bold

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
echo (set_color --bold brmagenta)"==>"(set_color normal)" Step 1: Downloading..."
echo (set_color --bold brmagenta)"==>"(set_color normal)" Step 2: Processing..."

# With icons (nerd fonts)
echo " Installing dependencies..."
echo "󰙨 Running tests..."
echo " Build complete!"
echo " Something failed"

# Progress dots
printf "Processing"
for i in (seq 1 5)
    sleep 0.5
    printf "."
end
printf " done!\n"
```

### Interactive Prompts

Use `read` for user input:

```fish
# Simple prompt
read -P "Continue? (y/N) " -n 1 response
if test "$response" = y; or test "$response" = Y
    echo "Continuing..."
end

# With default value
read -P "Enter name [default]: " name
if test -z "$name"
    set name "default"
end

# Password/hidden input
read -P "Password: " -s password
```

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
    set -l files (fd -t f -e tmp -e temp)
    if test (count $files) -eq 0
        echo "No temp files found"
        return 0
    end

    echo "Found "(count $files)" temp files:"
    printf "  %s\n" $files

    read -P (set_color yellow)"Delete these files? (y/N) "(set_color normal) -n 1 confirm
    if test "$confirm" = y
        rm $files
        echo (set_color green)"Deleted!"(set_color normal)
    else
        echo "Cancelled"
    end
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
        printf "Usage: imgopt [OPTIONS] <image>\n\n"
        printf "Optimize and optionally resize images.\n\n"
        printf "Options:\n"
        printf "  -h, --help       Show this help\n"
        printf "  -w, --width=PX   Resize to width (preserves aspect)\n"
        printf "  -q, --quality=N  Quality 1-100 (default: 80)\n"
        return 0
    end

    if not type -q magick
        echo (set_color red --bold)"[ERROR]"(set_color normal)" ImageMagick not found"
        echo "Install: brew install imagemagick"
        return 127
    end

    if test (count $argv) -lt 1
        echo (set_color red --bold)"[ERROR]"(set_color normal)" No image specified"
        echo "Try: imgopt --help"
        return 1
    end

    set -l input $argv[1]
    if not test -f "$input"
        echo (set_color red --bold)"[ERROR]"(set_color normal)" File not found: $input"
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

    echo (set_color cyan)"==>"(set_color normal)" Optimizing $input..."
    magick $input $resize_arg -quality $quality $output

    if test $status -eq 0
        echo (set_color green)" "(set_color normal)"Created: $output"
    else
        echo (set_color red)" "(set_color normal)"Optimization failed"
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
        printf "Usage: deploy [OPTIONS]\n\n"
        printf "Options:\n"
        printf "  -h, --help     Show help\n"
        printf "  -d, --dry-run  Show what would happen\n"
        return 0
    end

    set -l prefix ""
    if set -q _flag_dry_run
        set prefix (set_color yellow --bold)"[DRY-RUN] "(set_color normal)
    end

    echo $prefix(set_color --bold magenta)"==>"(set_color normal)" Running tests..."
    if not set -q _flag_dry_run
        if not npm test
            echo (set_color red --bold)"[ERROR]"(set_color normal)" Tests failed, aborting deploy"
            return 1
        end
    end

    echo $prefix(set_color --bold magenta)"==>"(set_color normal)" Building..."
    if not set -q _flag_dry_run
        npm run build
    end

    echo $prefix(set_color --bold magenta)"==>"(set_color normal)" Deploying..."
    if not set -q _flag_dry_run
        rsync -avz ./dist/ server:/var/www/
    end

    echo $prefix(set_color green --bold)" "(set_color normal)"Deploy complete!"
end
```

## Guidelines

### Do

- Include `-d "description"` on every function
- Add `--help` for any function with flags or non-obvious usage
- Validate inputs and dependencies before processing
- Use meaningful exit codes (0=success, 1=error, 2=usage, 127=missing dep)
- Write errors to stderr with `1>&2` for pipeable functions
- Use `set -l` for local variables to avoid pollution
- Prefer `test` over `[[ ]]` (Fish syntax)
- Prefer `type -q cmd` over `command -v cmd` (Fish idiom)
- Use `string` builtins for text manipulation
- Colorize output following the preferred conventions

### Do Not

- Use bash/zsh syntax (`[[ ]]`, `$(...)` without string, `VAR=value`)
- Forget `or return` after argparse
- Hard-code paths with usernames (use `$HOME`, `~`, or env vars)
- Create functions without testing in an actual Fish subshell (`fish -c "[command]" is your friend when using this skill`) - you cannot access Fish directly yourself, you have to run commands in a subshell from bash
- Forget to reset colors with `(set_color normal)`
- Use `echo -e` (use `printf` for escape sequences)

### Fish vs Bash Quick Reference

| Bash | Fish |
| ------ | ------ |
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
