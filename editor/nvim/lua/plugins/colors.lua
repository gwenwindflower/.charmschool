return {
  -- colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-frappe",
    },
  },
  {
    "catppuccin/nvim",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts or {}, {
        transparent_background = true,
        float = {
          transparent = true,
          solid = true,
        },
        integrations = {
          snacks = {
            enabled = true,
            indent_scope_color = "pink",
          },
          markview = true,
          blink_cmp = {
            enabled = true,
            style = "bordered",
          },
        },
        custom_highlights = function(colors)
          return {
            -- softens the red hl for selected search match
            CurSearch = { fg = colors.mantle, bg = colors.maroon },
            -- blink.cmp integration is (i think) still a WIP,
            -- this is just to temporarily make it consistent with other float windows like Snacks Picker
            Pmenu = { bg = "NONE" },
            BlinkCmpMenuBorder = { link = "FloatBorder" },
            BlinkCmpDocBorder = { link = "FloatBorder" },
            BlinkCmpScrollBarGutter = { bg = "NONE" },
            BlinkCmpLabel = { fg = colors.subtext0 },
            -- making the underline pop a little more while still looking natural
            TreesitterContextBottom = { underline = true, sp = colors.surface2, cterm = { underline = true } },
            -- darken inactive buffer 'tabs' a bit to more easily parse active buffer
            -- BufferLineBackground = {
            --   default = true,
            --   fg = colors.overlay0,
            -- },
          }
        end,
      })
    end,
  },
}
