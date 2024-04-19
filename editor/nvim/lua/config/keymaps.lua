-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<Leader>fs", "<cmd>w<cr>", { noremap = true, silent = true, desc = "Save file" })
vim.keymap.set("n", "∆", "<cmd>m +1<cr>", { noremap = true, silent = true, desc = "Move line down one line" })
vim.keymap.set("n", "˚", "<cmd>m -2<cr>", { noremap = true, silent = true, desc = "Move line up one line" })
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
  "<Leader>ft",
  "<cmd>ToggleTerm direction='float'<cr>",
  { noremap = true, silent = true, desc = "Open floating terminal" }
)
vim.keymap.set("n", "<C-a>", "^", { noremap = true, silent = true, desc = "Move to beginning of line" })
vim.keymap.set("n", "<C-z>", "$", { noremap = true, silent = true, desc = "Move to end of line" })
vim.keymap.set("v", "<C-a>", "^", { noremap = true, silent = true, desc = "Move to beginning of line" })
vim.keymap.set("v", "<C-z>", "$", { noremap = true, silent = true, desc = "Move to end of line" })
