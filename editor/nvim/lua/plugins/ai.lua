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
          security = "Audit {file} for security issues including: input validation gaps, injection vulnerabilities (SQL, XSS, command), authentication/authorization flaws, unsafe data handling, and cryptographic weaknesses. Provide specific line numbers and remediation steps for each issue found.",
          functional = "Refactor {buffers} toward functional programming principles: eliminate mutable state, extract pure functions, use immutable data structures, replace loops with map/filter/reduce, and minimize side effects. Preserve existing behavior while improving composability and testability.",
          class_design = "Analyze {class} design quality and suggest improvements: better names that reveal intent, cohesive responsibility alignment, appropriate encapsulation, clearer type signatures, removal of code smells (long methods, feature envy, data clumps), and adherence to SOLID principles where applicable.",
          clarify = "Review {file} for clarity and maintainability. Simplify complex logic, improve naming to be self-documenting, reduce cognitive load (nested conditionals, long functions), add strategic comments only where logic isn't self-evident, and restructure for better readability. Suggest specific refactorings with before/after examples.",
          teach = "Explain {selection} for someone new to this language. Break down: syntax and language-specific idioms, standard library APIs being used, design patterns or conventions, potential gotchas or common mistakes, and why this approach was chosen over alternatives. Use clear examples and relate to concepts from other languages where helpful.",
        },
      }
      return opts
    end,
  },
}
