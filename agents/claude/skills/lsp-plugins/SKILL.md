---
name: lsp-plugin-creation
description: Create and manage LSP server plugins for Claude Code
---

# LSP Plugin Configuration Skill

This skill helps you create Language Server Protocol (LSP) plugins for Claude Code, allowing Claude to leverage the same language servers you use in Neovim for diagnostics, hover information, and code intelligence.

## Plugin Structure

Each LSP plugin follows this directory structure:

```
<plugin-name>/
├── plugin.json       # Plugin metadata
└── .lsp.json        # LSP server configuration
```

## Creating a New LSP Plugin

When the user asks to create an LSP plugin, follow these steps:

### 1. Determine Plugin Location

LSP plugins should be created in the `agents/claude-code/plugins/` directory within the dotfiles repository. This keeps them version-controlled and manageable alongside other dotfiles.

### 2. Create plugin.json

The `plugin.json` file in the plugin root contains plugin metadata:

```json
{
  "name": "plugin-name",
  "version": "0.1.0",
  "description": "Brief description of what this LSP provides",
  "author": {
    "name": "User's Name",
    "email": "user@email.com"
  },
  "repository": "https://github.com/upstream/language-server",
  "license": "MIT",
  "keywords": ["language-name", "lsp", "language-server"]
}
```

**Required fields:**

- `name`: Plugin identifier (kebab-case, matches directory name)
- `version`: Semantic version
- `description`: What language/functionality this provides

**Optional but recommended:**

- `author`: Plugin author information
- `repository`: Upstream language server repository
- `license`: License identifier (MIT, Apache-2.0, BSD-3-Clause, etc.)
- `keywords`: Tags for searchability

### 3. Create .lsp.json

The `.lsp.json` file maps language identifiers to LSP server configurations:

```json
{
  "language-id": {
    "command": "language-server-executable",
    "args": ["--stdio"],
    "extensionToLanguage": {
      ".ext": "language-id",
      ".ext2": "language-id"
    },
    "transport": "stdio",
    "initializationOptions": {},
    "settings": {},
    "maxRestarts": 3
  }
}
```

**Configuration fields:**

- `language-id`: The LSP language identifier (e.g., "python", "go", "typescript")

- `command`: Executable name or path
  - Use just the executable name if it's in PATH (this should be everything)
  - If for some reason you can't find it, try the full path, but alert the user if this proves necessary: `/Users/winnie/.local/share/nvim/mason/bin/<server>`

- `args`: Command-line arguments (array)
  - Most LSP servers use `["--stdio"]`
  - Some may need additional flags

- `extensionToLanguage`: Map file extensions to language IDs (object)
  - Key: file extension including the dot (e.g., ".py")
  - Value: language identifier matching the top-level key

- `transport`: Communication method (always `"stdio"` for now)

- `initializationOptions`: Server-specific initialization options (object)
  - Leave empty `{}` unless server requires specific options
  - Check server documentation for available options

- `settings`: Runtime settings for the language server (object)
  - Leave empty `{}` to use defaults
  - Can configure linting rules, formatting options, etc.

- `maxRestarts`: Maximum automatic restarts on crash (number, typically 3)

### 4. Optional: Debug Logging

For troubleshooting LSP issues, add logging configuration:

```json
{
  "language-id": {
    "command": "...",
    "args": ["..."],
    "loggingConfig": {
      "args": ["--log-level", "verbose"],
      "env": {
        "SERVER_LOG": "${CLAUDE_PLUGIN_LSP_LOG_FILE}"
      }
    }
  }
}
```

Logs are written to `~/.claude/debug/`.

## Common LSP Server Configurations

### Python (pyright)

**Mason path:** `~/.local/share/nvim/mason/bin/pyright-langserver`

```json
{
  "python": {
    "command": "pyright-langserver",
    "args": ["--stdio"],
    "extensionToLanguage": {
      ".py": "python",
      ".pyi": "python",
      ".pyw": "python"
    },
    "transport": "stdio",
    "initializationOptions": {},
    "settings": {},
    "maxRestarts": 3
  }
}
```

### Go (gopls)

**Mason path:** `~/.local/share/nvim/mason/bin/gopls`

```json
{
  "go": {
    "command": "gopls",
    "args": [],
    "extensionToLanguage": {
      ".go": "go"
    },
    "transport": "stdio",
    "initializationOptions": {},
    "settings": {},
    "maxRestarts": 3
  }
}
```

### TypeScript (typescript-language-server)

**Mason path:** `~/.local/share/nvim/mason/bin/typescript-language-server`

```json
{
  "typescript": {
    "command": "typescript-language-server",
    "args": ["--stdio"],
    "extensionToLanguage": {
      ".ts": "typescript",
      ".tsx": "typescript"
    },
    "transport": "stdio",
    "initializationOptions": {},
    "settings": {},
    "maxRestarts": 3
  },
  "javascript": {
    "command": "typescript-language-server",
    "args": ["--stdio"],
    "extensionToLanguage": {
      ".js": "javascript",
      ".jsx": "javascript",
      ".mjs": "javascript",
      ".cjs": "javascript"
    },
    "transport": "stdio",
    "initializationOptions": {},
    "settings": {},
    "maxRestarts": 3
  }
}
```

