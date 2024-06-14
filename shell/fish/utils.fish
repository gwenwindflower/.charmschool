#         ___
#        /\_ \    __
#    __  \//\ \  /\_\     __      ____     __    ____
#  /'__`\  \ \ \ \/\ \  /'__`\   /',__\  /'__`\ /',__\
# /\ \L\.\_ \_\ \_\ \ \/\ \L\.\_/\__, `\/\  __//\__, `\
# \ \__/.\_\/\____\\ \_\ \__/.\_\/\____/\ \____\/\____/
#  \/__/\/_/\/____/ \/_/\/__/\/_/\/___/  \/____/\/___/

# shell and editor
alias vi nvim
alias vim nvim
function rr
    exec $SHELL
end
alias e clear
alias s z

# rotz dotfile tool
alias di "rotz install"
alias dl "rotz link"
function dli
    rotz link; and rotz install
end

function fp
    $EDITOR $__fish_config_dir/fish_plugins
end

# git tools
alias gdto "git difftool"
alias gdtoc "git difftool --cached"
alias gz lazygit
alias gho "gh repo view -w"
alias ghd "gh dash"
alias gcmm meteor

# dbt and data
alias dbtc "$HOMEBREW_PREFIX/bin/dbt"
function dbtp
    vi ~/.dbt/profiles.yml
end
function db
    dbtc build
end
function dbs
    dbtc build -s
end
function dt
    dbtc test
end
function dts
    dbtc test -s
end
function dr
    dbtc run
end
function drs
    dbtc run -s
end
function dp
    dbtc parse
end
alias dbx databricks

# media and misc
alias af als
alias bri "brew update and brew upgrade and brew install"
alias bu "brew update and brew upgrade"
alias cat bat
alias cc cookiecutter
alias kb "cd ~/qmk_firmware/keyboards/splitkb/kyria/keymaps/gwenwindflower and vi"
alias ddb duckdb
alias ki "kitty +kitten icat"
alias wthr "curl wttr.in/chicago"
alias moon pyphoon
alias moonl pyphoon-lolcat
alias pu "cmus-remote --pause"
alias spotify spotify_player
alias pg pgcli
alias yt yt-dlp
alias gdl gallery-dl
alias t task
alias mm macchina

# python
alias p python3
alias python python3
alias pip pip3
function venv
    uv venv .venv
end
function va
    source .venv/bin/activate.fish
end
alias da deactivate
function venva
    venv; and va
end
alias pi "uv pip"
alias pir "uv pip install -r"
alias pirr "uv pip install -r requirements.txt"
alias pc "uv pip compile requirements.in -o requirements.txt"
alias pcd "uv pip compile dev-requirements.in -o dev-requirements.txt"
alias pcu "uv pip compile -U requirements.in -o requirements.txt"
alias pcdu "uv pip compile -U dev-requirements.in -o dev-requirements.txt"
alias psy "uv pip sync requirements.txt"
alias psyd "uv pip sync requirements.txt dev-requirements.txt"
function pcy
    pc; and psy
end
function pcyd
    pc; and pcd; and psyd
end
alias piup "uv pip install --upgrade pip"
function vpi
    venva; and pirr
end
function vpci
    venva; and pc; and pirr
end
alias pdot "uv pip install -e ."
function pcydd
    pcyd; and pdot
end
alias pyt pytest

# go
alias gorm "go run main.go"
alias gord "go run ."
alias gotv "go test -v"

# eza
alias l "eza -l"
alias ls eza
alias ll "eza -l"
alias la "eza -a"
alias lla "eza -la"
alias lg "eza -laG --git"
alias lt "eza --tree"

# frontend
alias ni "pnpm i"
alias nu "pnpm up"
alias nd "pnpm dev"
alias nb "pnpm build"
alias bi "bun install"
alias bd "bun dev"
alias ad "astro dev"

#    ___                         __
#  /'___\                       /\ \__  __
# /\ \__/  __  __    ___     ___\ \ ,_\/\_\    ___     ___     ____
# \ \ ,__\/\ \/\ \ /' _ `\  /'___\ \ \/\/\ \  / __`\ /' _ `\  /',__\
#  \ \ \_/\ \ \_\ \/\ \/\ \/\ \__/\ \ \_\ \ \/\ \L\ \/\ \/\ \/\__, `\
#   \ \_\  \ \____/\ \_\ \_\ \____\\ \__\\ \_\ \____/\ \_\ \_\/\____/
#    \/_/   \/___/  \/_/\/_/\/____/ \/__/ \/_/\/___/  \/_/\/_/\/___/

# function to make a directory in a python package project with __init__.py
function pd
    mkdir $argv[1]; and touch $argv[1]/__init__.py
end

# open yazi and exit to directory navigated to
function ff
    set tmp (mktemp -t "yazi-cwd.XXXXX")
    yazi --cwd-file=$tmp
    set cwd (cat $tmp)
    if test -n "$cwd" -a "$cwd" != "$PWD"
        cd $cwd
    end
    rm -f $tmp
end

# function to get code suggestions from Gemma
function mc
    set file_name $argv[1]
    mods -m gemma "How would you improve the code in this file?" <$file_name | glow
end

# function to get a code explanation from Gemma
function mp
    mods -m gemma "Can you explain this code?" | glow
end

# function to copy an environment variable to the clipboard
function cpenv
    printenv $argv[1] | pbcopy
end

# function to time fish startup
function timezsh
    set shell (or $argv[1] $SHELL)
    for i in (seq 1 10)
        /usr/bin/time $shell -i -c exit
    end
end

function go_cover
    go test -coverprofile=coverage.out
    go tool cover -html=coverage.out
end

# Query a dbt saved query 
# Takes one argument, the name of the saved query
function dsq
    dbt parse and dbt sl query --limit=10 --saved-query $argv[1]
end

# Query a dbt metric
# Takes 3 arguments, the name of the metric, the group-by, and the filter
# It assumes you want to order by the group-by
function dsm
    if test -z "$argv[3]"
        dbt parse and dbt sl query --metrics $argv[1] --group-by $argv[2] --order-by $argv[2]
    else
        dbt parse and dbt sl query --metrics $argv[1] --group-by $argv[2] --order-by $argv[2] --where $argv[3]
    end
end

# Open nvim or z to a directory and open nvim
function v
    if test (count $argv) -eq 0
        nvim
    else
        z $argv[1]; and nvim
    end
end

# Clear the terminal and restart the shell
function er
    clear; and exec $SHELL
end

# Open nvim in the fish config directory
function oo
    z ~/.config/fish; and nvim
end
