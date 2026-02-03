function marico -d "Batch convert Jupyter notebooks to marimo in a directory"
    # Parse arguments
    argparse h/help d/destructive -- $argv
    or return

    # Handle --help
    if set -q _flag_help
        echo "Batch convert all .ipynb files in a directory to marimo .py notebooks."
        logirl help_usage "marico [OPTIONS] <directory>"
        logirl help_header "Options"
        logirl help_flag "h/help" "Show this help message"
        logirl help_flag "d/destructive" "Delete .ipynb files after successful conversion"
        logirl help_header "Examples"
        printf "  marico notebooks/          # Convert all .ipynb in notebooks/\n"
        printf "  marico .                   # Convert all .ipynb in current directory\n"
        printf "  marico -d notebooks/       # Convert and delete originals\n"
        return 0
    end

    # Check for marimo dependency
    if not type -q marimo
        logirl error "marimo not found in PATH"
        logirl info "Install with: pip install marimo"
        return 127
    end

    # Check for gum dependency if destructive mode
    if set -q _flag_destructive
        if not type -q gum
            logirl error "gum not found in PATH (required for --destructive mode)"
            logirl info "Install with: brew install gum"
            return 127
        end
    end

    # Validate argument count
    if test (count $argv) -eq 0
        logirl error "No directory specified"
        printf "Try: marico --help\n"
        return 2
    end

    if test (count $argv) -gt 1
        logirl error "Too many arguments (expected 1 directory path, got "(count $argv)")"
        printf "Try: marico --help\n"
        return 2
    end

    # Validate directory path
    set -l target_dir $argv[1]
    if not test -e "$target_dir"
        logirl error "Path does not exist: $target_dir"
        return 1
    end

    if not test -d "$target_dir"
        logirl error "Path is not a directory: $target_dir"
        return 1
    end

    # Find all .ipynb files in directory
    set -l ipynb_files (find "$target_dir" -maxdepth 1 -type f -name "*.ipynb" 2>/dev/null)

    if test (count $ipynb_files) -eq 0
        logirl warning "No .ipynb files found in $target_dir"
        return 0
    end

    # Show what we found
    logirl info "Found "(count $ipynb_files)" Jupyter notebook(s) in $target_dir"

    # Confirm deletion if destructive mode
    if set -q _flag_destructive
        echo ""
        if not gum confirm "Delete original .ipynb files after successful conversion?"
            logirl info "Cancelled - no files will be deleted"
            return 0
        end
        echo ""
    end

    # Convert each notebook
    set -l converted 0
    set -l skipped 0
    set -l failed 0
    set -l converted_files

    for ipynb_file in $ipynb_files
        set -l basename (basename "$ipynb_file")
        set -l output_file (string replace -r '\\.ipynb$' '.py' "$ipynb_file")

        # Check if output already exists
        if test -f "$output_file"
            logirl warning "Skipping $basename (output already exists)"
            set skipped (math $skipped + 1)
            continue
        end

        # Convert the notebook
        logirl special "Converting $basename..."
        if marimo convert "$ipynb_file" -o "$output_file" 2>&1
            logirl success "Created "(basename "$output_file")
            set converted (math $converted + 1)
            set -a converted_files "$ipynb_file"
        else
            logirl error "Failed to convert $basename"
            set failed (math $failed + 1)
        end
    end

    # Delete original files if destructive mode and conversions succeeded
    set -l deleted 0
    if set -q _flag_destructive; and test (count $converted_files) -gt 0
        echo ""
        logirl special "Deleting original .ipynb files..."
        for ipynb_file in $converted_files
            if rm "$ipynb_file"
                set deleted (math $deleted + 1)
            else
                logirl error "Failed to delete "(basename "$ipynb_file")
            end
        end
        logirl success "Deleted $deleted original file(s)"
    end

    # Summary
    echo ""
    logirl info "Conversion complete:"
    printf "  Converted: %s\n" (set_color brgreen)"$converted"(set_color normal)
    if test $skipped -gt 0
        printf "  Skipped:   %s\n" (set_color bryellow)"$skipped"(set_color normal)
    end
    if test $deleted -gt 0
        printf "  Deleted:   %s\n" (set_color brmagenta)"$deleted"(set_color normal)
    end
    if test $failed -gt 0
        printf "  Failed:    %s\n" (set_color brred)"$failed"(set_color normal)
        return 1
    end

    return 0
end
