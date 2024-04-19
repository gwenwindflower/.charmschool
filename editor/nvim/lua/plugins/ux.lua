return {
  -- Telescope
  {
    "nvim-telescope/telescope-media-files.nvim",
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-telescope/telescope-media-files.nvim" },
    keys = {
      -- This is used for yazi.nvim
      { "<Leader>ff", false },
    },
  },
  {
    {
      "akinsho/toggleterm.nvim",
      version = "*",
      opts = {
        float_opts = {
          border = "curved",
          width = 100,
          height = 30,
          winblend = 3,
        },
      },
    },
  },
  -- Auto Light/Dark Mode
  -- {
  --   "f-person/auto-dark-mode.nvim",
  --   opts = {
  --     update_interval = 10000,
  --     set_dark_mode = function()
  --       vim.api.nvim_set_option("background", "dark")
  --       vim.cmd("colorscheme catppuccin-frappe")
  --     end,
  --     set_light_mode = function()
  --       vim.api.nvim_set_option("background", "light")
  --       vim.cmd("colorscheme catppuccin-latte")
  --     end,
  --   },
  -- },
  -- Yazi
  {
    "DreamMaoMao/yazi.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>ff", "<cmd>Yazi<CR>", desc = "Toggle Yazi" },
    },
  },
  -- NeoTree
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
        },
      },
    },
  },
  -- Noice
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      -- This is for output from Mods
      views = {
        vsplit = {
          enter = true,
          size = "50%",
          buf_options = {
            filetype = "markdown",
          },
        },
        { view = "vsplit", filter = { event = "msg_show", kind = "", min_height = 20 } },
      },
      presets = {
        bottom_search = false,
        command_palette = true,
        inc_rename = true,
      },
    },
  },
  -- Navbuddy
  {
    "SmiteshP/nvim-navbuddy",
    dependencies = {
      "SmiteshP/nvim-navic",
      "MunifTanjim/nui.nvim",
    },
    opts = { lsp = { auto_attach = true } },
    keys = {
      { "<Leader>cd", "<cmd>Navbuddy<CR>", desc = "Open Navbuddy" },
    },
  },
  -- Edgy
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>ue",
        function()
          require("edgy").toggle()
        end,
        desc = "Edgy Toggle",
      },
    -- stylua: ignore
    { "<leader>uE", function() require("edgy").select() end, desc = "Edgy Select Window" },
    },
    opts = function()
      local opts = {
        floating = {
          {
            ft = "toggleterm",
            size = { height = 0.4 },
            filter = function(_, win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end,
          },
        },
        bottom = {
          "Trouble",
          {
            ft = "trouble",
            filter = function(_, win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end,
          },
          { ft = "qf", title = "QuickFix" },
          {
            ft = "help",
            size = { height = 20 },
            -- don't open help files in edgy that we're editing
            filter = function(buf)
              return vim.bo[buf].buftype == "help"
            end,
          },
          { title = "Spectre", ft = "spectre_panel", size = { height = 0.4 } },
          { title = "Neotest Output", ft = "neotest-output-panel", size = { height = 0.4 } },
        },
        right = {
          {
            ft = "lazyterm",
            title = "LazyTerm",
            size = { width = 0.4 },
            filter = function(buf)
              return not vim.b[buf].lazyterm_cmd
            end,
          },
        },
        keys = {
          -- increase width
          ["<c-Right>"] = function(win)
            win:resize("width", 2)
          end,
          -- decrease width
          ["<c-Left>"] = function(win)
            win:resize("width", -2)
          end,
          -- increase height
          ["<c-Up>"] = function(win)
            win:resize("height", 2)
          end,
          -- decrease height
          ["<c-Down>"] = function(win)
            win:resize("height", -2)
          end,
        },
      }
      return opts
    end,
  },
  -- Animations
  {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    opts = function()
      -- don't use animate when scrolling with the mouse
      local mouse_scrolled = false
      for _, scroll in ipairs({ "Up", "Down" }) do
        local key = "<ScrollWheel" .. scroll .. ">"
        vim.keymap.set({ "", "i" }, key, function()
          mouse_scrolled = true
          return key
        end, { expr = true })
      end

      local animate = require("mini.animate")
      return {
        open = {
          enable = false,
        },
        close = {
          enable = false,
        },
        resize = {
          enable = false,
        },
        scroll = {
          timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
          subscroll = animate.gen_subscroll.equal({
            predicate = function(total_scroll)
              if mouse_scrolled then
                mouse_scrolled = false
                return false
              end
              return total_scroll > 1
            end,
          }),
        },
      }
    end,
  },
}
