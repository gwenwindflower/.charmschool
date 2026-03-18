function wt-icon -d "Set a custom icon/emoji for a worktree branch (used in Claude Code statusline)"
    argparse h/help b/branch= r/remove -- $argv
    or return 1

    if set -q _flag_help
        logirl help_usage "wt-icon [options] <icon>"
        logirl help_header "Description" "Set a custom icon/emoji for a worktree branch.\nThe icon appears in the Claude Code statusline to identify worktrees at a glance."
        logirl help_header "Examples" ""
        logirl help_cmd "wt-icon 🧪" "Set icon for current branch"
        logirl help_cmd "wt-icon -b feature-auth 🌙" "Set icon for a specific branch"
        logirl help_cmd "wt-icon -r" "Remove icon from current branch"
        logirl help_cmd "wt-icon -r -b feature-auth" "Remove icon from a specific branch"
        logirl help_header "Options" ""
        logirl help_flag b/branch=NAME "Target branch (default: current branch)"
        logirl help_flag r/remove "Remove the icon instead of setting one"
        logirl help_flag h/help "Show this help"
        return 0
    end

    # Determine target branch
    set -l branch
    if set -q _flag_branch
        set branch $_flag_branch
    else
        set branch (git branch --show-current 2>/dev/null)
        if test -z "$branch"
            logirl error "Not on a branch (detached HEAD). Use -b to specify a branch."
            return 1
        end
    end

    # Remove mode
    if set -q _flag_remove
        git config --unset wt-icon.$branch 2>/dev/null
        logirl success "Removed icon from $branch"
        return 0
    end

    # Set mode — require exactly one argument (the icon)
    if test (count $argv) -ne 1
        logirl error "Expected one argument: the icon/emoji to set.\nRun wt-icon --help for usage."
        return 1
    end

    git config wt-icon.$branch $argv[1]
    logirl success "Set icon for $branch → $argv[1]"
end
