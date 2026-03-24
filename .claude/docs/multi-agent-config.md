# CodeCompanion + Claude Code + OpenCode Multi-Agent Setup

Architecture and configuration for the three coding agent tools: Claude Code (TUI), CodeCompanion (nvim), and OpenCode (TUI). All share resources via `~/.agents/` and use the same two subscriptions: Claude Pro and GitHub Copilot Pro.

## Architecture

```text
Claude Code (TUI)     <- primary agent, Claude Pro sub, full harness
    | ACP (stdio)
CodeCompanion (nvim)  <- in-editor hub, switches between ACP backends + direct Copilot
    | ACP (stdio)
OpenCode (TUI)        <- alt terminal agent, Copilot primary, also ACP backend for CodeCompanion
```

## Provider Strategy

| Subscription | Where Used | How |
| --- | --- | --- |
| Claude Pro | Claude Code (native), CodeCompanion chat (via ACP) | OAuth token (`CLAUDE_CODE_ACP_OAUTH_TOKEN`) |
| Copilot Pro | OpenCode (primary), CodeCompanion inline/cmd/background | Direct HTTP adapter or `github-copilot/` provider prefix |

No direct Anthropic API adapter is configured. The Claude Code harness adds enough value that raw API access isn't worth the complexity. Raycast with Advanced AI handles ad-hoc chat needs.

## CodeCompanion Adapter Layout (`editor/nvim/lua/plugins/ai.lua`)

### Interactions (default adapters per task type)

| Interaction | Adapter | Model | Rationale |
| --- | --- | --- | --- |
| chat | `claude_code` (ACP) | opus | Full agent harness, Claude Pro |
| inline | `copilot` (HTTP) | gpt-5.3-codex | Native CodeCompanion diff/edit features |
| cmd | `copilot` (HTTP) | claude-sonnet-4.6 | Fast one-shots |
| background | `copilot` (HTTP) | gpt-5.4-mini | Cheap (0.33x Copilot multiplier) |
| cli | `claude_code` (default) | N/A | Terminal agents launched from nvim |

### Available ACP Adapters

- **claude_code** — Primary. Uses `CLAUDE_CODE_ACP_OAUTH_TOKEN` env var. Inherits MCP servers from CodeCompanion config (`mcpServers = "inherit_from_config"`). Runs via `@zed-industries/claude-agent-acp` package installed globally with pnpm, which makes `claude-agent-acp` command available. CodeCompanion launches this as a background process and communicates via stdio.
- **opencode** — Alt backend. Uses OpenCode's own config for model/provider (Copilot). Switch to this in chat when you want OpenCode's tools.

### Available CLI Agents

These run as their full normal terminal experiences, in an nvim terminal buffer launched by CodeCompanion. The advantage of this versus just running in a tmux window or Kitty tab is that you can easily send context back and forth and use some of the CodeCompanion features.

- **claude_code** (default) — `claude` command
- **opencode** — `opencode` command

### Rules

`base_rules` group loads `~/.agents/rules/*.md` but only for HTTP adapter chats (Copilot direct). ACP adapters skip these since the underlying tools load rules through their own configs.

## OpenCode Config (`agents/opencode/opencode.jsonc`)

- **Primary model**: `github-copilot/claude-sonnet-4.6`
- **Small model**: `github-copilot/gpt-5.4-mini`
- **Provider**: Copilot only (`enabled_providers: ["github-copilot"]`)
- **Instructions**: `AGENTS.md` + `~/.agents/rules/*.md` (glob)
- **Shared resources**: OpenCode is configured to use the `~/.agents` shared directory as an additional source of skills and instructions, **and** it by default discovers Claude Code patterns (can be disabled with env vars or config), meaning it looks for instructions and skills in locations like `~/.claude/skills` or `<project root>/.claude/CLAUDE.md`, and it reads `CLAUDE.md` files
- **MCP**: TODO — Context7 and GitHub as remote HTTP endpoints when URLs are confirmed

## Shared Resource Discovery

```text
~/.agents/              <- canonical shared location (linked by agents/shared/dot.yaml)
  agents/               <- agent definitions
  skills/               <- shared skills
  rules/                <- shared rules (*.md)

Claude Code:            symlinks ~/.claude/{agents,skills,rules} -> shared dirs
                        (can't configure custom paths)

OpenCode:               specific configs are in ~/.config/opencode/opencode.jsonc
                        also configured with ~/.agents/ as additional resource dir
                        and natively discovers Claude Code patterns
                        so no need for any symlinking beyond the config file

CodeCompanion:          rules config with path "~/.agents/rules" + condition
                        to skip on ACP adapters (avoids double-loading as agents load the rules already)
```

## MCP Policy

Only HTTP remote MCPs. No npx/uvx-style local servers — they're slow and heavy. Currently used MCPs: Context7 and GitHub. These are configured per-tool:

- **Claude Code**: via official plugins (`context7-plugin@context7-marketplace`, `github@claude-plugins-official`)
- **OpenCode**: TODO, remote HTTP config in `opencode.jsonc` when endpoints are available
- **CodeCompanion**: ACP adapters inherit from their backing tool's config

## Key Files

| File | What it configures |
| --- | --- |
| `editor/nvim/lua/plugins/ai.lua` | CodeCompanion + Sidekick plugin specs |
| `agents/opencode/opencode.jsonc` | OpenCode config (linked to `~/.config/opencode/`) |
| `agents/opencode/dot.yaml` | OpenCode install + link |
| `agents/claude/settings.json` | Claude Code settings (permissions, plugins, MCPs) |
| `agents/claude/dot.yaml` | Claude Code install + links (including shared symlinks) |
| `agents/shared/dot.yaml` | Links shared resources to `~/.agents/` |
