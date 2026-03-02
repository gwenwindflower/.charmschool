-- TODO: set up projects and sessions tooling
return {
  -- Alignment tools
  -- TODO: figure out how the hell this works,
  -- my mental model of it is terrible and i can never
  -- get it to do what I want
  {
    "nvim-mini/mini.align",
    version = "*",
    opts = {
      mappings = {
        start = "<LocalLeader>na",
        start_with_preview = "<LocalLeader>np",
      },
      options = {
        split_pattern = " ",
        justify_side = "left",
        merge_delimiter = "",
        modifiers = {
          i = true, -- ignore comment patterns
          [" "] = true, -- better space delimiting (ignores multiple spaces)
        },
      },
    },
  },
  -- Add % to autopairs when in curly brackets as I use {% %} a lot
  {
    "nvim-mini/mini.pairs",
    opts = function(_, opts)
      opts = opts or {}
      opts.mappings = vim.tbl_extend("force", opts.mappings or {}, {
        ["%"] = { action = "closeopen", pair = "%%", neigh_pattern = "{" },
      })
      return opts
    end,
  },
  -- Snippet tool
  {
    "chrisgrieser/nvim-scissors",
    dependencies = "folke/snacks.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.snippetSelection = opts.snippetSelection or {}
      opts.snippetSelection.picker = "snacks"
      opts.snippetDir = vim.fn.stdpath("config") .. "/snippets"
      opts.jsonFormatter = "yq"
      opts.backdrop = opts.backdrop or {}
      opts.backdrop.enabled = false
      opts.editSnippetPopup = opts.editSnippetPopup or {}
      opts.editSnippetPopup.border = "rounded"
      return opts
    end,
    keys = {
      { "<LocalLeader>sa", "<cmd>ScissorsAddNewSnippet<cr>", mode = { "n", "x" }, desc = "Create new snippet" },
      { "<LocalLeader>se", "<cmd>ScissorsEditSnippet<cr>", mode = { "n" }, desc = "Edit snippet" },
    },
  },
}
