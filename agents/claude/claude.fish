# Fish completion for Claude Code CLI
# https://github.com/anthropics/claude-code

# Helper function to check if a subcommand has been used
function __fish_claude_using_subcommand
    set -l cmd (commandline -opc)
    set -e cmd[1]
    for i in $cmd
        switch $i
            case '-*'
                continue
            case '*'
                return 1
        end
    end
    return 0
end

# Helper function to check if we're in a specific subcommand context
function __fish_claude_in_subcommand
    set -l tokens (commandline -opc)
    for token in $tokens[2..-1]
        if contains -- $token $argv
            return 0
        end
    end
    return 1
end

# Main command completions
complete -c claude -f

# Global options (available for main command)
complete -c claude -n __fish_claude_using_subcommand -l add-dir -d "Additional directories to allow tool access to" -r
complete -c claude -n __fish_claude_using_subcommand -l agent -d "Agent for the current session" -r
complete -c claude -n __fish_claude_using_subcommand -l agents -d "JSON object defining custom agents" -r
complete -c claude -n __fish_claude_using_subcommand -l allow-dangerously-skip-permissions -d "Enable bypassing permission checks as an option"
complete -c claude -n __fish_claude_using_subcommand -l allowedTools -l allowed-tools -d "List of tool names to allow" -r
complete -c claude -n __fish_claude_using_subcommand -l append-system-prompt -d "Append a system prompt" -r
complete -c claude -n __fish_claude_using_subcommand -l betas -d "Beta headers for API requests" -r
complete -c claude -n __fish_claude_using_subcommand -l chrome -d "Enable Claude in Chrome integration"
complete -c claude -n __fish_claude_using_subcommand -l no-chrome -d "Disable Claude in Chrome integration"
complete -c claude -n __fish_claude_using_subcommand -s c -l continue -d "Continue most recent conversation in current directory"
complete -c claude -n __fish_claude_using_subcommand -l dangerously-skip-permissions -d "Bypass all permission checks"
complete -c claude -n __fish_claude_using_subcommand -s d -l debug -d "Enable debug mode with optional category filtering" -r
complete -c claude -n __fish_claude_using_subcommand -l disable-slash-commands -d "Disable all slash commands"
complete -c claude -n __fish_claude_using_subcommand -l disallowedTools -l disallowed-tools -d "List of tool names to deny" -r
complete -c claude -n __fish_claude_using_subcommand -l fallback-model -d "Automatic fallback model when overloaded" -r -a "sonnet opus haiku"
complete -c claude -n __fish_claude_using_subcommand -l fork-session -d "Create new session ID when resuming"
complete -c claude -n __fish_claude_using_subcommand -s h -l help -d "Display help for command"
complete -c claude -n __fish_claude_using_subcommand -l ide -d "Auto-connect to IDE on startup"
complete -c claude -n __fish_claude_using_subcommand -l include-partial-messages -d "Include partial message chunks"
complete -c claude -n __fish_claude_using_subcommand -l input-format -d "Input format for --print mode" -r -a "text stream-json"
complete -c claude -n __fish_claude_using_subcommand -l json-schema -d "JSON Schema for structured output validation" -r
complete -c claude -n __fish_claude_using_subcommand -l max-budget-usd -d "Maximum dollar amount to spend" -r
complete -c claude -n __fish_claude_using_subcommand -l mcp-config -d "Load MCP servers from JSON files" -r -F
complete -c claude -n __fish_claude_using_subcommand -l mcp-debug -d "Enable MCP debug mode (deprecated)"
complete -c claude -n __fish_claude_using_subcommand -l model -d "Model for current session" -r -a "sonnet opus haiku claude-sonnet-4-5-20250929"
complete -c claude -n __fish_claude_using_subcommand -l no-session-persistence -d "Disable session persistence"
complete -c claude -n __fish_claude_using_subcommand -l output-format -d "Output format for --print mode" -r -a "text json stream-json"
complete -c claude -n __fish_claude_using_subcommand -l permission-mode -d "Permission mode for session" -r -a "acceptEdits bypassPermissions default delegate dontAsk plan"
complete -c claude -n __fish_claude_using_subcommand -l plugin-dir -d "Load plugins from directories" -r -F -a "(__fish_complete_directories)"
complete -c claude -n __fish_claude_using_subcommand -s p -l print -d "Print response and exit"
complete -c claude -n __fish_claude_using_subcommand -l replay-user-messages -d "Re-emit user messages from stdin"
complete -c claude -n __fish_claude_using_subcommand -s r -l resume -d "Resume conversation by session ID" -r
complete -c claude -n __fish_claude_using_subcommand -l session-id -d "Use specific session ID" -r
complete -c claude -n __fish_claude_using_subcommand -l setting-sources -d "Setting sources to load" -r -a "user project local"
complete -c claude -n __fish_claude_using_subcommand -l settings -d "Path to settings JSON or JSON string" -r -F
complete -c claude -n __fish_claude_using_subcommand -l strict-mcp-config -d "Only use MCP servers from --mcp-config"
complete -c claude -n __fish_claude_using_subcommand -l system-prompt -d "System prompt for session" -r
complete -c claude -n __fish_claude_using_subcommand -l tools -d "List of available tools" -r
complete -c claude -n __fish_claude_using_subcommand -l verbose -d "Override verbose mode setting"
complete -c claude -n __fish_claude_using_subcommand -s v -l version -d "Output version number"

