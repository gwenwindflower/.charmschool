return {
  -- Yazi integration
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>fd",
        mode = { "n" },
        "<cmd>Yazi<cr>",
        desc = "Explorer Yazi (file)",
      },
      {
        "<D-f>",
        mode = { "n" },
        "<cmd>Yazi<cr>",
        desc = "Explorer Yazi (file)",
      },
      {
        "<leader>fD",
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
      },
    },
  },
  -- Noice
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        command_palette = true,
        bottom_search = false,
        lsp_doc_border = true,
      },
    },
  },
  -- blink.cmp completion plugin
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = { border = "rounded" },
        documentation = {
          window = { border = "rounded" },
        },
      },
      signature = { window = { border = "rounded" } },
      keymap = {
        preset = "super-tab",
      },
    },
  },
  -- Snacks picker, I try as much as possible to standardize all picker/search previews
  -- as using ctrl-p and ctrl-n to scroll the preview pane up and down
  {
    "folke/snacks.nvim",
    -- TODO: I want the symbol that prepends inputs to be 
    -- and for it to be pink 🌸
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
            activeBorderColor = { fg = "rainbow1", bold = true },
            searchingActiveBorderColor = { fg = "rainbow4", bold = true },
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
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.ui = opts.ui or {}
      opts.ui.border = "rounded"
      return opts
    end,
  },
  -- Note: lazy.nvim border config is in lua/config/lazy.lua (can't be configured via plugin spec)
}
