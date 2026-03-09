-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local wk = require("which-key")
wk.add({
  { "<Leader>a", mode = { "n", "v" }, group = "ai", icon = { icon = "󱚤 ", color = "purple" } },
})
wk.add({
  { "<LocalLeader>n", mode = { "n", "x" }, group = "align", icon = { icon = " ", color = "azure" } },
})
wk.add({
  { "<LocalLeader>s", mode = { "n", "x" }, group = "snippet", icon = { icon = " ", color = "green" } },
})
wk.add({
  { "<LocalLeader>nj", "<cmd>%!jq -S<cr>", mode = { "n" }, desc = "Sort JSON keys with jq" },
})
wk.add({
  { "<LocalLeader>L", "<cmd>LazyExtras<cr>", mode = { "n" }, desc = "LazyExtras" },
})
