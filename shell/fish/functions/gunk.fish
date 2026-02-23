function gunk -d "Download the main branch of a GitHub repo's current HEAD state into a plain non-git tracked directory."
    argparse h/help 'b/branch=' 't/tag=' -- $argv
    or return

    if set -q _flag_help
        echo "Download a GitHub repository as a plain directory (no git history)."
        logirl help_usage "gunk [OPTIONS] <github-url>"
        logirl help_header Options
        logirl help_flag h/help "Show this help message"
        logirl help_flag b/branch "NAME" "Download from specific branch (default: main)"
        logirl help_flag t/tag "NAME" "Download from specific tag/release"
        logirl help_header Examples
        printf "  gunk https://github.com/junegunn/fzf\n"
        printf "  gunk -b develop https://github.com/user/repo\n"
        printf "  gunk -t v1.2.3 https://github.com/user/repo\n"
        return 0
    end

    if not type -q wget
        logirl error "wget not found in PATH"
        logirl info "Install with: brew install wget"
        return 127
    end

    if test (count $argv) -lt 1
        logirl error "Missing required argument: github-url"
        logirl help_usage "gunk <github-repo-hompage>"
        printf "Use $(set_color brmagenta)gunk --help$(set_color normal) for more\n"
        return 1
    end

    # Check for mutually exclusive flags
    if set -q _flag_branch; and set -q _flag_tag
        logirl error "Cannot use both --branch and --tag flags"
        printf "Try: gunk --help\n"
        return 1
    end

    set -l url $argv[1]

    # Validate GitHub URL and extract user/repo using regex
    if not set -l match (string match -r '^https://github\.com/([^/]+)/([^/]+)' -- $url)
        logirl error "Invalid GitHub URL"
        logirl info "Expected format: https://github.com/user/repo"
        return 1
    end

    # Extract user and repo from regex capture groups
    set -l user $match[2]
    set -l repo $match[3]

    # Determine ref type and name
    set -l ref_type "heads"
    set -l ref_name "main"

    if set -q _flag_tag
        set ref_type "tags"
        set ref_name $_flag_tag
        logirl special "Downloading $user/$repo from tag $ref_name"
    else if set -q _flag_branch
        set ref_name $_flag_branch
        logirl special "Downloading $user/$repo from branch $ref_name"
    else
        logirl special "Downloading $user/$repo from main branch"
    end

    # Construct download URL
    set -l download_url "https://github.com/$user/$repo/archive/refs/$ref_type/$ref_name.tar.gz"

    # Download, extract, and rename
    if wget -qO- "$download_url" | tar xz
        mv ./"$repo-$ref_name" ./$repo
        logirl success "Downloaded $user/$repo to ./$repo"
    else
        logirl error "Failed to download $user/$repo"
        if set -q _flag_tag
            logirl info "Check that the tag '$ref_name' exists"
        else
            logirl info "Check that the branch '$ref_name' exists"
        end
        return 1
    end
end