# Subcommands
complete -c claude -n __fish_claude_using_subcommand -a doctor -d "Check health of Claude Code auto-updater"
complete -c claude -n __fish_claude_using_subcommand -a install -d "Install Claude Code native build"
complete -c claude -n __fish_claude_using_subcommand -a mcp -d "Configure and manage MCP servers"
complete -c claude -n __fish_claude_using_subcommand -a plugin -d "Manage Claude Code plugins"
complete -c claude -n __fish_claude_using_subcommand -a setup-token -d "Set up long-lived authentication token"
complete -c claude -n __fish_claude_using_subcommand -a update -d "Check for updates and install if available"

# doctor subcommand
complete -c claude -n "__fish_seen_subcommand_from doctor" -s h -l help -d "Display help for command"

# install subcommand
complete -c claude -n "__fish_seen_subcommand_from install" -l force -d "Force installation even if already installed"
complete -c claude -n "__fish_seen_subcommand_from install" -s h -l help -d "Display help for command"
complete -c claude -n "__fish_seen_subcommand_from install" -a "stable latest" -d "Installation target"

# setup-token subcommand
complete -c claude -n "__fish_seen_subcommand_from setup-token" -s h -l help -d "Display help for command"

# update subcommand
complete -c claude -n "__fish_seen_subcommand_from update" -s h -l help -d "Display help for command"

# mcp subcommand
complete -c claude -n "__fish_seen_subcommand_from mcp; and not __fish_seen_subcommand_from add add-from-claude-desktop add-json get list remove reset-project-choices serve help" -s h -l help -d "Display help for command"
complete -c claude -n "__fish_seen_subcommand_from mcp; and not __fish_seen_subcommand_from add add-from-claude-desktop add-json get list remove reset-project-choices serve help" -a add -d "Add an MCP server"
complete -c claude -n "__fish_seen_subcommand_from mcp; and not __fish_seen_subcommand_from add add-from-claude-desktop add-json get list remove reset-project-choices serve help" -a add-from-claude-desktop -d "Import MCP servers from Claude Desktop"
complete -c claude -n "__fish_seen_subcommand_from mcp; and not __fish_seen_subcommand_from add add-from-claude-desktop add-json get list remove reset-project-choices serve help" -a add-json -d "Add MCP server with JSON string"
complete -c claude -n "__fish_seen_subcommand_from mcp; and not __fish_seen_subcommand_from add add-from-claude-desktop add-json get list remove reset-project-choices serve help" -a get -d "Get details about an MCP server"
complete -c claude -n "__fish_seen_subcommand_from mcp; and not __fish_seen_subcommand_from add add-from-claude-desktop add-json get list remove reset-project-choices serve help" -a list -d "List configured MCP servers"
complete -c claude -n "__fish_seen_subcommand_from mcp; and not __fish_seen_subcommand_from add add-from-claude-desktop add-json get list remove reset-project-choices serve help" -a remove -d "Remove an MCP server"
complete -c claude -n "__fish_seen_subcommand_from mcp; and not __fish_seen_subcommand_from add add-from-claude-desktop add-json get list remove reset-project-choices serve help" -a reset-project-choices -d "Reset approved/rejected project-scoped servers"
complete -c claude -n "__fish_seen_subcommand_from mcp; and not __fish_seen_subcommand_from add add-from-claude-desktop add-json get list remove reset-project-choices serve help" -a serve -d "Start Claude Code MCP server"
complete -c claude -n "__fish_seen_subcommand_from mcp; and not __fish_seen_subcommand_from add add-from-claude-desktop add-json get list remove reset-project-choices serve help" -a help -d "Display help for command"

