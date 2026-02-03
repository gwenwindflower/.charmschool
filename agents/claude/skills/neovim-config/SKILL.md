---
name: neovim-config
description: Configure Neovim with LazyVim framework. Use when working with Lua-based Neovim configuration for (1) Adding or configuring plugins, (2) Modifying keymaps, options, or autocmds, (3) Setting up language-specific features (LSPs, formatters, linters), (4) Troubleshooting LazyVim configuration, (5) Managing snippets or theme customization
---

# LazyVim Configuration

LazyVim provides the base configuration for Neovim on this system, which is then customized to the user's needs and preferences. This skill works from this point of view, not a vanilla Neovim setup.

## Repository Context

- **Config location:** `editor/nvim/`
- **Theme:** Catppuccin Frappe (consistent with terminal, bat, etc.)
- **Focus areas:** Data work (dbt, SQL, Python) and Markdown authoring
- **Snippets:** `editor/nvim/snippets/` (friendly-snippets format)

## Configuration Files

| File | Purpose |
| --- | --- |
| `lua/plugins/*.lua` | Plugin specifications (auto-loaded) |
| `lua/config/keymaps.lua` | Custom keybindings |
| `lua/config/options.lua` | Vim options |
| `lua/config/autocmds.lua` | Autocommands |
| `lazy-lock.json` | Plugin version lockfile |
| `lazyvim.json` | LazyVim extras configuration |

## Instructions

### Before Making Changes

1. Check LazyVim defaults at <https://www.lazyvim.org/> to avoid redundant configuration
2. Read the existing config file before editing
3. Verify the plugin is not already configured by LazyVim extras

### Plugin Configuration

Use LazyVim's plugin spec format, not raw lazy.nvim:

```lua
-- lua/plugins/example.lua
return {
  -- Extend existing plugin
  {
    "plugin/name",
    opts = {
      -- Options merge with defaults
    },
  },

  -- Override existing plugin
  {
    "plugin/name",
    opts = function(_, opts)
      -- Modify opts table directly
      opts.some_option = "value"
    end,
  },

  -- Add new plugin
  {
    "author/new-plugin",
    event = "VeryLazy",  -- Lazy-load on event
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>PluginCommand<cr>", desc = "Description" },
    },
  },

  -- Disable a plugin
  { "plugin/to-disable", enabled = false },
}
```

### Keymap Configuration

```lua
-- lua/config/keymaps.lua
local map = vim.keymap.set

-- Format: map(mode, lhs, rhs, opts)
map("n", "<leader>xx", "<cmd>SomeCommand<cr>", { desc = "Description" })
map("v", "<leader>yy", function() ... end, { desc = "Description" })

-- Delete a LazyVim keymap
vim.keymap.del("n", "<leader>existing")
```

### Options Configuration

```lua
-- lua/config/options.lua
local opt = vim.opt

opt.relativenumber = false
opt.scrolloff = 8
opt.wrap = true
```

### Autocmds Configuration

```lua
-- lua/config/autocmds.lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "python" },
  callback = function()
    vim.opt_local.tabstop = 4
  end,
})
```

## Common Tasks

### Add Language Support

1. Check if LazyVim has an "extra" for the language (lazyvim.json)
2. If yes, enable it rather than manual config
3. If no, create `lua/plugins/lang-<name>.lua`

### Add Snippets

1. Create JSON file in `editor/nvim/snippets/<filetype>/<name>.json`
2. Follow friendly-snippets format
3. Snippets auto-load for matching filetypes

### Debug Configuration Issues

1. Run `:checkhealth` in Neovim
2. Check `:Lazy` for plugin errors
3. Use `:verbose map <key>` to trace keybindings
4. Check `:messages` for startup errors

## Guidelines

- Prefer LazyVim extras over manual plugin config when available
- Use `opts` table merging instead of full override when possible
- Include `desc` for all keymaps (appears in which-key)
- Lazy-load plugins with `event`, `ft`, `cmd`, or `keys`
- Test changes by restarting Neovim or running `:Lazy sync`
- Check for macOS keybinding conflicts (Mission Control, Spotlight)
- Keep Catppuccin Frappe theme consistent across colorscheme configs

### LuaLS Configuration and Warnings

LazyVim use LazyDev to configure LuaLS (Lua Language Server) to recognize extra types and Neovim globals like `vim`. If you see "Undefined global `vim`" warnings in Neovim plugin config files, this is okay - LazyDev includes these types in the actual editor instance of the LSP server, but does not carry them over to your bash instance of LuaLS.

## External Resources

- LazyVim Docs: <https://www.lazyvim.org/>
  - For needs not covered here, refer to LazyVim documentation.
