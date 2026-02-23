return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      interactions = {
        chat = {
          adapter = "copilot",
          model = "sonnet-4.6",
        },
        -- ACP integration works surprisingly well
        -- but I want to see the difference when
        -- the model has access to all of CodeCompanion's tools
        -- because it's hooked into nvim, the editing, diffs, etc.
        -- are more powerful, so I'm curious if that outweighs
        -- Claude Code's agent harness when it comes to pairing inside nvim
        -- as compared to purely driving from the CLI, and using nvim as a tool
        -- for reviewing and cleaning up edits after the work is done
        -- SO! using copilot for now, which is a purely http connection
        -- chat = {
        --   adapter = "claude_code",
        --   model = "opus",
        -- },
        inline = {
          adapter = "copilot",
          model = "gpt-5.1-codex-max",
        },
      },
      adapters = {
        -- TODO: add OpenRouter adapter
        --
        -- don't duplicate the base adapter: https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/adapters/http/openai_compatible.lua
        --
        -- look at:
        --    - openai-responses adapter https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/adapters/http/openai_responses.lua
        --    - copilot adapter https://github.com/olimorris/codecompanion.nvim/tree/main/lua/codecompanion/adapters/http/copilot
        -- https://codecompanion.olimorris.dev/extending/adapters
        --
        -- some notes on community implementations:
        -- https://github.com/olimorris/codecompanion.nvim/discussions/1013
        -- https://github.com/hanipcode/nvim/blob/main/lua/hanipcode/plugins/codecompanion.lua
        -- https://github.com/hanipcode/nvim/blob/main/lua/hanipcode/local/adapter.lua
        -- http = {
        --   openrouter = function()
        --     return require("codecompanion.adapters").extend("openai_compatible", {
        --       env = {
        --         url = "https://openrouter.ai/api",
        --         api_key = "OPENROUTER_API_KEY",
        --         chat_url = "/v1/chat/completions",
        --       },
        --       schema = {
        --         model = {
        --           default = "anthropic/claude-3.7-sonnet",
        --           choices = "anthropic/claude-3.7-sonnet",
        --         },
        --       },
        --     })
        --   end,
        -- },
        acp = {
          claude_code = function()
            return require("codecompanion.adapters").extend("claude_code", {
              env = {
                CLAUDE_CODE_OAUTH_TOKEN = "CLAUDE_CODE_ACP_OAUTH_TOKEN",
              },
            })
          end,
        },
      },
      prompt_library = {
        markdown = {
          dirs = {
            "~/.charmschool/agents/prompt_library",
          },
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
        "<Leader>ao",
        "<cmd>CodeCompanionChat Toggle<CR>",
        desc = "CodeCompanion Toggle",
        mode = { "n", "v" },
      },
      {
        "<C-'>",
        "<cmd>CodeCompanionChat Toggle<CR>",
        desc = "CodeCompanion Toggle",
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
          -- backend = "tmux",
          -- create = "terminal",
          enabled = false,
        },
        win = {
          keys = {
            -- Pretty much all of the default Sidekick keybinds conflict with various agents,
            -- e.g. ctrl-p for prompts is used in the ctrl-n/p based scrolling in Cluade Code,
            -- so I've remapped everything to use alt/opt/meta + a mnemonic key where possible
            prompt = { "<m-p>", "prompt", mode = "t", desc = "Insert prompt or context" },
            -- a for '@' is the mnemonic, you @ files in most agents, and usually I'm
            -- @'ing an open buffer
            buffers = { "<m-a>", "buffers", mode = "t", desc = "Pick buffers to add" },
            -- f for 'files'/'fuzzy finder'
            files = { "<m-f>", "files", mode = "t", desc = "Pick files to add" },
            -- Escape to normal mode from within Claude Code terminal,
            -- ctrl-b was default, which is send to background in Claude Code,
            -- thankfully this seems to be unused across agents, which is nice because
            -- it's a critical keybinding for this workflow
            stopinsert = { "<c-w>", "stopinsert", mode = "t", desc = "Escape to normal mode" },
          },
        },
        prompts = {
          security = "Audit {file} for security issues including: input validation gaps, injection vulnerabilities (SQL, XSS, command), authentication/authorization flaws, unsafe data handling, and cryptographic weaknesses. Provide specific line numbers and remediation steps for each issue found. Current diagnostics for the file (may be empty): {diagnostics}",
          functional = "Refactor {file} toward functional programming principles: eliminate mutable state, extract pure functions, use immutable data structures, replace loops with map/filter/reduce, and minimize side effects. Preserve existing behavior while improving composability and testability.",
          class_design = "Analyze {class} design quality and suggest improvements: better names that reveal intent, cohesive responsibility alignment, appropriate encapsulation, clearer type signatures, removal of code smells (long methods, feature envy, data clumps), and adherence to SOLID principles where applicable.",
          clarify = "Review {file} for clarity and maintainability. Simplify complex logic, improve naming to be self-documenting, reduce cognitive load (nested conditionals, long functions), add strategic comments only where logic isn't self-evident, and restructure for better readability. Suggest specific refactorings with before/after examples.",
          teach = "Explain {selection} for someone new to this language. Break down: syntax and language-specific idioms, standard library APIs being used, design patterns or conventions, potential gotchas or common mistakes, and why this approach was chosen over alternatives. Use clear examples and relate to concepts from other languages where helpful.",
        },
      }
      return opts
    end,
  },
}
