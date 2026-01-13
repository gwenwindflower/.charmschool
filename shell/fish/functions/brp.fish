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

    set command $argv[1]
    set pattern $argv[2]

    if not command -q brew
        echo "Error: Homebrew not found in PATH"
        return 1
    end

    # Validate dangerous patterns
    if test "$pattern" = "*" -o "$pattern" = "" -o (string length "$pattern") -lt 2
        echo "Error: Pattern '$pattern' is too broad or too short (minimum 2 characters)"
        return 1
    end

    set allowed_commands upgrade uninstall remove info deps uses outdated reinstall
    if not contains $command $allowed_commands
        echo "Error: Unsupported command '$command'"
        echo "Supported: $allowed_commands"
        return 1
    end

    set match_pattern
    if set -q _flag_prefix
        set match_pattern "$pattern*"
    else if set -q _flag_suffix
        set match_pattern "*$pattern"
    else
        set match_pattern "*$pattern*" # Default: match anywhere
    end

    set packages
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
        echo ""
        read -P "Continue with '$command' on "(count $packages)" packages? [y/N]: " -n 1 confirm
        echo ""
        if test "$confirm" != y -a "$confirm" != Y
            echo "Operation cancelled"
            return 0
        end
    end

    # Confirm for destructive operations
    set destructive_commands uninstall remove rm
    if contains $command $destructive_commands
        echo ""
        read -P "Continue with '$command' on these packages? [y/N]: " -n 1 confirm
        echo ""
        if test "$confirm" != y -a "$confirm" != Y
            echo "Operation cancelled"
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
