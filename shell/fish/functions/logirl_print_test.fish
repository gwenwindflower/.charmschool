function logirl_print_test -d "Visual reference and test suite for logirl message types"
    echo (set_color --bold)"════════════════════════════════════════════════════════"(set_color normal)
    echo (set_color --bold --italic)"                 logirl Visual Reference  "(set_color normal)
    echo (set_color --bold)"════════════════════════════════════════════════════════"(set_color normal)
    printf "\n"

    # Core Messages
    echo (set_color --bold --underline)"Core Messages"(set_color normal)
    echo "━━━━━━━━━━━━━"

    echo (set_color --dim)'$ logirl error "File not found"'(set_color normal)
    logirl error "File not found"
    printf "\n"

    echo (set_color --dim)'$ logirl warning "Deprecated flag used"'(set_color normal)
    logirl warning "Deprecated flag used"
    printf "\n"

    echo (set_color --dim)'$ logirl info "Processing 42 files"'(set_color normal)
    logirl info "Processing 42 files"
    printf "\n"

    echo (set_color --dim)'$ logirl success "Build completed successfully"'(set_color normal)
    logirl success "Build completed successfully"
    printf "\n"

    echo (set_color --dim)'$ logirl special "Step 1: Installing dependencies"'(set_color normal)
    logirl special "Step 1: Installing dependencies"
    printf "\n"

    # Help Text Formatting
    echo (set_color --bold --underline)"Help Text Formatting"(set_color normal)
    echo "━━━━━━━━━━━━━━━━━━━━"

    echo (set_color --dim)'$ logirl help_usage "mytool [OPTIONS] <file>"'(set_color normal)
    logirl help_usage "mytool [OPTIONS] <file>"

    echo (set_color --dim)'$ logirl help_header "Options"  # Title-only format'(set_color normal)
    logirl help_header Options

    echo (set_color --dim)'$ logirl help_cmd "mytool" "Run the main tool"'(set_color normal)
    printf "  "
    logirl help_cmd mytool "Run the main tool"
    printf "\n"

    echo (set_color --dim)'$ logirl help_flag "h/help" "Show this help message"'(set_color normal)
    printf "  "
    logirl help_flag h/help "Show this help message"
    printf "\n"

    echo (set_color --dim)'$ logirl help_flag "o/output=FILE" "Output file path"'(set_color normal)
    printf "  "
    logirl help_flag "o/output=FILE" "Output file path"
    printf "\n"

    # Utility Types
    echo (set_color --bold --underline)"Utility Types"(set_color normal)
    echo "━━━━━━━━━━━━━"

    echo (set_color --dim)'$ logirl dim "Deprecated feature"'(set_color normal)
    logirl dim "Deprecated feature"
    printf "\n"

    # Summary
    echo (set_color --bold)"════════════════════════════════════════════════════════"(set_color normal)
    echo (set_color --bold brgreen)"✓ All message types tested successfully"(set_color normal)
    echo (set_color --bold)"════════════════════════════════════════════════════════"(set_color normal)
    printf "\n"
    echo (set_color --dim)"For detailed usage: logirl --help"(set_color normal)
    echo (set_color --dim)"For complete docs: see LOGIRL_USAGE.md"(set_color normal)
end
