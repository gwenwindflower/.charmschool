function brcp -d "Snapshot Homebrew state and update chezmoi packages.yaml"
    argparse d/dry-run v/verbose h/help -- $argv
    or return

    if set -q _flag_help
        logirl help_header "Usage: brcp [OPTIONS]"
        logirl help_body "Snapshot current Homebrew state and update the chezmoi packages.yaml file."
        echo "$(logirl help_cmd -f h/help -n)         Show this help text and exit"
        echo "$(logirl help_cmd -f d/dry-run -n)      Show what would be written without actually writing"
        echo "$(logirl help_cmd -f v/verbose -n)      Print the list of taps, formulae, and casks being snapshotted"
        return 0
    end

    if test (count $argv) -ne 0
        logirl error "brcp does not take any arguments, use -h/--help to see options"
        return 1
    end

    # Check for required dependency
    if not type -q yq
        logirl error "yq is required but not found: `brew install yq`"
        return 1
    end

    set -l packages_file ~/.local/share/chezmoi/.chezmoidata/packages.yaml

    # Snapshot current Homebrew state (sorted for consistent diffs)
    logirl info "Capturing Homebrew state..."
    set -l taps (brew tap | sort)
    set -l formulae (brew list -1 --installed-on-request | sort)
    set -l casks (brew list --cask -1 | sort)

    # Create temp file with existing content or minimal structure
    set -l temp_file (mktemp)
    if test -f $packages_file
        cp $packages_file $temp_file
    else
        echo "packages: {}" >$temp_file
    end

    # Update homebrew section using yq (preserves other content in file)
    yq eval '.packages.darwin.homebrew.taps = []' -i $temp_file
    yq eval '.packages.darwin.homebrew.formulae = []' -i $temp_file
    yq eval '.packages.darwin.homebrew.casks = []' -i $temp_file

    # Populate taps
    for tap in $taps
        yq eval ".packages.darwin.homebrew.taps += [\"$tap\"]" -i $temp_file
    end

    # Populate formulae
    for formula in $formulae
        yq eval ".packages.darwin.homebrew.formulae += [\"$formula\"]" -i $temp_file
    end

    # Populate casks
    for cask in $casks
        yq eval ".packages.darwin.homebrew.casks += [\"$cask\"]" -i $temp_file
    end

    # Return if dry-run
    if set -q _flag_dry_run
        if set -q _flag_verbose
            cat $temp_file
        end
        rm $temp_file
        logirl success "Dry run - file not updated"
        return 0
    end

    # Ensure directory exists and write file
    mkdir -p (dirname $packages_file)
    mv $temp_file $packages_file
    if set -q _flag_verbose
        cat $packages_file
    end
    logirl success "Updated $packages_file with current Homebrew state"
    logirl info "Snapshotted $(count $taps) taps, $(count $formulae) formulae, $(count $casks) casks"
end
