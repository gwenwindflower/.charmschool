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
    event = "VeryLazy",
    build = "make",
    opts = {
      code_font_family = "GeistMono Nerd Font Mono",
      watermark_font_family = "GeistMono Nerd Font Mono",
      bg_theme = "summer",
      watermark = "datacowgirl.sh",
      save_path = os.getenv("HOME") .. "/Pictures/codesnap",
    },
  },
  {
    "charm-community/freeze.nvim",
    event = "VeryLazy",
    config = function()
      require("freeze").setup({
        command = "freeze",
        output = function()
          return "./" .. os.date("%Y-%m-%d") .. "_freeze.png"
        end,
        theme = "catppuccin-frappe",
      })
    end,
  },
}
