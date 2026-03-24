return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      interactions = {
        -- Claude Code via ACP as default main driver
        chat = {
          adapter = {
            name = "claude_code",
            model = "opus",
          },
        },
        -- Codex for more precise inline edits with less scope and context
        inline = {
          adapter = "copilot",
          model = "gpt-5.3-codex",
        },
        -- Copilot direct for one-shot commands
        cmd = {
          adapter = "copilot",
          model = "claude-sonnet-4.6",
        },
        -- Cheap background tasks via Copilot (0.33x multiplier)
        background = {
          adapter = "copilot",
          model = "gpt-5.4-mini",
        },
        -- CLI agents — launch full terminal agents from within nvim
        cli = {
          agent = "claude_code",
          agents = {
            claude_code = {
              cmd = "claude",
              args = {},
              description = "Claude Code CLI",
              provider = "terminal",
            },
            opencode = {
              cmd = "opencode",
              args = {},
              description = "OpenCode TUI",
              provider = "terminal",
            },
          },
        },
      },
      adapters = {
        -- NOTE: Copilot HTTP adapter (not the agent TUI) is default enabled and configured
        -- that's why we can reference it but it's not configured as an adapter here
        acp = {
          -- Claude Code — primary chat backend via Claude Pro sub
          claude_code = function()
            return require("codecompanion.adapters").extend("claude_code", {
              env = {
                CLAUDE_CODE_OAUTH_TOKEN = "CLAUDE_CODE_ACP_OAUTH_TOKEN",
              },
              defaults = {
                mcpServers = "inherit_from_config",
              },
            })
          end,
          -- OpenCode — alt ACP backend, uses Copilot provider
          -- switch to this in chat when you want OpenCode's tools/harness
          opencode = function()
            return require("codecompanion.adapters").extend("opencode", {})
          end,
        },
      },
      rules = {
        base_rules = {
          description = "Shared agent rules from ~/.agents/rules",
          files = {
            {
              path = "~/.agents/rules",
              files = "*.md",
            },
          },
        },
        opts = {
          chat = {
            -- Only load rules for HTTP adapters (Copilot direct) —
            -- ACP adapters (Claude Code, OpenCode) already load these
            -- through their own agent config
            ---@param chat CodeCompanion.Chat
            ---@return boolean
            condition = function(chat)
              return chat.adapter.type == "http"
            end,
          },
        },
      },
      prompt_library = {
        markdown = {
          dirs = {
            "~/.charmschool/agents/shared/prompts",
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
        mode = { "n" },
      },
      {
        "<C-'>",
        "<cmd>CodeCompanionChat Toggle<CR>",
        desc = "CodeCompanion Toggle",
        mode = { "n" },
      },
      {
        "<Leader>ac",
        "<cmd>CodeCompanionCLI<CR>",
        desc = "CodeCompanion CLI",
        mode = { "n" },
      },
      {
        "<Leader>ak",
        "<cmd>CodeCompanionActions<CR>",
        desc = "Action Palette",
        mode = { "n" },
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
          -- TODO: get this run `tmux_hint [tool]` when it launches
          backend = "tmux",
          create = "window",
          enabled = true,
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
