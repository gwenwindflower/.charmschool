-- TODO: set up projects and sessions tooling
return {
  -- Alignment tools
  {
    "nvim-mini/mini.align",
    version = "*",
    opts = {
      mappings = {
        start = "<LocalLeader>an",
        start_with_preview = "<LocalLeader>ap",
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
  -- octo.nvim - manage GitHub stuff
  -- mostly handled by Extra, but still has telescope as default
  -- we are Snacks girlies here
  {
    "pwntester/octo.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.picker = "snacks"
      return opts
    end,
  },
  -- Capture images of code
  {
    "charm-and-friends/freeze.nvim",
    event = "VeryLazy",
    opts = {
      command = "freeze",
      output = function()
        return "./" .. os.date("%Y-%m-%d") .. "_freeze.png"
      end,
      config = "user",
    },
    keys = {
      { "<LocalLeader>cp", "<cmd>Freeze<CR>", mode = { "n" }, desc = "Capture code image" },
      -- TODO: fix this keymap
      { "<LocalLeader>cp", ":Freeze<CR>", mode = { "v" }, desc = "Capture code image", silent = true },
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
  -- gitignore
  {
    "wintermute-cell/gitignore.nvim",
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
      opts.jsonFormatter = "jq"
      return opts
    end,
    -- TODO: fix colors (check for Catppuccin integration [there isn't one])
    -- TODO: add package.json
    keys = {
      { "<LocalLeader>sa", "<cmd>ScissorsAddNewSnippet<cr>", mode = { "n", "x" }, desc = "Create new snippet" },
      { "<LocalLeader>se", "<cmd>ScissorsEditSnippet<cr>", mode = { "n" }, desc = "Edit snippet" },
    },
  },
}
