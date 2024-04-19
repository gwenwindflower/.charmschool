-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.maplocalleader = ";"
vim.g.lazyvim_python_lsp = "basedpyright"

vim.cmd([[
  command! -range -nargs=0 ModsExplain :'<,'>w !mods explain this code please, be really clear and concise and as simple as possible | glow -w 70
]])
vim.cmd([[
  command! -range -nargs=* ModsRefactor :'<,'>w !mods suggest a refactor for this code to improve its readability | glow -w 70
]])
vim.cmd([[
  command! -range -nargs=+ Mods :'<,'>w !mods <q-args> | glow -w 70
]])
vim.cmd([[
  command! -nargs=1 DeleteMarks :delmark <args>
]])
