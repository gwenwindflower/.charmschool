return {
  -- nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
      "nvim-lua/plenary.nvim",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(
        vim.list_extend(opts.sources, { { name = "emoji" }, { name = "mkdnflow" }, { name = "conjure" } })
      )
    end,
  },
  -- LuaSnip
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/nvim/snippets/dbt" } })
    end,
  },
  -- Copilot
  {
    {
      "CopilotC-Nvim/CopilotChat.nvim",
      branch = "canary",
      dependencies = {
        { "zbirenbaum/copilot.lua" },
        { "nvim-lua/plenary.nvim" },
      },
      opts = {
        debug = true,
      },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    suggestion = { enabled = true },
    panel = { enabled = true },
    filetypes = {
      markdown = true,
      yaml = true,
      sql = true,
    },
  },
}
