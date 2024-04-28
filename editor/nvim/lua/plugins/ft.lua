return {
  -- CSv
  {
    "cameron-wags/rainbow_csv.nvim",
    config = true,
    ft = {
      "csv",
      "tsv",
      "csv_semicolon",
      "csv_whitespace",
      "csv_pipe",
      "rfc_csv",
      "rfc_semicolon",
    },
    cmd = {
      "RainbowDelim",
      "RainbowDelimSimple",
      "RainbowDelimQuoted",
      "RainbowMultiDelim",
    },
  },
  -- Visual colors for CSS, etc
  {
    "brenoprata10/nvim-highlight-colors",
    opts = {
      render = "background",
      enable_tailwind = true,
    },
  },
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
  },
  {
    "jakewvincent/mkdnflow.nvim",
    config = function()
      require("mkdnflow").setup({})
    end,
  },
  -- Justfile
  {
    "NoahTheDuke/vim-just",
    ft = { "just" },
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
