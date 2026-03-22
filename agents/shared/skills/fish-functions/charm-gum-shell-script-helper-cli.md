# Gum Shell Script Helper CLI

[Gum](https://github.com/charmbracelet/gum) provides beautiful, interactive CLI components for shell scripts. Use it to create polished user experiences in Fish functions.

## Installation

```bash
brew install gum
```

## Core Philosophy

Gum commands output to stdout and use exit codes to signal success/failure. This makes them perfect for Fish's command substitution and conditional logic:

```fish
# Capture user choice
set choice (gum choose "Option 1" "Option 2" "Option 3")

# Use exit code for conditionals
if gum confirm "Delete file?"
    rm file.txt
end
```

## Essential Commands for Fish Functions

### confirm

Ask yes/no questions. Exits with code 0 (yes) or 1 (no).

```fish
# Basic confirmation
if gum confirm "Continue?"
    logirl info "Proceeding..."
end

# With custom text
if gum confirm "Delete original files after conversion?"
    # User confirmed
else
    logirl info "Cancelled"
    return 0
end

# One-liner with default behavior
gum confirm "Remove temp files?" && rm *.tmp
```

**Best practices:**

- Always handle both cases (user confirms and user declines)
- Use clear, specific questions (not "Are you sure?")
- Pair with logirl messages for consistent output

### input

Prompt for single-line text input.

```fish
# Basic input
set name (gum input --placeholder "Enter your name")

# Password input (hidden)
set password (gum input --password --placeholder "Enter password")

# With default value
set branch (gum input --value "main" --placeholder "Branch name")

# Limit width
set commit_msg (gum input --width 72 --placeholder "Commit summary")
```

**Common flags:**

- `--placeholder TEXT` - Grayed hint text
- `--value TEXT` - Pre-filled value
- `--password` - Hide input
- `--width N` - Max width in characters

### write

Prompt for multi-line text (ctrl+d to finish).

```fish
# Multi-line input
set description (gum write --placeholder "Enter detailed description...")

# With size constraints
set notes (gum write --width 80 --height 10 --placeholder "Notes...")
```

**Use when:**

- Need more than one line of input
- Writing commit messages, descriptions, notes
- Editing configuration values

### choose

Select one or more items from a list.

```fish
# Single selection
set flavor (gum choose "Strawberry" "Banana" "Cherry")

# Multiple selections (tab/ctrl+space to select, enter to confirm)
set features (gum choose --no-limit "Feature A" "Feature B" "Feature C")

# Limited selections
set top_three (gum choose --limit 3 "Option 1" "Option 2" "Option 3" "Option 4")

# With custom height
set branch (git branch | gum choose --height 10)
```

**Common flags:**

- `--limit N` - Allow selecting up to N items
- `--no-limit` - Allow selecting any number of items
- `--height N` - Visible options (scrollable if more)
- `--header TEXT` - Header text above options

**Practical examples:**

```fish
# Choose git branch
set branch (git branch | cut -c 3- | gum choose --header "Select branch")
git checkout $branch

# Select files to delete
set files (fd -t f -e tmp | gum choose --no-limit --header "Files to delete")
test -n "$files" && rm $files

# Pick from command history
set cmd (history | gum choose --height 20)
eval $cmd
```

### filter

Fuzzy-find items from a list (like fzf but with gum styling).

```fish
# Filter from stdin
set file (fd --type f | gum filter)

# Filter with placeholder
set match (cat words.txt | gum filter --placeholder "Search...")

# Multiple selections
set files (fd | gum filter --no-limit)
```

**Use when:**

- Searching through many items
- Need fuzzy matching
- Alternative to fzf with consistent gum styling

### style

Apply colors, borders, padding, and alignment to text.

```fish
# Basic styling
gum style --foreground 212 "Colored text"

# With border
gum style --border double --border-foreground 212 "Boxed text"

# Centered with padding
gum style --align center --padding "1 2" "Centered text"

# Build layouts
set header (gum style --bold --foreground 212 "My Tool")
set body (gum style --foreground 240 "Description here")
gum join --vertical "$header" "$body"
```

**Common flags:**

- `--foreground N` - Text color (256 color)
- `--bold` - Bold text
- `--border TYPE` - Border style (none, normal, rounded, thick, double)
- `--border-foreground N` - Border color
- `--align ALIGN` - Text alignment (left, center, right)
- `--padding "V H"` - Vertical and horizontal padding
- `--margin "V H"` - Vertical and horizontal margin

**Note:** For most functions, prefer `logirl` for consistent messaging. Use `gum style` for special layouts or custom designs.

## Practical Patterns

### Confirm before dangerous action

```fish
function cleanup -d "Remove temp files with confirmation"
    set files (fd -t f -e tmp -e temp)

    if test (count $files) -eq 0
        logirl info "No temp files found"
        return 0
    end

    logirl info "Found "(count $files)" temp files"

    if not gum confirm "Delete these files?"
        logirl info "Cancelled"
        return 0
    end

    rm $files
    logirl success "Deleted "(count $files)" files"
end
```

### Multi-step wizard

```fish
function create_project -d "Create a new project"
    logirl special "Project Setup Wizard"

    set name (gum input --placeholder "Project name")
    if test -z "$name"
        logirl error "Project name required"
        return 1
    end

    set type (gum choose --header "Project type" "web" "cli" "library")
    set features (gum choose --no-limit --header "Features" "tests" "docs" "ci")

    logirl info "Creating project: $name ($type)"
    # ... create project ...

    logirl success "Project created!"
end
```

### Interactive file picker

```fish
function fedit -d "Pick and edit file"
    if not type -q gum
        logirl error "gum not found"
        return 127
    end

    set file (fd --type f | gum filter --placeholder "Search files...")

    if test -z "$file"
        logirl info "No file selected"
        return 0
    end

    $EDITOR "$file"
end
```

### Choose from options with validation

```fish
function deploy -d "Deploy to environment"
    set env (gum choose --header "Deploy to" "dev" "staging" "production")

    if test "$env" = "production"
        if not gum confirm "Deploy to PRODUCTION?"
            logirl info "Cancelled"
            return 0
        end

        # Extra confirmation for production
        if not gum confirm "Are you absolutely sure?"
            logirl info "Cancelled"
            return 0
        end
    end

    logirl special "Deploying to $env..."
    # ... deploy logic ...
end
```

## Integration with Fish Best Practices

### Dependency checking

Always check for gum before using it:

```fish
if not type -q gum
    logirl error "gum not found in PATH"
    logirl info "Install with: brew install gum"
    return 127
end
```

### Combine with logirl

Use gum for interactive input, logirl for status messages:

```fish
# Gum for user input
set name (gum input --placeholder "Enter name")

# Logirl for status updates
logirl info "Processing $name..."
logirl success "Done!"
```

### Error handling

Check for empty/cancelled input:

```fish
set choice (gum choose "A" "B" "C")

# User hit escape/ctrl+c - choice is empty
if test -z "$choice"
    logirl info "Cancelled"
    return 0
end

# User made a choice
logirl info "Selected: $choice"
```

### Exit codes

Gum commands exit with non-zero on cancellation:

```fish
if not gum confirm "Proceed?"
    # User said no OR cancelled (ctrl+c)
    logirl info "Cancelled"
    return 0
end

# User said yes
logirl info "Proceeding..."
```

## When to Use Gum vs. Traditional Approaches

**Use gum when:**

- Need confirmation for dangerous operations
- Offering choices from a predefined list
- Building interactive wizards or setup scripts
- Want polished, consistent UI components

**Use traditional Fish when:**

- Simple yes/no with `read -P` is sufficient
- No interactivity needed (batch scripts)
- Gum not available in target environment
- Performance is critical (gum adds small overhead)

**Use logirl for:**

- Status messages (error, warning, info, success)
- Progress indicators
- Help text formatting
- All non-interactive output

## Customization

Gum supports extensive customization via flags or environment variables:

```fish
# Via flags
gum input --cursor.foreground "#FF0" \
          --prompt.foreground "#0FF" \
          --placeholder "Custom styled input"

# Via environment variables
set -gx GUM_INPUT_CURSOR_FOREGROUND "#FF0"
set -gx GUM_INPUT_PROMPT_FOREGROUND "#0FF"
gum input  # Uses env vars
```

For most use cases, the defaults are fine. Customize only when building branded tools or matching specific color schemes.

## Summary

Gum provides professional interactive components for Fish functions:

- **confirm** - Yes/no questions (exit code based)
- **input** - Single-line text entry
- **write** - Multi-line text entry
- **choose** - Select from list (single or multiple)
- **filter** - Fuzzy search through items
- **style** - Format and color text

**Golden rule:** Use gum for input, logirl for output, combine them for delightful Fish functions.

For complete documentation: <https://github.com/charmbracelet/gum>
