# Set the theme for bat
set -x -g BAT_THEME Catppuccin-frappe

# Set theme for tools that use LS_COLORS (fd, tree, eza etc)
set -Ux LS_COLORS (vivid generate catppuccin-frappe)

# Set the theme, preview command, and custom bindings for fzf
set -Ux FZF_DEFAULT_OPTS "\
--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
--color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 \
--preview 'bat --style=numbers,changes --color always --line-range :500 {}' \
--bind 'shift-up:preview-up' \
--bind 'shift-down:preview-down' \
--bind 'ctrl-p:preview-up' \
--bind 'ctrl-n:preview-down'
--bind 'ctrl-/:toggle-preview'
--bind 'ctrl-o:become(nvim {})'
"

# fzf integration config
## set Ctrl-f to do a fzf file search in the current directory
fzf_configure_bindings --directory=\cf
## set Ctrl-o to open the selected file in nvim
set fzf_directory_opts --bind 'ctrl-o:become(nvim {})'
## fzf show hidden files by default
set fzf_fd_opts --hidden
## fzf preview use bat with color and line numbers for file preview
set fzf_preview_file_cmd bat --style=numbers,changes --color always
## fzf preview use eza with color for directory preview
set fzf_preview_dir_cmd eza --all --color=always
