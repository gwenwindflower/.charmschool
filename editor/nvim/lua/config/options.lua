-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- avoid Biome conflicting with Prettier
-- bc still some file types that Biome doesn't support yet
vim.g.lazyvim_prettier_needs_config = true
-- Snacks is awesome
vim.g.lazyvim_picker = "snacks"
vim.g.lazyvim_python_ruff = "ruff"
vim.g.snacks_animate = true
-- Set the spellfile explicitly to the standard path so we can add rare words
-- zg works a bit more magically, it will create a spellfile here if doesn't exist
-- spellrare will not, so it fails if this is not specified
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
