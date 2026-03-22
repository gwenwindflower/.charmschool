function tstat -d "Get basic info on tmux status"
    if tmux list-sessions >/dev/null 2>&1
        echo "Yep, tmux $(set_color -r -o blue) is running! $(set_color normal)"
    else
        echo "Nope, tmux $(set_color -r -o red) is not running! $(set_color normal)"
    end
end
