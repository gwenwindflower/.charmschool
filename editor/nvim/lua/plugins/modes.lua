return {
  -- Presentation mode
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
  -- Capture images of code
  {
    "mistricky/codesnap.nvim",
    build = "make",
  },
}
