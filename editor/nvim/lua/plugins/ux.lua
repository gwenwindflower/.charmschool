return {
  {
    -- Needed for venv-selector, otherwise we use fzf-lua as picker
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
  },
  {
    "ibhagwan/fzf-lua",
    keys = {
      -- This is used for yazi.nvim
      { "<Leader>ff", false },
    },
  },
  -- Yazi integration
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      {
        -- Open in the current working directory
        "<leader>ff",
        function()
          require("yazi").yazi({ cwd = vim.fn.getcwd() })
        end,
        desc = "Open the file manager in nvim's working directory",
      },
    },
    opts = {
      open_for_directories = true,
    },
  },
  -- Floating Terminal
  {
    {
      "akinsho/toggleterm.nvim",
      version = "*",
      opts = {
        float_opts = {
          border = "double",
          width = 100,
          height = 40,
          winblend = 20,
        },
      },
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
      presets = {
        bottom_search = false,
      },
    },
  },
  -- Edgy
  {
    "folke/edgy.nvim",
    opts = function(_, opts)
      local options = opts or {}
      options.bottom = table.remove(options.bottom, 3)
      options.right = {
        {
          ft = "lazyterm",
          title = "LazyTerm",
          size = { width = 0.5 },
          filter = function(buf)
            return not vim.b[buf].lazyterm_cmd
          end,
        },
      }
      options.animate = {
        enabled = false,
      }
      return options
    end,
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
}
