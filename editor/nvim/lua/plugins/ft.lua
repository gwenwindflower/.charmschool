return {
  -- gitignore
  {
    "wintermute-cell/gitignore.nvim",
  },
  -- Databricks still pretty experimental
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
