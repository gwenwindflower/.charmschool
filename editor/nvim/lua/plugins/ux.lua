return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
      {
        "<leader>fe",
        false,
      },
      {
        "<leader>fE",
        false,
      },
      {
        "<leader>e",
        function()
          Snacks.explorer({ cwd = LazyVim.root() })
        end,
        desc = "Explorer Snacks (root dir)",
      },
      {
        "<leader>E",
        function()
          Snacks.explorer()
        end,
        desc = "Explorer Snacks (cwd)",
      },
    },
  },
  -- Yazi integration
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>fe",
        mode = { "n" },
        "<cmd>Yazi<cr>",
        desc = "Explorer Yazi (file)",
      },
      {
        "<leader>fE",
        mode = { "n" },
        "<cmd>Yazi cwd<cr>",
        desc = "Explorer Yazi (cwd)",
      },
      {
        "<D-f>",
        mode = { "n" },
        "<cmd>Yazi<cr>",
        desc = "Explorer Yazi (file)",
      },
      {
        "<D-F>",
        mode = { "n" },
        "<cmd>Yazi cwd<cr>",
        desc = "Explorer Yazi (cwd)",
      },
    },
    opts = {
      integrations = {
        fzf = true,
        grep_in_directory = "snacks.picker",
        grep_in_selected_files = "snacks.picker",
        picker_add_copy_relative_path_action = "snacks.picker",
        resolve_relative_path_application = "realpath",
      },
    },
  },
  -- Noice
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        bottom_search = false,
        lsp_doc_border = true,
      },
    },
  },
  -- blink.cmp completion plugin
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts or {}, {
        completion = {
          menu = {
            border = "rounded",
            -- Disable auto-show in Markdown; completions still available via manual trigger
            auto_show = function()
              return vim.bo.filetype ~= "markdown"
            end,
          },
          documentation = {
            window = { border = "rounded" },
          },
          list = {
            selection = {
              preselect = function(ctx)
                return not require("blink.cmp").snippet_active({ direction = 1 })
              end,
            },
          },
        },
        signature = { window = { border = "rounded" } },
        keymap = {
          preset = "super-tab",
          -- I use C-space as tmux prefix
          -- so add this as an alternate option for when I'm in tmux
          ["<M-space>"] = { "show", "show_documentation", "hide_documentation" },
        },
      })
    end,
  },
  {
    "folke/flash.nvim",
    keys = {
      {
        -- I use C-space as tmux prefix
        -- so add this as an alternate option for when I'm in tmux
        "<M-space>",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter({
            actions = {
              ["<M-space>"] = "next",
              ["<BS>"] = "prev",
            },
          })
        end,
        desc = "Treesitter Incremental Selection",
      },
    },
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
  -- Snacks picker, I try as much as possible to standardize all picker/search previews
  -- as using ctrl-p and ctrl-n to scroll the preview pane up and down
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts or {}, {
        picker = {
          win = {
            input = {
              keys = {
                ["<c-p>"] = { "preview_scroll_up", mode = { "i", "n" } },
                ["<c-n>"] = { "preview_scroll_down", mode = { "i", "n" } },
              },
            },
            list = {
              keys = {
                ["<c-p>"] = { "preview_scroll_up", mode = { "i", "n" } },
                ["<c-n>"] = { "preview_scroll_down", mode = { "i", "n" } },
              },
            },
          },
          ui_select = true,
          prompt = " ",
        },
        lazygit = {
          theme = {
            activeBorderColor = { fg = "rainbow6", bold = true },
            searchingActiveBorderColor = { fg = "rainbow5", bold = true },
          },
        },
      })
    end,
  },
  -- super cool plugin for reactive highlighting, i haven't dug very deep yet,
  -- just using these presets, but they are already very cool
  {
    "rasulomaroff/reactive.nvim",
    opts = {
      load = { "catppuccin-frappe-cursor", "catppuccin-frappe-cursorline" },
    },
  },
  -- Rounding borders on key plugin windows to match the flat UI aesthetic
  -- Note: lazy.nvim border config is in lua/config/lazy.lua (can't be configured via plugin spec)
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.ui = opts.ui or {}
      opts.ui.border = "rounded"
      return opts
    end,
  },
  {
    "sphamba/smear-cursor.nvim",
    opts = {
      never_draw_over_target = true,
      hide_target_hack = true,
      stiffness = 0.5,
      trailing_stiffness = 0.4,
      damping = 0.8,
      cursor_color = "#F4B8E4",
    },
  },
}
