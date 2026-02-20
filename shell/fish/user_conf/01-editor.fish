set -gx EDITOR nvim
set -gx NVIM_PLUGIN_DIR $XDG_DATA_HOME/nvim
set -gx NVIM_MASON_INSTALL $NVIM_PLUGIN_DIR/mason/packages
# Make mason-installed tools (LSPs, linters, formatters, etc for nvim) available in PATH
# mason creates a bin dir with symlinks to the actual installed packages in NVIM_MASON_INSTALL
fish_add_path -g $NVIM_PLUGIN_DIR/mason/bin