# mcp add subcommand
complete -c claude -n "__fish_seen_subcommand_from mcp; and __fish_seen_subcommand_from add" -s e -l env -d "Set environment variables" -r
complete -c claude -n "__fish_seen_subcommand_from mcp; and __fish_seen_subcommand_from add" -s H -l header -d "Set WebSocket headers" -r
complete -c claude -n "__fish_seen_subcommand_from mcp; and __fish_seen_subcommand_from add" -s h -l help -d "Display help for command"
complete -c claude -n "__fish_seen_subcommand_from mcp; and __fish_seen_subcommand_from add" -s s -l scope -d "Configuration scope" -r -a "local user project"
complete -c claude -n "__fish_seen_subcommand_from mcp; and __fish_seen_subcommand_from add" -s t -l transport -d "Transport type" -r -a "stdio sse http"

# mcp serve subcommand
complete -c claude -n "__fish_seen_subcommand_from mcp; and __fish_seen_subcommand_from serve" -s d -l debug -d "Enable debug mode"
complete -c claude -n "__fish_seen_subcommand_from mcp; and __fish_seen_subcommand_from serve" -s h -l help -d "Display help for command"
complete -c claude -n "__fish_seen_subcommand_from mcp; and __fish_seen_subcommand_from serve" -l verbose -d "Override verbose mode setting"

# plugin subcommand
complete -c claude -n "__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from disable enable install i marketplace uninstall remove update validate help" -s h -l help -d "Display help for command"
complete -c claude -n "__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from disable enable install i marketplace uninstall remove update validate help" -a disable -d "Disable an enabled plugin"
complete -c claude -n "__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from disable enable install i marketplace uninstall remove update validate help" -a enable -d "Enable a disabled plugin"
complete -c claude -n "__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from disable enable install i marketplace uninstall remove update validate help" -a install -d "Install a plugin"
complete -c claude -n "__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from disable enable install i marketplace uninstall remove update validate help" -a i -d "Install a plugin (alias)"
complete -c claude -n "__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from disable enable install i marketplace uninstall remove update validate help" -a marketplace -d "Manage Claude Code marketplaces"
complete -c claude -n "__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from disable enable install i marketplace uninstall remove update validate help" -a uninstall -d "Uninstall an installed plugin"
complete -c claude -n "__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from disable enable install i marketplace uninstall remove update validate help" -a remove -d "Uninstall an installed plugin (alias)"
complete -c claude -n "__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from disable enable install i marketplace uninstall remove update validate help" -a update -d "Update a plugin to latest version"
complete -c claude -n "__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from disable enable install i marketplace uninstall remove update validate help" -a validate -d "Validate plugin or marketplace manifest"
complete -c claude -n "__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from disable enable install i marketplace uninstall remove update validate help" -a help -d "Display help for command"

# plugin marketplace subcommand
complete -c claude -n "__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and not __fish_seen_subcommand_from add list remove rm update help" -s h -l help -d "Display help for command"
complete -c claude -n "__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and not __fish_seen_subcommand_from add list remove rm update help" -a add -d "Add a marketplace from URL, path, or GitHub repo"
complete -c claude -n "__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and not __fish_seen_subcommand_from add list remove rm update help" -a list -d "List all configured marketplaces"
complete -c claude -n "__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and not __fish_seen_subcommand_from add list remove rm update help" -a remove -d "Remove a configured marketplace"
complete -c claude -n "__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and not __fish_seen_subcommand_from add list remove rm update help" -a rm -d "Remove a configured marketplace (alias)"
complete -c claude -n "__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and not __fish_seen_subcommand_from add list remove rm update help" -a update -d "Update marketplace(s) from source"
complete -c claude -n "__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and not __fish_seen_subcommand_from add list remove rm update help" -a help -d "Display help for command"
