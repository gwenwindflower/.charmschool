function brewshot -d "Snapshot or diff Homebrew state as YAML"
    # Parse arguments
    argparse h/help d/dry-run v/verbose 'o/output=' -- $argv
    or return

    # Handle --help
    if set -q _flag_help
        echo "Snapshot current Homebrew state to YAML or compare against a saved snapshot."
        logirl help_usage "brewshot [OPTIONS] [SUBCOMMAND]"
        logirl help_header "Subcommands"
        logirl help_cmd save "Capture current Homebrew state to YAML (default)"
        logirl help_cmd diff "Compare current state against saved snapshot"
        logirl help_header "Options"
        logirl help_flag "h/help" "Show this help message"
        logirl help_flag "d/dry-run" "Show what would be written without writing"
        logirl help_flag "v/verbose" "Print full package lists"
        logirl help_flag "o/output=PATH" "Output file (default: chezmoi packages.yaml)"
        logirl help_header "Examples"
        printf "  brewshot                   # Save snapshot to default location\n"
        printf "  brewshot diff              # Show what changed since last snapshot\n"
        printf "  brewshot -d -v             # Dry-run verbose save (preview output)\n"
        printf "  brewshot -o ~/snap.yaml    # Save to custom path\n"
        return 0
    end

    # Check dependencies
    if not type -q brew
        logirl error "Homebrew not found in PATH"
        return 127
    end

    if not type -q yq
        logirl error "yq not found in PATH"
        logirl info "Install with: brew install yq"
        return 127
    end

    # Determine subcommand (default: save)
    set -l subcommand save
    if test (count $argv) -ge 1
        set subcommand $argv[1]
    end

    set -l valid_subcommands save diff
    if not contains $subcommand $valid_subcommands
        logirl error "Unknown subcommand: $subcommand"
        printf "  Supported: %s\n" (string join ", " $valid_subcommands)
        printf "Try: brewshot --help\n"
        return 2
    end

    # Output path
    set -l packages_file ~/.local/share/chezmoi/.chezmoidata/packages.yaml
    if set -q _flag_output
        set packages_file $_flag_output
    end

    # Capture current Homebrew state (shared by both subcommands)
    logirl info "Capturing Homebrew state..."
    set -l cur_taps (brew tap 2>/dev/null | sort)
    set -l cur_formulae (brew list -1 --installed-on-request 2>/dev/null | sort)
    set -l cur_casks (brew list --cask -1 2>/dev/null | sort)

    logirl info "Current: "(count $cur_taps)" taps, "(count $cur_formulae)" formulae, "(count $cur_casks)" casks"

    # --- DIFF subcommand ---
    if test "$subcommand" = diff
        if not test -f "$packages_file"
            logirl error "No saved snapshot found at: $packages_file"
            logirl info "Run 'brewshot save' first to create a snapshot"
            return 1
        end

        logirl info "Comparing against: $packages_file"

        # Load saved state via yq
        set -l saved_taps (yq eval '.packages.darwin.homebrew.taps[]' "$packages_file" 2>/dev/null)
        set -l saved_formulae (yq eval '.packages.darwin.homebrew.formulae[]' "$packages_file" 2>/dev/null)
        set -l saved_casks (yq eval '.packages.darwin.homebrew.casks[]' "$packages_file" 2>/dev/null)

        # Compute diffs: added = in current but not saved, removed = in saved but not current
        set -l added_taps
        set -l removed_taps
        set -l added_formulae
        set -l removed_formulae
        set -l added_casks
        set -l removed_casks

        # Taps
        for tap in $cur_taps
            if not contains $tap $saved_taps
                set -a added_taps $tap
            end
        end
        for tap in $saved_taps
            if not contains $tap $cur_taps
                set -a removed_taps $tap
            end
        end

        # Formulae
        for f in $cur_formulae
            if not contains $f $saved_formulae
                set -a added_formulae $f
            end
        end
        for f in $saved_formulae
            if not contains $f $cur_formulae
                set -a removed_formulae $f
            end
        end

        # Casks
        for c in $cur_casks
            if not contains $c $saved_casks
                set -a added_casks $c
            end
        end
        for c in $saved_casks
            if not contains $c $cur_casks
                set -a removed_casks $c
            end
        end

        # Check if anything changed
        set -l total_changes (math \
            (count $added_taps) + (count $removed_taps) + \
            (count $added_formulae) + (count $removed_formulae) + \
            (count $added_casks) + (count $removed_casks))

        if test $total_changes -eq 0
            logirl success "No differences — current state matches snapshot"
            return 0
        end

        # Display differences
        echo ""

        # Taps
        if test (count $added_taps) -gt 0; or test (count $removed_taps) -gt 0
            printf "%sTaps:%s\n" (set_color --bold) (set_color normal)
            for t in $added_taps
                printf "  %s+ %s%s\n" (set_color green) $t (set_color normal)
            end
            for t in $removed_taps
                printf "  %s- %s%s\n" (set_color red) $t (set_color normal)
            end
            echo ""
        end

        # Formulae
        if test (count $added_formulae) -gt 0; or test (count $removed_formulae) -gt 0
            printf "%sFormulae:%s\n" (set_color --bold) (set_color normal)
            for f in $added_formulae
                printf "  %s+ %s%s\n" (set_color green) $f (set_color normal)
            end
            for f in $removed_formulae
                printf "  %s- %s%s\n" (set_color red) $f (set_color normal)
            end
            echo ""
        end

        # Casks
        if test (count $added_casks) -gt 0; or test (count $removed_casks) -gt 0
            printf "%sCasks:%s\n" (set_color --bold) (set_color normal)
            for c in $added_casks
                printf "  %s+ %s%s\n" (set_color green) $c (set_color normal)
            end
            for c in $removed_casks
                printf "  %s- %s%s\n" (set_color red) $c (set_color normal)
            end
            echo ""
        end

        logirl info "$total_changes change(s) since last snapshot"
        return 0
    end

    # --- SAVE subcommand ---

    # Create temp file with existing content or minimal structure
    set -l temp_file (mktemp)
    if test -f "$packages_file"
        cp "$packages_file" $temp_file
    else
        echo "packages: {}" >$temp_file
    end

    # Update homebrew section using yq (preserves other content in file)
    yq eval '.packages.darwin.homebrew.taps = []' -i $temp_file
    yq eval '.packages.darwin.homebrew.formulae = []' -i $temp_file
    yq eval '.packages.darwin.homebrew.casks = []' -i $temp_file

    # Populate taps
    for tap in $cur_taps
        yq eval ".packages.darwin.homebrew.taps += [\"$tap\"]" -i $temp_file
    end

    # Populate formulae
    for formula in $cur_formulae
        yq eval ".packages.darwin.homebrew.formulae += [\"$formula\"]" -i $temp_file
    end

    # Populate casks
    for cask in $cur_casks
        yq eval ".packages.darwin.homebrew.casks += [\"$cask\"]" -i $temp_file
    end

    # Dry-run: show but don't write
    if set -q _flag_dry_run
        if set -q _flag_verbose
            echo ""
            cat $temp_file
            echo ""
        end
        rm $temp_file
        logirl success "Dry run — file not updated"
        return 0
    end

    # Write the file
    mkdir -p (dirname "$packages_file")
    mv $temp_file "$packages_file"

    if set -q _flag_verbose
        echo ""
        cat "$packages_file"
        echo ""
    end

    logirl success "Updated $packages_file"
    logirl info "Snapshotted "(count $cur_taps)" taps, "(count $cur_formulae)" formulae, "(count $cur_casks)" casks"
end
