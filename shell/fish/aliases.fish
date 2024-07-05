# shell and editor
alias vi nvim
alias vim nvim
alias rr "exec $SHELL"
alias e clear
alias s z
alias fun functions
alias m "mkdir -p"
alias top btm
alias ldr lazydocker

# rotz dotfile tool
alias di "rotz install"
alias dl "rotz link"
alias dlf "rotz link --force"
alias fp "$EDITOR $__fish_config_dir/fish_plugins"

# git tools
alias gdc "git dft --cached"
alias gdh "git dft HEAD"
alias gcob "git checkout -b"
alias gdto "git difftool"
alias gdtoc "git difftool --cached"
alias gz lazygit
alias gho "gh repo view -w"
alias ghd "gh dash"
alias gcmm meteor
alias lg lazygit

# dbt and data
alias dbtc "$HOMEBREW_PREFIX/bin/dbt"
alias dbtp "vi ~/.dbt/profiles.yml"
alias db "dbtc build"
alias dbs "dbtc build -s"
alias dt "dbtc test"
alias dts "dbtc test -s"
alias dr "dbtc run"
alias drs "dbtc run -s"
alias dp "dbtc parse"
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
alias venv "uv venv .venv"
alias va "source .venv/bin/activate.fish"
alias da deactivate
alias pi "uv pip"
alias pir "uv pip install -r"
alias pirr "uv pip install -r requirements.txt"
alias pird "uv pip install -r pyproject.toml --extra dev"
alias pc "uv pip compile requirements.in -o requirements.txt"
alias pcd "uv pip compile pyprpoject.toml --extra dev -o requirements.txt"
alias pcu "uv pip compile -U requirements.in -o requirements.txt"
alias psy "uv pip sync requirements.txt"
alias piup "uv pip install --upgrade pip"
alias pd "uv pip install -e ."
alias pyt pytest

# go
alias gorm "go run main.go"
alias gord "go run ."
alias gotv "go test -v"
alias gob "go build"

# lsd
alias l "lsd -lag"
alias ls lsd
alias ll "lsd -l"
alias lg "lsd -lg"
alias la "lsd -a"
alias lla "lsd -la"
alias lt "lsd --tree"

# frontend
alias ni "pnpm i"
alias nu "pnpm up"
alias nd "pnpm dev"
alias nb "pnpm build"
alias bi "bun install"
alias bd "bun dev"
alias ad "astro dev"
