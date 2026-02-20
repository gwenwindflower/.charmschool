# skillutil Lightweight CLI Utility for Agent Skills

CLI tools for managing Agent Skills, at present specifically configured for Claude Code.

## Quick Start

### Development Workflow

Run commands directly without installing (from `~/.charmschool/agents/claude` directory):

```bash
# Run any command based on current source code
# via script wrapper
deno task skillutil <command> [args]

# Examples
deno task skillutil init my-skill
deno task skillutil validate ~/.claude/skills/my-skill
deno task skillutil --help

# Type check the code
deno task skillutil:check

# Run test suite (test-skillutil.ts)
deno task skillutil:test
```

### Production Usage

(Re-)install as a global binary once you've tested and are ready to deploy:

```bash
# Install globally
deno task skillutil:install

# Now use anywhere
skillutil init my-skill
skillutil validate my-skill
```

## Available Commands

| Command | Description |
| --- | --- |
| `init <skill-name>` | Initialize new skill from template |
| `validate <skill-path>` | Validate skill structure and frontmatter |
| `refresh-docs` | Fetch latest Anthropic skill documentation |
| `activate <skill-name>` | Move skill from deactivated to active |
| `deactivate <skill-name>` | Move skill from active to deactivated |

## Command Details

### init

Create a new skill with proper structure:

```bash
# Create in default location (~/.claude/skills)
deno task skillutil init my-awesome-skill

# Create in custom location
deno task skillutil init my-skill --path ~/projects/skills

# Generated structure:
# my-skill/
# ├── SKILL.md              # Frontmatter + instructions
# ├── scripts/              # Executable code
# │   └── example.ts
# ├── references/           # Documentation to load
# │   └── api_reference.md
# └── assets/               # Templates/files to use
#     └── example_asset.txt
```

**Validation rules**:

- Lowercase letters, digits, and hyphens only
- Cannot start/end with hyphen
- No consecutive hyphens
- Max 64 characters

### validate

Check skill structure and SKILL.md frontmatter:

```bash
deno task skillutil validate ~/.claude/skills/my-skill
```

Validates:

- SKILL.md exists and has proper frontmatter
- Required fields: `name`, `description`
- Name follows naming rules
- No unexpected frontmatter keys
- Description under 1024 chars, no angle brackets

### refresh-docs

Fetch latest Anthropic documentation about agent skills:

```bash
deno task skillutil refresh-docs
```

Downloads to: `~/.claude/skills/agent-skills/references/anthropic-docs/`

### activate / deactivate

Temporarily disable/enable skills:

```bash
# Disable a skill (moves to _deactivated_skills)
deno task skillutil deactivate old-skill

# Re-enable it later
deno task skillutil activate old-skill
```

**Paths**:

- Active: `~/.charmschool/agents/claude/skills/`, symlinked to `~/.claude/skills/`
- Deactivated: `~/.charmschool/agents/claude/_deactivated_skills/`

## Testing

Run the comprehensive test suite:

```bash
deno task skillutil:test
```

Tests include:

- Help/version commands
- Skill creation with all files
- Validation rules (name format, required fields, unexpected keys)
- Template interpolation
- Error handling
- File permissions

All tests run in isolated temporary directories.

## Development Tips

1. **Make changes**: Edit `skillutil.ts`
2. **Type check**: `deno task skillutil:check`
3. **Test**: `deno task skillutil:test`
4. **Try it**: `deno task skillutil <command>`
5. **Deploy**: `deno task skillutil:install` (updates global binary)

No need to reinstall the binary during development - just use the task commands!

## Architecture

Built with:

- **Deno** - Secure by default, TypeScript native
- **Deno Standard Library** - File ops, path handling, YAML parsing
- **Cliffy** - The most popular Deno CLI framework with great help text and validation

Key features:

- Declarative command structure
- Comprehensive validation
- Helpful error messages
- Dry-run friendly
- Permission-scoped (no unnecessary access)
