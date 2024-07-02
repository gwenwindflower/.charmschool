function frg -d "Launch fzf as an interface to ripgrep"
    set RG_PREFIX "rg --column --line-number --no-heading --color=always --smart-case "
    set INITIAL_QUERY (string join " " $argv)
    fzf --ansi --disabled --query "$INITIAL_QUERY" \
        --bind "start:reload:$RG_PREFIX {q}" \
        --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
        --bind 'enter:become(vim {1} +{2})'
end
