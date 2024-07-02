function rgf -d "Search for a string in files using ripgrep then filter files with fzf"
    rg --color=always --line-number --no-heading --smart-case (string join " " $argv) |
        fzf --ansi \
            --color "hl:-1:underline,hl+:-1:underline:reverse" \
            --delimiter : \
            --preview 'bat --color=always {1} --highlight-line {2}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
            --bind 'enter:become(vim {1} +{2})'
end