### Lua (lua-language-server)

**Mason path:** `~/.local/share/nvim/mason/bin/lua-language-server`

```json
{
  "lua": {
    "command": "lua-language-server",
    "args": [],
    "extensionToLanguage": {
      ".lua": "lua"
    },
    "transport": "stdio",
    "initializationOptions": {},
    "settings": {},
    "maxRestarts": 3
  }
}
```

### Bash (bash-language-server)

**Mason path:** `~/.local/share/nvim/mason/bin/bash-language-server`

```json
{
  "bash": {
    "command": "bash-language-server",
    "args": ["start"],
    "extensionToLanguage": {
      ".sh": "bash",
      ".bash": "bash"
    },
    "transport": "stdio",
    "initializationOptions": {},
    "settings": {},
    "maxRestarts": 3
  }
}
```

### YAML (yaml-language-server)

**Mason path:** `~/.local/share/nvim/mason/bin/yaml-language-server`

```json
{
  "yaml": {
    "command": "yaml-language-server",
    "args": ["--stdio"],
    "extensionToLanguage": {
      ".yaml": "yaml",
      ".yml": "yaml"
    },
    "transport": "stdio",
    "initializationOptions": {},
    "settings": {},
    "maxRestarts": 3
  }
}
```

### JSON (vscode-json-language-server)

**Mason path:** `~/.local/share/nvim/mason/bin/vscode-json-language-server`

```json
{
  "json": {
    "command": "vscode-json-language-server",
    "args": ["--stdio"],
    "extensionToLanguage": {
      ".json": "json",
      ".jsonc": "json"
    },
    "transport": "stdio",
    "initializationOptions": {},
    "settings": {},
    "maxRestarts": 3
  }
}
```

### Markdown (marksman)

**Mason path:** `~/.local/share/nvim/mason/bin/marksman`

```json
{
  "markdown": {
    "command": "marksman",
    "args": ["server"],
    "extensionToLanguage": {
      ".md": "markdown",
      ".markdown": "markdown"
    },
    "transport": "stdio",
    "initializationOptions": {},
    "settings": {},
    "maxRestarts": 3
  }
}
```

### Fish (fish-lsp)

**Mason path:** `~/.local/share/nvim/mason/bin/fish-lsp`

```json
{
  "fish": {
    "command": "fish-lsp",
    "args": ["start"],
    "extensionToLanguage": {
      ".fish": "fish"
    },
    "transport": "stdio",
    "initializationOptions": {},
    "settings": {},
    "maxRestarts": 3
  }
}
```

## Enabling LSP Support

After creating your plugin, you must add it to the `enabledPlugins` list in `~/.claude/settings.json`:

```json
{
  "enabledPlugins": [
    "plugin-name"
  ]
}
```

**Note:** The plugin name must match the directory name of your plugin (e.g., `pyright-lsp`, `gopls-lsp`).

## Workflow

When a user requests an LSP plugin:

1. **Identify the language server**: Check Mason installation for the appropriate server
2. **Verify Mason path**: Confirm executable exists at `~/.local/share/nvim/mason/bin/<server>`
3. **Create plugin directory**: `agents/claude-code/plugins/<plugin-name>/`
4. **Get git author info**: Run `git config user.name` and `git config user.email` for plugin metadata
5. **Write plugin.json**: Use template with user's git info and appropriate metadata
6. **Write .lsp.json**: Configure server with correct command, args, and extensions
7. **Enable the plugin**: Add plugin name to `enabledPlugins` array in `~/.claude/settings.json`
8. **Verify**: The plugin is automatically available via the symlinked `plugins/` directory
9. **Test**: Suggest user restart Claude Code and test with a file of that language

## Troubleshooting

**LSP server not found:**

- Verify executable exists: `ls ~/.local/share/nvim/mason/bin/<server>`
- Check if executable is in PATH: `which <server>`
- Try using full absolute path in `command` field

**Server not starting:**

- Enable debug logging with `loggingConfig`
- Check `~/.claude/debug/` for log files
- Verify `args` match server's expected CLI interface

**Wrong file associations:**

- Check `extensionToLanguage` mappings
- Ensure language ID matches top-level key in .lsp.json
- Some servers support multiple languages (e.g., typescript-language-server for JS and TS)

## External Resources

For needs not covered in this skill, you can check the following in order of precedence:

- [Claude Code Plugins Docs Guide](https://code.claude.com/docs/en/plugins)
- [Claude Code Plugins Docs Reference](https://code.claude.com/docs/en/plugins-reference)
- [Piebald-AI LSP Examples](https://github.com/Piebald-AI/claude-code-lsps)
