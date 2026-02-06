# Claude Code LSP Plugins

This directory contains custom LSP (Language Server Protocol) plugins for Claude Code, allowing it to leverage the same language servers installed via Neovim's Mason plugin.

## Why Local Plugins?

These LSP plugins are really simple, it feels ridiculous to be adding third-party code for something so minimal. By keeping them local, we maintain full control over their configuration and ensure they align perfectly with our Neovim setup and we don't introduce unnecessary security risks, dependencies, redundant installs, etc.

_I feel like this whole config system will probably change soon to allow Claude Code to just directly detect and use LSP servers installed on the system, but until then, this is what we're doing!_

## Plugin Structure

Each plugin is a directory with two files:

```text
<plugin-name>/
├── plugin.json    # Plugin metadata
└── .lsp.json     # LSP server configuration
```

## Currently Configured Plugins

- **pyright-lsp**: Python type checking and language intelligence

## Creating New Plugins

Use the `lsp-plugin` skill in Claude Code:

```bash
# In Claude Code conversation
"Create an LSP plugin for Go using gopls"
```

The skill will guide you through creating properly configured plugins.

## How It Works

The entire `plugins/` directory is symlinked to `~/.claude/plugins/` via rotz:

```yaml
# In agents/claude-code/dot.yaml
links:
  plugins/: ~/.claude/plugins/
```

Any plugin added here is automatically available to Claude Code.

## Mason Integration

Plugins reference language servers installed via Mason for Neovim:

- Mason packages: `~/.local/share/nvim/mason/packages/<server>/`
- Mason binaries: `~/.local/share/nvim/mason/bin/<server>`

This ensures Claude Code uses the exact same LSP servers as Neovim, maintaining consistency across development tools and avoiding redundant installations.

You can use either of the following commands to list installed Mason packages:

```bash
# for a minimal option, use tree:
tree -L 1 ~/.local/share/nvim/mason/packages
# OR, for a faster, more full-featured option, use lsd's tree mode:
lsd --tree --depth 1 ~/.local/share/nvim/mason/packages
```

If you want to install a new language server, don't follow the default behavior of suggesting a Claude Code plugin. Instead, suggest the user install it via Mason in Neovim, then you can create a corresponding LSP plugin here once you've confirmed the server is installed.

## References

- Skill documentation: `../skills/lsp-plugin.md`
- Claude Code docs: <https://code.claude.com/docs/en/plugins-reference>
