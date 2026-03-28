# =============================================================================
# OS / Architecture detection (single check, reused everywhere)
# =============================================================================
# We only support macOS and Linux. Anything else gets a simple fallback.
set -l __os (uname -s)
set -l __arch (uname -m)

# Derive Homebrew prefix without calling `brew shellenv`
# macOS Apple Silicon: /opt/homebrew
# macOS Intel:         /usr/local
# Linux (Linuxbrew):   /home/linuxbrew/.linuxbrew
switch "$__os/$__arch"
    case Darwin/arm64
        set __brew_prefix /opt/homebrew
    case 'Darwin/*'
        set __brew_prefix /usr/local
    case 'Linux/*'
        set __brew_prefix /home/linuxbrew/.linuxbrew
    case '*'
        # Unknown platform — fall back to calling brew shellenv if brew exists
        if type -q brew
            brew shellenv fish | source
        end
end

# =============================================================================
# 00 — Core environment
# =============================================================================

#  PATH
# Construct fish_user_paths as a global (not universal) to avoid stale accumulation
set -e fish_user_paths
set -gx fish_user_paths $HOME/.local/bin
fish_add_path -g $HOME/.local/bin

#  Homebrew (inlined brew shellenv)
if set -q __brew_prefix
    set -gx HOMEBREW_PREFIX $__brew_prefix
    set -gx HOMEBREW_CELLAR $__brew_prefix/Cellar
    set -gx HOMEBREW_REPOSITORY $__brew_prefix/Homebrew
    # On Intel macOS the repository IS the prefix
    if test "$__os" = Darwin -a "$__arch" = x86_64
        set -gx HOMEBREW_REPOSITORY $__brew_prefix/Homebrew
    end
    fish_add_path -gm $__brew_prefix/bin $__brew_prefix/sbin
    if test -n "$MANPATH[1]"
        set -gx MANPATH '' $MANPATH
    end
    if not contains "$__brew_prefix/share/info" $INFOPATH
        set -gx INFOPATH "$__brew_prefix/share/info" $INFOPATH
    end
end
set -gx HOMEBREW_NO_ENV_HINTS 1

#  Terminal and Shell
set -gx SHELL $HOMEBREW_PREFIX/bin/fish

#  GPG
set -gx GPG_TTY (tty)

#  SSH (macOS only — on Linux, ssh agent forwarding handles this)
if test "$__os" = Darwin
    set -gx SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
end

#  XDG
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_STATE_HOME $HOME/.local/state
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_CONFIG_HOME $HOME/.config
# macOS GUI apps often use ~/Library/Application Support
set -gx MACOS_CONFIG_HOME "$HOME/Library/Application Support"
# For tools that look for $TEMP instead of $TMPDIR
set -gx TEMP $TMPDIR

#  Pager, docs, man
# moor as bat's pager, bat as global pager, themed man pages
set -gx MOOR "\
--quit-if-one-screen \
--wrap \
--no-linenumbers \
--style=catppuccin-frappe \
"
set -gx PAGER $HOMEBREW_PREFIX/bin/bat
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
# tldr client config
set -gx TLRC_CONFIG $XDG_CONFIG_HOME/tlrc/tlrc.toml

#  tmux
set -gx TMUX_PLUGIN_MANAGER_PATH $XDG_CONFIG_HOME/tmux/plugins
set -gx TMUX_PLUGIN_MANAGER_INSTALL $HOMEBREW_PREFIX/opt/tpm/share/tpm

#  1Password env dir
set -gx OP_ENV_DIR $XDG_CONFIG_HOME/op/environments

#  Project Bookmarks
set -gx PROJECTS $HOME/dev
set -gx PROJECTS_AGENTS $HOME/dev/01_agent-workbench
set -gx PROJECTS_SCRIPTS $HOME/dev/02_spellbook
set -gx PROJECTS_SANDBOX $HOME/dev/03_sandboxes
set -gx PROJECTS_FORKS $HOME/dev/04_forks
set -gx PROJECTS_UTILS $HOME/dev/05_utils
set -gx PROJECTS_ARCHIVE $HOME/dev/zzz/
set -gx PROJECTS_GRAVEYARD $HOME/dev/zzz-rip

# =============================================================================
# 01 — Editor
# =============================================================================
set -gx EDITOR nvim
set -gx NVIM_PLUGIN_DIR $XDG_DATA_HOME/nvim
set -gx NVIM_MASON_INSTALL $NVIM_PLUGIN_DIR/mason/packages
fish_add_path $NVIM_PLUGIN_DIR/mason/bin

# =============================================================================
# 02 — Git
# =============================================================================
set -gx GIT_PAGER delta
set -gx DFT_DISPLAY inline
set -gx GH_USER gwenwindflower
set -gx FORGIT_NO_ALIASES 1
set -gx FORGIT_GLO_FORMAT "%C(green)%h %C(reset)%d %s %C(magenta)%cr%C(reset)"
set -gx FORGIT_STASH_FZF_OPTS '--bind="ctrl-d:reload(git stash drop $(cut -d: -f1 <<<{}) 1>/dev/null && git stash list)"'
if test -f $HOMEBREW_PREFIX/share/forgit/forgit.plugin.fish
    source $HOMEBREW_PREFIX/share/forgit/forgit.plugin.fish
end
fish_add_path $FORGIT_INSTALL_DIR/bin

# =============================================================================
# 03 — AI
# =============================================================================
set -gx CLAUDE_HOME $HOME/.claude
set -gx OPENCODE_ENABLE_EXA 1

# =============================================================================
# 04 — Containers
# =============================================================================
set -gx ORBSTACK_HOME ~/.orbstack
fish_add_path $ORBSTACK_HOME/bin

# =============================================================================
# 10 — Rust
# =============================================================================
set -gx RUST_HOME $HOME/.cargo
fish_add_path $RUST_HOME/bin

# =============================================================================
# 11 — TypeScript (Bun, pnpm, Deno)
# =============================================================================
set -gx BUN_INSTALL $HOME/.bun
fish_add_path $BUN_INSTALL/bin

set -gx PNPM_HOME $XDG_DATA_HOME/pnpm
fish_add_path $PNPM_HOME

set -gx DENO_HOME $XDG_DATA_HOME/deno
set -gx DENO_INSTALL_ROOT $DENO_HOME/bin
fish_add_path $DENO_INSTALL_ROOT

