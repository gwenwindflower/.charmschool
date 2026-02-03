# Skills Directory

User-level Claude Code skills. This directory is symlinked to `~/.claude/skills`, so any new skills added here are immediately available to Claude Code (may require a restart).

## Structure

```text
skills/
├── <skill-name>/
│   ├── SKILL.md          # Required - frontmatter + instructions
│   ├── scripts/          # Optional - executable code
│   ├── references/       # Optional - docs loaded on-demand
│   └── assets/           # Optional - templates, images
└── agent-skills/         # Meta-skill for creating/improving skills
../_deactivated_skills/   # Disabled skills (not symlinked, but relevant)
```

If you need more context for creating or editing skills, use the 'agent-skills' skill.

## skillutil Commands

The 'agent-skills' meta-skill provides a `skillutil` CLI tool for managing the user- and project-level skill libraries. You can use it for various helpful tasks without loading that full skill (you only need that deeper context when creating or editing skills):

```bash
skillutil init <name>              # Create new skill
skillutil validate <path>          # Check skill structure
skillutil refresh-docs             # Update Anthropic docs
skillutil deactivate <name>        # Disable skill (preserves in ../_deactivated_skills/)
skillutil activate <name>          # Re-enable skill
```

## Skill Loading

1. **Startup**: Name + description loaded (~100 tokens each)
2. **Triggered**: When activated, full SKILL.md content is loaded into context
3. **Modules**: The skills references, assets, and scripts also become available when invoked, allowing modular structure and skill-specific commands

## Creating New Skills

Use the `agent-skills` skill or just run `skillutil init <name>` directly.
