return {
  -- Markdown Preview and Links
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>cp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
    config = function()
      vim.cmd([[do FileType]])
    end,
  },
  {
    "ellisonleao/glow.nvim",
    config = true,
    cmd = "Glow",
    keys = {
      {
        "<leader>co",
        ft = "markdown",
        "<cmd>Glow<cr>",
        desc = "Glow Markdown Preview",
      },
    },
  },
  -- gitignore
  {
    "wintermute-cell/gitignore.nvim",
  },
  -- Databricks
  {
    "phdah/nvim-databricks",
    dependencies = {
      "mfussenegger/nvim-dap", -- Optional dependency
    },
    opts = {
      DBConfigFile = "~/.databrickscfg",
      python = "python3",
    },
  },
}
