# shell and editor
abbr --add p echo # p for print
abbr --add pp bat # pp for pretty print
abbr --add r rip
abbr --add e fresh -r # reload shell
abbr --add ee fresh -c # clear screen
abbr --add eee fresh # clear and reload
abbr --add fun functions
abbr --add top btm # you can use ctrl+space to stop the abbreviation expansion
abbr --add cat bat # helpful if you really do need the classic tool versus the modern alternative
abbr --add vi opo nvim
abbr --add vim opo nvim
abbr --add nvim opo nvim
abbr --add mkt mktemp
abbr --add mkd mkdir -p
abbr --add cp. "pwd | pbcopy"
## colorized help via bat
abbr --add --position anywhere -- --help '--help | bat -plhelp'
abbr --add --position anywhere -- -h '-h | bat -plhelp'
## quick access to quietly dumping output
abbr --add --position anywhere -- qq '>/dev/null'
## if you want to discard both stdout and stderr
abbr --add --position anywhere -- qqq '>/dev/null 2>&1'

# config and dotfiles
abbr --add moi chezmoi
abbr --add moid chezmoi cd
abbr --add moie chezmoi edit
abbr --add moia chezmoi apply

# tooling
abbr --add t task
abbr --add m mise
abbr --add mu mise use
abbr --add mi mise install
abbr --add mr mise run
abbr --add mc mise config
abbr --add mcl mise config list
abbr --add mcs mise config set
abbr --add mpth $HOME/.local/share/mise/installs/
abbr --add mac macchina # stats of my mac? mac -> macchina
## TUIs
abbr --add lgt lazygit
abbr --add ldr lazydocker
abbr --add lsh lazyssh
abbr --add lku k9s
## fzf
abbr --add f fzf
## this gives a nice preview for file searches by piping fd into fzf with a preview window
## useful if you know you want to search files in a directory
abbr --add fp "fd . --color always --hidden --ignore | fzf --preview '_fzf_preview_file {}'"
## print the default opts in a readable list format
abbr --add fzfopts "echo \$FZF_DEFAULT_OPTS | sed 's/^--//; s/ --/\n/g' | bat"

# Homebrew
abbr --add bri "brew update; brew install"
abbr --add brr brew uninstall
abbr --add bru "brew update; brew upgrade; brew cleanup"
abbr --add brs "brew update; brew search"
abbr --add br? brew info
abbr --add brls brew list
abbr --add brlsf brew list --installed-on-request
abbr --add brlsc brew list --cask
abbr --add brd brew deps
abbr --add brdt brew deps --tree
abbr --add bruise brew uses --installed
abbr --add brbg brew services
abbr --add brc brew cleanup
# custom function to run commands across multiple fzf-selected formulae/casks
abbr --add brx brewdo

# ai
abbr --add ccf zex $HOME/.claude
abbr --add cco opo claude
abbr --add claude opo claude
abbr --add ccfs "zex $HOME/.charmschool/agents/claude/skills"
# TODO: set up env files for crush, opencode, copilot, and codex
abbr --add uwu opo crush
# abbr --add crush opo crush
abbr --add opc opo opencode
# abbr --add opencode opo opencode
abbr --add cdx opo codex
# abbr --add codex opo codex
abbr --add ccu "bunx ccusage@latest"

# writing, notes, and to-dos
## default Obsidian vault
abbr --add notes "zex -e '$OBSIDIAN_DEFAULT_VAULT'"
abbr --add ob obsidian-cli
abbr --add obsidian obsidian-cli

# mitmproxy
abbr -a 'prx?' prxstate
abbr -a mp mitmproxy

# zoxide quick directory jumping
## built on top of zex fish function wrapping zoxide -> [nvim | yazi]
abbr --add s z
abbr --add dots "zex -e $HOME/.charmschool"
abbr --add conf "zex $HOME/.config"
abbr --add dev "zex $HOME/dev"
abbr --add keeb "zex -e $HOME/dev/04_utils/tinybabykeeb"

# dbt
abbr --add db dbtf build -s
abbr --add dba dbtf build
abbr --add dt dbtf test -s
abbr --add dta dbtf test
abbr --add dr dbtf run -s
abbr --add dra dbtf run
abbr --add dbtp nvim ~/.dbt/profiles.yml
abbr --add dbtpp bat ~/.dbt/profiles.yml

# compute and data
abbr --add dbx databricks
abbr --add ddb duckdb
abbr --add pg pgcli

# media and misc
abbr --add spotify spotify_player
abbr --add spt spotify_player
abbr --add ytdl yt-dlp
abbr --add gdl gallery-dl

# python
abbr --add py python
abbr --add pym python main.py
abbr --add ip ipython
abbr --add pyt pytest
abbr --add uvpy uv python
abbr --add uvpyh "cd (uv python dir)"
abbr --add uvpyi uv python install
abbr --add uvpyls uv python list
abbr --add uvpyu uv python upgrade
abbr --add uvt uv tool
abbr --add uvti uv tool install
abbr --add uvtu uv tool upgrade
abbr --add uvr uv run
abbr --add uvp uv pip
abbr --add uvpi uv pip install
abbr --add uvpir "uv pip install -r requirements.txt"
abbr --add uva uv add
abbr --add uvs uv sync
abbr --add uvi uv init
abbr --add uvb uv build
abbr --add va source .venv/bin/activate.fish
abbr --add da deactivate

# go
abbr --add gor go run main.go
abbr --add gord go run .
abbr --add got go test
abbr --add gotv go test -v
abbr --add gob go build

# rust
abbr --add ruu rustup up

# lsd
abbr --add l lsd -lAg
abbr --add ls lsd --classic
abbr --add ll lsd -l
abbr --add lg lsd -lg
abbr --add la lsd -A
abbr --add lla lsd -lA
abbr --add lt lsd --tree

# typescript
# pnpm
abbr --add n pnpm
abbr --add nx pnpx
abbr --add ni pnpm i
abbr --add nu pnpm up
abbr --add nd pnpm dev
abbr --add nb pnpm build
# bun
abbr --add b bun
abbr --add bi bun i
abbr --add ba bun add
abbr --add bu bun upgrade
abbr --add bs bun start
abbr --add br bun run
abbr --add bx bunx
abbr --add bt bun test
# deno
abbr --add d deno
abbr --add dig deno install -grAf --root $DENO_HOME

# git
abbr --add g git
## config
abbr --add gcfg git config --global
## github
abbr --add gho gh repo view -w
abbr --add ghd gh dash
## interactive tools
abbr --add gui lazygit
abbr --add gcmm meteor
## forgit
abbr --add gfgii "git forgit ignore >> .gitignore"
abbr --add gfg git forgit
abbr --add gfga git forgit add
abbr --add gfglo git forgit log
abbr --add gfgd git forgit diff
abbr --add gfgi git forgit ignore
abbr --add gfgbl git forgit blame
abbr --add gfgrb git forgit rebase
abbr --add gfgbd git forgit branch_delete
abbr --add gfgb git forgit checkout_branch
abbr --add gfgct git forgit checkout_tag
abbr --add gfgcf git forgit checkout_file
abbr --add gfgcc git forgit checkout_commit
abbr --add gfgrc git forgit revert_commit
abbr --add gfgcl git forgit clean

abbr --add gfgrh git forgit reset_head
abbr --add gfgss git forgit stash_show
abbr --add gfgsp git forgit stash_push
abbr --add gfgcp git forgit cherry_pick
abbr --add gfgcpb git forgit cherry_pick_from_branch
