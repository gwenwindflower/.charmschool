function brp -d "Batch Homebrew commands based on matched pattern"
    # TODO: finish this!
    argparse d/dry-run p/prefix P/suffix casks formulae -- $argv
    or return

    if test (count $argv) -lt 2
        echo "Usage: brp [options] <command> <pattern>"
        echo "Options:"
        echo "  -d, --dry-run    Show what would happen without executing"
        echo "  -p, --prefix     Match pattern at start only (default: match anywhere)"
        echo "  -P, --suffix     Match pattern at end only"
        echo "  --casks          Only search casks"
        echo "  --formulae       Only search formulae"
        return 1
    end

    set -l command $argv[1]
    set -l pattern $argv[2]

    if not command -q brew
        echo "Error: Homebrew not found in PATH"
        return 1
    end

    # Validate dangerous patterns
    if test "$pattern" = "*" -o "$pattern" = "" -o (string length "$pattern") -lt 2
        echo "Error: Pattern '$pattern' is too broad or too short (minimum 2 characters)"
        return 1
    end

    set -l allowed_commands upgrade uninstall remove info deps uses outdated reinstall
    if not contains $command $allowed_commands
        echo "Error: Unsupported command '$command'"
        echo "Supported: $allowed_commands"
        return 1
    end

    set -l match_pattern
    if set -q _flag_prefix
        set match_pattern "$pattern*"
    else if set -q _flag_suffix
        set match_pattern "*$pattern"
    else
        set match_pattern "*$pattern*" # Default: match anywhere
    end

    set -l packages
    if set -q _flag_casks
        set packages (brew list --casks 2>/dev/null | string match $match_pattern)
    else if set -q _flag_formulae
        set packages (brew list --formulae 2>/dev/null | string match $match_pattern)
    else
        set packages (brew list 2>/dev/null | string match $match_pattern)
    end

    if test (count $packages) -eq 0
        echo "No packages found matching: '$pattern'"
        return 1
    end

    # Start execution
    echo "Found "(count $packages)" package(s) matching '$pattern':"
    printf "  %s\n" $packages

    # Confirm for large operations
    if test (count $packages) -gt 10
        gum confirm "You are about to run '$command' on "(count $packages)" packages. Continue?"; or begin
            logirl warning "Operation cancelled by user."
            return 0
        end
    end

    # Confirm for destructive operations
    set -l destructive_commands uninstall remove rm
    if contains $command $destructive_commands
        gum confirm "You are about to '$command' "(count $packages)" packages, to undo will require reinstalling them. Are you sure?"; or begin
            logirl warning "Operation cancelled by user."
            return 0
        end
    end

    if set -q _flag_dry_run
        echo "Would execute: brew $command $packages"
        return 0
    end

    # Here we go!
    echo "Executing: brew $command $packages"
    brew $command $packages
end
