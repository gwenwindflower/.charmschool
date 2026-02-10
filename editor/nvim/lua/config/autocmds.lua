-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

vim.filetype.add({
  group = augroup("filetype_additions"),
  filename = {
    -- SQLFluff uses TOML format, but Tree-sitter doesn't clock that obviously
    -- because it's not a super popular tool/filetype so we have to manually set it
    [".sqlfluff"] = "toml",
    -- For the sake of my gitconfig not being hidden in the explorer
    -- my root file that is symlinked to ~/.gitconfig is named gitconfig
    -- but that means we have to manually set the filetype
    ["gitconfig"] = "gitconfig",
    ["gitignore_global"] = "gitignore",
    ["bashrc"] = "ft",
  },
  extension = {
    ["http"] = "http",
    ["env"] = "dotenv",
  },
})

-- use bash syntax highlighting for dotenv files,
-- since there isn't a dedicated one and it's close enough
vim.treesitter.language.register("bash", "dotenv")
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("dotenv_files"),
  pattern = { "dotenv" },
  callback = function()
    vim.bo.commentstring = "#%s"
  end,
})

-- For some reason the kitty filetype doesn't set the commentstring
-- It recognizes and highlights comments correctly, but doesn't set the commentstring, strange
-- Unfortunately I do not have time to look into fixing it
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("config_formatting"),
  pattern = { "kitty" },
  callback = function()
    vim.bo.commentstring = "#%s"
  end,
})

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

local wk = require("which-key")
-- Markdown-specific keymaps (buffer-local, only active in markdown files)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(event)
    wk.add({
      {
        "<LocalLeader>m",
        mode = { "x", "v" },
        group = "markdown",
        icon = { icon = " ", color = "orange" },
        buffer = event.buf,
      },
    })
    wk.add({
      {
        "<LocalLeader>ml",
        ":MarkdownPasteLink<cr>",
        mode = { "x" },
        desc = "Paste URL as link",
        buffer = event.buf,
      },
    })
    wk.add({
      {
        "<LocalLeader>mt",
        "<cmd>'<,'>MarkdownTableFixCompactPipeSpacing<cr>",
        mode = { "x" },
        desc = "Fix table pipe spacing",
        buffer = event.buf,
      },
    })
  end,
})
