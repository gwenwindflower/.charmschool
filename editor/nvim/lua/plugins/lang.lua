return {
  -- Shell
  -- LazyVim installs fish linter and formatter by default,
  -- but LSP and Treesitter grammar need to be explicitly installed
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "fish")
      return opts
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      -- in case LazyVim adds fish_lsp configs at some point, we'll defer to those
      opts.servers.fish_lsp = opts.servers.fish_lsp or {}
      return opts
    end,
  },
  -- GraphQL
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.graphql = {}
      return opts
    end,
  },
  -- TypeScript/Frontend
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      -- Deno LSP: LazyVim's TypeScript extra handles vtsls/denols disambiguation.
      -- denols will attach to files in directories containing deno.json or deno.jsonc,
      -- while vtsls handles Node/npm projects (package.json, tsconfig.json).
      -- See: lazyvim.plugins.extras.lang.typescript setup.vtsls for the logic.
      opts.servers.denols = {}
      opts.servers.emmet_language_server = {}
      return opts
    end,
  },
  -- Lua
  ---- It's helpful for plugins with lots of config to be able to
  ---- pull in their type definitions for checking with LuaLS
  ---- particularly stuff from folke and others heavily in the LazyVim ecosystem
  ---- who are very rigorous about their type annotations, which I also happen
  ---- to use and customize the most
  {
    "folke/lazydev.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.library = opts.library or {}
      table.insert(opts.library, { path = "sidekick.nvim", words = { "Sidekick" } })
      table.insert(
        opts.library,
        { path = vim.fs.normalize("~/.config/yazi/plugins/types.yazi"), words = { "ya", "Yazi" } }
      )
      return opts
    end,
  },
}

-- Handled by LazyVim defaults: most Lua stuff, *some* basic shell stuff

-- Handled by LazyVim Extras:

---- Most TypeScript / Frontend

---- NOTE: Currently running both Biome and Prettier extras until Biome
---- has full frontend filetype coverage, examine this more closely

------ Frameworks: Astro, Svelte
------ ORMs: Prisma
------ CSS: Tailwind

---- Go

---- Python
---- Confiured in options.lua to use Ruff for everything

---- Rust

---- SQL
---- TODO: Not sure aout this extra, should roll my own

---- Text: Markdown

---- Config: JSON, YAML, TOML
