# fzf
## default opts are parsed from a config file for easier maintenance
## Notes on color themeing:
## bg/fg is default, bg+/fg+ is selected,
## hl/hl+ is matched text and matched text on selected line,
## info is the counter, header is the text *above* the input line,
## marker is the mark when you multi-select with tab
set -gx FZF_DEFAULT_OPTS "$(cat ~/.config/fzf/fzf.conf | tr '\n' ' ')"
## fzf opts for interactive zoxide
set -gx _ZO_FZF_OPTS $FZF_DEFAULT_OPTS"\
--layout=reverse \
--height=90% \
--preview-window=wrap\
"
## fzf.fish plugin config
### include hidden files in the fd command that feeds fzf directory search
set -gx fzf_fd_opts --hidden
### fzf preview use bat with color and line numbers for file preview
set -gx fzf_preview_file_cmd bat --style=numbers,changes --color always
### fzf preview use lsd tree view with color for directory preview
set -gx fzf_preview_dir_cmd lsd --color=always --group-directories-first --tree --depth=2
### use delta for diff highlighting in fzf.fish git widgets
set -gx fzf_diff_highlighter delta --paging=never --width=20
### ctrl-y to copy the value of the env var to the clipboard
set -gx fzf_variables_opts --bind "\
ctrl-y:execute-silent( \
  echo {} \
  | xargs -I{} sh -c '"'eval printf '%s' \$$0'"' {} \
  | fish_clipboard_copy \
)+abort"
### easier editor launch when using primary file search widget
set -gx fzf_directory_opts --bind 'enter:become($EDITOR {} &>/dev/tty)'
### forgit is better than the fzf.fish git widgets, so i disable those bindings
### they can be called manually if needed
### also assign variable search a more consistent mnemonic bind
fzf_configure_bindings --variables='ctrl-alt-v' --git_log= --git_status=

# zoxide
zoxide init fish | source

# ripgrep
## ripgrep does not automatically look for config, but the upside is
## we can put it wherever we want
## it's just command line flags like bat's config
set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/ripgrep.conf"
