# Abbreviations

# abbrs are the preferred way to handle shortcuts in fish
# they do everything aliases do with more flexibility and transparency
# e.g. full command is stored in history, not the abbreviation, which powers more useful completion
# e.g. expand the abbr then edit one of the flags, instead of making tons of variant aliases
# use ctrl+space to block expanding the abbr
# so classic commands I abbr can still be run: `cat>ctrl+space>enter` will run `cat` instead of `bat`

# printing
abbr --add p echo # p for print
abbr --add pp bat # pp for pretty print
abbr --add cat bat
# shell
abbr --add e fresh -r # reload shell
abbr --add ee fresh -c # clear screen
abbr --add et fresh -g # navigate to ~ then clear and reload
abbr --add er fresh # clear and reload
abbr --add fun functions
# processes
abbr --add top btm
abbr --add pps procs
# dir and file management
abbr --add cp. "pwd | pbcopy"
abbr --add mkd mkdir -p
abbr --add mkt mktemp
abbr --add r rip
abbr --add mac macchina
abbr --add cmx chmod +x # make executable
abbr --add cmme chmod 700 # give me all permsissions and nobody else any
# editor
## opo = run nvim via `op run` with nvim environment file
abbr --add vi opo nvim
abbr --add vim opo nvim
abbr --add nvim opo nvim
# shell snippets
## colorized help via bat
abbr --add --position anywhere -- --help '--help | bat -plhelp'
abbr --add --position anywhere -- -h '-h | bat -plhelp'
## quick access to quietly dumping output
abbr --add --position anywhere -- qq '>/dev/null'
## if you want to discard both stdout and stderr
abbr --add --position anywhere -- qqq '>/dev/null 2>&1'
# dotfiles
abbr --add moi chezmoi
abbr --add moid chezmoi cd
abbr --add moie chezmoi edit
abbr --add moia chezmoi apply
# runners
abbr --add t task
abbr --add mk make
# 'lazy' TUIs
abbr --add lgt lazygit
abbr --add ldr lazydocker
# file search/view/explore
abbr --add f fzf
## 'fe' function launches yazi
## this gives a nice preview for file searches by piping fd into fzf with a preview window
## useful if you know you want to search files in a directory
abbr --add fdf "fd . --color always --hidden --ignore | fzf --preview '_fzf_preview_file {}'"
### print the default opts in a readable list format
abbr --add fzfopts "echo \$FZF_DEFAULT_OPTS | sed 's/^--//; s/ --/\n/g' | bat"
# listing
abbr --add l lsd -lAg
abbr --add ls lsd --classic
abbr --add ll lsd -l
abbr --add lg lsd -lg
abbr --add la lsd -A
abbr --add lla lsd -lA
abbr --add lt lsd --tree
# navigation
abbr --add s z
abbr --add ss zex # zoxide > launch yazi/nvim
abbr --add dots "zex -e $HOME/.charmschool"
abbr --add conf "zex $XDG_CONFIG_HOME"
abbr --add proj "zex $PROJECTS"
abbr --add keeb "zex -e $PROJECTS_UTILS/tinybabykeeb"
# Homebrew
## custom function to run commands across multiple fzf-selected formulae/casks
abbr --add brx brewdo
## updates and installs
abbr --add bri "brew update; brew install"
abbr --add brr brew uninstall
abbr --add bru "brew update; brew upgrade; brew cleanup"
abbr --add brs "brew update; brew search"
abbr --add brc brew cleanup
abbr --add brcl brew cleanup
## details and dependencies
abbr --add brl brew list
abbr --add brl brew list
abbr --add brlf brew list --installed-on-request
abbr --add brli brew list --installed-on-request
abbr --add brlc brew list --cask
abbr --add brls brew list
abbr --add brlsf brew list --installed-on-request
abbr --add brlsi brew list --installed-on-request
abbr --add brlsc brew list --cask
abbr --add br? brew info
abbr --add brin brew info
abbr --add brd brew deps
abbr --add brdt brew deps --tree
abbr --add bruse brew uses --installed
abbr --add bruise brew uses --installed
## background services
abbr --add brbg brew services
abbr --add brsrv brew services
# ai
abbr --add opc opo opencode
abbr --add ghc opo copilot
## claude
abbr --add cco opo claude
abbr --add ccf zex $HOME/.claude
abbr --add ccfs "zex $HOME/.charmschool/agents/claude/skills"
abbr --add ccu "bunx ccusage@latest"
# writing
## default Obsidian vault
abbr --add notes "zex -e '$OBSIDIAN_DEFAULT_VAULT'"
abbr --add ob obsidian-cli
# security and network
## 1password
abbr --add ope "op run --env-file=$OP_ENV_DIR/global.env --no-masking -- " # run with default global env file, without setting env vars for the session, no masking (for interactive use)
abbr --add opi "op run --no-masking -- "
abbr --add opr "op run -- "
abbr --add openv o $OP_ENV_DIR
## macos keyring
abbr --add keys security
## mitmproxy
abbr -a 'prx?' prx status
abbr -a mp mitmproxy
# data
abbr --add dbx databricks
abbr --add ddb duckdb
abbr --add pg pgcli
abbr --add sqli sqlite3
## dbt
abbr --add db dbtf build -s
abbr --add dba dbtf build
abbr --add dt dbtf test -s
abbr --add dta dbtf test
abbr --add dr dbtf run -s
abbr --add dra dbtf run
abbr --add dbtp nvim ~/.dbt/profiles.yml
abbr --add dbtpp bat ~/.dbt/profiles.yml
# languages
## multi-runtime
abbr --add m mise
abbr --add mu mise use
abbr --add mi mise install
abbr --add mr mise run
abbr --add mc mise config
abbr --add mcl mise config list
abbr --add mcs mise config set
abbr --add mpth $HOME/.local/share/mise/installs/
## python
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
## go
abbr --add gor go run main.go
abbr --add gord go run .
abbr --add got go test
abbr --add gotv go test -v
abbr --add gob go build
## rust
abbr --add ruu rustup up
## typescript
### pnpm
abbr --add n pnpm
abbr --add nx pnpx
abbr --add ni pnpm i
abbr --add nu pnpm up
abbr --add nd pnpm dev
abbr --add nb pnpm build
### bun
abbr --add b bun
abbr --add bi bun i
abbr --add ba bun add
abbr --add bu bun upgrade
abbr --add bs bun start
abbr --add br bun run
abbr --add bx bunx
### deno
abbr --add bt bun test
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
# media
abbr --add spotify spotify_player
abbr --add spt spotify_player
abbr --add ytdl yt-dlp
abbr --add gdl gallery-dl
