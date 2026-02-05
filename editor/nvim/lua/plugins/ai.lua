return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      interactions = {
        chat = {
          adapter = "claude_code",
          model = "sonnet",
        },
      },
      adapters = {
        acp = {
          claude_code = function()
            return require("codecompanion.adapters").extend("claude_code", {
              env = {
                CLAUDE_CODE_OAUTH_TOKEN = "CLAUDE_CODE_OAUTH_TOKEN",
              },
            })
          end,
        },
      },
      display = {
        action_palette = {
          width = 95,
          height = 10,
          provider = "snacks",
          opts = {
            show_default_actions = true,
            show_default_prompt_library = true,
          },
        },
      },
    },
    keys = {
      {
        "<D-p>",
        "<cmd>CodeCompanionChat Toggle<CR>",
        desc = "CodeCompanion",
        mode = { "n", "v" },
      },
      --   {
      --     "<Leader>aa",
      --     "<cmd>CodeCompanionChat Toggle<CR>",
      --     desc = "Toggle sidebar",
      --     mode = { "n", "v" },
      --   },
      --   {
      --     "<Leader>an",
      --     "<cmd>CodeCompanionChat<CR>",
      --     desc = "New thread",
      --     mode = { "n", "v" },
      --   },
      --   {
      --     "<Leader>ap",
      --     ":CodeCompanion",
      --     desc = "New prompt",
      --     mode = { "n", "v" },
      --   },
      {
        "<D-k>",
        "<cmd>CodeCompanionActions<CR>",
        desc = "Action Palette",
        mode = { "n", "v" },
      },
      {
        "<Leader>ak",
        "<cmd>CodeCompanionActions<CR>",
        desc = "Action Palette",
        mode = { "n", "v" },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
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
            -- Had to change this from default <c-p> because I need ctrl-n/p for scrolling options,
            -- including cycling prompt history in Claude Code
            -- also the menu launcher in OpenCode
            -- OpenCode uses a primarily leader-based keymap, which defaults to <c-x>
            -- I changed that to <c-o> for a more natural reach, and o for 'open'
            -- which frees up <c-x> for the prompt menu in Sidekick, prompts operate like commands
            -- in Sidekick, so <c-x> makes sense mnemonically to me
            prompt = { "<c-x>", "prompt", mode = "t", desc = "insert prompt or context" },
            -- This was <c-q> by default, <c-e> e for exit, felt more natural, doesn't seem
            -- to be used by any of the agent CLIs so far
            stopinsert = { "<c-w>", "stopinsert", mode = "t", desc = "enter normal mode" },
          },
        },
        prompts = {
          security = "Review {file} for security vulnerabilities",
          functional = "Refactor {buffers} for a more data-oriented functional programming style with minimal side effects or state mutations",
          class_design = "Improve naming, organization, and data structures of {class} using best practices for the language",
          clarify = "Explain {file} step-by-step and suggest edits to improve clarity, simplicity, naming, and structure",
          teach = "Explain {selection} as you would to a junior developer new to the language, focus on syntax, language-specific APIs, features, and idioms",
        },
      }
      return opts
    end,
  },
}
