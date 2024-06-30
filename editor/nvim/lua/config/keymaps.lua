-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<Leader>fs", "<cmd>w<cr>", { noremap = true, silent = true, desc = "Save file" })
vim.keymap.set(
  "v",
  "<Leader>me",
  "<cmd>'<,'>ModsExplain<cr>",
  { noremap = true, silent = false, desc = "Mods - explain code" }
)
vim.keymap.set(
  "v",
  "<Leader>mr",
  "<cmd>'<,'>ModsRefactor<cr>",
  { noremap = true, silent = false, desc = "Mods - suggest refactor" }
)
vim.keymap.set(
  "v",
  "<Leader>mw",
  "<cmd>'<,'>Mods",
  { noremap = true, silent = false, desc = "Mods - open query selection" }
)
vim.keymap.set("n", "<Leader>md", ":delmark ", { noremap = true, silent = true, desc = "Delete mark" })
vim.keymap.set(
  "n",
  "<C-p>",
  "<cmd>ToggleTerm direction='float'<cr>",
  { noremap = true, silent = true, desc = "Open floating terminal" }
)
vim.keymap.set("n", "<C-a>", "^", { noremap = true, silent = true, desc = "Move to beginning of line" })
vim.keymap.set("n", "<C-z>", "$", { noremap = true, silent = true, desc = "Move to end of line" })
vim.keymap.set("v", "<C-a>", "^", { noremap = true, silent = true, desc = "Move to beginning of line" })
vim.keymap.set("v", "<C-z>", "$", { noremap = true, silent = true, desc = "Move to end of line" })
vim.keymap.set(
  "n",
  "<LocalLeader>r",
  ":w<cr>:DBRun<cr>",
  { noremap = true, silent = true, desc = "Run code on Databricks cluster" }
)
-- Free up C-j and C-k in terminal mode, mainly for fzf
-- This works since I only use side and floating terminals,
-- so I don't need to navigate up and down
vim.keymap.del("t", "<C-j>")
vim.keymap.del("t", "<C-k>")
