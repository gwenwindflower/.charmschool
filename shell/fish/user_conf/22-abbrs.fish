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
## colorized help via bat
abbr --add --position anywhere -- --help '--help | bat -plhelp'
abbr --add --position anywhere -- -h '-h | bat -plhelp'
## quick access to quietly dumping output
abbr --add --position anywhere -- qq '>/dev/null'
## if you want to discard both stdout and stderr
abbr --add --position anywhere -- qqq '>/dev/null 2>&1'
abbr --add mac macchina # stats of my mac? mac -> macchina

# tooling
abbr --add t task
abbr --add ldr lazydocker
abbr --add f fzf
## this gives a nice preview for file searches by piping fd into fzf with a preview window
## useful if you know you want to search files in a directory
abbr --add fp "fd . --color always --hidden --ignore | fzf --preview '_fzf_preview_file {}'"

# Homebrew
## these force us to keep brew up-to-date if we want convenient abbreviations
abbr --add bri "brew update; brew upgrade; brew install"
abbr --add bru "brew update; brew upgrade"
abbr --add brs "brew update; brew search"
abbr --add brq brew info
abbr --add brl brew list
abbr --add brlc brew list --cask
abbr --add brd brew deps
abbr --add brdt brew deps --tree
abbr --add brD brew uses
abbr --add brsv brew services
abbr --add brcl brew cleanup

# ai
abbr --add lll claude
abbr --add ggg gemini
abbr --add ppp copilot
abbr --add xxx codex
abbr --add uuu crush

# mitmproxy
abbr -a 'prx?' prxstate
abbr -a mp mitmproxy

# quick directory navigation
## built on top of sd fish function wrapping zoxide -> launchers
abbr --add sc sd_dotfiles -e
abbr --add sf sd_config
abbr --add sp sd_dev

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
abbr --add ip ipython
abbr --add pyt pytest
abbr --add uvpy uv python
abbr --add uvpyi uv python install
abbr --add uvpyls uv python list
abbr --add uvpyu uv python upgrade
abbr --add uvt uv tool
abbr --add uvti uv tool install
abbr --add uvtu uv tool upgrade
abbr --add uvr uv run
abbr --add uvp uv pip
abbr --add uvpi uv pip install
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

# frontend
abbr --add n pnpm
abbr --add nx pnpx
abbr --add ni pnpm i
abbr --add nu pnpm up
abbr --add nd pnpm dev
abbr --add nb pnpm build
abbr --add b bun
abbr --add bi bun i
abbr --add ba bun add
abbr --add bu bun upgrade
abbr --add bs bun start
abbr --add br bun run
abbr --add bx bunx
abbr --add bt bun test

# git
abbr --add g git
## operations
### staging
abbr --add gaa git add --all
abbr --add gau git add --update
abbr --add gap git add --patch
abbr --add gust git unstage
abbr --add gusta git unstage-all
### viewing state and history
abbr --add gsh git show
abbr --add gst git status -M -sb
### branches
abbr --add gb git branch -vv # list branches with tracking info
abbr --add gba git branch -a -vv # all branches including remote
abbr --add gbf git branch -a -vv --list # follow with search terms to filter branches
abbr --add gban git branch -a -vv --no-merged # called from main, gives all branches not merged into main/HEAD
abbr --add gbd git branch -d # safe delete
abbr --add gbD git branch -D # force delete
abbr --add gbm git branch -m # safe rename
abbr --add gbM git branch -M # force rename
abbr --add gs git switch
abbr --add gsc git switch -c # new branch
# checkout and restore
abbr --add grs git restore
abbr --add grss git restore --source
abbr --add grst git restore --staged
abbr --add grsts git restore --staged --source
abbr --add grsth git restore . --source HEAD
abbr --add gco git checkout
# git worktree abbreviations
abbr --add gwt git worktree
abbr --add gwta git worktree add
abbr --add gwtls git worktree list
abbr --add gwtlo git worktree lock
abbr --add gwtmv git worktree move
abbr --add gwtpr git worktree prune
abbr --add gwtrm git worktree remove
abbr --add gwtulo git worktree unlock
## config
abbr --add gcfg git config --global
abbr --add gcfls git config --list
## github
abbr --add gho gh repo view -w
abbr --add ghd gh dash
## interactive tools
abbr --add gui lazygit
abbr --add gcmm meteor
## forgit
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

