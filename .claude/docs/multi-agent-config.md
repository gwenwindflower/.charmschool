# Multi-Agent Configuration

Architecture and configuration for the three coding agent tools: Claude Code (CLI), CodeCompanion (nvim), and OpenCode (TUI). All share resources via `~/.agents/` and use the same two subscriptions: Claude Pro and GitHub Copilot Pro.

## Architecture

```text
Claude Code (CLI)     <- primary agent, Claude Pro sub, full harness
    | ACP (stdio)
CodeCompanion (nvim)  <- in-editor hub, switches between ACP backends + direct Copilot
    | ACP (stdio)
OpenCode (TUI)        <- alt terminal agent, Copilot primary, also ACP backend for CC
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

- **claude_code** — Primary. Uses `CLAUDE_CODE_ACP_OAUTH_TOKEN` env var. Inherits MCP servers from CodeCompanion config (`mcpServers = "inherit_from_config"`).
- **opencode** — Alt backend. Uses OpenCode's own config for model/provider (Copilot). Switch to this in chat when you want OpenCode's tools.

### Available CLI Agents

- **claude_code** (default) — `claude` command
- **opencode** — `opencode` command

### Rules

`base_rules` group loads `~/.agents/rules/*.md` but only for HTTP adapter chats (Copilot direct). ACP adapters skip these since the underlying tools load rules through their own configs.

## OpenCode Config (`agents/opencode/opencode.jsonc`)

- **Primary model**: `github-copilot/claude-sonnet-4.6`
- **Small model**: `github-copilot/gpt-5.4-mini`
- **Provider**: Copilot only (`enabled_providers: ["github-copilot"]`)
- **Instructions**: `AGENTS.md` + `~/.agents/rules/*.md` (glob)
- **Shared resources**: `OPENCODE_CONFIG_DIR` env var set to `~/.agents` in fish config, giving OpenCode native access to `~/.agents/agents/`, `~/.agents/skills/` without symlinks
- **MCP**: TODO — Context7 and GitHub as remote HTTP endpoints when URLs are confirmed

## Shared Resource Discovery

```text
~/.agents/              <- canonical shared location (linked by agents/shared/dot.yaml)
  agents/               <- agent definitions
  skills/               <- shared skills
  rules/                <- shared rules (*.md)

Claude Code:            symlinks ~/.claude/{agents,skills,rules} -> shared dirs
                        (can't configure custom paths)

OpenCode:               OPENCODE_CONFIG_DIR=~/.agents
                        (discovers agents/, skills/ natively)
                        instructions glob for rules/*.md

CodeCompanion:          rules config with path "~/.agents/rules" + condition
                        to skip on ACP adapters (avoids double-loading)
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
