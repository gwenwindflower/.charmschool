function gitdiverge -d "Check if a commit is still descendend from another commit or has diverged, defaults to checking if HEAD is still a descendant of origin/main"
    if test (count $argv) -gt 2
        logirl error "Too many args."
        logirl help_usage "gitdiverge [ancestor commit] [descendant commit]"
        return 1
    end
    set -l ancestor_commit origin/main
    set -l descendant_commit HEAD
    if test (count $argv) -eq 2
        set ancestor_commit $argv[1]
        set descendant_commit $argv[2]
    else if test (count $argv) -eq 1
        set ancestor_commit $argv[1]
    end
    if git merge-base --is-ancestor $ancestor_commit $descendant_commit
        logirl success "$descendant_commit is still a descendant of $ancestor_commit"
    else
        logirl error "$ancestor_commit and $descendant_commit have diverged"
        echo "$descendant_commit is no longer a descendant of $ancestor_commit"
    end
end