# TODO: finish reviewing
abbr --add ggsup git branch --set-upstream-to=origin/\(__git.current_branch\)
abbr --add gbl git blame -b -w
abbr --add gbs git bisect
abbr --add gbsb git bisect bad
abbr --add gbsg git bisect good
abbr --add gbsr git bisect reset
abbr --add gbss git bisect start
abbr --add grset git remote set-url
abbr --add gc git commit -v
abbr --add gc! git commit -v --amend
abbr --add gcn! git commit -v --no-edit --amend
abbr --add gca git commit -v -a
abbr --add gca! git commit -v -a --amend
abbr --add gcan! git commit -v -a --no-edit --amend
abbr --add gcv git commit -v --no-verify
abbr --add gcav git commit -a -v --no-verify
abbr --add gcav! git commit -a -v --no-verify --amend
abbr --add gcm git commit -m
abbr --add gcam git commit -a -m
abbr --add gcs git commit -S
abbr --add gscam git commit -S -a -m
abbr --add gcfx git commit --fixup
abbr --add gcf git config --list
abbr --add gcl git clone
abbr --add gclean git clean -di
abbr --add gclean! git clean -dfx
abbr --add gclean!! "git reset --hard; and git clean -dfx"
abbr --add gcount git shortlog -sn
abbr --add gcp git cherry-pick
abbr --add gcpa git cherry-pick --abort
abbr --add gcpc git cherry-pick --continue
abbr --add gd git diff
abbr --add gdca git diff --cached
abbr --add gds git diff --stat
abbr --add gdsc git diff --stat --cached
abbr --add gdt git diff-tree --no-commit-id --name-only -r
abbr --add gdw git diff --word-diff
abbr --add gdwc git diff --word-diff --cached
abbr --add gdg git diff --no-ext-diff
abbr --add gignore git update-index --assume-unchanged
abbr --add gf git fetch
abbr --add gfa git fetch --all --prune
abbr --add gfm "git fetch origin (__git.default_branch) --prune; and git merge FETCH_HEAD"
abbr --add gfo git fetch origin
abbr --add gl git pull
abbr --add ggl git pull origin \(__git.current_branch\)
abbr --add gll git pull origin
abbr --add glr git pull --rebase
abbr --add glg git log --stat
abbr --add glgg git log --graph
abbr --add glgga git log --graph --decorate --all
abbr --add glo git log --oneline --decorate --color
abbr --add glog git log --oneline --decorate --color --graph
abbr --add gloga git log --oneline --decorate --color --graph --all
abbr --add glom git log --oneline --decorate --color \(__git.default_branch\)..
abbr --add gm git merge
abbr --add gmt git mergetool --no-prompt
abbr --add gmom git merge origin/\(__git.default_branch\)
abbr --add gp git push
abbr --add gp! git push --force-with-lease
abbr --add gpo git push origin
abbr --add gpo! git push --force-with-lease origin
abbr --add gpv git push --no-verify
abbr --add gpv! git push --no-verify --force-with-lease
abbr --add ggp git push origin \(__git.current_branch\)
abbr --add ggp! git push origin \(__git.current_branch\) --force-with-lease
abbr --add gpu git push origin \(__git.current_branch\) --set-upstream
abbr --add gpoat "git push origin --all; and git push origin --tags"
abbr --add ggpnp "git pull origin (__git.current_branch); and git push origin (__git.current_branch)"
abbr --add gr git remote -vv
abbr --add gra git remote add
abbr --add grb git rebase
abbr --add grba git rebase --abort
abbr --add grbc git rebase --continue
abbr --add grbi git rebase --interactive
abbr --add grbm git rebase \(__git.default_branch\)
abbr --add grbmi git rebase \(__git.default_branch\) --interactive
abbr --add grbmia git rebase \(__git.default_branch\) --interactive --autosquash
abbr --add grbom "git fetch origin (__git.default_branch); and git rebase FETCH_HEAD"
abbr --add grbomi "git fetch origin (__git.default_branch); and git rebase FETCH_HEAD --interactive"
abbr --add grbomia "git fetch origin (__git.default_branch); and git rebase FETCH_HEAD --interactive --autosquash"
abbr --add grbd git rebase develop
abbr --add grbdi git rebase develop --interactive
abbr --add grbdia git rebase develop --interactive --autosquash
abbr --add grbs git rebase --skip
abbr --add ggu git pull --rebase origin \(__git.current_branch\)
abbr --add grev git revert
abbr --add grh git reset
abbr --add grhh git reset --hard
abbr --add grhpa git reset --patch
abbr --add grm git rm
abbr --add grmc git rm --cached
abbr --add grmv git remote rename
abbr --add grpo git remote prune origin
abbr --add grrm git remote remove
abbr --add grup git remote update
abbr --add grv git remote -v
abbr --add gsta git stash
abbr --add gstd git stash drop
abbr --add gstl git stash list
abbr --add gstp git stash pop
abbr --add gsts git stash show --text
abbr --add gsu git submodule update
abbr --add gsur git submodule update --recursive
abbr --add gsuri git submodule update --recursive --init
abbr --add gts git tag -s
abbr --add gtv git tag | sort -V
abbr --add gunignore git update-index --no-assume-unchanged
abbr --add gup git pull --rebase
abbr --add gupv git pull --rebase -v
abbr --add gupa git pull --rebase --autostash
abbr --add gupav git pull --rebase --autostash -v
abbr --add gwch git whatchanged -p --abbrev-commit --pretty=medium
