function af -d "Search aliases and abbreviations with fzf"
    # @fish-lsp-disable 2002
    set -l results (abbr | sed 's/^abbr -a -- /abbr /') (alias)
    if test (count $argv) -eq 0
        printf '%s\n' $results | fzf --no-preview
    else if test (count $argv) -eq 1
        set -l search_term $argv[1]
        printf '%s\n' $results | fzf --query="$search_term" --no-preview
    else
        echo "Usage: af [search_term]"
        echo "Searches aliases and abbreviations with fzf"
    end
end
