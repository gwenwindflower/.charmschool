# Set the theme, preview command, and custom bindings for fzf
# Notes on color themeing:
# bg/fg is default, bg+/fg+ is selected,
# hl/hl+ is matched text and matched text on selected line,
# info is the counter, header is the text *above* the input line,
# marker is the mark when you multi-select with tab
set -gx FZF_DEFAULT_OPTS "\
--cycle \
--ansi \
--multi \
--border='rounded' \
--color=border:#737994 \
--scrollbar='█' \
--color=scrollbar:#838ba7 \
--prompt='❯ ' \
--color=prompt:#f4b8e4 \
--pointer='█' \
--color=pointer:#ef9f76 \
--marker=' ' \
--color=marker:#a6d189 \
--color=gutter:#292c3c \
--color=bg:#303446,fg:#b5bfe2 \
--color=bg+:#414559,fg+:#c6d0f5 \
--color=hl+:#ef9f76,hl:#ea999c \
--color=header:#ca9ee6,info:#a6d189,spinner:#a6d189 \
--bind 'ctrl-p:preview-up' \
--bind 'ctrl-n:preview-down' \
--bind='ctrl-d:preview-page-down' \
--bind='ctrl-u:preview-page-up' \
--bind 'alt-p:toggle-preview' \
--bind 'ctrl-y:execute-silent(printf {} | pbcopy)+abort' \
--bind 'ctrl-e:become($EDITOR {} &>/dev/tty)' \
"

# fzf opts for interactive zoxide
set -gx _ZO_FZF_OPTS $FZF_DEFAULT_OPTS"\
--layout=reverse \
--height=90% \
--preview-window=wrap\
"

# fzf.fish plugin config
## example of how to configure bindings:
## include hidden files in the fd command that feeds fzf directory search
set -gx fzf_fd_opts --hidden
## fzf preview use bat with color and line numbers for file preview
set -gx fzf_preview_file_cmd bat --style=numbers,changes --color always
## fzf preview use lsd tree view with color for directory preview
set -gx fzf_preview_dir_cmd lsd --color=always --group-directories-first --tree --depth=2
## use delta for diff highlighting in fzf.fish git widgets
set -gx fzf_diff_highlighter delta --paging=never --width=20
# forgit is better than the fzf.fish git widgets, so i disable those bindings
## ctrl-y to copy the value of the env var to the clipboard
set -gx fzf_variables_opts --bind "\
ctrl-y:execute-silent( \
  echo {} \
  | xargs -I{} sh -c '"'eval printf '%s' \$$0'"' {} \
  | pbcopy \
)+abort"
set -gx fzf_directory_opts --bind 'enter:become($EDITOR {} &>/dev/tty)'
fzf_configure_bindings --variables='ctrl-alt-v' --git_log= --git_status=