# =============================================================================
# 12 — Go
# =============================================================================
# GOPATH is ~/.go (set by rotz install, not the default ~/go)
fish_add_path $HOME/.go/bin

# =============================================================================
# 13 — Python
# =============================================================================
set -gx UV_MANAGED_PYTHON 1

# =============================================================================
# 14 — Ruby
# =============================================================================
fish_add_path $HOMEBREW_PREFIX/opt/ruby/bin

# =============================================================================
# 19 — Mise: REMOVED
# =============================================================================
# mise activation removed for startup speed. Use `mise activate fish | source`
# manually in projects that need it, or add it back if the other optimizations
# provide enough headroom.
#
# We still move Homebrew's bin to the front of PATH so brew-installed tools
# take priority over mason duplicates (e.g. deno)
fish_add_path -m $HOMEBREW_PREFIX/bin
# Env var is still useful for quick access even without auto-activation
set -gx MISE_INSTALLS $XDG_DATA_HOME/mise/installs/

# =============================================================================
# Interactive-only section
# =============================================================================
if status is-interactive

    # =============================================================================
    # 20 — Theme
    # =============================================================================
    fish_config theme choose catppuccin-frappe
    set -gx fish_greeting
    set -gx BAT_THEME Catppuccin-Frappe

    # LS_COLORS — inlined output of `vivid generate catppuccin-frappe`
    # Regenerate with: vivid generate catppuccin-frappe
    set -gx LS_COLORS '*~=0;38;2;98;104;128:bd=0;38;2;133;193;220;48;2;65;69;89:ca=0:cd=0;38;2;244;184;228;48;2;65;69;89:di=0;38;2;140;170;238:do=0;38;2;35;38;52;48;2;244;184;228:ex=1;38;2;231;130;132:fi=0:ln=0;38;2;244;184;228:mh=0:mi=0;38;2;35;38;52;48;2;231;130;132:no=0:or=0;38;2;35;38;52;48;2;231;130;132:ow=0:pi=0;38;2;35;38;52;48;2;140;170;238:rs=0:sg=0:so=0;38;2;35;38;52;48;2;244;184;228:st=0:su=0:tw=0:*.1=0;38;2;229;200;144:*.a=1;38;2;231;130;132:*.c=0;38;2;166;209;137:*.d=0;38;2;166;209;137:*.h=0;38;2;166;209;137:*.m=0;38;2;166;209;137:*.o=0;38;2;98;104;128:*.p=0;38;2;166;209;137:*.r=0;38;2;166;209;137:*.t=0;38;2;166;209;137:*.v=0;38;2;166;209;137:*.z=4;38;2;133;193;220:*.7z=4;38;2;133;193;220:*.ai=0;38;2;238;190;190:*.as=0;38;2;166;209;137:*.bc=0;38;2;98;104;128:*.bz=4;38;2;133;193;220:*.cc=0;38;2;166;209;137:*.cp=0;38;2;166;209;137:*.cr=0;38;2;166;209;137:*.cs=0;38;2;166;209;137:*.db=4;38;2;133;193;220:*.di=0;38;2;166;209;137:*.el=0;38;2;166;209;137:*.ex=0;38;2;166;209;137:*.fs=0;38;2;166;209;137:*.go=0;38;2;166;209;137:*.gv=0;38;2;166;209;137:*.gz=4;38;2;133;193;220:*.ha=0;38;2;166;209;137:*.hh=0;38;2;166;209;137:*.hi=0;38;2;98;104;128:*.hs=0;38;2;166;209;137:*.jl=0;38;2;166;209;137:*.js=0;38;2;166;209;137:*.ko=1;38;2;231;130;132:*.kt=0;38;2;166;209;137:*.la=0;38;2;98;104;128:*.ll=0;38;2;166;209;137:*.lo=0;38;2;98;104;128:*.ma=0;38;2;238;190;190:*.mb=0;38;2;238;190;190:*.md=0;38;2;229;200;144:*.mk=0;38;2;129;200;190:*.ml=0;38;2;166;209;137:*.mn=0;38;2;166;209;137:*.nb=0;38;2;166;209;137:*.nu=0;38;2;166;209;137:*.pl=0;38;2;166;209;137:*.pm=0;38;2;166;209;137:*.pp=0;38;2;166;209;137:*.ps=0;38;2;231;130;132:*.py=0;38;2;166;209;137:*.rb=0;38;2;166;209;137:*.rm=0;38;2;238;190;190:*.rs=0;38;2;166;209;137:*.sh=0;38;2;166;209;137:*.so=1;38;2;231;130;132:*.td=0;38;2;166;209;137:*.ts=0;38;2;166;209;137:*.ui=0;38;2;229;200;144:*.vb=0;38;2;166;209;137:*.wv=0;38;2;238;190;190:*.xz=4;38;2;133;193;220:*FAQ=0;38;2;48;52;70;48;2;229;200;144:*.3ds=0;38;2;238;190;190:*.3fr=0;38;2;238;190;190:*.3mf=0;38;2;238;190;190:*.adb=0;38;2;166;209;137:*.ads=0;38;2;166;209;137:*.aif=0;38;2;238;190;190:*.amf=0;38;2;238;190;190:*.ape=0;38;2;238;190;190:*.apk=4;38;2;133;193;220:*.ari=0;38;2;238;190;190:*.arj=4;38;2;133;193;220:*.arw=0;38;2;238;190;190:*.asa=0;38;2;166;209;137:*.asm=0;38;2;166;209;137:*.aux=0;38;2;98;104;128:*.avi=0;38;2;238;190;190:*.awk=0;38;2;166;209;137:*.bag=4;38;2;133;193;220:*.bak=0;38;2;98;104;128:*.bat=1;38;2;231;130;132:*.bay=0;38;2;238;190;190:*.bbl=0;38;2;98;104;128:*.bcf=0;38;2;98;104;128:*.bib=0;38;2;229;200;144:*.bin=4;38;2;133;193;220:*.blg=0;38;2;98;104;128:*.bmp=0;38;2;238;190;190:*.bsh=0;38;2;166;209;137:*.bst=0;38;2;229;200;144:*.bz2=4;38;2;133;193;220:*.c++=0;38;2;166;209;137:*.cap=0;38;2;238;190;190:*.cfg=0;38;2;229;200;144:*.cgi=0;38;2;166;209;137:*.clj=0;38;2;166;209;137:*.com=1;38;2;231;130;132:*.cpp=0;38;2;166;209;137:*.cr2=0;38;2;238;190;190:*.cr3=0;38;2;238;190;190:*.crw=0;38;2;238;190;190:*.css=0;38;2;166;209;137:*.csv=0;38;2;229;200;144:*.csx=0;38;2;166;209;137:*.cxx=0;38;2;166;209;137:*.dae=0;38;2;238;190;190:*.dcr=0;38;2;238;190;190:*.dcs=0;38;2;238;190;190:*.deb=4;38;2;133;193;220:*.def=0;38;2;166;209;137:*.dll=1;38;2;231;130;132:*.dmg=4;38;2;133;193;220:*.dng=0;38;2;238;190;190:*.doc=0;38;2;231;130;132:*.dot=0;38;2;166;209;137:*.dox=0;38;2;129;200;190:*.dpr=0;38;2;166;209;137:*.drf=0;38;2;238;190;190:*.dxf=0;38;2;238;190;190:*.eip=0;38;2;238;190;190:*.elc=0;38;2;166;209;137:*.elm=0;38;2;166;209;137:*.epp=0;38;2;166;209;137:*.eps=0;38;2;238;190;190:*.erf=0;38;2;238;190;190:*.erl=0;38;2;166;209;137:*.exe=1;38;2;231;130;132:*.exr=0;38;2;238;190;190:*.exs=0;38;2;166;209;137:*.fbx=0;38;2;238;190;190:*.fff=0;38;2;238;190;190:*.fls=0;38;2;98;104;128:*.flv=0;38;2;238;190;190:*.fnt=0;38;2;238;190;190:*.fon=0;38;2;238;190;190:*.fsi=0;38;2;166;209;137:*.fsx=0;38;2;166;209;137:*.gif=0;38;2;238;190;190:*.git=0;38;2;98;104;128:*.gpr=0;38;2;238;190;190:*.gvy=0;38;2;166;209;137:*.h++=0;38;2;166;209;137:*.hda=0;38;2;238;190;190:*.hip=0;38;2;238;190;190:*.hpp=0;38;2;166;209;137:*.htc=0;38;2;166;209;137:*.htm=0;38;2;229;200;144:*.hxx=0;38;2;166;209;137:*.ico=0;38;2;238;190;190:*.ics=0;38;2;231;130;132:*.idx=0;38;2;98;104;128:*.igs=0;38;2;238;190;190:*.iiq=0;38;2;238;190;190:*.ilg=0;38;2;98;104;128:*.img=4;38;2;133;193;220:*.inc=0;38;2;166;209;137:*.ind=0;38;2;98;104;128:*.ini=0;38;2;229;200;144:*.inl=0;38;2;166;209;137:*.ino=0;38;2;166;209;137:*.ipp=0;38;2;166;209;137:*.iso=4;38;2;133;193;220:*.jar=4;38;2;133;193;220:*.jpg=0;38;2;238;190;190:*.jsx=0;38;2;166;209;137:*.jxl=0;38;2;238;190;190:*.k25=0;38;2;238;190;190:*.kdc=0;38;2;238;190;190:*.kex=0;38;2;231;130;132:*.kra=0;38;2;238;190;190:*.kts=0;38;2;166;209;137:*.log=0;38;2;98;104;128:*.ltx=0;38;2;166;209;137:*.lua=0;38;2;166;209;137:*.m3u=0;38;2;238;190;190:*.m4a=0;38;2;238;190;190:*.m4v=0;38;2;238;190;190:*.mdc=0;38;2;238;190;190:*.mef=0;38;2;238;190;190:*.mid=0;38;2;238;190;190:*.mir=0;38;2;166;209;137:*.mkv=0;38;2;238;190;190:*.mli=0;38;2;166;209;137:*.mos=0;38;2;238;190;190:*.mov=0;38;2;238;190;190:*.mp3=0;38;2;238;190;190:*.mp4=0;38;2;238;190;190:*.mpg=0;38;2;238;190;190:*.mrw=0;38;2;238;190;190:*.msi=4;38;2;133;193;220:*.mtl=0;38;2;238;190;190:*.nef=0;38;2;238;190;190:*.nim=0;38;2;166;209;137:*.nix=0;38;2;229;200;144:*.nrw=0;38;2;238;190;190:*.obj=0;38;2;238;190;190:*.obm=0;38;2;238;190;190:*.odp=0;38;2;231;130;132:*.ods=0;38;2;231;130;132:*.odt=0;38;2;231;130;132:*.ogg=0;38;2;238;190;190:*.ogv=0;38;2;238;190;190:*.orf=0;38;2;238;190;190:*.org=0;38;2;229;200;144:*.otf=0;38;2;238;190;190:*.otl=0;38;2;238;190;190:*.out=0;38;2;98;104;128:*.pas=0;38;2;166;209;137:*.pbm=0;38;2;238;190;190:*.pcx=0;38;2;238;190;190:*.pdf=0;38;2;231;130;132:*.pef=0;38;2;238;190;190:*.pgm=0;38;2;238;190;190:*.php=0;38;2;166;209;137:*.pid=0;38;2;98;104;128:*.pkg=4;38;2;133;193;220:*.png=0;38;2;238;190;190:*.pod=0;38;2;166;209;137:*.ppm=0;38;2;238;190;190:*.pps=0;38;2;231;130;132:*.ppt=0;38;2;231;130;132:*.pro=0;38;2;129;200;190:*.ps1=0;38;2;166;209;137:*.psd=0;38;2;238;190;190:*.ptx=0;38;2;238;190;190:*.pxn=0;38;2;238;190;190:*.pyc=0;38;2;98;104;128:*.pyd=0;38;2;98;104;128:*.pyo=0;38;2;98;104;128:*.qoi=0;38;2;238;190;190:*.r3d=0;38;2;238;190;190:*.raf=0;38;2;238;190;190:*.rar=4;38;2;133;193;220:*.raw=0;38;2;238;190;190:*.rpm=4;38;2;133;193;220:*.rst=0;38;2;229;200;144:*.rtf=0;38;2;231;130;132:*.rw2=0;38;2;238;190;190:*.rwl=0;38;2;238;190;190:*.rwz=0;38;2;238;190;190:*.sbt=0;38;2;166;209;137:*.sql=0;38;2;166;209;137:*.sr2=0;38;2;238;190;190:*.srf=0;38;2;238;190;190:*.srw=0;38;2;238;190;190:*.stl=0;38;2;238;190;190:*.stp=0;38;2;238;190;190:*.sty=0;38;2;98;104;128:*.svg=0;38;2;238;190;190:*.swf=0;38;2;238;190;190:*.swp=0;38;2;98;104;128:*.sxi=0;38;2;231;130;132:*.sxw=0;38;2;231;130;132:*.tar=4;38;2;133;193;220:*.tbz=4;38;2;133;193;220:*.tcl=0;38;2;166;209;137:*.tex=0;38;2;166;209;137:*.tga=0;38;2;238;190;190:*.tgz=4;38;2;133;193;220:*.tif=0;38;2;238;190;190:*.tml=0;38;2;229;200;144:*.tmp=0;38;2;98;104;128:*.toc=0;38;2;98;104;128:*.tsx=0;38;2;166;209;137:*.ttf=0;38;2;238;190;190:*.txt=0;38;2;229;200;144:*.typ=0;38;2;229;200;144:*.usd=0;38;2;238;190;190:*.vcd=4;38;2;133;193;220:*.vim=0;38;2;166;209;137:*.vob=0;38;2;238;190;190:*.vsh=0;38;2;166;209;137:*.wav=0;38;2;238;190;190:*.wma=0;38;2;238;190;190:*.wmv=0;38;2;238;190;190:*.wrl=0;38;2;238;190;190:*.x3d=0;38;2;238;190;190:*.x3f=0;38;2;238;190;190:*.xlr=0;38;2;231;130;132:*.xls=0;38;2;231;130;132:*.xml=0;38;2;229;200;144:*.xmp=0;38;2;229;200;144:*.xpm=0;38;2;238;190;190:*.xvf=0;38;2;238;190;190:*.yml=0;38;2;229;200;144:*.zig=0;38;2;166;209;137:*.zip=4;38;2;133;193;220:*.zsh=0;38;2;166;209;137:*.zst=4;38;2;133;193;220:*TODO=1:*hgrc=0;38;2;129;200;190:*.avif=0;38;2;238;190;190:*.bash=0;38;2;166;209;137:*.braw=0;38;2;238;190;190:*.conf=0;38;2;229;200;144:*.dart=0;38;2;166;209;137:*.data=0;38;2;238;190;190:*.diff=0;38;2;166;209;137:*.docx=0;38;2;231;130;132:*.epub=0;38;2;231;130;132:*.fish=0;38;2;166;209;137:*.flac=0;38;2;238;190;190:*.h264=0;38;2;238;190;190:*.hack=0;38;2;166;209;137:*.heif=0;38;2;238;190;190:*.hgrc=0;38;2;129;200;190:*.html=0;38;2;229;200;144:*.iges=0;38;2;238;190;190:*.info=0;38;2;229;200;144:*.java=0;38;2;166;209;137:*.jpeg=0;38;2;238;190;190:*.json=0;38;2;229;200;144:*.less=0;38;2;166;209;137:*.lisp=0;38;2;166;209;137:*.lock=0;38;2;98;104;128:*.make=0;38;2;129;200;190:*.mojo=0;38;2;166;209;137:*.mpeg=0;38;2;238;190;190:*.nims=0;38;2;166;209;137:*.opus=0;38;2;238;190;190:*.orig=0;38;2;98;104;128:*.pptx=0;38;2;231;130;132:*.prql=0;38;2;166;209;137:*.psd1=0;38;2;166;209;137:*.psm1=0;38;2;166;209;137:*.purs=0;38;2;166;209;137:*.raku=0;38;2;166;209;137:*.rlib=0;38;2;98;104;128:*.sass=0;38;2;166;209;137:*.scad=0;38;2;166;209;137:*.scss=0;38;2;166;209;137:*.step=0;38;2;238;190;190:*.tbz2=4;38;2;133;193;220:*.tiff=0;38;2;238;190;190:*.toml=0;38;2;229;200;144:*.usda=0;38;2;238;190;190:*.usdc=0;38;2;238;190;190:*.usdz=0;38;2;238;190;190:*.webm=0;38;2;238;190;190:*.webp=0;38;2;238;190;190:*.woff=0;38;2;238;190;190:*.xbps=4;38;2;133;193;220:*.xlsx=0;38;2;231;130;132:*.yaml=0;38;2;229;200;144:*stdin=0;38;2;98;104;128:*v.mod=0;38;2;129;200;190:*.blend=0;38;2;238;190;190:*.cabal=0;38;2;166;209;137:*.cache=0;38;2;98;104;128:*.class=0;38;2;98;104;128:*.cmake=0;38;2;129;200;190:*.ctags=0;38;2;98;104;128:*.dylib=1;38;2;231;130;132:*.dyn_o=0;38;2;98;104;128:*.gcode=0;38;2;166;209;137:*.ipynb=0;38;2;166;209;137:*.mdown=0;38;2;229;200;144:*.patch=0;38;2;166;209;137:*.rmeta=0;38;2;98;104;128:*.scala=0;38;2;166;209;137:*.shtml=0;38;2;229;200;144:*.swift=0;38;2;166;209;137:*.toast=4;38;2;133;193;220:*.woff2=0;38;2;238;190;190:*.xhtml=0;38;2;229;200;144:*Icon\r=0;38;2;98;104;128:*LEGACY=0;38;2;48;52;70;48;2;229;200;144:*NOTICE=0;38;2;48;52;70;48;2;229;200;144:*README=0;38;2;48;52;70;48;2;229;200;144:*go.mod=0;38;2;129;200;190:*go.sum=0;38;2;98;104;128:*passwd=0;38;2;229;200;144:*shadow=0;38;2;229;200;144:*stderr=0;38;2;98;104;128:*stdout=0;38;2;98;104;128:*.bashrc=0;38;2;166;209;137:*.config=0;38;2;229;200;144:*.dyn_hi=0;38;2;98;104;128:*.flake8=0;38;2;129;200;190:*.gradle=0;38;2;166;209;137:*.groovy=0;38;2;166;209;137:*.ignore=0;38;2;129;200;190:*.matlab=0;38;2;166;209;137:*.nimble=0;38;2;166;209;137:*COPYING=0;38;2;148;156;187:*INSTALL=0;38;2;48;52;70;48;2;229;200;144:*LICENCE=0;38;2;148;156;187:*LICENSE=0;38;2;148;156;187:*TODO.md=1:*VERSION=0;38;2;48;52;70;48;2;229;200;144:*.alembic=0;38;2;238;190;190:*.desktop=0;38;2;229;200;144:*.gemspec=0;38;2;129;200;190:*.mailmap=0;38;2;129;200;190:*Doxyfile=0;38;2;129;200;190:*Makefile=0;38;2;129;200;190:*TODO.txt=1:*setup.py=0;38;2;129;200;190:*.DS_Store=0;38;2;98;104;128:*.cmake.in=0;38;2;129;200;190:*.fdignore=0;38;2;129;200;190:*.kdevelop=0;38;2;129;200;190:*.markdown=0;38;2;229;200;144:*.rgignore=0;38;2;129;200;190:*.tfignore=0;38;2;129;200;190:*CHANGELOG=0;38;2;48;52;70;48;2;229;200;144:*COPYRIGHT=0;38;2;148;156;187:*README.md=0;38;2;48;52;70;48;2;229;200;144:*bun.lockb=0;38;2;98;104;128:*configure=0;38;2;129;200;190:*.gitconfig=0;38;2;129;200;190:*.gitignore=0;38;2;129;200;190:*.localized=0;38;2;98;104;128:*.scons_opt=0;38;2;98;104;128:*.timestamp=0;38;2;98;104;128:*CODEOWNERS=0;38;2;129;200;190:*Dockerfile=0;38;2;229;200;144:*INSTALL.md=0;38;2;48;52;70;48;2;229;200;144:*README.txt=0;38;2;48;52;70;48;2;229;200;144:*SConscript=0;38;2;129;200;190:*SConstruct=0;38;2;129;200;190:*.cirrus.yml=0;38;2;166;209;137:*.gitmodules=0;38;2;129;200;190:*.synctex.gz=0;38;2;98;104;128:*.travis.yml=0;38;2;166;209;137:*INSTALL.txt=0;38;2;48;52;70;48;2;229;200;144:*LICENSE-MIT=0;38;2;148;156;187:*MANIFEST.in=0;38;2;129;200;190:*Makefile.am=0;38;2;129;200;190:*Makefile.in=0;38;2;98;104;128:*.applescript=0;38;2;166;209;137:*.fdb_latexmk=0;38;2;98;104;128:*.webmanifest=0;38;2;229;200;144:*CHANGELOG.md=0;38;2;48;52;70;48;2;229;200;144:*CONTRIBUTING=0;38;2;48;52;70;48;2;229;200;144:*CONTRIBUTORS=0;38;2;48;52;70;48;2;229;200;144:*appveyor.yml=0;38;2;166;209;137:*configure.ac=0;38;2;129;200;190:*.bash_profile=0;38;2;166;209;137:*.clang-format=0;38;2;129;200;190:*.editorconfig=0;38;2;129;200;190:*CHANGELOG.txt=0;38;2;48;52;70;48;2;229;200;144:*.gitattributes=0;38;2;129;200;190:*.gitlab-ci.yml=0;38;2;166;209;137:*CMakeCache.txt=0;38;2;98;104;128:*CMakeLists.txt=0;38;2;129;200;190:*LICENSE-APACHE=0;38;2;148;156;187:*pyproject.toml=0;38;2;129;200;190:*CODE_OF_CONDUCT=0;38;2;48;52;70;48;2;229;200;144:*CONTRIBUTING.md=0;38;2;48;52;70;48;2;229;200;144:*CONTRIBUTORS.md=0;38;2;48;52;70;48;2;229;200;144:*.sconsign.dblite=0;38;2;98;104;128:*CONTRIBUTING.txt=0;38;2;48;52;70;48;2;229;200;144:*CONTRIBUTORS.txt=0;38;2;48;52;70;48;2;229;200;144:*requirements.txt=0;38;2;129;200;190:*package-lock.json=0;38;2;98;104;128:*CODE_OF_CONDUCT.md=0;38;2;48;52;70;48;2;229;200;144:*.CFUserTextEncoding=0;38;2;98;104;128:*CODE_OF_CONDUCT.txt=0;38;2;48;52;70;48;2;229;200;144:*azure-pipelines.yml=0;38;2;166;209;137'

    # =============================================================================
    # 21 — Prompt (inlined starship init fish)
    # =============================================================================
    # Regenerate with: starship init fish --print-full-init

    function __starship_set_job_count --description 'Set STARSHIP_JOBS using fish job groups (or legacy PIDs if toggled)'
        if test "$__starship_fish_use_job_groups" = false
            set -g STARSHIP_JOBS (jobs -p 2>/dev/null | count)
        else
            set -g STARSHIP_JOBS (jobs -g 2>/dev/null | count)
        end
    end

    function fish_prompt
        switch "$fish_key_bindings"
            case fish_hybrid_key_bindings fish_vi_key_bindings fish_helix_key_bindings
                set STARSHIP_KEYMAP "$fish_bind_mode"
            case '*'
                set STARSHIP_KEYMAP insert
        end

        set STARSHIP_CMD_PIPESTATUS $pipestatus
        set STARSHIP_CMD_STATUS $status
        set STARSHIP_DURATION "$CMD_DURATION$cmd_duration"

        __starship_set_job_count

        if contains -- --final-rendering $argv; or test "$TRANSIENT" = 1
            if test "$TRANSIENT" = 1
                set -g TRANSIENT 0
                printf \e\[0J
            end
            if type -q starship_transient_prompt_func

                # starship's initialization is somewhat dynamic,
                # so fish-lsp doesn't see parts of it at analysis, but they're fine
                # @fish-lsp-disable-next-line 
                starship_transient_prompt_func --terminal-width="$COLUMNS" --status=$STARSHIP_CMD_STATUS --pipestatus="$STARSHIP_CMD_PIPESTATUS" --keymap=$STARSHIP_KEYMAP --cmd-duration=$STARSHIP_DURATION --jobs=$STARSHIP_JOBS
            else
                printf "\e[1;32m>\e[0m "
            end
        else
            $HOMEBREW_PREFIX/bin/starship prompt --terminal-width="$COLUMNS" --status=$STARSHIP_CMD_STATUS --pipestatus="$STARSHIP_CMD_PIPESTATUS" --keymap=$STARSHIP_KEYMAP --cmd-duration=$STARSHIP_DURATION --jobs=$STARSHIP_JOBS
        end
    end

    function fish_right_prompt
        switch "$fish_key_bindings"
            case fish_hybrid_key_bindings fish_vi_key_bindings fish_helix_keybindings
                set STARSHIP_KEYMAP "$fish_bind_mode"
            case '*'
                set STARSHIP_KEYMAP insert
        end

        set STARSHIP_CMD_PIPESTATUS $pipestatus
        set STARSHIP_CMD_STATUS $status
        set STARSHIP_DURATION "$CMD_DURATION$cmd_duration"

        __starship_set_job_count

        if contains -- --final-rendering $argv; or test "$RIGHT_TRANSIENT" = 1
            set -g RIGHT_TRANSIENT 0
            if type -q starship_transient_rprompt_func
                # starship's initialization is somewhat dynamic,
                # so fish-lsp doesn't see parts of it at analysis, but they're fine
                # @fish-lsp-disable-next-line 
                starship_transient_rprompt_func --terminal-width="$COLUMNS" --status=$STARSHIP_CMD_STATUS --pipestatus="$STARSHIP_CMD_PIPESTATUS" --keymap=$STARSHIP_KEYMAP --cmd-duration=$STARSHIP_DURATION --jobs=$STARSHIP_JOBS
            else
                printf ""
            end
        else
            $HOMEBREW_PREFIX/bin/starship prompt --right --terminal-width="$COLUMNS" --status=$STARSHIP_CMD_STATUS --pipestatus="$STARSHIP_CMD_PIPESTATUS" --keymap=$STARSHIP_KEYMAP --cmd-duration=$STARSHIP_DURATION --jobs=$STARSHIP_JOBS
        end
    end

    set -g VIRTUAL_ENV_DISABLE_PROMPT 1
    builtin functions -e fish_mode_prompt
    set -gx STARSHIP_SHELL fish

    function __starship_reset_transient --on-event fish_postexec
        set -g TRANSIENT 0
        set -g RIGHT_TRANSIENT 0
    end

    function __starship_transient_execute
        if commandline --is-valid || test -z "$(commandline | string collect)" && not commandline --paging-mode
            set -g TRANSIENT 1
            set -g RIGHT_TRANSIENT 1
            commandline -f repaint
        end
        commandline -f execute
    end

    function __starship_fish_version_at_least --description 'Check if fish version is at least the given version'
        set -l parts (string split '.' $FISH_VERSION)
        set -l major $parts[1]
        set -l minor 0
        if set -q parts[2]
            set minor $parts[2]
        end

        set req_parts (string split '.' $argv[1])
        set req_major $req_parts[1]
        set req_minor 0
        if set -q req_parts[2]
            set req_minor $req_parts[2]
        end

        if test $major -gt $req_major
            return 0
        else if test $major -eq $req_major -a $minor -ge $req_minor
            return 0
        else
            return 1
        end
    end

    function enable_transience --description 'enable transient prompt keybindings'
        if __starship_fish_version_at_least 4.1
            set -g fish_transient_prompt 1
            return
        end
        bind --user \r __starship_transient_execute
        bind --user -M insert \r __starship_transient_execute
    end

    function disable_transience --description 'remove transient prompt keybindings'
        if __starship_fish_version_at_least 4.1
            set -g fish_transient_prompt 0
            return
        end
        bind --user -e \r
        bind --user -M insert -e \r
    end

    set -gx STARSHIP_SESSION_KEY (string sub -s1 -l16 (random)(random)(random)(random)(random)0000000000000000)

    # =============================================================================
    # 22 — Abbreviations
    # =============================================================================

    # print, copy, paste
    abbr --add p echo
    abbr --add pp bat
    abbr --add cat bat
    abbr --add pcp fish_clipboard_copy
    abbr --add ppp fish_clipboard_paste
    # shell
    abbr --add r fresh -r
    abbr --add rr fresh
    abbr --add rrh fresh -g
    abbr --add fun functions
    abbr --add cmd command
    # processes
    abbr --add top btm
    abbr --add pps procs
    # dir and file management
    abbr --add cp. "pwd | pbcopy"
    abbr --add mkd mkdir -p
    abbr --add rmd rmdir
    abbr --add mkt mktemp
    abbr --add mac macchina
    abbr --add cmx chmod +x
    abbr --add cmme chmod 700
    # editor
    abbr --add v nvim
    abbr --add vi nvim
    # ssh
    abbr --add sshk kitten ssh -A
    # tmux
    abbr --add tm tmux
    abbr --add tm? tstat
    abbr --add tmls tmux list-sessions
    abbr --add tmn tmux new-session
    abbr --add tma tmux attach-session
    abbr --add tmd tmux detach-client
    abbr --add tmw twin (basename "$PWD") --cmd
    abbr --add tmh tmux_hint
    abbr --add tmhspark 'tmux_hint -d ""'
    # shell snippets
    abbr --add --position anywhere -- --help '--help | bat -plhelp'
    abbr --add --position anywhere -- -h '-h | bat -plhelp'
    abbr --add --position anywhere -- qq '>/dev/null'
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
    abbr --add fdf "fd . --color always --hidden --ignore | fzf --preview '_fzf_preview_file {}'"
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
    abbr --add dots "ee -e $HOME/.charmschool"
    abbr --add conf "ee $XDG_CONFIG_HOME"
    abbr --add proj "ee $PROJECTS"
    abbr --add keeb "ee -e $PROJECTS_UTILS/tinybabykeeb"
    # Homebrew
    abbr --add brx brewdo
    abbr --add bri "brew update; brew install"
    abbr --add brrm brew uninstall
    abbr --add brup brew upgrade
    abbr --add brcup "brew update; brew upgrade; brew cleanup"
    abbr --add brs brew search
    abbr --add brc brew cleanup
    abbr --add brcl brew cleanup
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
    abbr --add brbg brew services
    abbr --add brsrv brew services
    # ai
    abbr --add oc opencode
    abbr --add occf ee $HOME/.config/opencode
    abbr --add co copilot
    abbr --add cl claude
    abbr --add clcf ee $HOME/.claude
    abbr --add ccu bunx ccusage@latest
    abbr --add clyj yj ~/.charmschool/agents/claude/settings.yaml --force
    # writing
    abbr --add notes "ee ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents"
    abbr --add ob notesmd-cli
    abbr --add obf "fd . --color always --hidden --ignore --extension md | fzf --preview '_fzf_preview_file {}'"
    abbr --add obs notesmd-cli search
    abbr --add obse notesmd-cli search -e
    abbr --add obg notesmd-cli search-content
    abbr --add obge notesmd-cli search-content -e
    abbr --add oba notesmd-cli create
    abbr --add obrm notesmd-cli delete
    abbr --add obday notesmd-cli daily
    abbr --add obfm notesmd-cli frontmatter
    abbr --add ob? notesmd-cli help
    abbr --add obls notesmd-cli list
    abbr --add oblsv notesmd-cli list-vaults
    abbr --add obmv notesmd-cli move
    abbr --add obo notesmd-cli open
    abbr --add obp notesmd-cli print
    abbr --add obdv notesmd-cli print-default
    abbr --add obfmp "fd . --color always --hidden --ignore --extension md | fzf --preview '_fzf_preview_file {}' --bind 'enter:execute(notesmd-cli frontmatter {} --print)+abort'"
    # security and network
    abbr --add opg "op run --env-file=$OP_ENV_DIR/global.env --no-masking -- "
    abbr --add opi "op run --no-masking -- "
    abbr --add opr "op run -- "
    abbr --add openv ee $OP_ENV_DIR
    abbr --add keys security
    abbr -a 'prx?' prx status
    abbr -a mp mitmproxy
    # data
    abbr --add dbx databricks
    abbr --add ddb duckdb
    abbr --add pg pgcli
    abbr --add sqli sqlite3
    abbr --add dbbs dbtf build -s
    abbr --add dbba dbtf build
    abbr --add dbts dbtf test -s
    abbr --add dbta dbtf test
    abbr --add dbrs dbtf run -s
    abbr --add dbra dbtf run
    abbr --add dbtpo nvim ~/.dbt/profiles.yml
    abbr --add dbtpp bat ~/.dbt/profiles.yml
    # languages
    abbr --add mi mise
    abbr --add mia "mise activate fish | source"
    abbr --add mida mise deactivate
    abbr --add miu mise use
    abbr --add mii mise install
    abbr --add mir mise run
    abbr --add mic mise config
    abbr --add micl mise config list
    abbr --add mics mise config set
    abbr --add mipth $HOME/.local/share/mise/installs/
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
    abbr --add uvtid uv tool install . --reinstall
    abbr --add uvtu uv tool upgrade
    abbr --add uvr uv run
    abbr --add uvrt uv run pytest
    abbr --add uvp uv pip
    abbr --add uvpi uv pip install
    abbr --add uvpir "uv pip install -r requirements.txt"
    abbr --add uva uv add
    abbr --add uvs uv sync
    abbr --add uvi uv init
    abbr --add uvb uv build
    abbr --add va source .venv/bin/activate.fish
    abbr --add da deactivate
    abbr --add gor go run main.go
    abbr --add gord go run .
    abbr --add got go test
    abbr --add gotv go test -v
    abbr --add gob go build
    abbr --add ruu rustup up
    abbr --add n npm
    abbr --add nx npx
    abbr --add ni npm install
    abbr --add nu npm update
    abbr --add nd npm run dev
    abbr --add nb npm run build
    abbr --add pn pnpm
    abbr --add pnx pnpm dlx
    abbr --add pni pnpm install
    abbr --add pnrm pnpm remove
    abbr --add pna pnpm add
    abbr --add pnu pnpm update
    abbr --add pnd pnpm dev
    abbr --add pnb pnpm build
    abbr --add pnl pnpm lint
    abbr --add pnf pnpm fix
    abbr --add b bun
    abbr --add bi bun install
    abbr --add ba bun add
    abbr --add bu bun upgrade
    abbr --add bs bun start
    abbr --add br bun run
    abbr --add bt bun test
    abbr --add bx bunx
    abbr --add d deno
    abbr --add dig deno install -grAf --root $DENO_HOME
    abbr --add dt deno task
    # git
    abbr --add g git
    abbr --add gcfg git config --global
    abbr --add gho gh repo view -w
    abbr --add ghd gh dash
    abbr --add ghrcd gh repo create --push --public --source .
    abbr --add gui lazygit
    abbr --add gcmm meteor
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
    abbr --add wtsw wt switch
    abbr --add wtswc wt switch -c
    abbr --add wtm wt merge
    # media
    abbr --add spotify spotify_player
    abbr --add spt spotify_player
    abbr --add ytdl yt-dlp
    abbr --add gdl gallery-dl

    # =============================================================================
    # 23 — Bindings
    # =============================================================================
    fish_vi_key_bindings

    # bracket nav <-[ ]->
    bind --user -M insert alt-h prevd-or-backward-word
    bind --user -M insert alt-l nextd-or-forward-word
    bind --user alt-h prevd-or-backward-word
    bind --user alt-l nextd-or-forward-word

    bind --user -M insert alt-H backward-kill-word
    bind --user -M insert alt-L kill-word-vi
    bind --user alt-H backward-kill-word
    bind --user alt-L kill-word-vi

    # launch yazi file explorer
    bind --user -M insert super-f "ff; commandline -f repaint"
    bind --user super-f "ff; commandline -f repaint"
    bind --user -M insert alt-f "ff; commandline -f repaint"
    bind --user alt-f "ff; commandline -f repaint"
    # open Mac Finder
    bind --user -M insert super-F "open ."
    bind --user super-F "open ."
    bind --user -M insert alt-F "open ."
    bind --user alt-F "open ."

    # TUI git tools
    bind --user -M insert super-g "commandline -r 'lazygit'; commandline -f execute"
    bind --user super-g "commandline -r 'lazygit'; commandline -f execute"
    bind --user -M insert alt-g "commandline -r 'lazygit'; commandline -f execute"
    bind --user alt-g "commandline -r 'lazygit'; commandline -f execute"
    bind --user -M insert ctrl-alt-g "commandline -r 'git forgit log'; commandline -f execute"
    bind --user ctrl-alt-g "commandline -r 'git forgit log'; commandline -f execute"
    bind --user -M insert super-G "commandline -r 'gh dash'; commandline -f execute"
    bind --user super-G "commandline -r 'gh dash'; commandline -f execute"
    bind --user -M insert alt-G "commandline -r 'gh dash'; commandline -f execute"
    bind --user alt-G "commandline -r 'gh dash'; commandline -f execute"

    # clearing and reloading
    bind --user -M insert super-r "fresh -r"
    bind --user super-r "fresh -r"
    bind --user -M insert alt-r "fresh -r"
    bind --user alt-r "fresh -r"
    bind --user -M insert super-e "fresh -c"
    bind --user super-e "fresh -c"
    # alt-e defaults to edit commandline in $EDITOR
    # but thankfully has an alt binding as alt-v ($VISUAL)
    # which is what I would remap it to
    bind --user -M insert alt-e "fresh -c"
    bind --user alt-e "fresh -c"
    bind --user -M insert super-R "fresh; commandline -f repaint"
    bind --user super-R "fresh; commandline -f repaint"
    bind --user -M insert alt-R "fresh; commandline -f repaint"
    bind --user alt-R "fresh; commandline -f repaint"
    bind --user -M insert ctrl-super-r "fresh -g; commandline -f repaint"
    bind --user ctrl-super-r "fresh -g; commandline -f repaint"
    bind --user -M insert ctrl-alt-r "fresh -g; commandline -f repaint"
    bind --user ctrl-alt-r "fresh -g; commandline -f repaint"

    # print, list, pager
    bind --user -M insert super-p "commandline -r 'lsd -lAg .'; commandline -f execute"
    bind --user super-p "commandline -r 'lsd -lAg .'; commandline -f execute"
    bind --user -M insert alt-p "commandline -r 'lsd -lAg .'; commandline -f execute"
    bind --user alt-p "commandline -r 'lsd -lAg .'; commandline -f execute"
    # wrapping commands
    bind --user -M insert alt-P _wrap_echo
    bind --user alt-P _wrap_echo
    bind --user -M insert super-P _wrap_echo
    bind --user super-P _wrap_echo
    # 1Password env wrapper
    bind --user -M insert ctrl-o "_wrap_op_interactive -a"
    bind --user ctrl-o "_wrap_op_interactive -a"
    bind --user -M insert ctrl-alt-o _wrap_op_interactive
    bind --user ctrl-alt-o _wrap_op_interactive

    # =============================================================================
    # 24 — Tools (fzf, zoxide, ripgrep)
    # =============================================================================

    # fzf — read config file using fish builtins (avoids cat | tr subprocess)
    set -gx FZF_DEFAULT_OPTS (string join ' ' < ~/.config/fzf/fzf.conf)
    # fzf opts for interactive zoxide
    set -gx _ZO_FZF_OPTS $FZF_DEFAULT_OPTS"\
--layout=reverse \
--height=90% \
--preview-window=wrap\
"
    # fzf.fish plugin config
    set -gx fzf_fd_opts --hidden
    set -gx fzf_preview_file_cmd bat --style=numbers,changes --color always
    set -gx fzf_preview_dir_cmd lsd --color=always --group-directories-first --tree --depth=2
    set -gx fzf_diff_highlighter delta --paging=never --width=20
    set -gx fzf_variables_opts --bind "\
ctrl-y:execute-silent( \
  echo {} \
  | xargs -I{} sh -c '"'eval printf '%s' \$$0'"' {} \
  | fish_clipboard_copy \
)+abort"
    set -gx fzf_directory_opts --bind 'enter:become($EDITOR {} &>/dev/tty)'
    fzf_configure_bindings --variables='ctrl-alt-v' --git_log= --git_status=

    # zoxide — inlined output of `zoxide init fish`
    # Regenerate with: zoxide init fish

    function __zoxide_pwd
        builtin pwd -L
    end

    if ! builtin functions --query __zoxide_cd_internal
        if status list-files functions/cd.fish &>/dev/null
            status get-file functions/cd.fish | string replace --regex -- '^function cd\s' 'function __zoxide_cd_internal ' | source
        else
            string replace --regex -- '^function cd\s' 'function __zoxide_cd_internal ' <$__fish_data_dir/functions/cd.fish | source
        end
    end

    function __zoxide_cd
        if set -q __zoxide_loop
            builtin echo "zoxide: infinite loop detected"
            builtin echo "Avoid aliasing `cd` to `z` directly, use `zoxide init --cmd=cd fish` instead"
            return 1
        end
        # zoxide's initialization is somewhat dynamic,
        # so fish-lsp doesn't see parts of it at analysis, but they're fine
        # @fish-lsp-disable-next-line
        __zoxide_loop=1 __zoxide_cd_internal $argv
    end

    function __zoxide_hook --on-variable PWD
        test -z "$fish_private_mode"
        and command zoxide add -- (__zoxide_pwd)
    end

    function __zoxide_z
        set -l argc (builtin count $argv)
        if test $argc -eq 0
            __zoxide_cd $HOME
        else if test "$argv" = -
            __zoxide_cd -
        else if test $argc -eq 1 -a -d $argv[1]
            __zoxide_cd $argv[1]
        else if test $argc -eq 2 -a $argv[1] = --
            __zoxide_cd -- $argv[2]
        else
            set -l result (command zoxide query --exclude (__zoxide_pwd) -- $argv)
            and __zoxide_cd $result
        end
    end

    function __zoxide_z_complete
        set -l tokens (builtin commandline --current-process --tokenize)
        set -l curr_tokens (builtin commandline --cut-at-cursor --current-process --tokenize)

        if test (builtin count $tokens) -le 2 -a (builtin count $curr_tokens) -eq 1
            complete --do-complete "'' "(builtin commandline --cut-at-cursor --current-token) | string match --regex -- '.*/$'
        else if test (builtin count $tokens) -eq (builtin count $curr_tokens)
            set -l query $tokens[2..-1]
            set -l result (command zoxide query --exclude (__zoxide_pwd) --interactive -- $query)
            and __zoxide_cd $result
            and builtin commandline --function cancel-commandline repaint
        end
    end
    complete --command __zoxide_z --no-files --arguments '(__zoxide_z_complete)'

    function __zoxide_zi
        set -l result (command zoxide query --interactive -- $argv)
        and __zoxide_cd $result
    end

    abbr --erase z &>/dev/null
    complete --erase --command z
    alias z=__zoxide_z

    abbr --erase zi &>/dev/null
    complete --erase --command zi
    alias zi=__zoxide_zi

    # ripgrep
    set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/ripgrep.conf"

    # =============================================================================
    # 25 — App tools
    # =============================================================================
    set -gx OBSIDIAN_HOME "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
    set -gx OBSIDIAN_DEFAULT_VAULT $OBSIDIAN_HOME/girlOS
    fish_add_path -a /Applications/Obsidian.app/Contents/MacOS
    fish_add_path -a /Applications/Monodraw.app/Contents/Resources/monodraw

end # status is-interactive
