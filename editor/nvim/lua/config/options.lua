-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- easier to reach local leader
vim.g.maplocalleader = ";"
-- avoid Biome conflicting with Prettier
-- bc still some file types that Biome doesn't support yet
vim.g.lazyvim_prettier_needs_config = true
-- Snacks is awesome
vim.g.lazyvim_picker = "snacks"
vim.g.lazyvim_python_ruff = "ruff"
vim.g.snacks_animate = true
