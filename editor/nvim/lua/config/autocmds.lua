-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("sql_formatting"),
  pattern = { "sql" },
  callback = function()
    vim.opt.expandtab = true
    vim.opt_local.tabstop = 4
    vim.opt.softtabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("zsh"),
  pattern = { ".zshrc", ".zshenv", ".zsh", ".zprofile" },
  callback = function()
    vim.set_filetype("zsh")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("go"),
  pattern = { "go" },
  callback = function()
    vim.keymap.set("n", "<Leader>gr", "<cmd>!go run %<CR>", { noremap = true, silent = true, desc = "Go run file" })
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("config_file_types"),
  pattern = { ".sqlfluff" },
  callback = function()
    vim.opt_local.filetype = "toml"
  end,
})
