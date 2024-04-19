return {
  -- Presenting
  {
    "sotte/presenting.nvim",
    opts = {},
    cmd = { "Presenting" },
    keys = {
      { "<Leader>mg", "<cmd>Presenting<CR>", desc = "Toggle Presenting" },
    },
  },
  -- ZenMode
  {
    "folke/zen-mode.nvim",
    opts = {},
    keys = {
      { "<Leader>mz", "<cmd>ZenMode<CR>", desc = "Toggle ZenMode" },
    },
  },
  {
    "folke/twilight.nvim",
    opts = {},
  },
}
