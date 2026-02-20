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

If you need more context for creating or editing a more complex Skill -- for instance, if the Skill requires extensive references, is covering an unfamiliar tool, or integrated commands (bash scripts, CLI calls) -- you can use the `develop-agent-skills` skill for more detailed context. Otherwise, just focus on creating a concise SKILL.md outlining how to do the most common aspects of the task. Focus on unique information that future agents wouldn't already know from their base training, and avoid restating general best practices or safety guidelines that would be redundant with the agent’s existing knowledge.

## skillutil Commands

The `develop-agent-skills` meta-Skill provides a `skillutil` CLI tool for managing the user- and project-level Skill libraries. You can use it for various helpful tasks even if you don't need to load that full Skill, just call it directly with your bash tool:

```bash
skillutil init <name>              # Create new skill
skillutil validate <path>          # Check skill structure
skillutil refresh-docs             # Update Anthropic docs
skillutil deactivate <name>        # Disable skill (preserves in ../_deactivated_skills/)
skillutil activate <name>          # Re-enable skill
```

## Skill Loading

1. **Startup**: Name + description loaded (aim for <100 tokens each)
2. **Triggered**: When activated, full SKILL.md content is loaded into context, keep this file tight, and use markdown links to references/assets/scripts for deeper dives
3. **Modules**: The Skill's references, assets, and scripts can be loaded on demand, only as needed, so they protect valuable context window space -- by keeping the main SKILL.md concise and information-dense, and using many small modular references/assets/scripts (if necessary), you follow the correct progressive disclosure pattern, giving agents the option to load only what is necessary

## Creating New Skills

Run `skillutil init <name>` -- if starting a more complex Skill, you can load the full `develop-agent-skills` Skill.
