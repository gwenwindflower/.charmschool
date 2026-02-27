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
          blink_cmp = {
            enabled = true,
            style = "bordered",
          },
          auto_integrations = true,
        },
        custom_highlights = function(colors)
          return {
            -- TODO: contribute these back to catppuccin/nvim
            -- these make blink.cmp consistent with the nvchad style of
            -- float.transparent + float.solid
            Pmenu = { bg = "NONE" },
            BlinkCmpMenuBorder = { link = "FloatBorder" },
            BlinkCmpScrollBarGutter = { bg = "NONE" },
            BlinkCmpLabel = { fg = colors.subtext0 },
            -- making the underline pop a little more while still looking natural
            TreesitterContextBottom = { underline = true, sp = colors.overlay0, cterm = { underline = true } },
          }
        end,
      })
    end,
  },
}
