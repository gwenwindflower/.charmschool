---
name: neovim-plugin-dev
description: Write Neovim plugins in Lua. Use for vim.api, custom plugin logic, buffer/window management, event system. Triggers: neovim plugin, lua plugin, vim.api, nvim lua.
---

# Neovim Plugin Development

Write Neovim plugins from scratch in Lua, working with Neovim's internal APIs at a low level.

## When to Use This Skill

- Writing custom Neovim plugin logic (not just configuration)
- Working with vim.api, vim.fn, vim.opt directly
- Understanding how existing plugins work internally
- Creating buffer manipulation, window management, or custom UI
- Implementing autocommands, user commands, or highlight groups
- Debugging Lua code running inside Neovim

## Core APIs

### vim.api (Neovim API)

Primary interface for Neovim internals:

```lua
-- Buffers
vim.api.nvim_get_current_buf()
vim.api.nvim_buf_get_lines(buf, start, end_, strict)
vim.api.nvim_buf_set_lines(buf, start, end_, strict, lines)
vim.api.nvim_buf_get_name(buf)
vim.api.nvim_buf_set_option(buf, name, value)  -- deprecated, use vim.bo
vim.api.nvim_buf_get_mark(buf, name)

-- Windows
vim.api.nvim_get_current_win()
vim.api.nvim_win_get_buf(win)
vim.api.nvim_win_set_cursor(win, {row, col})
vim.api.nvim_win_get_cursor(win)  -- returns {row, col}, 1-indexed row
vim.api.nvim_open_win(buf, enter, config)  -- floating windows

-- Commands and keymaps
vim.api.nvim_create_user_command(name, command, opts)
vim.api.nvim_create_autocmd(event, opts)
vim.api.nvim_set_keymap(mode, lhs, rhs, opts)

-- Namespaces (for highlights, extmarks)
vim.api.nvim_create_namespace(name)
vim.api.nvim_buf_add_highlight(buf, ns, hl_group, line, col_start, col_end)
vim.api.nvim_buf_set_extmark(buf, ns, line, col, opts)
```

### vim.fn (Vimscript Functions)

Access Vimscript functions from Lua:

```lua
vim.fn.expand("%:p")           -- full path of current file
vim.fn.fnamemodify(path, ":t") -- filename only
vim.fn.filereadable(path)      -- returns 1 or 0
vim.fn.glob(pattern)           -- file globbing
vim.fn.system(cmd)             -- run shell command
vim.fn.json_decode(str)
vim.fn.json_encode(table)
vim.fn.input("Prompt: ")       -- user input
vim.fn.confirm("Question?", "&Yes\n&No")
```

### vim.opt / vim.o / vim.bo / vim.wo

```lua
-- Global options
vim.opt.number = true
vim.o.number = true  -- direct access

-- Buffer-local options
vim.bo.filetype = "lua"
vim.bo[bufnr].modifiable = false

-- Window-local options
vim.wo.wrap = false
vim.wo[winnr].signcolumn = "yes"

-- Option with list/map operations
vim.opt.wildignore:append({ "*.o", "*.a" })
vim.opt.listchars = { tab = ">> ", trail = "-" }
```

### vim.keymap

```lua
vim.keymap.set("n", "<leader>x", function()
  -- inline function
end, { desc = "Description", buffer = bufnr, silent = true })

vim.keymap.del("n", "<leader>x")
```

## Plugin Structure

### Minimal Plugin

```lua
-- lua/my-plugin/init.lua
local M = {}

M.setup = function(opts)
  opts = opts or {}
  -- Initialize plugin with user options
end

return M
```

### Full Plugin Structure

```
my-plugin.nvim/
├── lua/
│   └── my-plugin/
│       ├── init.lua      -- Main entry, exports M.setup()
│       ├── config.lua    -- Default config, merged with user opts
│       ├── commands.lua  -- User commands
│       └── util.lua      -- Helper functions
├── plugin/
│   └── my-plugin.lua     -- Auto-loaded, can call setup if no config needed
└── doc/
    └── my-plugin.txt     -- Help documentation
```

### Config Pattern

```lua
-- lua/my-plugin/config.lua
local M = {}

M.defaults = {
  option1 = true,
  option2 = "default",
}

M.options = {}

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
```

## Common Patterns

### Autocommands

```lua
local group = vim.api.nvim_create_augroup("MyPlugin", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*.lua",
  callback = function(args)
    -- args.buf, args.file, args.match available
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "MyPluginEvent",
  callback = function() ... end,
})

-- Trigger custom event
vim.api.nvim_exec_autocmds("User", { pattern = "MyPluginEvent" })
```

### User Commands

```lua
vim.api.nvim_create_user_command("MyCommand", function(opts)
  -- opts.args, opts.fargs, opts.bang, opts.line1, opts.line2, opts.range
  print(opts.args)
end, {
  nargs = "*",      -- 0, 1, *, ?, +
  bang = true,
  range = true,
  complete = function(arglead, cmdline, cursorpos)
    return { "option1", "option2" }
  end,
})
```

### Floating Windows

```lua
local buf = vim.api.nvim_create_buf(false, true)  -- nofile, scratch
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Line 1", "Line 2" })

local win = vim.api.nvim_open_win(buf, true, {
  relative = "editor",
  width = 40,
  height = 10,
  row = 5,
  col = 10,
  style = "minimal",
  border = "rounded",
})

-- Close with q
vim.keymap.set("n", "q", function()
  vim.api.nvim_win_close(win, true)
end, { buffer = buf })
```

### Extmarks and Virtual Text

```lua
local ns = vim.api.nvim_create_namespace("my-plugin")

-- Virtual text at end of line
vim.api.nvim_buf_set_extmark(buf, ns, line, 0, {
  virt_text = { { "virtual text", "Comment" } },
  virt_text_pos = "eol",
})

-- Clear namespace
vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
```

### Async with vim.schedule

```lua
-- Defer to main loop (required when calling from callbacks)
vim.schedule(function()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end)

-- Debounce pattern
local timer = vim.loop.new_timer()
local function debounce(fn, ms)
  return function(...)
    local args = { ... }
    timer:stop()
    timer:start(ms, 0, vim.schedule_wrap(function()
      fn(unpack(args))
    end))
  end
end
```

## Debugging

```lua
-- Print inspection
print(vim.inspect(table))
vim.print(table)  -- shorthand

-- Notifications
vim.notify("Message", vim.log.levels.INFO)
vim.notify("Error!", vim.log.levels.ERROR)

-- Check value
assert(condition, "Error message")

-- Debug print to file
local f = io.open("/tmp/nvim-debug.log", "a")
f:write(vim.inspect(data) .. "\n")
f:close()
```

## Guidelines

- Use `vim.schedule` when modifying buffers from async callbacks
- Clear autocommand groups before recreating to avoid duplicates
- Use namespaces for highlights/extmarks to enable clean removal
- Prefer `vim.keymap.set` over `vim.api.nvim_set_keymap`
- Use `vim.tbl_deep_extend` for merging config tables
- Check `vim.fn.has("nvim-0.10")` for version-specific features
- Test with `:luafile %` or `:source %` during development
- Use `:messages` and `:checkhealth` for debugging
