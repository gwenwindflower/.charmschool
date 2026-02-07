function brewdo -d "Find Homebrew packages and perform actions on them"
    # Parse arguments
    # Note: -p/--pattern takes a value, prefix/suffix are boolean modifiers
    argparse h/help d/dry-run s/search 'p/pattern=' casks formulae prefix suffix -- $argv
    or return

    # Handle --help
    if set -q _flag_help
        echo "Find Homebrew packages and perform actions on them."
        logirl help_usage "brewdo [OPTIONS] <action> [packages...]"
        logirl help_header Actions
        logirl help_cmd info "Show detailed info for matched packages"
        logirl help_cmd install "Install packages (skips already-installed)"
        logirl help_cmd uninstall "Uninstall matched packages (with confirmation)"
        logirl help_cmd upgrade "Upgrade matched packages"
        logirl help_cmd reinstall "Reinstall matched packages"
        logirl help_cmd deps "Show dependency tree"
        logirl help_cmd uses "Show reverse dependencies (what uses these)"
        logirl help_cmd outdated "Show which matched packages are outdated"
        logirl help_header "Selection Modes"
        logirl help_cmd "(default)" "Interactive fzf multi-select from installed packages"
        logirl help_cmd s/search "Interactive fzf over brew's remote catalog"
        logirl help_cmd "p/pattern <...>" "Non-interactive glob match against installed packages"
        logirl help_cmd "pkg1 pkg2..." "Direct package names (e.g. brewdo install ripgrep bat)"
        logirl help_header Options
        logirl help_flag h/help "Show this help message"
        logirl help_flag d/dry-run "Show what would happen without executing"
        logirl help_flag s/search "Use brew's remote catalog instead of installed packages"
        logirl help_flag "p/pattern=GLOB" "Non-interactive glob pattern match (min 2 chars)"
        logirl help_flag casks "Only casks"
        logirl help_flag formulae "Only formulae"
        logirl help_flag prefix "Match pattern at start only (with -p)"
        logirl help_flag suffix "Match pattern at end only (with -p)"
        logirl help_header Examples
        printf "  brewdo info                        # fzf browse installed → show info\n"
        printf "  brewdo info ripgrep                # info for a specific package\n"
        printf "  brewdo info -s python              # search remote catalog via fzf\n"
        printf "  brewdo upgrade -p font -d          # dry-run upgrade font-* packages\n"
        printf "  brewdo install ripgrep bat         # install if not already present\n"
        printf "  brewdo uninstall -p old --casks    # uninstall matching casks\n"
        return 0
    end

    # Check for brew
    if not type -q brew
        logirl error "Homebrew not found in PATH"
        return 127
    end

    # Extract action (first positional arg)
    if test (count $argv) -lt 1
        logirl error "No action specified"
        printf "Try: brewdo --help\n"
        return 2
    end

    set -l action $argv[1]
    set -l remaining $argv[2..-1]

    # Validate action
    set -l allowed_actions info install uninstall upgrade reinstall deps uses outdated
    if not contains $action $allowed_actions
        logirl error "Unknown action: $action"
        printf "  Supported: %s\n" (string join ", " $allowed_actions)
        printf "Try: brewdo --help\n"
        return 2
    end

    # Determine selection mode and resolve packages
    set -l packages

    if test (count $remaining) -gt 0; and not set -q _flag_pattern; and not set -q _flag_search
        # --- Direct names mode: args after action are package names ---
        set packages $remaining

    else if set -q _flag_pattern
        # --- Pattern mode (non-interactive, from brp) ---
        set -l pattern $_flag_pattern

        # Safety: pattern must be 2+ chars
        if test (string length "$pattern") -lt 2
            logirl error "Pattern too short (minimum 2 characters): '$pattern'"
            return 1
        end

        # Build glob pattern
        set -l match_pattern
        if set -q _flag_prefix
            set match_pattern "$pattern*"
        else if set -q _flag_suffix
            set match_pattern "*$pattern"
        else
            set match_pattern "*$pattern*"
        end

        # Match against installed packages
        if set -q _flag_casks
            set packages (brew list --casks 2>/dev/null | string match $match_pattern)
        else if set -q _flag_formulae
            set packages (brew list --formulae 2>/dev/null | string match $match_pattern)
        else
            set packages (brew list 2>/dev/null | string match $match_pattern)
        end

        if test (count $packages) -eq 0
            logirl warning "No installed packages match pattern: '$pattern'"
            return 0
        end

        logirl info "Matched "(count $packages)" package(s) for '$pattern'"
        printf "  %s\n" $packages

    else
        # --- Interactive fzf mode ---
        if not type -q fzf
            logirl error "fzf not found in PATH (required for interactive mode)"
            logirl info "Install with: brew install fzf"
            return 127
        end

        set -l fzf_source
        set -l fzf_prompt

        if set -q _flag_search
            # Search mode: fzf over remote catalog
            set fzf_prompt "brewdo $action (search) > "
            # Build search query from remaining args
            set -l query (string join " " $remaining)

            if set -q _flag_casks
                set fzf_source (brew search --casks $query 2>/dev/null)
            else if set -q _flag_formulae
                set fzf_source (brew search --formulae $query 2>/dev/null)
            else
                set fzf_source (brew search $query 2>/dev/null)
            end
        else
            # Default mode: fzf over installed packages
            set fzf_prompt "brewdo $action > "

            if set -q _flag_casks
                set fzf_source (brew list --casks 2>/dev/null)
            else if set -q _flag_formulae
                set fzf_source (brew list --formulae 2>/dev/null)
            else
                set fzf_source (brew list 2>/dev/null)
            end
        end

        if test (count $fzf_source) -eq 0
            logirl warning "No packages found"
            return 0
        end

        set packages (printf "%s\n" $fzf_source | sort | fzf \
            --multi \
            --prompt="$fzf_prompt" \
            --header="TAB to select multiple, Enter to confirm" \
            --preview="brew info {1}" \
            --preview-window=right:60%:wrap)

        if test (count $packages) -eq 0
            logirl info "No packages selected"
            return 0
        end
    end

    # Validate we have something to work with
    if test (count $packages) -eq 0
        logirl warning "No packages to act on"
        return 0
    end

    # Special handling for install: skip already-installed packages
    if test "$action" = install
        set -l to_install
        set -l already 0
        for pkg in $packages
            if brew list --formula $pkg &>/dev/null; or brew list --cask $pkg &>/dev/null
                logirl dim "$pkg is already installed, skipping"
                set already (math $already + 1)
            else
                set -a to_install $pkg
            end
        end
        if test $already -gt 0
            logirl info "Skipped $already already-installed package(s)"
        end
        if test (count $to_install) -eq 0
            logirl success "All packages already installed"
            return 0
        end
        set packages $to_install
    end

    # Safety gates: confirm for destructive actions
    set -l destructive_actions uninstall reinstall
    if contains $action $destructive_actions
        if not type -q gum
            logirl error "gum not found in PATH (required for destructive action confirmation)"
            logirl info "Install with: brew install gum"
            return 127
        end
        echo ""
        if not gum confirm "Run 'brew $action' on "(count $packages)" package(s)?"
            logirl info Cancelled
            return 0
        end
    else if test (count $packages) -gt 10
        # Confirm large batch operations even for non-destructive actions
        if type -q gum
            echo ""
            if not gum confirm "Run 'brew $action' on "(count $packages)" packages?"
                logirl info Cancelled
                return 0
            end
        end
    end

    # Dry-run: show what would happen
    if set -q _flag_dry_run
        logirl info "Dry run — would execute:"
        echo "  brew $action $packages"
        return 0
    end

    # Execute
    logirl special "brew $action "(count $packages)" package(s)..."
    brew $action $packages
    set -l brew_status $status

    if test $brew_status -eq 0
        logirl success "brew $action completed"
    else
        logirl error "brew $action exited with status $brew_status"
        return $brew_status
    end
end
