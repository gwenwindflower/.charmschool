return {
  -- {
  --   "olimorris/codecompanion.nvim",
  --   opts = {
  --     display = {
  --       action_palette = {
  --         width = 95,
  --         height = 10,
  --         provider = "snacks",
  --         opts = {
  --           show_default_actions = true,
  --           show_default_prompt_library = true,
  --         },
  --       },
  --     },
  --     extensions = {
  --       mcphub = {
  --         callback = "mcphub.extensions.codecompanion",
  --         opts = {
  --           make_vars = true,
  --           make_slash_commands = true,
  --           show_result_in_chat = true,
  --           show_server_tools_in_chat = true,
  --         },
  --       },
  --     },
  --   },
  --   keys = {
  --     {
  --       "<D-p>",
  --       "<cmd>CodeCompanionChat Toggle<CR>",
  --       desc = "CodeCompanion",
  --       mode = { "n", "v" },
  --     },
  --     {
  --       "<Leader>aa",
  --       "<cmd>CodeCompanionChat Toggle<CR>",
  --       desc = "Toggle sidebar",
  --       mode = { "n", "v" },
  --     },
  --     {
  --       "<Leader>an",
  --       "<cmd>CodeCompanionChat<CR>",
  --       desc = "New thread",
  --       mode = { "n", "v" },
  --     },
  --     {
  --       "<Leader>ap",
  --       ":CodeCompanion",
  --       desc = "New prompt",
  --       mode = { "n", "v" },
  --     },
  --     {
  --       "<D-k>",
  --       "<cmd>CodeCompanionActions<CR>",
  --       desc = "Action Palette",
  --       mode = { "n", "v" },
  --     },
  --     {
  --       "<Leader>ak",
  --       "<cmd>CodeCompanionActions<CR>",
  --       desc = "Action Palette",
  --       mode = { "n", "v" },
  --     },
  --   },
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  -- },
  {
    "folke/sidekick.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.cli = {
        mux = {
          backend = "tmux",
          -- TODO: i *think* ideally i would like the below to be 'split', but my mux config is not fleshed out enough yet,
          -- so it's easier to just stick with the default Neovim terminal for now
          -- this is the default setting but i'm leaving it here to remind myself
          create = "terminal",
          enabled = true,
        },
        win = {
          keys = {
            -- Had to change this from default <c-p> because I need ctrl-n/p for scrolling options
            -- this is a bit sketch but honestly don't use this that much it's fine
            prompt = { "<D-p>", "prompt", mode = "t", desc = "insert prompt or context" },
            -- This was <c-q> by default, felt to similar to q'ing out of LazyVim windows or ctrl-c
            stopinsert = { "<c-a>", "stopinsert", mode = "t", desc = "enter normal mode" },
          },
        },
      }
      return opts
    end,
  },
}
